//
//  FcrDetachedStreamWindowUIController.swift
//  AgoraEduUI
//
//  Created by Cavan on 2022/6/15.
//

import AgoraUIBaseViews
import AgoraEduCore
import AgoraWidget

protocol FcrDetachedStreamWindowUIComponentDelegate: NSObjectProtocol {
    func onNeedWindowRenderViewFrameOnTopWindow(userId: String) -> CGRect?
    func onWillStartRenderVideoStream(streamId: String)
    func onDidStopRenderVideoStream(streamId: String)
}

class FcrDetachedStreamWindowUIComponent: UIViewController {
    public let roomController: AgoraEduRoomContext
    public let userController: AgoraEduUserContext
    public let streamController: AgoraEduStreamContext
    public let mediaController: AgoraEduMediaContext
    public let widgetController: AgoraEduWidgetContext
    public let subRoom: AgoraEduSubRoomContext?
    
    // For lecture
    internal var roomId: String {
        if let `subRoom` = subRoom {
            return subRoom.getSubRoomInfo().subRoomUuid
        } else {
            return roomController.getRoomInfo().roomUuid
        }
    }
    
    private weak var delegate: FcrDetachedStreamWindowUIComponentDelegate?
    
    // dataSource index is equal to view.subViews index
    private(set) var dataSource = [FcrDetachedStreamWindowWidgetItem]() {
        didSet {
            guard dataSource.count != oldValue.count else {
                return
            }
            
            view.isHidden = (dataSource.count == 0)
        }
    }
    
    private(set) var renderViews = [String: FcrWindowRenderView]() // Key: streamId
    private(set) var widgets = [String: AgoraBaseWidget]()         // Key: widget object Id
    private(set) var syncFrames = [String: AgoraWidgetFrame]()     // Key: widget object Id
    
    private weak var componentDataSource: FcrUIComponentDataSource?
    
    init(roomController: AgoraEduRoomContext,
         userController: AgoraEduUserContext,
         streamController: AgoraEduStreamContext,
         mediaController: AgoraEduMediaContext,
         widgetController: AgoraEduWidgetContext,
         subRoom: AgoraEduSubRoomContext? = nil,
         delegate: FcrDetachedStreamWindowUIComponentDelegate? = nil,
         componentDataSource: FcrUIComponentDataSource? = nil) {
        self.roomController = roomController
        self.userController = userController
        self.streamController = streamController
        self.mediaController = mediaController
        self.widgetController = widgetController
        self.subRoom = subRoom
        self.delegate = delegate
        self.componentDataSource = componentDataSource
        
        super.init(nibName: nil,
                   bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        // Case:
        // During the animated movement of the view, if the view controller gets destroyed,
        // it results in the widget view remaining on the top window and unable to be removed.
        for item in widgets.values {
            item.view.removeFromSuperview()
        }
        
        print("\(#function): \(self.classForCoder)")
    }
    
    override func loadView() {
        view = AgoraBaseUIContainer()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let `subRoom` = subRoom {
            subRoom.registerSubRoomEventHandler(self)
        } else {
            roomController.registerRoomEventHandler(self)
        }
        
        mediaController.registerMediaEventHandler(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        for item in dataSource {
            guard let frame = syncFrames[item.widgetObjectId] else {
                continue
            }
            
            updateFrame(widgetObjectId: item.widgetObjectId,
                        syncFrame: frame,
                        animation: false)
        }
    }
    
    public func onAddedRenderWidget(widgetView: UIView) {
        // 给子类重写来对widget view 进行操作
    }
}

extension FcrDetachedStreamWindowUIComponent: AgoraUIActivity {
    func viewWillActive() {
        widgetController.add(self)
        userController.registerUserEventHandler(self)
        streamController.registerStreamEventHandler(self)
        createAllItems()
        
        guard dataSource.count > 0 else {
            return
        }
        
        view.agora_visible = true
    }
    
    func viewWillInactive() {
        widgetController.remove(self)
        userController.unregisterUserEventHandler(self)
        streamController.unregisterStreamEventHandler(self)
        deleteAllItems()
        
        view.agora_visible = false
    }
}

// MARK: - Public Item
extension FcrDetachedStreamWindowUIComponent {
    func updateItemData(_ data: FcrStreamWindowViewData,
                        index: Int) {
        var item = dataSource[index]
        
        let prevData = item.data
        
        guard prevData != data else {
            return
        }
        
        guard let renderView = renderViews[item.data.streamId] else {
            return
        }
        
        item.data = data
        
        updateRenderView(renderView,
                         data: data)
        
        dataSource[index] = item
    }
    
    func onWillDisplayItem(_ item: FcrDetachedStreamWindowWidgetItem,
                           renderView: FcrWindowRenderVideoView) {
        let renderConfig = AgoraEduContextRenderConfig()
        
        renderConfig.mode = .fit
        
        let streamId = item.data.streamId
        
        delegate?.onWillStartRenderVideoStream(streamId: streamId)
        
        streamController.setRemoteVideoStreamSubscribeLevel(streamUuid: streamId,
                                                            level: .high)
        
        mediaController.startRenderVideo(roomUuid: roomId,
                                         view: renderView,
                                         renderConfig: renderConfig,
                                         streamUuid: streamId)
    }
    
    func onDidEndDisplayingItem(_ item: FcrDetachedStreamWindowWidgetItem) {
        let streamId = item.data.streamId
        
        mediaController.stopRenderVideo(roomUuid: roomId,
                                        streamUuid: streamId)
        
        delegate?.onDidStopRenderVideoStream(streamId: streamId)
    }
}

// MARK: - Private Item
private extension FcrDetachedStreamWindowUIComponent {
    func addItem(_ item: FcrDetachedStreamWindowWidgetItem,
                 animation: Bool = true) {
        let syncFrame = widgetController.getStreamWidgetSyncFrame(item.widgetObjectId)
        
        addItem(item,
                syncFrame: syncFrame,
                animation: animation)
    }
    
    internal func addItem(_ item: FcrDetachedStreamWindowWidgetItem,
                          syncFrame: AgoraWidgetFrame,
                          animation: Bool = true) {
        if let _ = getItem(widgetObjectId: item.widgetObjectId) {
            updateFrame(widgetObjectId: item.widgetObjectId,
                        syncFrame: syncFrame,
                        animation: true)
            return
        }
        
        guard let widget = widgets[item.widgetObjectId] else {
            return
        }
        
        dataSource.append(item)
        
        // FcrWindowRenderView
        let renderView = createRenderView()
        
        widget.view.addSubview(renderView)
        
        renderView.mas_makeConstraints { make in
            make?.right.left().top().bottom().equalTo()(0)
        }
        
        renderViews[item.data.streamId] = renderView
        
        if item.type == .camera {
            updateRenderView(renderView,
                             data: item.data)
        }
        
        onWillDisplayItem(item,
                          renderView: renderView.videoView)
        
        // init Frame & Animation
        let itemIndex = (dataSource.count - 1)
        
        syncFrames[item.widgetObjectId] = syncFrame
        
        addItemViewFrame(widgetObjectId: item.widgetObjectId,
                         widgetView: widget.view,
                         userId: item.data.userId,
                         zIndex: item.zIndex,
                         itemIndex: itemIndex,
                         syncFrame: syncFrame,
                         animation: animation)
        
        // Observe widget event
        widgetController.add(self,
                             widgetId: item.widgetObjectId)
        
        widgetController.addObserver(forWidgetSyncFrame: self,
                                     widgetId: item.widgetObjectId)
        
        onAddedRenderWidget(widgetView: widget.view)
    }
    
    internal func removeItem(_ widgetObjectId: String,
                             animation: Bool = true) {
        guard let index = dataSource.firstItemIndex(widgetObjectId: widgetObjectId),
              let widget = widgets[widgetObjectId]
        else {
            return
        }
        
        // FcrWindowWidgetItem
        let item = dataSource[index]
        dataSource.remove(at: index)
        
        // Widget
        widget.view.removeFromSuperview()
        widgets.removeValue(forKey: item.widgetObjectId)
        
        // Frame & Animation
        syncFrames.removeValue(forKey: item.widgetObjectId)
        
        deleteViewFrame(widgetView: widget.view,
                        userId: item.data.userId,
                        animation: animation) { [weak self] in
            guard let `self` = self else {
                return
            }
            
            // Stop render video stream
            self.onDidEndDisplayingItem(item)
        }
        
        // RenderView
        renderViews.removeValue(forKey: item.data.streamId)
        
        // Cancel observe widget event
        widgetController.remove(self,
                                widgetId: item.widgetObjectId)
        
        widgetController.removeObserver(forWidgetSyncFrame: self,
                                        widgetId: item.widgetObjectId)
    }
    
    internal func getItem(widgetObjectId: String) -> FcrDetachedStreamWindowWidgetItem? {
        return dataSource.firstItem(widgetObjectId: widgetObjectId)
    }
    
    func createItem(widgetObjectId: String) -> FcrDetachedStreamWindowWidgetItem? {
        guard let streamId = widgetObjectId.splitStreamId(),
              let streamList = streamController.getAllStreamList(),
              let stream = streamList.first(where: {$0.streamUuid == streamId})
        else {
            return nil
        }
        
        return createItem(widgetObjectId: widgetObjectId,
                          stream: stream)
    }
    
    internal func createItem(widgetObjectId: String,
                             stream: AgoraEduContextStreamInfo) -> FcrDetachedStreamWindowWidgetItem? {
        guard UIConfig.streamWindow.enable,
              widgetObjectId.hasPrefix(WindowWidgetId)
        else {
            return nil
        }
        
        if let item = getItem(widgetObjectId: widgetObjectId) {
            return item
        }
        
        guard let config = widgetController.getWidgetConfig(WindowWidgetId) else {
            return nil
        }
        
        // ScreenSharing enable
        if stream.videoSourceType == .screenSharing,
           !UIConfig.screenShare.enable {
            return nil
        }
        
        let userId = stream.owner.userUuid
        
        // Widget object
        config.widgetId = widgetObjectId
        let widget = widgetController.create(config)
        widgets[widgetObjectId] = widget
        
        // zIndex
        var zIndex = widget.getZIndex()
        
        if stream.videoSourceType == .screenSharing {
            zIndex = 0
        }
        
        // Board privilege
        let boardPrivilege = hasBoardPrivilega(userId: userId)
        
        // Reward
        let reward = userController.getUserRewardCount(userUuid: userId)
        
        let item = FcrDetachedStreamWindowWidgetItem.create(widgetObjectId: widgetObjectId,
                                                            stream: stream,
                                                            rewardCount: reward,
                                                            boardPrivilege: boardPrivilege,
                                                            zIndex: zIndex)
        
        return item
    }
    
    func updateItemHierarchy(_ zIndex: Int,
                             index: Int) {
        var item = dataSource[index]
        
        guard let widget = widgets[item.widgetObjectId] else {
            return
        }
        
        item.zIndex = zIndex
        
        dataSource.remove(at: index)
        
        // Update view hierarchy
        let viewIndex = dataSource.insertItem(item)
        
        view.insertSubview(widget.view,
                           at: viewIndex)
    }
    
    func createAllItems() {
        guard let list = widgetController.getActiveWidgetList(widgetId: WindowWidgetId) else {
            return
        }
        
        for widgetObjectId in list {
            guard let item = createItem(widgetObjectId: widgetObjectId) else {
                continue
            }
            
            addItem(item,
                    animation: false)
        }
    }
    
    func deleteAllItems() {
        let array = dataSource
        
        for item in array {
            removeItem(item.widgetObjectId,
                       animation: false)
        }
    }
}

// MARK: - UI
private extension FcrDetachedStreamWindowUIComponent {
    internal func updateFrame(widgetObjectId: String,
                              syncFrame: AgoraWidgetFrame,
                              animation: Bool = false) {
        guard let widget = widgets[widgetObjectId] else {
            return
        }
        
        let frame = syncFrame.rectInView(view)
        
        syncFrames[widgetObjectId] = syncFrame
        
        if animation {
            UIView.animate(withDuration: TimeInterval.agora_animation,
                           delay: 0,
                           options: .curveEaseOut) {
                widget.view.frame = frame
            }
        } else {
            widget.view.frame = frame
        }
    }
    
    func addItemViewFrame(widgetObjectId: String,
                          widgetView: UIView,
                          userId: String,
                          zIndex: Int,
                          itemIndex: Int,
                          syncFrame: AgoraWidgetFrame,
                          animation: Bool = false) {
        let rect = syncFrame.rectInView(view)
        
        let originationFrame = delegate?.onNeedWindowRenderViewFrameOnTopWindow(userId: userId)
        
        if let `originationFrame` = originationFrame,
           animation {
            
            let topWindow = UIWindow.agora_top_window()
            
            topWindow.addSubview(widgetView)
            
            widgetView.frame = originationFrame
            
            let destinationFrame = view.convert(rect,
                                                to: topWindow)
            
            UIView.animate(withDuration: TimeInterval.agora_animation,
                           delay: 0,
                           options: .curveEaseOut) {
                widgetView.frame = destinationFrame
            } completion: { [weak self] isFinish in
                guard isFinish else {
                    return
                }
                
                guard let `self` = self,
                      // Avoid item was removed after animation
                      let index = self.dataSource.firstItemIndex(widgetObjectId: widgetObjectId)
                else {
                    widgetView.removeFromSuperview()
                    return
                }
                
                self.updateItemHierarchy(zIndex,
                                         index: index)

                widgetView.frame = rect
            }
        } else {
            updateItemHierarchy(zIndex,
                                index: itemIndex)
            
            widgetView.frame = rect
        }
    }
    
    func deleteViewFrame(widgetView: UIView,
                         userId: String,
                         animation: Bool = false,
                         completion: @escaping () -> Void) {
        let destinationFrame = delegate?.onNeedWindowRenderViewFrameOnTopWindow(userId: userId)
        
        if let `destinationFrame` = destinationFrame,
           animation {
            
            let topWindow = UIWindow.agora_top_window()
            
            let originationFrame = view.convert(widgetView.frame,
                                                to: topWindow)
            
            topWindow.addSubview(widgetView)
            
            widgetView.frame = originationFrame
            
            UIView.animate(withDuration: TimeInterval.agora_animation,
                           delay: 0,
                           options: .curveEaseOut) {
                widgetView.frame = destinationFrame
            } completion: { isFinish in
                guard isFinish else {
                    return
                }
                
                widgetView.removeFromSuperview()
                
                completion()
            }
        } else {
            widgetView.removeFromSuperview()
            
            completion()
        }
    }
    
    func updateRenderView(_ renderView: FcrWindowRenderView,
                          data: FcrStreamWindowViewData) {
        renderView.nameLabel.agora_visible = true
        renderView.micView.agora_visible = true
        renderView.nameLabel.agora_visible = true
        renderView.rewardView.agora_visible = true
        renderView.videoView.isHidden = !(data.videoState.isBoth)
        
        renderView.nameLabel.text = data.userName
        
        switch data.videoState {
        case .none(let image):
            renderView.videoMaskView.agora_visible = true
            renderView.videoMaskView.image = image
        case .hasStreamPublishPrivilege(let image):
            renderView.videoMaskView.agora_visible = true
            renderView.videoMaskView.image = image
        case .mediaSourceOpen(let image):
            renderView.videoMaskView.agora_visible = true
            renderView.videoMaskView.image = image
        case .both:
            renderView.videoMaskView.agora_visible = false
        }
        
        switch data.audioState {
        case .none(let image):
            renderView.micView.imageView.image = image
            renderView.updateVolume(0)
        case .hasStreamPublishPrivilege(let image):
            renderView.micView.imageView.image = image
            renderView.updateVolume(0)
        case .mediaSourceOpen(let image):
            renderView.micView.imageView.image = image
            renderView.updateVolume(0)
        case .both(let image):
            renderView.micView.imageView.image = image
        }
        
        switch data.boardPrivilege {
        case .none:
            renderView.boardPrivilegeView.agora_visible = false
        case .has(let image):
            renderView.boardPrivilegeView.agora_visible = true
            renderView.boardPrivilegeView.image = image
        }
        
        renderView.rewardView.imageView.image = data.reward.image
        renderView.rewardView.label.text = data.reward.count
        renderView.rewardView.isHidden = data.reward.isHidden
    }
    
    func createRenderView() -> FcrWindowRenderView {
        let renderView = FcrWindowRenderView(frame: .zero)
        
        let config = UIConfig.streamWindow
        renderView.backgroundColor = config.backgroundColor
        renderView.layer.cornerRadius = config.cornerRadius
        renderView.layer.borderWidth = config.borderWidth
        renderView.layer.borderColor = config.borderColor
        
        renderView.boardPrivilegeView.agora_visible = false
        renderView.micView.agora_visible = false
        renderView.nameLabel.agora_visible = false
        renderView.rewardView.agora_visible = false
        renderView.videoMaskView.agora_visible = false
        
        renderView.boardPrivilegeView.agora_visible = false
        renderView.micView.agora_visible = false
        renderView.nameLabel.agora_visible = false
        renderView.rewardView.agora_visible = false
        renderView.videoMaskView.agora_visible = false
        
        return renderView
    }
    
    func createViewData(with stream: AgoraEduContextStreamInfo) -> FcrStreamWindowViewData {
        let userId = stream.owner.userUuid
        
        let boardPrivilege = hasBoardPrivilega(userId: userId)
        
        let rewardCount = userController.getUserRewardCount(userUuid: userId)
        
        let data = FcrStreamWindowViewData.create(stream: stream,
                                                  rewardCount: rewardCount,
                                                  boardPrivilege: boardPrivilege)
        return data
    }
    
    func hasBoardPrivilega(userId: String) -> Bool {
        guard let userList = componentDataSource?.componentNeedGrantedUserList() else {
            return false
        }
        
        return userList.contains(userId)
    }
}

// MARK: - AgoraEduRoomHandler
extension FcrDetachedStreamWindowUIComponent: AgoraEduRoomHandler {
    func onJoinRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        viewWillActive()
    }
}

extension FcrDetachedStreamWindowUIComponent: AgoraEduSubRoomHandler {
    func onJoinSubRoomSuccess(roomInfo: AgoraEduContextSubRoomInfo) {
        viewWillActive()
    }
}

// MARK: - AgoraWidgetActivityObserver
extension FcrDetachedStreamWindowUIComponent: AgoraWidgetActivityObserver {
    public func onWidgetActive(_ widgetId: String) {
        guard let item = createItem(widgetObjectId: widgetId) else {
            return
        }
        
        let animation: Bool = (item.type == .camera)
        
        addItem(item,
                animation: animation)
    }
    
    public func onWidgetInactive(_ widgetId: String) {
        guard let item = getItem(widgetObjectId: widgetId) else {
            return
        }
        
        let animation: Bool = (item.type == .camera)
        
        removeItem(widgetId,
                   animation: animation)
    }
}

// MARK: - AgoraWidgetMessageObserver
extension FcrDetachedStreamWindowUIComponent: AgoraWidgetMessageObserver {
    func onMessageReceived(_ message: String,
                           widgetId: String) {
        guard let json = message.json(),
              let zIndex = json.keyPath("zIndex",
                                        result: Int.self)
        else {
            return
        }
        
        guard let index = dataSource.firstItemIndex(widgetObjectId: widgetId) else {
            return
        }
        
        let item = dataSource[index]
        
        guard item.zIndex != zIndex else {
            return
        }
        
        updateItemHierarchy(zIndex,
                            index: index)
    }
}

// MARK: - AgoraWidgetSyncFrameObserver
extension FcrDetachedStreamWindowUIComponent: AgoraWidgetSyncFrameObserver {
    func onWidgetSyncFrameUpdated(_ syncFrame: AgoraWidgetFrame,
                                  widgetId: String,
                                  operatorUser: AgoraWidgetUserInfo?) {
        guard let item = dataSource.firstItem(widgetObjectId: widgetId) else {
            return
        }
        
        updateFrame(widgetObjectId: widgetId,
                    syncFrame: syncFrame,
                    animation: true)
    }
}

// MARK: - AgoraEduStreamHandler
extension FcrDetachedStreamWindowUIComponent: AgoraEduStreamHandler {
    func onStreamUpdated(stream: AgoraEduContextStreamInfo,
                         operatorUser: AgoraEduContextUserInfo?) {
        guard let index = dataSource.firstItemIndex(streamId: stream.streamUuid) else {
            return
        }
        
        let data = createViewData(with: stream)
        
        updateItemData(data,
                       index: index)
    }
}

// MARK: - AgoraEduMediaHandler
extension FcrDetachedStreamWindowUIComponent: AgoraEduMediaHandler {
    func onVolumeUpdated(volume: Int,
                         streamUuid: String) {
        guard let renderView = renderViews[streamUuid] else {
            return
        }
        
        renderView.updateVolume(volume,
                                delay: true)
    }
}

extension FcrDetachedStreamWindowUIComponent: AgoraEduUserHandler {
    func onUserHandsWave(userUuid: String,
                         duration: Int,
                         payload: [String : Any]?) {
        guard let item = dataSource.firstCameraItem(userId: userUuid),
              let renderView = renderViews[item.data.streamId]
        else {
            return
        }
        
        renderView.startWaving()
    }
    
    func onUserHandsDown(userUuid: String,
                         payload: [String : Any]?) {
        guard let item = dataSource.firstCameraItem(userId: userUuid),
              let renderView = renderViews[item.data.streamId]
        else {
            return
        }
        
        renderView.stopWaving()
    }
    
    func onUserRewarded(user: AgoraEduContextUserInfo,
                        rewardCount: Int,
                        operatorUser: AgoraEduContextUserInfo?) {
        guard let index = dataSource.firstCameraItemIndex(userId: user.userUuid) else {
            return
        }
        
        var item = dataSource[index]
        
        item.data.reward = FcrRewardViewData.create(count: rewardCount,
                                                    isHidden: false)
        
        dataSource[index] = item
        
        updateItemData(item.data,
                       index: index)
    }
}

fileprivate extension Array where Element == FcrDetachedStreamWindowWidgetItem {
    func firstItemIndex(widgetObjectId: String) -> Int? {
        return firstIndex(where: {return $0.widgetObjectId == widgetObjectId})
    }
    
    func firstItem(widgetObjectId: String) -> FcrDetachedStreamWindowWidgetItem? {
        return first(where: {return $0.widgetObjectId == widgetObjectId})
    }
    
    func firstCameraItem(userId: String) -> FcrDetachedStreamWindowWidgetItem? {
        let item = first { item in
            guard item.type == .camera else {
                return false
            }
            
            return (item.data.userId == userId)
        }
        
        return item
    }
    
    func firstCameraItemIndex(userId: String) -> Int? {
        let index = firstIndex { item in
            guard item.type == .camera else {
                return false
            }
            
            return (item.data.userId == userId)
        }
        
        return index
    }
    
    internal func firstItem(streamId: String) -> FcrDetachedStreamWindowWidgetItem? {
        return first(where: {return $0.data.streamId == streamId})
    }
    
    func firstItemIndex(streamId: String) -> Int? {
        return firstIndex(where: {return $0.data.streamId == streamId})
    }
    
    mutating func insertItem(_ item: FcrDetachedStreamWindowWidgetItem) -> Int {
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
}

fileprivate extension AgoraBaseWidget {
    func getZIndex() -> Int {
        guard let properties = info.roomProperties else {
            return 0
        }
        var zIndex = Int(info.syncFrame.z)
        if let index = properties.keyPath("zIndex",
                                          result: Int.self) {
            zIndex = index
        }
        return zIndex
    }
}

fileprivate extension AgoraEduWidgetContext {
    func getStreamWidgetSyncFrame(_ widgetId: String) -> AgoraWidgetFrame {
        var syncFrame = getWidgetSyncFrame(widgetId)
        
        if syncFrame.width == 0,
           syncFrame.height == 0 {
            syncFrame = AgoraWidgetFrame(x: 0,
                                         y: 0,
                                         z: 0,
                                         width: 1,
                                         height: 1)
        }
        
        return syncFrame
    }
}
