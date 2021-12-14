//
//  AgoraSpreadRenderWidget.swift
//  AgoraWidgets
//
//  Created by LYY on 2021/10/11.
//

import AgoraUIEduBaseViews
import AgoraUIBaseViews
import AgoraEduContext
import AgoraWidget

@objcMembers public class AgoraSpreadRenderWidget: AgoraBaseWidget {
    private weak var userContext: AgoraEduUserContext?
    private weak var streamContext: AgoraEduStreamContext?
    private weak var mediaContext: AgoraEduMediaContext?
    
    private lazy var spreadView = AgoraRenderSpreadView(frame: .zero)
    
    private var latestMessage: String?
    
    private var localUserInfo: AgoraEduContextUserInfo?
    private var renderUserInfo: AgoraSpreadRenderUserInfo? {
        didSet {
            guard let renderUser = renderUserInfo else {
                return
            }
            spreadView.updateRenderInfo(renderInfo: renderUser.toViewInfo())
        }
    }
    
//    public override init(widgetId: String,
//                         properties: [AnyHashable : Any]?) {
//        super.init(widgetId: widgetId,
//                   properties: properties)
//        initViews()
//        initLayout()
//        initData()
//
//        if let contextPool = properties?["contextPool"] as? AgoraEduContextPool {
//            userContext = contextPool.user
//            streamContext = contextPool.stream
//            mediaContext = contextPool.media
//            initData()
//        }
//    }
    
    public override func onMessageReceived(_ message: String) {
        guard let dic = message.json(),
              let `localUser` = localUserInfo else {
            return
        }
        
        handleRoomPropsMessage(dic: dic)
        handleVCMessage(dic: dic)
    }
}

// MARK: - AgoraRenderSpreadViewDelegate
extension AgoraSpreadRenderWidget: AgoraRenderSpreadViewDelegate {
    func onCloseSpreadView(_ view: AgoraBaseUIView) {
        guard let renderInfo = renderUserInfo,
              let localUser = localUserInfo,
              localUser.role == .teacher,
              let message = ["spreadFlag": false,
                             "operatedUuid": renderInfo.userId].jsonString() else {
            return
        }
        sendMessage(message)
        renderUserInfo = nil
    }
}

// MARK: - AgoraEduUserHandler
extension AgoraSpreadRenderWidget: AgoraEduUserHandler {
    public func onUpdateCoHostList(_ list: [AgoraEduContextUserInfo]) {
        // 下台/离开房间，大窗消失
        if let renderUser = renderUserInfo,
           list.first(where: {$0.userUuid == renderUser.userId }) == nil {
            sendDismissMessage()
        }
    }
    
    public func onUpdateUserList(_ list: [AgoraEduContextUserInfo]) {
        if let render = renderUserInfo,
           list.first(where: { $0.userUuid == render.userId}) == nil {
            sendDismissMessage()
        }
    }
    
    public func onUpdateAudioVolumeIndication(_ value: Int,
                                              streamUuid: String) {
        spreadView.updateVolume(volume: CGFloat(value))
    }
}

// MARK: - AgoraEduStreamHandler
extension AgoraSpreadRenderWidget: AgoraEduStreamHandler {
    public func onStreamJoin(stream: AgoraEduContextStreamInfo,
                             operator: AgoraEduContextUserInfo?) {
        updateRenderStreamInfo(stream: stream)
    }
    public func onStreamUpdate(stream: AgoraEduContextStreamInfo,
                               operator: AgoraEduContextUserInfo?){
        updateRenderStreamInfo(stream: stream)
    }
}

// MARK: - private
fileprivate extension AgoraSpreadRenderWidget {
    func initViews() {
        view.backgroundColor = .clear
        view.addSubview(spreadView)
        view.isHidden = true
    }
    
    func initLayout() {
        spreadView.mas_makeConstraints {[weak self] make in
            make?.top.left().bottom().right().equalTo()(self?.view)
        }
    }
    
    func initData() {
        spreadView.delegate = self
        userContext?.registerUserEventHandler(self)
        streamContext?.registerStreamEventHandler(self)
        localUserInfo = userContext?.getLocalUserInfo()
    }
    
    func handleRoomPropsMessage(dic: [String: Any]) {
        guard let `localUser` = localUserInfo,
              localUser.role != .teacher else {
            return
        }
        if let remove = dic["remove"] as? Bool,
           remove {
            sendDismissMessage()
            return
        }
        
        guard let messageModel = AgoraSpreadRoomMessageModel.decode(dic),
              let userInfo = userContext?.getAllUserList().first(where: { $0.userUuid == messageModel.extra.userId}) else {
            return
        }
        
        if messageModel.extra.initial {
            if renderUserInfo == nil {
                renderUserInfo = AgoraSpreadRenderUserInfo(userId: messageModel.extra.userId,
                                                           userName: userInfo.userName,
                                                           streamId: messageModel.extra.streamId,
                                                           role: userInfo.role.toSpread())
                // 1. 渲染弹出
                if let message = ["widgetAction": AgoraSpreadAction.start.rawValue,
                                  "spreadStreamId": messageModel.extra.streamId,
                                  "operatedUuid": messageModel.extra.userId,
                                  "xaxis": messageModel.position.xaxis,
                                  "yaxis": messageModel.position.yaxis,
                                  "width": messageModel.size.width,
                                  "height": messageModel.size.height].jsonString() {
                    latestMessage = message
                    sendMessage(message)
                }
            } else if renderUserInfo?.userId != messageModel.extra.userId ,
                      let local = localUserInfo {
                // 2. stream切换
                renderUserInfo = AgoraSpreadRenderUserInfo(userId: messageModel.extra.userId,
                                                           userName: userInfo.userName,
                                                           streamId: messageModel.extra.streamId,
                                                           role: userInfo.role.toSpread())
                if let message = ["widgetAction": AgoraSpreadAction.start.rawValue,
                                  "spreadStreamId": messageModel.extra.streamId,
                                  "operatedUuid": messageModel.extra.userId,
                                  "xaxis": messageModel.position.xaxis,
                                  "yaxis": messageModel.position.yaxis,
                                  "width": messageModel.size.width,
                                  "height": messageModel.size.height].jsonString() {
                    latestMessage = message
                }
                executeRender(startFlag: true,
                              isLocal: messageModel.extra.userId == local.userUuid,
                              streamId: messageModel.extra.streamId)
            }

        } else {
            // 3. 大窗移动
            if let message = ["widgetAction": AgoraSpreadAction.move.rawValue,
                              "spreadStreamId": messageModel.extra.streamId,
                              "operatedUuid": messageModel.extra.userId,
                              "xaxis": messageModel.position.xaxis,
                              "yaxis": messageModel.position.yaxis,
                              "width": messageModel.size.width,
                              "height": messageModel.size.height].jsonString() {
                sendMessage(message)
            }
        }
    }
    
    func handleVCMessage(dic: [String: Any]) {
        guard let messageModel = AgoraSpreadVCMessageModel.decode(dic),
              let localUser = userContext?.getLocalUserInfo(),
              let media = mediaContext else {
            return
        }
        let isLocal = (localUser.userUuid == messageModel.userId)
        
        switch messageModel.action {
        case .start: fallthrough
        case .change:
            view.isHidden = false
            view.backgroundColor = .white
            // TODO: 若为教师端发起 需要发送http请求

            if let streams = streamContext?.getStreamList(userUuid: messageModel.userId) {
                for stream in streams {
                    if stream.streamUuid == messageModel.streamId {
                        updateRenderStreamInfo(stream: stream)
                    }
                }
            }
            executeRender(startFlag: true,
                          isLocal: isLocal,
                          streamId: messageModel.streamId)
        case .close:
            // TODO: 若为教师端发起 需要发送http请求

            executeRender(startFlag: false,
                          isLocal: isLocal,
                          streamId: messageModel.streamId)
            view.isHidden = true
        default: break
        }
    }
    
    func sendDismissMessage() {
        if let userId = renderUserInfo?.userId,
           let streamId = renderUserInfo?.streamId,
           let message = ["widgetAction": AgoraSpreadAction.close.rawValue,
                          "spreadStreamId": streamId,
                          "operatedUuid": userId].jsonString() {
            sendMessage(message)
        }
        renderUserInfo = nil
    }
    
    func updateRenderStreamInfo(stream: AgoraEduContextStreamInfo) {
        
        guard let renderUser = renderUserInfo,
              stream.owner.userUuid == renderUser.userId else {
            return
        }
        
        let cameraState = stream.videoSourceType.toSpread()
        let microState = stream.audioSourceType.toSpread()
        let enableVideo = (stream.streamType == .video) || (stream.streamType == .both)
        let enableAudio = (stream.streamType == .audio) || (stream.streamType == .both)
        
        renderUserInfo = AgoraSpreadRenderUserInfo(userId: renderUser.userId,
                                                   userName: renderUser.userName,
                                                   streamId: stream.streamUuid,
                                                   role: renderUser.role,
                                                   isOnline: renderUser.isOnline,
                                                   cameraState: cameraState,
                                                   microState: microState,
                                                   enableVideo: enableVideo,
                                                   enableAudio: enableAudio)
    }
    
    func executeRender(startFlag: Bool,
                       isLocal: Bool,
                       streamId: String) {
        guard let media = mediaContext else {
            return
        }
        
        if startFlag {
            streamContext?.setRemoteVideoStreamSubscribeLevel(streamUuid: streamId,
                                                              level: .high)
            
            media.startRenderVideo(view: spreadView.getVideoCanvas(),
                                   renderConfig: renderConfig(),
                                   streamUuid: streamId)
        } else {
            media.stopRenderVideo(streamUuid: streamId)
        }
    }
    
    func renderConfig() -> AgoraEduContextRenderConfig {
        let renderConfig = AgoraEduContextRenderConfig()
        renderConfig.mode = .hidden
        return renderConfig
    }
}

extension AgoraSpreadRenderWidget {
//    public override func addMessageObserver(_ observer: AgoraWidgetMessageObserver) {
//        super.addMessageObserver(observer)
//        if let message = latestMessage {
//            sendMessage(message)
//        }
//        
//    }
}
