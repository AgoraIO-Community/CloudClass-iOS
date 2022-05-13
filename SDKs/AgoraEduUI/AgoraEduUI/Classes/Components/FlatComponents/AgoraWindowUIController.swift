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

class AgoraWindowUIController: UIViewController {
    private var userController: AgoraEduUserContext {
        if let `subRoom` = subRoom {
            return subRoom.user
        } else {
            return contextPool.user
        }
    }
    
    private var streamController: AgoraEduStreamContext {
        if let `subRoom` = subRoom {
            return subRoom.stream
        } else {
            return contextPool.stream
        }
    }
    
    private var widgetController: AgoraEduWidgetContext {
        if let `subRoom` = subRoom {
            return subRoom.widget
        } else {
            return contextPool.widget
        }
    }
    
    private var roomId: String {
        if let `subRoom` = subRoom {
            return subRoom.getSubRoomInfo().subRoomUuid
        } else {
            return contextPool.room.getRoomInfo().roomUuid
        }
    }
    
    private var contextPool: AgoraEduContextPool
    private var subRoom: AgoraEduSubRoomContext?
    
    weak var delegate: AgoraWindowUIControllerDelegate?
    
    /**widgetId: AgoraBaseWidget **/
    private var widgetDic = [String: AgoraBaseWidget]() {
        didSet {
            view.isHidden = (widgetDic.count == 0)
        }
    }
    /**widgetId: AgoraStreamWindowType **/
    private var modelDic = [String: AgoraStreamWindowType]()

    private let kScreenViewIndex = -1
    private var curMaxZIndexTuple: (zIndex: Int,topWidget: AgoraBaseWidget)?
    
    init(context: AgoraEduContextPool,
         subRoom: AgoraEduSubRoomContext? = nil,
         delegate: AgoraWindowUIControllerDelegate? = nil) {
        self.contextPool = context
        self.subRoom = subRoom
        self.delegate = delegate
        super.init(nibName: nil,
                   bundle: nil)
    }
    
    deinit {
        print("\(#function): \(self.classForCoder)")
    }
    
    override func loadView() {
        view = AgoraBaseUIContainer()
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        if let `subRoom` = subRoom {
            subRoom.registerSubRoomEventHandler(self)
        } else {
            contextPool.room.registerRoomEventHandler(self)
        }
        
        contextPool.media.registerMediaEventHandler(self)
    }
}

extension AgoraWindowUIController: AgoraUIActivity {
    func viewWillActive() {
        widgetController.add(self)
        userController.registerUserEventHandler(self)
        streamController.registerStreamEventHandler(self)
        createAllActiveWidgets()
        
        guard widgetDic.count > 0 else {
            return
        }
        
        view.isHidden = false
    }
    
    func viewWillInactive() {
        widgetController.remove(self)
        userController.unregisterUserEventHandler(self)
        streamController.unregisterStreamEventHandler(self)
        releaseAllWidgets()
        
        view.isHidden = true
    }
}

// MARK: - AgoraEduRoomHandler
extension AgoraWindowUIController: AgoraEduRoomHandler {
    func onJoinRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        viewWillActive()
    }
}

extension AgoraWindowUIController: AgoraEduSubRoomHandler {
    func onJoinSubRoomSuccess(roomInfo: AgoraEduContextSubRoomInfo) {
        viewWillActive()
    }
}

// MARK: - AgoraWidgetActivityObserver
extension AgoraWindowUIController: AgoraWidgetActivityObserver {
    public func onWidgetActive(_ widgetId: String) {
        createWidget(widgetId)
    }
    
    public func onWidgetInactive(_ widgetId: String) {
        releaseWidget(widgetId)
    }
}

// MARK: - AgoraWidgetSyncFrameObserver
extension AgoraWindowUIController: AgoraWidgetSyncFrameObserver {
    func onWidgetSyncFrameUpdated(_ syncFrame: CGRect,
                                  widgetId: String) {
        guard let widget = widgetDic[widgetId] else {
            return
        }
        handleSyncFrame(widget: widget)
    }
}

// MARK: - AgoraWidgetMessageObserver
extension AgoraWindowUIController: AgoraWidgetMessageObserver {
    func onMessageReceived(_ message: String,
                           widgetId: String) {
        guard let widget = widgetDic[widgetId],
              let signal = message.toWindowSignal() else {
                  return
              }
        
        switch signal {
        case .RenderInfo(let renderInfo):
            guard !modelDic.keys.contains(widgetId),
                  let stream = streamController.getStreamList(userUuid: renderInfo.userUuid)?.first(where: {$0.streamUuid == renderInfo.streamId}) else {
                return
            }
            switch stream.videoSourceType {
            case .camera:
                addCameraRenderInfo(stream: stream,
                                    renderInfo: renderInfo,
                                    widget: widget,
                                    zIndex: renderInfo.zIndex)
            case .screen:
                addScreenSharingInfo(stream: stream,
                                     renderInfo: renderInfo,
                                     widget: widget)
            default:
                break
            }
        case .ViewZIndex(let zIndex):
            handleVideoZIndex(zIndex: zIndex,
                              widget: widget)
        }
    }
}

// MARK: - AgoraEduStreamHandler
extension AgoraWindowUIController: AgoraEduStreamHandler {
    func onStreamJoined(stream: AgoraEduContextStreamInfo,
                        operatorUser: AgoraEduContextUserInfo?) {
        updateCameraRenderInfo(stream)
    }
    
    func onStreamUpdated(stream: AgoraEduContextStreamInfo,
                         operatorUser: AgoraEduContextUserInfo?) {
        updateCameraRenderInfo(stream)
    }
    
    func onStreamLeft(stream: AgoraEduContextStreamInfo,
                      operatorUser: AgoraEduContextUserInfo?) {
        updateCameraRenderInfo(stream.toEmptyStream())
    }
}

// MARK: - AgoraEduMediaHandler
extension AgoraWindowUIController: AgoraEduUserHandler {
    func onUserHandsWave(userUuid: String,
                         duration: Int,
                         payload: [String : Any]?) {
        guard let streamList = streamController.getStreamList(userUuid: userUuid) else {
            return
        }
        
        for stream in streamList {
            let widgetId = stream.streamUuid.makeWidgetId()
            guard let type = modelDic[widgetId],
                  case let AgoraStreamWindowType.video(cameraInfo) = type else {
                continue
            }
            cameraInfo.renderView.startWaving()
        }
    }
    
    func onUserHandsDown(userUuid: String,
                         payload: [String : Any]?) {
        guard let streamList = streamController.getStreamList(userUuid: userUuid) else {
            return
        }
        var cameraInfo: AgoraStreamWindowCameraInfo?
        for stream in streamList {
            let widgetId = stream.streamUuid.makeWidgetId()
            guard let type = modelDic[widgetId],
                  case let AgoraStreamWindowType.video(cameraInfo) = type else {
                continue
            }
            cameraInfo.renderView.stopWaving()
        }
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
        renderInfo.renderView.updateVolume(volume)
    }
}

// MARK: - Widget create & relase
private extension AgoraWindowUIController {
    func createAllActiveWidgets() {
        let allWidgetActivity = widgetController.getAllWidgetActivity()
        
        guard allWidgetActivity.count > 0 else {
            return
        }
        
        for (widgetId, activityNumber) in allWidgetActivity {
            let active = activityNumber.boolValue
            
            guard widgetId.hasPrefix(kWindowWidgetId),
                  active == true else {
                continue
            }
            
            createWidget(widgetId)
        }
    }
    
    func releaseAllWidgets() {
        for widgetId in widgetDic.keys {
            releaseWidget(widgetId)
        }
    }
    
    func createWidget(_ widgetId: String) {
        guard widgetId.hasPrefix(kWindowWidgetId),
              !self.widgetDic.keys.contains(widgetId),
              let config = widgetController.getWidgetConfig(kWindowWidgetId),
              let streamId = widgetId.splitStreamId(),
              let streamList = streamController.getAllStreamList(),
              streamList.contains(where: {$0.streamUuid == streamId}) else {
            return
        }
        
        config.widgetId = widgetId
        widgetController.add(self,
                             widgetId: widgetId)
        
        let widget = widgetController.create(config)
        self.widgetDic[widgetId] = widget
        
        widgetController.addObserver(forWidgetSyncFrame: self,
                                     widgetId: widgetId)
    }
    
    func releaseWidget(_ widgetId: String) {
        guard let widget = widgetDic[widgetId],
              let streamId = widgetId.splitStreamId() else {
            return
        }
        
        // stop render
        var isCamera = false
        if let type = modelDic[widgetId],
           case AgoraStreamWindowType.video(let renderInfo) = type {
            isCamera = true
        }
        stopRenderOnWindow(streamId: streamId,
                           isCamera: isCamera)
        
        // TODO: 2.3.0暂时不需要动画，后期大窗需要stopSpreadObj(widgetId: widgetId)
        widget.view.removeFromSuperview()

        if let tuple = curMaxZIndexTuple,
           tuple.topWidget.info.widgetId == widgetId {
            curMaxZIndexTuple = nil
        }
        curMaxZIndexTuple = nil
        widgetDic.removeValue(forKey: widgetId)
        modelDic.removeValue(forKey: widgetId)
        
        widgetController.remove(self,
                                widgetId: widgetId)
        widgetController.removeObserver(forWidgetSyncFrame: self,
                                        widgetId: widgetId)
    }
}

// MARK: - Private
private extension AgoraWindowUIController {
    func addCameraRenderInfo(stream: AgoraEduContextStreamInfo,
                             renderInfo: AgoraStreamWindowWidgetRenderInfo,
                             widget: AgoraBaseWidget,
                             zIndex: Int?) {
        let renderModel = makeRenderModel(userId: renderInfo.userUuid,
                                          stream: stream)
        let renderView = AgoraRenderMemberView(frame: .zero)
        
        let spreadInfo = AgoraStreamWindowCameraInfo(renderModel: renderModel,
                                                     renderView: renderView)
        
        widget.view.addSubview(renderView)
        renderView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
        
        view.addSubview(widget.view)
        
        handleSyncFrame(widget: widget)
        
        handleVideoZIndex(zIndex: zIndex,
                          widget: widget)
        
        modelDic[widget.info.widgetId] = .video(cameraInfo: spreadInfo)
        if let streamList = streamController.getStreamList(userUuid: renderInfo.userUuid),
           let stream = streamList.first(where: {$0.streamUuid == renderInfo.streamId}),
           stream.videoSourceType != .screen {
            delegate?.startSpreadForUser(with: renderInfo.userUuid)
        }
        // 开启渲染视频窗大流
        startHandleVideoOnWindow(renderView,
                                 isCamera: true,
                                 renderMemberModel: renderModel,
                                 streamId: stream.streamUuid)
    }
    
    func addScreenSharingInfo(stream: AgoraEduContextStreamInfo,
                              renderInfo: AgoraStreamWindowWidgetRenderInfo,
                              widget: AgoraBaseWidget) {
        view.addSubview(widget.view)
        
        widget.view.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
        
        let sharingInfo = AgoraStreamWindowSharingInfo(userUuid: renderInfo.userUuid,
                                                 streamUuid: renderInfo.streamId)
        modelDic[widget.info.widgetId] = .screen(sharingInfo: sharingInfo)
        // 开启渲染屏幕共享
        startHandleVideoOnWindow(widget.view,
                                 isCamera: false,
                                 streamId: renderInfo.streamId)
    }
    
    func updateCameraRenderInfo(_ stream: AgoraEduContextStreamInfo) {
        let widgetId = stream.streamUuid.makeWidgetId()
        guard stream.videoSourceType != .screen,
        let type = modelDic[widgetId],
        case AgoraStreamWindowType.video(var renderInfo) = type else {
            return
        }
        let oldValue = renderInfo.renderModel
        renderInfo.renderModel = AgoraRenderMemberViewModel.model(oldValue: oldValue,
                                                                  stream: stream,
                                                                  windowFlag: true)
        setViewWithModel(view: renderInfo.renderView,
                         model: renderInfo.renderModel)
    }
    
    // model to view
    func setViewWithModel(view: AgoraRenderMemberView,
                          model: AgoraRenderMemberViewModel) {
        model.setRenderMemberView(view: view)
        
        guard let streamId = model.streamId,
              model.videoState == .normal else {
            return
        }
        contextMediaHandle(streamId: streamId,
                           renderView: view)
    }
    
    func contextMediaHandle(streamId: String,
                            renderView: AgoraRenderMemberView) {
        
        if !isLocalStream(streamId) {
            streamController.setRemoteVideoStreamSubscribeLevel(streamUuid: streamId,
                                                                level: .high)
        }
        
        let renderConfig = AgoraEduContextRenderConfig()
        renderConfig.mode = .hidden
        renderConfig.isMirror = false
        
        contextPool.media.startRenderVideo(roomUuid: roomId,
                                           view: renderView.videoView,
                                           renderConfig: renderConfig,
                                           streamUuid: streamId)
    }
    
    func makeRenderModel(userId: String,
                         stream: AgoraEduContextStreamInfo) -> AgoraRenderMemberViewModel {
        guard let user = userController.getAllUserList().first(where: {$0.userUuid == userId}) else {
            return AgoraRenderMemberViewModel.defaultNilValue(role: .student)
        }
        var model = AgoraRenderMemberViewModel.model(user: user,
                                                     stream: stream,
                                                     windowFlag: true,
                                                     curWindow: true)
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
            userId = cameraInfo.renderModel.userId
        case .screen(let screenInfo):
            userId = screenInfo.userUuid
        }
        return userId
    }
    
    func startHandleVideoOnWindow(_ view: UIView,
                                  isCamera: Bool,
                                  renderMemberModel: AgoraRenderMemberViewModel? = nil,
                                  streamId: String) {
        if isCamera {
            guard let model = renderMemberModel,
                  let renderView = view as? AgoraRenderMemberView else {
                return
            }
            setViewWithModel(view: renderView,
                             model: model)
        } else {
            // 屏幕共享只有远端
            let renderConfig = AgoraEduContextRenderConfig()
            renderConfig.mode = .fit
            renderConfig.isMirror = false
            streamController.setRemoteVideoStreamSubscribeLevel(streamUuid: streamId,
                                                                level: .high)
            
            contextPool.media.startRenderVideo(roomUuid: roomId,
                                               view: view,
                                               renderConfig: renderConfig,
                                               streamUuid: streamId)
        }
    }
    
    func stopRenderOnWindow(streamId: String,
                            isCamera: Bool) {
        contextPool.media.stopRenderVideo(streamUuid: streamId)
        if let uid = getUidWithStreamId(streamId),
           isCamera {
            delegate?.didStopSpreadForUser(with: uid)
        }
    }
    
    func handleSyncFrame(widget: AgoraBaseWidget) {
        let syncFrame = widgetController.getWidgetSyncFrame(widget.info.widgetId)
        let frame = syncFrame.displayFrameFromSyncFrame(superView: self.view)

        widget.view.mas_remakeConstraints { make in
            make?.left.equalTo()(frame.minX)
            make?.top.equalTo()(frame.minY)
            make?.width.equalTo()(frame.width)
            make?.height.equalTo()(frame.height)
        }

        UIView.animate(withDuration: TimeInterval.agora_animation) {
            self.view.layoutIfNeeded()
        }
    }
    
    func handleVideoZIndex(zIndex: Int?,
                           widget: AgoraBaseWidget) {
        let finalZIndex = zIndex ?? 0
        if curMaxZIndexTuple != nil,
           finalZIndex <= curMaxZIndexTuple!.zIndex {
            view.bringSubviewToFront(curMaxZIndexTuple!.topWidget.view)
        } else {
            curMaxZIndexTuple = (finalZIndex, widget)
            view.bringSubviewToFront(widget.view)
        }
    }
    
    func isLocalStream(_ streamId: String) -> Bool {
        let localUid = userController.getLocalUserInfo().userUuid
        
        if let localStreamList = streamController.getStreamList(userUuid: localUid),
           localStreamList.contains(where: {$0.streamUuid == streamId}) {
            return true
        } else {
            return false
        }
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
