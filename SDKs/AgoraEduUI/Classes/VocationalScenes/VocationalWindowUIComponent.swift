//
//  AgoraSpreadUIController.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2022/1/7.
//

import AgoraEduContext
import AgoraWidget
import UIKit

protocol VocationalWindowUIComponentDelegate: NSObjectProtocol {
    /** 获取目标视图 */
    func getTargetView(with userId: String) -> UIView?
    /** 获取目标视图用于计算layout的父视图 */
    func getTargetSuperView() -> UIView?
    /** 开始展开大窗*/
    func startSpreadForUser(with userId: String)
    /** 已经结束展开大窗，目标可以重新渲染*/
    func stopSpreadForUser(with userId: String)
}

class VocationalWindowUIComponent: UIViewController {
    
    public var isRenderByRTC = true {
        didSet {
            if isRenderByRTC != oldValue {
                // update all renders
                for (k, type) in self.modelDic {
                    guard case AgoraStreamWindowType.video(var renderInfo) = type else {
                        return
                    }
                    setViewWithModel(view: renderInfo.renderView,
                                     model: renderInfo.renderModel)
                }
            }
        }
    }
    
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
    
    weak var delegate: VocationalWindowUIComponentDelegate?
    
    /**widgetId: AgoraStreamWindowType **/
    private var modelDic = [String: AgoraStreamWindowType]()
    
    // widgetArray index is equal to view.subViews index
    private var widgetArray = [FcrWindowWidgetItem]() {
        didSet {
            view.isHidden = (widgetArray.count == 0)
        }
    }
    
    init(context: AgoraEduContextPool,
         subRoom: AgoraEduSubRoomContext? = nil,
         delegate: VocationalWindowUIComponentDelegate? = nil) {
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

extension VocationalWindowUIComponent: AgoraUIActivity {
    func viewWillActive() {
        widgetController.add(self)
        userController.registerUserEventHandler(self)
        streamController.registerStreamEventHandler(self)
        createAllActiveWidgets()
        
        guard widgetArray.count > 0 else {
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
extension VocationalWindowUIComponent: AgoraEduRoomHandler {
    func onJoinRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        viewWillActive()
    }
}

extension VocationalWindowUIComponent: AgoraEduSubRoomHandler {
    func onJoinSubRoomSuccess(roomInfo: AgoraEduContextSubRoomInfo) {
        viewWillActive()
    }
}

// MARK: - AgoraWidgetActivityObserver
extension VocationalWindowUIComponent: AgoraWidgetActivityObserver {
    public func onWidgetActive(_ widgetId: String) {
        createWidget(widgetId)
    }
    
    public func onWidgetInactive(_ widgetId: String) {
        releaseWidget(widgetId)
    }
}

// MARK: - AgoraWidgetSyncFrameObserver
extension VocationalWindowUIComponent: AgoraWidgetSyncFrameObserver {
    func onWidgetSyncFrameUpdated(_ syncFrame: CGRect,
                                  widgetId: String,
                                  operatorUser: AgoraWidgetUserInfo?) {
        guard operatorUser?.userUuid != userController.getLocalUserInfo().userUuid,
              let item = widgetArray.firstItem(widgetId: widgetId) else {
            return
        }
        
        let frame = syncFrame.displayFrameFromSyncFrame(superView: view)
        handleSyncFrame(widget: item.object,
                        frame: frame)
    }
}

// MARK: - AgoraWidgetMessageObserver
extension VocationalWindowUIComponent: AgoraWidgetMessageObserver {
    func onMessageReceived(_ message: String,
                           widgetId: String) {
        guard let item = widgetArray.firstItem(widgetId: widgetId),
              let signal = message.toWindowSignal() else {
            return
        }
        
        switch signal {
        case .RenderInfo(let renderInfo):
            guard !modelDic.keys.contains(widgetId),
                  let streamList = streamController.getStreamList(userUuid: renderInfo.userUuid),
                  let stream = streamList.first(where: {$0.streamUuid == renderInfo.streamId}) else {
                return
            }
            
            switch stream.videoSourceType {
            case .camera:
                addCameraRenderInfo(stream: stream,
                                    renderInfo: renderInfo,
                                    widget: item.object,
                                    zIndex: renderInfo.zIndex ?? 1)
            case .screen:
                addScreenSharingInfo(stream: stream,
                                     renderInfo: renderInfo,
                                     widget: item.object)
            default:
                break
            }
        case .ViewZIndex(let zIndex):
            handleVideoZIndex(zIndex: zIndex,
                              widget: item.object)
        }
    }
}

// MARK: - AgoraEduStreamHandler
extension VocationalWindowUIComponent: AgoraEduStreamHandler {
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
extension VocationalWindowUIComponent: AgoraEduUserHandler {
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
extension VocationalWindowUIComponent: AgoraEduMediaHandler {
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
private extension VocationalWindowUIComponent {
    func createAllActiveWidgets() {
        let allWidgetActivity = widgetController.getAllWidgetActivity()
        
        guard allWidgetActivity.count > 0 else {
            return
        }
        
        for (widgetId, activityNumber) in allWidgetActivity {
            let active = activityNumber.boolValue
            
            guard widgetId.hasPrefix(WindowWidgetId),
                  active == true else {
                continue
            }
            
            createWidget(widgetId)
        }
    }
    
    func releaseAllWidgets() {
        for item in widgetArray {
            releaseWidget(item.widgetObjectId)
        }
    }
    
    func createWidget(_ widgetId: String) {
        guard widgetId.hasPrefix(WindowWidgetId),
              widgetArray.firstItem(widgetId: widgetId) == nil,
              let config = widgetController.getWidgetConfig(WindowWidgetId),
              let streamId = widgetId.splitStreamId(),
              let streamList = streamController.getAllStreamList(),
              let stream = streamList.first(where: {$0.streamUuid == streamId}) else {
            return
        }
        
        config.widgetId = widgetId
        widgetController.add(self,
                             widgetId: widgetId)
        
        let widget = widgetController.create(config)
        
        guard let properties = widget.info.roomProperties as? Dictionary<String, Any>,
              let userId = properties["userUuid"] as? String else {
            return
        }
        
        var zIndex = 0
        
        if stream.videoSourceType == .camera {
            if let index = (properties["zIndex"] as? Int) {
                zIndex = index
            } else {
                zIndex = 1
            }
        }
        
        let renderInfo = AgoraStreamWindowWidgetRenderInfo(userUuid: userId,
                                                           streamId: streamId,
                                                           zIndex: zIndex)
        
        let item = FcrWindowWidgetItem(widgetObjectId: widgetId,
                                       owner: "",
                                       streamId: "",
                                       videoSourceType: .camera,
                                       object: widget,
                                       zIndex: zIndex)
        
        widgetArray.append(item)
        
        switch stream.videoSourceType {
        case .camera:
            addCameraRenderInfo(stream: stream,
                                renderInfo: renderInfo,
                                widget: item.object,
                                zIndex: zIndex)
        case .screen:
            addScreenSharingInfo(stream: stream,
                                 renderInfo: renderInfo,
                                 widget: item.object)
        default:
            break
        }
        
        widgetController.addObserver(forWidgetSyncFrame: self,
                                     widgetId: widgetId)
    }
    
    func releaseWidget(_ widgetId: String) {
        guard let index = widgetArray.firstItemIndex(widgetId: widgetId) else {
            return
        }
        
        let widget = widgetArray[index]
        
        guard let streamId = widget.widgetObjectId.splitStreamId() else {
            return
        }
        
        // stop render
        var isCamera = false
        var userId = getUserIdWithStreamId(streamId) ?? ""
        if let type = modelDic[widgetId],
           case AgoraStreamWindowType.video(let renderInfo) = type {
            isCamera = true
        }
        
        stopRenderOnWindow(streamId: streamId,
                           isCamera: isCamera,
                           userId: userId,
                           widget: widget.object) { [weak self] in
            guard let `self` = self else {
                return
            }
                        
            self.widgetArray.remove(at: index)
            
            self.modelDic.removeValue(forKey: widgetId)
            
            self.widgetController.remove(self,
                                         widgetId: widgetId)
            self.widgetController.removeObserver(forWidgetSyncFrame: self,
                                                 widgetId: widgetId)
        }
    }
}

// MARK: - Private
private extension VocationalWindowUIComponent {
    func addCameraRenderInfo(stream: AgoraEduContextStreamInfo,
                             renderInfo: AgoraStreamWindowWidgetRenderInfo,
                             widget: AgoraBaseWidget,
                             zIndex: Int) {
        let renderModel = makeRenderModel(userId: renderInfo.userUuid,
                                          stream: stream)
        let renderView = AgoraRenderMemberView(frame: .zero)
        
        let spreadInfo = AgoraStreamWindowCameraInfo(renderModel: renderModel,
                                                     renderView: renderView)
        
        widget.view.addSubview(renderView)
        
        renderView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
        
        modelDic[widget.info.widgetId] = .video(cameraInfo: spreadInfo)
        
        // 动画
        let syncFrame = widgetController.getWidgetSyncFrame(widget.info.widgetId)
        let frame = syncFrame.displayFrameFromSyncFrame(superView: view)
        view.addSubview(widget.view)
        
        delegate?.startSpreadForUser(with: renderInfo.userUuid)
        
        if let targetView = delegate?.getTargetView(with: renderInfo.userUuid),
           let targetSuperView = delegate?.getTargetSuperView() {
            startHandleVideoOnWindow(renderView,
                                     isCamera: true,
                                     renderMemberModel: renderModel,
                                     streamId: stream.streamUuid)
            let rect = targetSuperView.convert(targetView.frame,
                                               from: targetView.superview)
            let oldRect = view.convert(rect,
                                       from: targetSuperView)
            
            widget.view.mas_remakeConstraints { make in
                make?.left.equalTo()(oldRect.minX)
                make?.top.equalTo()(oldRect.minY)
                make?.width.equalTo()(oldRect.width)
                make?.height.equalTo()(oldRect.height)
            }
            view.layoutIfNeeded()
        } else {
            startHandleVideoOnWindow(renderView,
                                     isCamera: true,
                                     renderMemberModel: renderModel,
                                     streamId: stream.streamUuid)
        }
        
        handleSyncFrame(widget: widget,
                        frame: frame)
        
        handleVideoZIndex(zIndex: zIndex,
                          widget: widget)
    }
    
    func addScreenSharingInfo(stream: AgoraEduContextStreamInfo,
                              renderInfo: AgoraStreamWindowWidgetRenderInfo,
                              widget: AgoraBaseWidget) {
        let sharingInfo = AgoraStreamWindowSharingInfo(userUuid: renderInfo.userUuid,
                                                       streamUuid: renderInfo.streamId)
        modelDic[widget.info.widgetId] = .screen(sharingInfo: sharingInfo)
        // 开启渲染屏幕共享
        startHandleVideoOnWindow(widget.view,
                                 isCamera: false,
                                 streamId: renderInfo.streamId)
        
        handleVideoZIndex(zIndex: 0,
                          widget: widget)
        
        widget.view.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
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
                           cdnURL: model.cdnURL,
                           renderView: view)
    }
    
    func contextMediaHandle(streamId: String,
                            cdnURL: String?,
                            renderView: AgoraRenderMemberView) {
        if !isLocalStream(streamId) {
            streamController.setRemoteVideoStreamSubscribeLevel(streamUuid: streamId,
                                                                level: .high)
        }
        
        let renderConfig = AgoraEduContextRenderConfig()
        renderConfig.mode = .hidden
        renderConfig.isMirror = false
        if self.isRenderByRTC {
            if let url = cdnURL {
                self.contextPool.media.stopRenderVideoFromCdn(streamUrl: url)
            }
            self.contextPool.media.startRenderVideo(roomUuid: roomId,
                                                    view: renderView.videoView,
                                                    renderConfig: renderConfig,
                                                    streamUuid: streamId)
        } else if let url = cdnURL {
            self.contextPool.media.stopRenderVideo(streamUuid: streamId)
            // 先调用一遍stop用以处理拖拉拽时不显示的问题
            self.contextPool.media.stopRenderVideoFromCdn(streamUrl: url)
            self.contextPool.media.stopPlayAudioFromCdn(streamUrl: url)
            // 开始渲染
            self.contextPool.media.startRenderVideoFromCdn(view: renderView,
                                                      mode: .hidden,
                                                      streamUrl: url)
            self.contextPool.media.startPlayAudioFromCdn(streamUrl: url)
        }
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
    
    func getUserIdWithStreamId(_ streamId: String) -> String? {
        let widgetId = streamId.makeWidgetId()
        
        guard let type = modelDic[widgetId] else {
            return nil
        }
        
        var userId: String
        
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
                            isCamera: Bool,
                            userId: String,
                            widget: AgoraBaseWidget,
                            completion: @escaping (()->())) {
        guard isCamera,
              let targetView = delegate?.getTargetView(with: userId),
              let targetSuperView = delegate?.getTargetSuperView() else {
            contextPool.media.stopRenderVideo(streamUuid: streamId)
            widget.view.removeFromSuperview()
            completion()
            return
        }
        let rect = targetSuperView.convert(targetView.frame,
                                           from: targetView.superview)
        let newRect = view.convert(rect,
                                   from: targetSuperView)
        
        widget.view.mas_remakeConstraints { make in
            make?.left.equalTo()(newRect.minX)
            make?.top.equalTo()(newRect.minY)
            make?.width.equalTo()(newRect.width)
            make?.height.equalTo()(newRect.height)
        }
        
        UIView.animate(withDuration: TimeInterval.agora_animation) {
            self.view.layoutIfNeeded()
        } completion: { finish in
            widget.view.removeFromSuperview()
            self.delegate?.stopSpreadForUser(with: userId)
            completion()
        }
    }
    
    func handleSyncFrame(widget: AgoraBaseWidget,
                         frame: CGRect) {
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
    
    func handleVideoZIndex(zIndex: Int,
                           widget: AgoraBaseWidget) {
        guard let index = widgetArray.firstItemIndex(widgetId: widget.info.widgetId) else {
            return
        }
        
        var item = widgetArray[index]
        item.zIndex = zIndex
        
        widgetArray.remove(at: index)
        
        let viewIndex = widgetArray.insertItem(item)
        
        view.insertSubview(widget.view,
                           at: viewIndex)
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

fileprivate extension Array where Element == FcrWindowWidgetItem {
    func firstItemIndex(widgetId: String) -> Int? {
        return firstIndex(where: {return $0.widgetObjectId == widgetId})
    }
    
    func firstItem(widgetId: String) -> FcrWindowWidgetItem? {
        return first(where: {return $0.widgetObjectId == widgetId})
    }
    
    mutating func insertItem(_ item: FcrWindowWidgetItem) -> Int {
        var insertIndex = 0
        
        for (index, element) in self.enumerated() where item.zIndex >= element.zIndex  {
            insertIndex = (index + 1)
        }
        
        self.insert(item,
                    at: insertIndex)
        
        return insertIndex
    }
}

fileprivate extension String {
    func splitStreamId() -> String? {
        let subStringArray = split(separator: "-")
        
        guard subStringArray.count == 2 else {
            return nil
        }
        
        return String(subStringArray[1])
    }
    
    func makeWidgetId() -> String {
        return "\(WindowWidgetId)-\(self)"
    }
}
