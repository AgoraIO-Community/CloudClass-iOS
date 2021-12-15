//
//  AgoraWhiteboardWidget.swift
//  AgoraWidgets
//
//  Created by LYY on 2021/12/2.
//

import Masonry
import Whiteboard
import AgoraLog
import AgoraWidget
import AgoraUIEduBaseViews

struct InitCondition {
    var configComplete = false
    var needInit = false
    var needJoin = false
}

@objcMembers public class AgoraWhiteboardWidget: AgoraBaseWidget {

    private(set) var contentView: UIView!
    
    var whiteSDK: WhiteSDK?
    var room: WhiteRoom?

    var dt: AgoraWhiteboardWidgetDT
    
    var joinedFlag: Bool = false
    
    private var logger: AgoraLogger
    
    var initCondition = InitCondition() {
        didSet {
            if initCondition.configComplete,
               initCondition.needInit,
               initCondition.needJoin {
                initWhiteboard()
                joinWhiteboard()
            }
        }
    }
    
    // MARK: - AgoraBaseWidget
    public override init(widgetInfo: AgoraWidgetInfo) {
        guard let extraDic = widgetInfo.extraInfo as? [String: Any],
              let extra = extraDic.toObj(AgoraWhiteboardExtraInfo.self) else {
            fatalError()
            return
        }
        self.dt = AgoraWhiteboardWidgetDT(extra: extra,
                                          localUserInfo: widgetInfo.localUserInfo)

        
        self.logger = AgoraLogger(folderPath: self.dt.logFolder,
                                  filePrefix: widgetInfo.widgetId,
                                  maximumNumberOfFiles: 5)
        // 在此修改日志是否打印在控制台
        self.logger.setPrintOnConsoleType(.all)
        
        super.init(widgetInfo: widgetInfo)
        self.dt.delegate = self
        
        initCondition.needInit = true

        if let wbProperties = widgetInfo.properties?.toObj(AgoraWhiteboardProperties.self) {
            dt.properties = wbProperties
        }
    }
    
    // MARK: widget callback
    public override func onLocalUserInfoUpdated(_ localUserInfo: AgoraWidgetUserInfo) {
        dt.localUserInfo = localUserInfo
    }
    
    public override func onMessageReceived(_ message: String) {
        let signal = message.toSignal()
        switch signal {
        case .JoinBoard:
            initCondition.needJoin = true
        case .MemberStateChanged(let agoraWhiteboardMemberState):
            handleMemberState(state: agoraWhiteboardMemberState)
        case .AudioMixingStateChanged(let agoraBoardAudioMixingData):
            handleAudioMixing(data: agoraBoardAudioMixingData)
        default:
            break
        }
    }
    
    public override func onPropertiesUpdated(_ properties: [String : Any],
                                             cause: [String : Any]?,
                                             keyPaths: [String]) {
        guard let wbProperties = properties.toObj(AgoraWhiteboardProperties.self) else {
            return
        }
        log(.info,
            log: "[Whiteboard widget] onPropertiesUpdated:\(properties)")
        dt.properties = wbProperties
    }
    
    public override func onPropertiesDeleted(_ properties: [String : Any]?,
                                             cause: [String : Any]?,
                                             keyPaths: [String]) {
        guard let wbProperties = properties?.toObj(AgoraWhiteboardProperties.self) else {
            return
        }
        dt.properties = wbProperties
    }
    
    func log(_ type: AgoraWhiteboardLogType,
             log: String) {
        switch type {
        case .info:
            logger.log(log,
                       type: .info)
        case .warning:
            logger.log(log,
                       type: .warning)
        case .error:
            logger.log(log,
                       type: .error)
        default:
            logger.log(log,
                       type: .info)
        }
    }
    
    deinit {
        room?.disconnect(nil)
        room = nil
        whiteSDK = nil
    }
}


// MARK: - private
extension AgoraWhiteboardWidget {
    func sendMessage(signal: AgoraBoardInteractionSignal) {
        guard let text = signal.toMessageString() else {
            log(.error,
                log: "signal encode error!")
            return
        }
        sendMessage(text)
    }
    
    func initWhiteboard() {
        guard let whiteSDKConfig = dt.getWhiteSDKConfigToInit(),
              whiteSDK == nil else {
            return
        }
        
        let wkConfig = dt.getWKConfig()
        contentView = WhiteBoardView(frame: .zero,
                                     configuration: wkConfig)
        
        contentView.isUserInteractionEnabled = true
        view.isUserInteractionEnabled = true
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        whiteSDK = WhiteSDK(whiteBoardView: contentView as! WhiteBoardView,
                            config: whiteSDKConfig,
                            commonCallbackDelegate: self,
                            audioMixerBridgeDelegate: self)
        
        // 需要先将白板视图添加到视图栈中再加入白板
        view.addSubview(contentView)
        
        contentView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(view)
        }
        WhiteDisplayerState.setCustomGlobalStateClass(AgoraWhiteboardGlobalState.self)
        
        initCondition.needInit = false
    }
    
    func joinWhiteboard() {
        guard let sdk = whiteSDK,
              let roomConfig = dt.getWhiteRoomConfigToJoin() else {
            return
        }
        
        DispatchQueue.main.async {
            AgoraLoading.loading()
        }
        log(.info,
            log: "[Whiteboard widget] start join")
        sdk.joinRoom(with: roomConfig,
                     callbacks: self) {[weak self] (success, room, error) in
            guard let `self` = self,
                  success,
                  error == nil,
                  let whiteRoom = room else {
                
                DispatchQueue.main.async {
                    AgoraLoading.hide()
                }
                
                self?.log(.error,
                          log: "[Whiteboard widget] join room error :\(error?.localizedDescription)")
                self?.dt.reconnectTime += 2
                self?.sendMessage(signal: .BoardPhaseChanged(.Disconnected))
                return
            }
            
            DispatchQueue.main.async {
                AgoraLoading.hide()
            }
            
            self.log(.info,
                      log: "[Whiteboard widget] join room success")
            

            
            self.room = whiteRoom
            self.initRoomState(state: whiteRoom.state)
            
            self.dt.reconnectTime = 0
            self.initCondition.needJoin = false
            self.joinedFlag = true
        }
    }
    
    func ifUseLocalCameraConfig() -> Bool {
        guard dt.extra.autoFit,
              dt.localGranted,
              let cameraConfig = getLocalCameraConfig(),
              let `room` = room else {
            return false
        }
        room.moveCamera(cameraConfig.toWhiteboard())
        return true
    }
    
    func getLocalCameraConfig() -> AgoraWhiteBoardCameraConfig? {
        let path = dt.scenePath.translatePath()
        return dt.localCameraConfigs[path]
    }
    
    func handleMemberState(state: AgoraBoardMemberState) {
        dt.updateMemberState(state: state)
        if let curState = dt.currentMemberState {
            room?.setMemberState(curState)
        }
    }
    
    func handleAudioMixing(data: AgoraBoardAudioMixingData) {
        whiteSDK?.audioMixer?.setMediaState(data.statusCode,
                                           errorCode: data.errorCode)
    }
    
    func initRoomState(state: WhiteRoomState) {
            guard let `room` = room else {
                return
            }
            
            if let memberState = state.memberState as? WhiteReadonlyMemberState {
                var member = memberState.toMemberState()
                // 初始化时需要修改画笔状态，重连时不需要
                if !joinedFlag {
                    member.currentApplianceName = WhiteApplianceNameKey.ApplianceSelector
                    member.strokeWidth = NSNumber(16)
                    member.strokeColor = UIColor(rgb: 0x0073FF).getRGBAArr()
                    member.textSize = NSNumber(18)
                }

                self.dt.currentMemberState = member
                room.setMemberState(member)
                // 发送初始画笔状态的消息
                var colorArr = Array<Int>()
                member.strokeColor?.forEach { number in
                    colorArr.append(number.intValue)
                }
                let widgetMember = AgoraBoardMemberState(member)
                self.sendMessage(signal: .MemberStateChanged(widgetMember))
            }
            
            // 老师离开
            if let broadcastState = state.broadcastState {
                if broadcastState.broadcasterId == nil {
                    room.scalePpt(toFit: .continuous)
                    room.scaleIframeToFit()
                }
            }
        
            if let state = state.globalState as? AgoraWhiteboardGlobalState {
                // 发送初始授权状态的消息
                dt.updateGlobalState(state: state)
            }
            
            if let sceneState = state.sceneState {
                // 1. 取真实regionDomain
                if sceneState.scenes.count > 0,
                   let ppt = sceneState.scenes[0].ppt,
                   ppt.src.hasPrefix("pptx://") {
                    let src = ppt.src
                    let index = src.index(src.startIndex, offsetBy:7)
                    let arr = String(src[index...]).split(separator: ".")
                    dt.regionDomain = (dt.regionDomain == String(arr[0])) ? dt.regionDomain : String(arr[0])
                }
                
                // 2. scenePath 判断
                let paths = sceneState.scenePath.split(separator: "/")
                if  paths.count > 0 {
                    let newScenePath = String(sceneState.scenePath.split(separator: "/")[0])
                    dt.scenePath = "/(newScenePath)"
                }
                
                // 3. ppt 获取总页数，当前第几页
                room.scaleIframeToFit()
                if sceneState.scenes[sceneState.index] != nil {
                    room.scalePpt(toFit: .continuous)
                }
                // page改变
    //            let pageCount = sceneState.scenes.count
    //            let pageIndex = sceneState.index
                ifUseLocalCameraConfig()
                
            }
            
            if let cameraState = state.cameraState,
               dt.localGranted {
                // 如果本地被授权，则是本地自己设置的摄像机视角
                dt.localCameraConfigs[room.sceneState.scenePath] = cameraState.toWidget()
            }
    }
    
//    
//    public func pushScenes(dir: String,
//                           scenes: [AgoraEduContextWhiteScene],
//                           index: UInt) {
//        let newScenes = scenes.map({ scene -> WhiteScene in
//            let src = scene.ppt.src
//            let size = CGSize(width: CGFloat(scene.ppt.width),
//                              height: CGFloat(scene.ppt.height))
//            let previewURL = scene.ppt.previewURL
//            var pptPage: WhitePptPage!
//            if let url = previewURL {
//                pptPage = WhitePptPage.init(src: src,
//                                            preview: url,
//                                            size: size)
//            }
//            else {
//                pptPage = WhitePptPage.init(src: src,
//                                            size: size)
//            }
//            return WhiteScene(name: scene.name,
//                              ppt: pptPage)
//        })
//        
//        manager?.putScenes(dir,
//                           scenes: newScenes,
//                           index: index)
//    }
//    
//    public func getCoursewares() -> [AgoraEduContextCourseware] {
//        return dt.getCoursewares()
//    }
}
