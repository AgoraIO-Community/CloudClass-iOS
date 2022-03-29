//
//  AgoraSpreadUIController.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2022/1/7.
//

import AgoraEduContext
import AgoraWidget
import UIKit

protocol AgoraWindowUIControllerDelegate: NSObjectProtocol {
    /** 开始展开大窗*/
    func startSpreadForUser(with userId: String) -> UIView?
    /** 将要结束展开大窗，拿到目标的视图*/
    func willStopSpreadForUser(with userId: String) -> UIView?
    /** 已经结束展开大窗，目标可以重新渲染*/
    func didStopSpreadForUser(with userId: String)
}

fileprivate class AgoraCameraWindowInfo: NSObject {
    var renderModel: AgoraRenderMemberModel
    var renderView: AgoraRenderMemberView
    
    init(renderModel: AgoraRenderMemberModel,
         renderView: AgoraRenderMemberView) {
        self.renderModel = renderModel
        self.renderView = renderView
    }
}

fileprivate class AgoraSharingWindowInfo: NSObject {
    var userUuid: String
    var streamUuid: String
    
    init(userUuid: String,
         streamUuid: String) {
        self.userUuid = userUuid
        self.streamUuid = streamUuid
    }
}

fileprivate enum AgoraStreamWindowType: Equatable {
    case video(AgoraCameraWindowInfo)
    case screen(AgoraSharingWindowInfo)
    
    static func == (lhs: Self,
                    rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (let .video(_),let .video(_)):   return true
        case (let .screen(_),let .screen(_)): return true
        default:                              return false
        }
    }
}

class AgoraWindowUIController: UIViewController {
    weak var delegate: AgoraWindowUIControllerDelegate?
    
    /**widgetId: AgoraBaseWidget **/
    private var widgetDic = [String: AgoraBaseWidget]() {
        didSet {
            self.view.isHidden = (widgetDic.count == 0)
        }
    }
    /**widgetId: AgoraStreamWindowType **/
    private var modelDic = [String: AgoraStreamWindowType]()
    
    /** SDK环境*/
    var contextPool: AgoraEduContextPool!
    
    deinit {
        print("\(#function): \(self.classForCoder)")
    }
    
    init(context: AgoraEduContextPool) {
        super.init(nibName: nil, bundle: nil)
        
        contextPool = context
    }
    
    override func loadView() {
        view = AgoraBaseUIContainer()
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
                        
        contextPool.widget.add(self)
        contextPool.stream.registerStreamEventHandler(self)
        contextPool.media.registerMediaEventHandler(self)
        contextPool.room.registerRoomEventHandler(self)
    }
}

// MARK: - AgoraWidgetActivityObserver
extension AgoraWindowUIController: AgoraWidgetActivityObserver {
    public func onWidgetActive(_ widgetId: String) {
        guard widgetId.hasPrefix(kWindowWidgetId),
              !self.widgetDic.keys.contains(widgetId),
              let config = contextPool.widget.getWidgetConfig(kWindowWidgetId),
              let streamId = widgetId.splitStreamId() else {
            return
        }
        
        config.widgetId = widgetId
        contextPool.widget.add(self,
                               widgetId: widgetId)
        
        let widget = contextPool.widget.create(config)
        self.widgetDic[widgetId] = widget
        
        view.addSubview(widget.view)
        // TODO: v2.3.0暂时铺满
//        let syncFrame = contextPool.widget.getWidgetSyncFrame(widget.info.widgetId)
//        let frame = syncFrame.displayFrameFromSyncFrame(superView: self.view)
        let frame = CGRect(x: 0,
                           y: 0,
                           width: self.view.width,
                           height: self.view.height)
        print(">>>> onWidgetActive:\(widgetId) ")
        widget.view.mas_makeConstraints { make in
            make?.left.equalTo()(frame.minX)
            make?.top.equalTo()(frame.minY)
            make?.width.equalTo()(frame.width)
            make?.height.equalTo()(frame.height)
        }
    }
    
    public func onWidgetInactive(_ widgetId: String) {
        guard let widget = widgetDic[widgetId],
              let streamId = widgetId.splitStreamId() else {
            return
        }
        // stop render
        contextPool.media.stopRenderVideo(streamUuid: streamId)
        print(">>>> onWidgetInactive:\(widgetId) ")
        // TODO: 2.3.0暂时不需要动画，后期大窗需要stopSpreadObj(widgetId: widgetId)
        widget.view.removeFromSuperview()
        widgetDic.removeValue(forKey: widgetId)
        modelDic.removeValue(forKey: widgetId)
        
        contextPool.widget.remove(self,
                                  widgetId: widgetId)
        contextPool.widget.removeObserver(forWidgetSyncFrame: self,
                                          widgetId: widgetId)
    }
}

// MARK: - AgoraWidgetSyncFrameObserver
extension AgoraWindowUIController: AgoraWidgetSyncFrameObserver {
    func onWidgetSyncFrameUpdated(_ syncFrame: CGRect,
                                  widgetId: String) {
        // TODO: 2.3.0暂不需移动，缩放和动画
//        guard let targetView = widgetDic[widgetId]?.view else {
//            return
//        }
//
//        let frame = syncFrame.displayFrameFromSyncFrame(superView: self.view)
//
//        self.view.bringSubviewToFront(targetView)
//        self.view.layoutIfNeeded()
//
//        targetView.mas_remakeConstraints { make in
//            make?.left.equalTo()(frame.minX)
//            make?.top.equalTo()(frame.minY)
//            make?.width.equalTo()(frame.width)
//            make?.height.equalTo()(frame.height)
//        }
//
//        UIView.animate(withDuration: TimeInterval.agora_animation) {
//            self.view.layoutIfNeeded()
//        }
    }
}

// MARK: - AgoraWidgetMessageObserver
extension AgoraWindowUIController: AgoraWidgetMessageObserver {
    func onMessageReceived(_ message: String,
                           widgetId: String) {
        guard let widget = widgetDic[widgetId],
              let signal = message.toWindowSignal(),
              !modelDic.keys.contains(widgetId) else {
                  return
              }
        
        switch signal {
        case .RenderInfo(let renderInfo):
            guard let stream = contextPool.stream.getStreamList(userUuid: renderInfo.userUuid)?.first(where: {$0.streamUuid == renderInfo.streamId}) else {
                return
            }
            switch stream.videoSourceType {
            case .camera:
                addCameraRenderInfo(stream: stream,
                                    renderInfo: renderInfo,
                                    widget: widget)
            case .screen:
                addScreenSharingInfo(stream: stream,
                                     renderInfo: renderInfo,
                                     widget: widget)
            default:
                break
            }
        }
    }
}
// MARK: - AgoraRenderMemberViewDelegate
extension AgoraWindowUIController: AgoraRenderMemberViewDelegate {
    func memberViewRender(memberView: AgoraRenderMemberView,
                          in view: UIView,
                          renderID: String) {
        startRenderOnWindow(view,
                            streamId: renderID)
    }

    func memberViewCancelRender(memberView: AgoraRenderMemberView,
                                renderID: String) {
        stopRenderOnWindow(streamId: renderID)
    }
}

// MARK: - AgoraEduRoomHandler
extension AgoraWindowUIController: AgoraEduRoomHandler {
    func onJoinRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        let allWidgetActivity = contextPool.widget.getAllWidgetActivity()
        
        guard allWidgetActivity.count > 0 else {
            return
        }
        
        for (widgetId, activityNumber) in allWidgetActivity {
            let active = activityNumber.boolValue
            
            guard widgetId.hasPrefix(kWindowWidgetId),
                  active == true else {
                continue
            }
            
            self.onWidgetActive(widgetId)
        }
    }
}
// MARK: - AgoraEduStreamHandler
extension AgoraWindowUIController: AgoraEduStreamHandler {
    func onStreamJoined(stream: AgoraEduContextStreamInfo,
                        operatorUser: AgoraEduContextUserInfo?) {
        self.updateStreamInfo(stream)
    }
    
    func onStreamUpdated(stream: AgoraEduContextStreamInfo,
                         operatorUser: AgoraEduContextUserInfo?) {
        self.updateStreamInfo(stream)
    }
    
    func onStreamLeft(stream: AgoraEduContextStreamInfo,
                      operatorUser: AgoraEduContextUserInfo?) {
        let emptyStream = AgoraEduContextStreamInfo(streamUuid: stream.streamUuid,
                                                    streamName: stream.streamName,
                                                    streamType: .none,
                                                    videoSourceType: .none,
                                                    audioSourceType: .none,
                                                    videoSourceState: .error,
                                                    audioSourceState: .error,
                                                    owner: stream.owner)
        self.updateStreamInfo(emptyStream)
    }
}
// MARK: - AgoraEduMediaHandler
extension AgoraWindowUIController: AgoraEduMediaHandler {
    func onVolumeUpdated(volume: Int,
                         streamUuid: String) {
        let widgetId = streamUuid.makeWidgetId()
        guard let type = modelDic[widgetId],
              case AgoraStreamWindowType.video(let renderInfo) = type else {
                  return
              }
        renderInfo.renderModel.volume = volume
    }
}

// MARK: - Private
private extension AgoraWindowUIController {
    func addCameraRenderInfo(stream: AgoraEduContextStreamInfo,
                             renderInfo: AgoraStreamWindowWidgetRenderInfo,
                             widget: AgoraBaseWidget) {
        let renderModel = makeRenderModel(userId: renderInfo.userUuid,
                                          stream: stream)
        let renderView = AgoraRenderMemberView(frame: .zero)
        
        let spreadInfo = AgoraCameraWindowInfo(renderModel: renderModel,
                                               renderView: renderView)

        widget.view.addSubview(renderView)
        spreadInfo.renderView = renderView
        renderView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
        
        modelDic[widget.info.widgetId] = .video(spreadInfo)
        // 开启渲染视频窗大流
        renderView.setModel(model: renderModel,
                            delegate: self)
    }
    
    func addScreenSharingInfo(stream: AgoraEduContextStreamInfo,
                              renderInfo: AgoraStreamWindowWidgetRenderInfo,
                              widget: AgoraBaseWidget) {
        guard let targetView =  widgetDic[widget.info.widgetId]?.view else {
            return
        }
        let sharingInfo = AgoraSharingWindowInfo(userUuid: renderInfo.userUuid,
                                                 streamUuid: renderInfo.streamId)
        modelDic[widget.info.widgetId] = .screen(sharingInfo)
        // 开启渲染屏幕共享
        startRenderOnWindow(targetView,
                            streamId: renderInfo.streamId)
    }
    
    func updateStreamInfo(_ stream: AgoraEduContextStreamInfo) {
        let widgetId = stream.streamUuid.makeWidgetId()
        guard stream.videoSourceType != .screen,
        let type = modelDic[widgetId],
        case AgoraStreamWindowType.video(let renderInfo) = type else {
            return
        }
        renderInfo.renderModel.updateStream(stream)
    }
    
    func makeRenderModel(userId: String,
                         stream: AgoraEduContextStreamInfo) -> AgoraRenderMemberModel {
        guard let user = contextPool.user.getAllUserList().first(where: {$0.userUuid == userId}) else {
            return AgoraRenderMemberModel()
        }
        var model = AgoraRenderMemberModel()
        model.uuid = user.userUuid
        model.name = user.userName
        model.updateStream(stream)
        // TODO: 在这里设置合适吗
        model.rendEnable = true
        return model
    }
    
    func getUidWithStreamId(_ streamId: String) -> String? {
        let widgetId = streamId.makeWidgetId()
        guard let type = modelDic[widgetId] else {
            return nil
        }
        
        var userId: String?
        switch type {
        case .video(let cameraInfo):
            userId = cameraInfo.renderModel.uuid
        case .screen(let screenInfo):
            userId = screenInfo.userUuid
        }
        return userId
    }
    
    func startRenderOnWindow(_ view: UIView,
                             streamId: String) {
        if let uid = getUidWithStreamId(streamId) {
            delegate?.startSpreadForUser(with: uid)
        }
        
        let renderConfig = AgoraEduContextRenderConfig()
        renderConfig.mode = .hidden
        renderConfig.isMirror = false
        contextPool.stream.setRemoteVideoStreamSubscribeLevel(streamUuid: streamId,
                                                              level: .high)
        contextPool.media.startRenderVideo(view: view,
                                           renderConfig: renderConfig,
                                           streamUuid: streamId)
    }
    
    func stopRenderOnWindow(streamId: String) {
        if let uid = getUidWithStreamId(streamId) {
            delegate?.didStopSpreadForUser(with: uid)
        }
        contextPool.media.stopRenderVideo(streamUuid: streamId)
    }
}

extension String {
    func splitStreamId() -> String? {
        let subStringArr = self.split(separator: "-")
        guard subStringArr.count == 2 else {
            return nil
        }
        return String(subStringArr[1])
    }
    
    func makeWidgetId() -> String {
        return "\(kWindowWidgetId)-\(self)"
    }
}
