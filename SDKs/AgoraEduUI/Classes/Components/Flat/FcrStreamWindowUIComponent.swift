//
//  FcrStreamWindowUIController.swift
//  AgoraEduUI
//
//  Created by Cavan on 2022/6/15.
//

import AgoraUIBaseViews
import AgoraEduContext
import AgoraWidget

protocol FcrStreamWindowUIComponentDelegate: NSObjectProtocol {
    func onNeedWindowRenderViewFrameOnTopWindow(userId: String) -> CGRect?
    func onWillStartRenderVideoStream(streamId: String)
    func onDidStopRenderVideoStream(streamId: String)
}

class FcrStreamWindowUIComponent: UIViewController {
    public let roomController: AgoraEduRoomContext
    public let userController: AgoraEduUserContext
    public let streamController: AgoraEduStreamContext
    private(set) var mediaController: AgoraEduMediaContext
    public let widgetController: AgoraEduWidgetContext
    public var subRoom: AgoraEduSubRoomContext?
    
    // For lecture
    internal var roomId: String {
        if let `subRoom` = subRoom {
            return subRoom.getSubRoomInfo().subRoomUuid
        } else {
            return roomController.getRoomInfo().roomUuid
        }
    }
    // For lecture
    private weak var delegate: FcrStreamWindowUIComponentDelegate?

    // dataSource index is equal to view.subViews index
    private(set) var dataSource = [FcrStreamWindowWidgetItem]() {
        didSet {
            view.isHidden = (dataSource.count == 0)
        }
    }
        
    private weak var componentDataSource: FcrUIComponentDataSource?
    
    init(roomController: AgoraEduRoomContext,
         userController: AgoraEduUserContext,
         streamController: AgoraEduStreamContext,
         mediaController: AgoraEduMediaContext,
         widgetController: AgoraEduWidgetContext,
         subRoom: AgoraEduSubRoomContext? = nil,
         delegate: FcrStreamWindowUIComponentDelegate? = nil,
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
    
    public func onAddedRenderWidget(widgetView: UIView) {
        // 给子类重写来对widget view 进行操作
    }
}

extension FcrStreamWindowUIComponent: AgoraUIActivity {
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
extension FcrStreamWindowUIComponent {
    func updateItemData(_ data: FcrWindowRenderViewData,
                        index: Int) {
        var item = dataSource[index]
        guard item.data != data,
              let renderView = item.renderView
        else {
            return
        }
        item.data = data
        updateRenderView(renderView,
                         data: data)
    }
    
    func onWillDisplayItem(_ item: FcrStreamWindowWidgetItem,
                           renderView: FcrWindowRenderVideoView) {
        let renderConfig = AgoraEduContextRenderConfig()
        
        switch item.type {
        case .camera:
            renderConfig.mode = .hidden
        case .screen:
            renderConfig.mode = .fit
        default:
            break
        }
        
        let streamId = item.data.streamId
        
        delegate?.onWillStartRenderVideoStream(streamId: streamId)
        
        mediaController.startRenderVideo(roomUuid: roomId,
                                         view: renderView,
                                         renderConfig: renderConfig,
                                         streamUuid: streamId)
    }
    
    func onDidEndDisplayingItem(_ item: FcrStreamWindowWidgetItem) {
        let streamId = item.data.streamId
        
        mediaController.stopRenderVideo(roomUuid: roomId,
                                        streamUuid: streamId)
        
        delegate?.onDidStopRenderVideoStream(streamId: streamId)
    }
}

// MARK: - Private Item
private extension FcrStreamWindowUIComponent {
    func addItem(_ item: FcrStreamWindowWidgetItem,
                 animation: Bool = true) {
        guard dataSource.contains(where: {$0.widgetId == item.widgetId}) == false else {
            return
        }
        dataSource.append(item)
        guard let widget = item.widget else {
            return
        }
        // FcrWindowRenderView
        let renderView = createRenderView()
        
        widget.view.addSubview(renderView)
        
        renderView.mas_makeConstraints { make in
            make?.right.left().top().bottom().equalTo()(0)
        }
        item.renderView = renderView
        if item.type == .camera {
            updateRenderView(renderView,
                             data: item.data)
        }
        onWillDisplayItem(item,
                          renderView: renderView.videoView)
        // Frame & Animation
        let itemIndex = (dataSource.count - 1)
        
        addItemViewFrame(widgetView: widget.view,
                         widgetId: item.widgetId,
                         userId: item.data.userId,
                         zIndex: item.zIndex,
                         itemIndex: itemIndex,
                         animation: animation)
        
        // Observe widget event
        widgetController.add(self,
                             widgetId: item.widgetId)
        
        widgetController.addObserver(forWidgetSyncFrame: self,
                                     widgetId: item.widgetId)
        onAddedRenderWidget(widgetView: widget.view)
    }
    
    func removeItem(_ widgetId: String,
                    animation: Bool = true) {
        guard let item = dataSource.first(where: {$0.widgetId == widgetId}) else {
            return
        }
        dataSource.removeAll(where: {$0.widgetId == widgetId})
        guard let widget = item.widget else {
            return
        }
        // Frame & Animation
        deleteViewFrame(widgetView: widget.view,
                        userId: item.data.userId,
                        animation: animation) { [weak self] in
            guard let `self` = self else {
                return
            }
            // Stop render video stream
            self.onDidEndDisplayingItem(item)
        }
        
        // Cancel observe widget event
        widgetController.remove(self,
                                widgetId: item.widgetId)
        
        widgetController.removeObserver(forWidgetSyncFrame: self,
                                        widgetId: item.widgetId)
    }
    
    func createItem(widgetId: String) -> FcrStreamWindowWidgetItem? {
        guard UIConfig.streamWindow.enable,
              widgetId.hasPrefix(WindowWidgetId),
              dataSource.firstItem(widgetId: widgetId) == nil,
              let config = widgetController.getWidgetConfig(WindowWidgetId),
              let streamId = widgetId.splitStreamId(),
              let streamList = streamController.getAllStreamList(),
              let stream = streamList.first(where: {$0.streamUuid == streamId}) else {
            return nil
        }
        
        if stream.videoSourceType == .screen,
           !UIConfig.screenShare.enable {
            return nil
        }
        
        let userId = stream.owner.userUuid
        
        // Widget object
        config.widgetId = widgetId
        let widget = widgetController.create(config)
        // zIndex
        var zIndex = widget.getZIndex()
        if stream.videoSourceType == .screen {
            zIndex = 0
        }
        // Board privilege
        var boardPrivilege: Bool = false
        if let userList = componentDataSource?.componentNeedGrantedUserList(),
           userList.contains(userId) {
            boardPrivilege = true
        }
        // Reward
        let reward = userController.getUserRewardCount(userUuid: userId)
        let item = FcrStreamWindowWidgetItem.create(widgetId: widgetId,
                                                    stream: stream,
                                                    rewardCount: reward,
                                                    boardPrivilege: boardPrivilege,
                                                    zIndex: zIndex)
        item.widget = widget
        return item
    }
    
    func updateItemHierarchy(_ zIndex: Int,
                             index: Int) {
        var item = dataSource[index]
        guard let widget = item.widget else {
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
        for widgetId in list {
            guard let item = createItem(widgetId: widgetId) else {
                continue
            }
            addItem(item,
                    animation: false)
        }
    }
    
    func deleteAllItems() {
        let array = dataSource
        for item in array {
            removeItem(item.widgetId,
                       animation: false)
        }
    }
}

// MARK: - UI
private extension FcrStreamWindowUIComponent {
    func updateFrame(widgetObjectId: String,
                     syncFrame: AgoraWidgetFrame,
                     animation: Bool = false) {
        guard let widget = dataSource.first(where: {$0.widgetId == widgetObjectId})?.widget else {
            return
        }
        let frame = syncFrame.rectInView(view)
        if animation {
            UIView.animate(withDuration: TimeInterval.agora_animation) {
                widget.view.frame = frame
            }
        } else {
            widget.view.frame = frame
        }
    }
        
    func addItemViewFrame(widgetView: UIView,
                          widgetId: String,
                          userId: String,
                          zIndex: Int,
                          itemIndex: Int,
                          animation: Bool = false) {
        var syncFrame = widgetController.getWidgetSyncFrame(widgetId)
        if syncFrame.width == 0,
           syncFrame.height == 0 {
            syncFrame = AgoraWidgetFrame(x: 0,
                                         y: 0,
                                         z: 0,
                                         width: 1,
                                         height: 1)
        }
        let rect = syncFrame.rectInView(view)
        if animation,
           let originationFrame = delegate?.onNeedWindowRenderViewFrameOnTopWindow(userId: userId) {
            let topWindow = UIWindow.agora_top_window()
            topWindow.addSubview(widgetView)
            widgetView.frame = originationFrame
            let destinationFrame = view.convert(rect,
                                                to: topWindow)
            UIView.animate(withDuration: TimeInterval.agora_animation) {
                widgetView.frame = destinationFrame
            } completion: { isFinish in
                guard isFinish else {
                    return
                }
                self.updateItemHierarchy(zIndex,
                                         index: itemIndex)
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
        if let destinationFrame = delegate?.onNeedWindowRenderViewFrameOnTopWindow(userId: userId),
           animation {
            
            let topWindow = UIWindow.agora_top_window()
            let originationFrame = view.convert(widgetView.frame,
                                                to: topWindow)
            
            topWindow.addSubview(widgetView)
            widgetView.frame = originationFrame
            
            UIView.animate(withDuration: TimeInterval.agora_animation) {
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
                          data: FcrWindowRenderViewData) {
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
    
    func createViewData(with stream: AgoraEduContextStreamInfo) -> FcrWindowRenderViewData {
        var boardPrivilege: Bool = false
        let userId = stream.owner.userUuid
        if let userList = componentDataSource?.componentNeedGrantedUserList(),
           userList.contains(userId),
           stream.owner.userRole != .teacher  {
            boardPrivilege = true
        }
        let rewardCount = userController.getUserRewardCount(userUuid: userId)
        let data = FcrWindowRenderViewData.create(stream: stream,
                                                  rewardCount: rewardCount,
                                                  boardPrivilege: boardPrivilege)
        return data
    }
}

// MARK: - AgoraEduRoomHandler
extension FcrStreamWindowUIComponent: AgoraEduRoomHandler {
    func onJoinRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        viewWillActive()
    }
}

extension FcrStreamWindowUIComponent: AgoraEduSubRoomHandler {
    func onJoinSubRoomSuccess(roomInfo: AgoraEduContextSubRoomInfo) {
        viewWillActive()
    }
}

// MARK: - AgoraWidgetActivityObserver
extension FcrStreamWindowUIComponent: AgoraWidgetActivityObserver {
    public func onWidgetActive(_ widgetId: String) {
        guard let item = createItem(widgetId: widgetId) else {
            return
        }
        let animation: Bool = (item.type == .camera)
        addItem(item,
                animation: animation)
    }
    
    public func onWidgetInactive(_ widgetId: String) {
        guard let item = dataSource.firstItem(widgetId: widgetId) else {
            return
        }
        let animation: Bool = (item.type == .camera)
        removeItem(widgetId,
                   animation: animation)
    }
}

// MARK: - AgoraWidgetMessageObserver
extension FcrStreamWindowUIComponent: AgoraWidgetMessageObserver {
    func onMessageReceived(_ message: String,
                           widgetId: String) {
        guard let json = message.json(),
              let zIndex = json.keyPath("zIndex",
                                        result: Int.self) else {
            return
        }
        guard let index = dataSource.firstItemIndex(widgetId: widgetId) else {
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
extension FcrStreamWindowUIComponent: AgoraWidgetSyncFrameObserver {
    func onWidgetSyncFrameUpdated(_ syncFrame: AgoraWidgetFrame,
                                  widgetId: String,
                                  operatorUser: AgoraWidgetUserInfo?) {
        guard operatorUser?.userUuid != userController.getLocalUserInfo().userUuid,
              let item = dataSource.firstItem(widgetId: widgetId) else {
            return
        }
        updateFrame(widgetObjectId: widgetId,
                    syncFrame: syncFrame,
                    animation: true)
    }
}

// MARK: - AgoraEduStreamHandler
extension FcrStreamWindowUIComponent: AgoraEduStreamHandler {
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
extension FcrStreamWindowUIComponent: AgoraEduMediaHandler {
    func onVolumeUpdated(volume: Int,
                         streamUuid: String) {
        guard let renderView = dataSource.first(where: {$0.streamId == streamUuid})?.renderView else {
            return
        }
        
        renderView.updateVolume(volume,
                                delay: true)
    }
}

extension FcrStreamWindowUIComponent: AgoraEduUserHandler {
    func onUserHandsWave(userUuid: String,
                         duration: Int,
                         payload: [String : Any]?) {
        guard let item = dataSource.firstCameraItem(userId: userUuid),
              let renderView = item.renderView
        else {
            return
        }
        
        renderView.startWaving()
    }
    
    func onUserHandsDown(userUuid: String,
                         payload: [String : Any]?) {
        guard let item = dataSource.firstCameraItem(userId: userUuid),
              let renderView = item.renderView
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
        
        updateItemData(item.data,
                       index: index)
    }
}

fileprivate extension Array where Element == FcrStreamWindowWidgetItem {
    func firstItemIndex(widgetId: String) -> Int? {
        return firstIndex(where: {return $0.widgetId == widgetId})
    }
    
    func firstItem(widgetId: String) -> FcrStreamWindowWidgetItem? {
        return first(where: {return $0.widgetId == widgetId})
    }
    
    func firstCameraItem(userId: String) -> FcrStreamWindowWidgetItem? {
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
    
    func firstItem(streamId: String) -> FcrStreamWindowWidgetItem? {
        return first(where: {return $0.data.streamId == streamId})
    }
    
    func firstItemIndex(streamId: String) -> Int? {
        return firstIndex(where: {return $0.data.streamId == streamId})
    }
    
    mutating func insertItem(_ item: FcrStreamWindowWidgetItem) -> Int {
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
