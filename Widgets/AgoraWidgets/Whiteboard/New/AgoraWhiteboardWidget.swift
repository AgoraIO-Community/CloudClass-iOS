//
//  AgoraWhiteboardWidget.swift
//  AgoraWidgets
//
//  Created by LYY on 2021/12/2.
//

import Masonry
import Whiteboard
import AgoraWidget
import AgoraEduContext
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

    var needInit: Bool = false {
        didSet {
            if needInit {
                initWhiteboard()
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
                content: "signal encode error!")
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
        
        AgoraLoading.loading()
        sdk.joinRoom(with: roomConfig,
                     callbacks: self) {[weak self] (success, room, error) in
            guard let `self` = self,
                  success,
                  error == nil,
                  let whiteRoom = room else {
                AgoraLoading.hide()
                self?.sendMessage(signal: .BoardPhaseChanged(.Disconnected))
                return
            }
            
            AgoraLoading.hide()
            self.room = whiteRoom

            // 初始化完成时需要向外发送当前工具状态的消息
            var colorArr = Array<Int>()
            whiteRoom.memberState.strokeColor.forEach { number in
                colorArr.append(number.intValue)
            }
            let member = AgoraBoardMemberState(activeApplianceType: whiteRoom.memberState.currentApplianceName.toWidget(),
                                                    strokeColor: colorArr,
                                                    strokeWidth: whiteRoom.memberState.strokeWidth?.intValue,
                                                    textSize: whiteRoom.memberState.textSize?.intValue)
            self.sendMessage(signal: .MemberStateChanged(member))
            whiteRoom.disableCameraTransform(true)
            
            self.initCondition.needJoin = false
            
            // 初始化完成，抛出当前状态
            self.fireRoomStateChanged(room?.state)
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
        room?.setMemberState(state.toWhiteboard())
    }
    
    func handleAudioMixing(data: AgoraBoardAudioMixingData) {
        whiteSDK?.audioMixer?.setMediaState(data.statusCode,
                                           errorCode: data.errorCode)
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

extension AgoraWhiteboardWidget: AgoraEduMediaHandler {
    public func onAudioMixingStateChanged(stateCode: Int,
                                          errorCode: Int) {
        whiteSDK?.audioMixer?.setMediaState(stateCode,
                                           errorCode: errorCode)
    }
}
