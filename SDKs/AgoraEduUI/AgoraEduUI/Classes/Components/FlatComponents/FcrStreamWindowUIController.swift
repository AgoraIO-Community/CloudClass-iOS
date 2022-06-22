//
//  FcrStreamWindowUIController.swift
//  AgoraEduUI
//
//  Created by Cavan on 2022/6/15.
//

import AgoraUIBaseViews
import AgoraEduContext
import AgoraWidget

protocol FcrStreamWindowUIControllerDelegate: NSObjectProtocol {
    func onNeedWindowRenderViewFrameOnTopWindow(userId: String) -> CGRect?
    func onWillStartRenderVideoStream(streamId: String)
    func onDidStopRenderVideoStream(streamId: String)
}

class FcrStreamWindowUIController: UIViewController {
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

    // For lecture
    internal var roomId: String {
        if let `subRoom` = subRoom {
            return subRoom.getSubRoomInfo().subRoomUuid
        } else {
            return contextPool.room.getRoomInfo().roomUuid
        }
    }

    private var subRoom: AgoraEduSubRoomContext?
    
    // For lecture
    let contextPool: AgoraEduContextPool
    
    private weak var delegate: FcrStreamWindowUIControllerDelegate?

    // dataSource index is equal to view.subViews index
    private(set) var dataSource = [FcrStreamWindowWidgetItem]() {
        didSet {
            view.isHidden = (dataSource.count == 0)
        }
    }
    
    private var renderViews = [String: FcrWindowRenderView]() // Key: streamId
    private var widgets = [String: AgoraBaseWidget]()         // Key: widget object Id
    
    private let zIndexKey = "zIndex"
//    private let userIdKey = "userUuid"
    
    private weak var controllerDataSource: FcrUIControllerDataSource?
    
    init(context: AgoraEduContextPool,
         subRoom: AgoraEduSubRoomContext? = nil,
         delegate: FcrStreamWindowUIControllerDelegate? = nil,
         controllerDataSource: FcrUIControllerDataSource? = nil) {
        self.contextPool = context
        self.subRoom = subRoom
        self.delegate = delegate
        self.controllerDataSource = controllerDataSource
        
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
            contextPool.room.registerRoomEventHandler(self)
        }
        
        contextPool.media.registerMediaEventHandler(self)
    }
}

extension FcrStreamWindowUIController: AgoraUIActivity {
    func viewWillActive() {
        widgetController.add(self)
        userController.registerUserEventHandler(self)
        streamController.registerStreamEventHandler(self)
        createAllItems()
        
        guard dataSource.count > 0 else {
            return
        }
        
        view.isHidden = false
    }
    
    func viewWillInactive() {
        widgetController.remove(self)
        userController.unregisterUserEventHandler(self)
        streamController.unregisterStreamEventHandler(self)
        deleteAllItems()
        
        view.isHidden = true
    }
}

// MARK: - Public Item
extension FcrStreamWindowUIController {
    func updateItemData(_ data: FcrWindowRenderViewData,
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
        
        contextPool.media.startRenderVideo(roomUuid: roomId,
                                           view: renderView,
                                           renderConfig: renderConfig,
                                           streamUuid: streamId)
    }
    
    func onDidEndDisplayingItem(_ item: FcrStreamWindowWidgetItem) {
        let streamId = item.data.streamId
        
        contextPool.media.stopRenderVideo(roomUuid: roomId,
                                          streamUuid: streamId)
        
        delegate?.onDidStopRenderVideoStream(streamId: streamId)
    }
}

// MARK: - Private Item
private extension FcrStreamWindowUIController {
    func addItem(_ item: FcrStreamWindowWidgetItem,
                 animation: Bool = true) {
        if let prevItem = dataSource.firstItem(widgetObjectId: item.widgetObjectId) {
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
        
        // Frame & Animation
        let itemIndex = (dataSource.count - 1)
        
        createWidgetViewFrame(widgetView: widget.view,
                              widgetObjectId: item.widgetObjectId,
                              userId: item.data.userId,
                              zIndex: item.zIndex,
                              itemIndex: itemIndex,
                              animation: animation)
        
        // Observe widget event
        widgetController.add(self,
                             widgetId: item.widgetObjectId)
        
        widgetController.addObserver(forWidgetSyncFrame: self,
                                     widgetId: item.widgetObjectId)
    }
    
    func removeItem(_ widgetObjectId: String,
                    animation: Bool = true) {
        guard let index = dataSource.firstItemIndex(widgetObjectId: widgetObjectId),
              let widget = widgets[widgetObjectId] else {
            return
        }
        
        // FcrWindowWidgetItem
        let item = dataSource[index]
        dataSource.remove(at: index)
        
        // Widget
        widgets.removeValue(forKey: item.widgetObjectId)
        
        // Frame & Animation
        releaseWidgetViewFrame(widgetView: widget.view,
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
    
    func createItem(widgetObjectId: String) -> FcrStreamWindowWidgetItem? {
        guard widgetObjectId.hasPrefix(WindowWidgetId),
              dataSource.firstItem(widgetObjectId: widgetObjectId) == nil,
              let config = widgetController.getWidgetConfig(WindowWidgetId),
              let streamId = widgetObjectId.splitStreamId(),
              let streamList = streamController.getAllStreamList(),
              let stream = streamList.first(where: {$0.streamUuid == streamId}) else {
            return nil
        }
        
        let userId = stream.owner.userUuid
        
        // Widget object
        config.widgetId = widgetObjectId
        
        let widget = widgetController.create(config)
        widgets[widgetObjectId] = widget
        
        // zIndex
        var zIndex = widget.getZIndex()
        
        if stream.videoSourceType == .screen {
            zIndex = 0
        }
        
        // Board privilege
        var boardPrivilege: Bool = false
        
        if let userList = controllerDataSource?.controllerNeedGrantedUserList(),
           userList.contains(userId) {
            boardPrivilege = true
        }
        
        // Reward
        let reward = userController.getUserRewardCount(userUuid: userId)
        
        let item = FcrStreamWindowWidgetItem.create(widgetObjectId: widgetObjectId,
                                                    stream: stream,
                                                    rewardCount: reward,
                                                    boardPrivilege: boardPrivilege,
                                                    zIndex: zIndex)
        
        return item
    }
}

// MARK: - Widget create & relase
private extension FcrStreamWindowUIController {
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
    
    func createViewData(with stream: AgoraEduContextStreamInfo) -> FcrWindowRenderViewData {
        var boardPrivilege: Bool = false
        
        let userId = stream.owner.userUuid
        
        if let userList = controllerDataSource?.controllerNeedGrantedUserList(),
           userList.contains(userId) {
            boardPrivilege = true
        }
        
        let rewardCount = userController.getUserRewardCount(userUuid: userId)
        
        let data = FcrWindowRenderViewData.create(stream: stream,
                                                  rewardCount: rewardCount,
                                                  boardPrivilege: boardPrivilege)
        
        return data
    }
}

extension FcrStreamWindowUIController {
    func updateFrame(widgetObjectId: String,
                     syncFrame: CGRect,
                     animation: Bool = false) {
        guard let widget = widgets[widgetObjectId] else {
            return
        }
        
        let frame = syncFrame.displayFrameFromSyncFrame(superView: view)
        
        if animation {
            UIView.animate(withDuration: TimeInterval.agora_animation) {
                widget.view.frame = frame
            }
        } else {
            widget.view.frame = frame
        }
    }
        
    func createWidgetViewFrame(widgetView: UIView,
                               widgetObjectId: String,
                               userId: String,
                               zIndex: Int,
                               itemIndex: Int,
                               animation: Bool = false) {
        var syncFrame = widgetController.getWidgetSyncFrame(widgetObjectId)
        
        if syncFrame == .zero {
            syncFrame = CGRect(x: 0,
                               y: 0,
                               width: 1,
                               height: 1)
        }
        
        let displayFrame = syncFrame.displayFrameFromSyncFrame(superView: view)
        
        if animation,
           let originationFrame = delegate?.onNeedWindowRenderViewFrameOnTopWindow(userId: userId) {
            
            let topWindow = UIWindow.ag_topWindow()
            topWindow.addSubview(widgetView)
            
            widgetView.frame = originationFrame
            
            let destinationFrame = view.convert(displayFrame,
                                                to: topWindow)
            
            UIView.animate(withDuration: TimeInterval.agora_animation) {
                widgetView.frame = destinationFrame
            } completion: { isFinish in
                guard isFinish else {
                    return
                }
                
                self.updateItemHierarchy(zIndex,
                                         index: itemIndex)
                
                widgetView.frame = displayFrame
            }
        } else {
            updateItemHierarchy(zIndex,
                                index: itemIndex)
            widgetView.frame = displayFrame
        }
    }
    
    func releaseWidgetViewFrame(widgetView: UIView,
                                userId: String,
                                animation: Bool = false,
                                completion: @escaping () -> Void) {
        if let destinationFrame = delegate?.onNeedWindowRenderViewFrameOnTopWindow(userId: userId),
           animation {
            
            let topWindow = UIWindow.ag_topWindow()
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
        renderView.nameLabel.isHidden = false
        renderView.micView.isHidden = false
        renderView.nameLabel.isHidden = false
        renderView.rewardView.isHidden = false
        renderView.videoView.isHidden = !(data.videoState.isBoth)
        
        renderView.nameLabel.text = data.userName
        
        switch data.videoState {
        case .none(let image):
            renderView.videoMaskView.isHidden = false
            renderView.videoMaskView.image = image
        case .hasStreamPublishPrivilege(let image):
            renderView.videoMaskView.isHidden = false
            renderView.videoMaskView.image = image
        case .mediaSourceOpen(let image):
            renderView.videoMaskView.isHidden = false
            renderView.videoMaskView.image = image
        case .both:
            renderView.videoMaskView.isHidden = true
        }
        
        switch data.audioState {
        case .none(let image):
            renderView.micView.imageView.image = image
            renderView.micView.updateVolume(0)
        case .hasStreamPublishPrivilege(let image):
            renderView.micView.imageView.image = image
            renderView.micView.updateVolume(0)
        case .mediaSourceOpen(let image):
            renderView.micView.imageView.image = image
            renderView.micView.updateVolume(0)
        case .both(let image):
            renderView.micView.imageView.image = image
        }
        
        switch data.boardPrivilege {
        case .none:
            renderView.boardPrivilegeView.isHidden = true
        case .has(let image):
            renderView.boardPrivilegeView.isHidden = false
            renderView.boardPrivilegeView.image = image
        }
        
        renderView.rewardView.imageView.image = data.reward.image
        renderView.rewardView.label.text = data.reward.count
        renderView.rewardView.isHidden = data.reward.isHidden
    }
    
    func createRenderView() -> FcrWindowRenderView {
        let renderView = FcrWindowRenderView(frame: .zero)
        let ui = AgoraUIGroup()
        
        renderView.backgroundColor = ui.color.render_cell_bg_color
        renderView.layer.cornerRadius = ui.frame.render_cell_corner_radius
        renderView.layer.borderWidth = ui.frame.render_cell_border_width
        renderView.layer.borderColor = ui.color.render_mask_border_color
        
        renderView.boardPrivilegeView.isHidden = true
        renderView.micView.isHidden = true
        renderView.nameLabel.isHidden = true
        renderView.rewardView.isHidden = true
        renderView.videoMaskView.isHidden = true
        
        return renderView
    }
}

// MARK: - AgoraEduRoomHandler
extension FcrStreamWindowUIController: AgoraEduRoomHandler {
    func onJoinRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        viewWillActive()
    }
}

extension FcrStreamWindowUIController: AgoraEduSubRoomHandler {
    func onJoinSubRoomSuccess(roomInfo: AgoraEduContextSubRoomInfo) {
        viewWillActive()
    }
}

// MARK: - AgoraWidgetActivityObserver
extension FcrStreamWindowUIController: AgoraWidgetActivityObserver {
    public func onWidgetActive(_ widgetId: String) {
        guard let item = createItem(widgetObjectId: widgetId) else {
            return
        }
        
        let animation: Bool = (item.type == .camera)
        
        addItem(item,
                animation: animation)
    }
    
    public func onWidgetInactive(_ widgetId: String) {
        guard let item = dataSource.firstItem(widgetObjectId: widgetId) else {
            return
        }
        
        let animation: Bool = (item.type == .camera)
        
        removeItem(widgetId,
                   animation: animation)
    }
}

// MARK: - AgoraWidgetMessageObserver
extension FcrStreamWindowUIController: AgoraWidgetMessageObserver {
    func onMessageReceived(_ message: String,
                           widgetId: String) {
        guard let json = message.json(),
              let zIndex = json.keyPath(zIndexKey,
                                        result: Int.self) else {
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
extension FcrStreamWindowUIController: AgoraWidgetSyncFrameObserver {
    func onWidgetSyncFrameUpdated(_ syncFrame: CGRect,
                                  widgetId: String,
                                  operatorUser: AgoraWidgetUserInfo?) {
        guard operatorUser?.userUuid != userController.getLocalUserInfo().userUuid,
              let item = dataSource.firstItem(widgetObjectId: widgetId) else {
            return
        }
        
        updateFrame(widgetObjectId: widgetId,
                    syncFrame: syncFrame,
                    animation: true)
    }
}

// MARK: - AgoraEduStreamHandler
extension FcrStreamWindowUIController: AgoraEduStreamHandler {
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
extension FcrStreamWindowUIController: AgoraEduMediaHandler {
    func onVolumeUpdated(volume: Int,
                         streamUuid: String) {
        guard let renderView = renderViews[streamUuid] else {
            return
        }
        
        renderView.updateVolume(volume)
    }
}

extension FcrStreamWindowUIController: AgoraEduUserHandler {
    func onUserHandsWave(userUuid: String,
                         duration: Int,
                         payload: [String : Any]?) {
        guard let item = dataSource.firstCameraItem(userId: userUuid),
              let renderView = renderViews[item.data.streamId] else {
            return
        }
        
        renderView.startWaving()
    }
    
    func onUserHandsDown(userUuid: String,
                         payload: [String : Any]?) {
        guard let item = dataSource.firstCameraItem(userId: userUuid),
              let renderView = renderViews[item.data.streamId] else {
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
    func firstItemIndex(widgetObjectId: String) -> Int? {
        return firstIndex(where: {return $0.widgetObjectId == widgetObjectId})
    }
    
    func firstItem(widgetObjectId: String) -> FcrStreamWindowWidgetItem? {
        return first(where: {return $0.widgetObjectId == widgetObjectId})
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
        var zIndex: Int = 0
        
        guard let properties = info.roomProperties else {
            return zIndex
        }
        
        let zIndexKey = "zIndex"
        
        if let index = properties.keyPath(zIndexKey,
                                          result: Int.self) {
            zIndex = index
        }
        
        return zIndex
    }
}
