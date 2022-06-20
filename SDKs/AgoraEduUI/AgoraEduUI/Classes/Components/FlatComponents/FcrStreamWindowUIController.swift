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

    // widgetArray index is equal to view.subViews index
    private var widgetArray = [FcrWindowWidgetItem]() {
        didSet {
            view.isHidden = (widgetArray.count == 0)
        }
    }
    
    private var renderViewList = [String: FcrWindowRenderView]() // Key: streamId
    
    private let zIndexKey = "zIndex"
    private let userIdKey = "userUuid"
    
    init(context: AgoraEduContextPool,
         subRoom: AgoraEduSubRoomContext? = nil,
         delegate: FcrStreamWindowUIControllerDelegate? = nil) {
        self.contextPool = context
        self.subRoom = subRoom
        self.delegate = delegate
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

// MARK: - Widget create & relase
private extension FcrStreamWindowUIController {
    func createAllActiveWidgets() {
        guard let list = widgetController.getActiveWidgetList(widgetId: WindowWidgetId) else {
            return
        }
        
        for widgetObjectId in list {
            createWidget(widgetObjectId)
        }
    }
    
    func releaseAllWidgets() {
        for item in widgetArray {
            releaseWidget(item.widgetObjectId)
        }
    }
    
    func createWidget(_ widgetObjectId: String,
                      animation: Bool = false) {
        guard widgetObjectId.hasPrefix(WindowWidgetId),
              widgetArray.firstItem(widgetObjectId: widgetObjectId) == nil,
              let config = widgetController.getWidgetConfig(WindowWidgetId),
              let streamId = widgetObjectId.splitStreamId(),
              let streamList = streamController.getAllStreamList(),
              let stream = streamList.first(where: {$0.streamUuid == streamId}) else {
            return
        }
        
        // Widget object
        config.widgetId = widgetObjectId
        
        let widget = widgetController.create(config)
        
        // Properties
        guard let properties = widget.info.roomProperties else {
            return
        }
        
        var zIndex: Int = 0
        
        if let index = properties.keyPath(zIndexKey,
                                          result: Int.self) {
            zIndex = index
        }
        
        if stream.videoSourceType == .screen {
            zIndex = 0
        }
        
        guard let userId = properties.keyPath(userIdKey,
                                              result: String.self) else {
            return
        }
        
        // FcrWindowWidgetItem
        let item = FcrWindowWidgetItem(widgetObjectId: widgetObjectId,
                                       owner: userId,
                                       streamId: streamId,
                                       videoSourceType: stream.videoSourceType,
                                       object: widget,
                                       zIndex: zIndex)
        
        widgetArray.append(item)
        
        // FcrWindowRenderView
        let renderView = createRenderView()
        
        widget.view.addSubview(renderView)
        
        renderView.mas_makeConstraints { make in
            make?.right.left().top().bottom().equalTo()(0)
        }
        
        renderViewList[streamId] = renderView
        
        let data = createViewData(with: stream)
        
        updateRenderView(renderView,
                         stream: stream)
        
        // Start render Video
        let renderConfig = AgoraEduContextRenderConfig()
        
        switch stream.videoSourceType {
        case .camera:
            renderConfig.mode = .hidden
        case .screen:
            renderConfig.mode = .fit
        default:
            break
        }
        
        delegate?.onWillStartRenderVideoStream(streamId: streamId)
        
        contextPool.media.startRenderVideo(roomUuid: roomId,
                                           view: renderView.videoView,
                                           renderConfig: renderConfig,
                                           streamUuid: streamId)
        
        // Frame & Animation
        let isCameraStream = (stream.videoSourceType == .camera)
        
        var hasAnimation = animation
        
        if !isCameraStream {
            hasAnimation = false
        }
        
        createWidgetViewFrame(widget: widget,
                              userId: userId,
                              zIndex: zIndex,
                              animation: hasAnimation)
        
        // Observe widget event
        widgetController.add(self,
                             widgetId: widgetObjectId)
        
        widgetController.addObserver(forWidgetSyncFrame: self,
                                     widgetId: widgetObjectId)
    }
    
    func releaseWidget(_ widgetObjectId: String,
                       animation: Bool = false) {
        guard let index = widgetArray.firstItemIndex(widgetObjectId: widgetObjectId) else {
            return
        }
        
        // FcrWindowWidgetItem
        let item = widgetArray[index]
        widgetArray.remove(at: index)
        
        let isCameraStream = (item.videoSourceType == .camera)
        
        var hasAnimation = animation
        
        if !isCameraStream {
            hasAnimation = false
        }
        
        // Frame & Animation
        releaseWidgetViewFrame(widget: item.object,
                               userId: item.owner,
                               animation: hasAnimation) { [weak self] in
            guard let `self` = self else {
                return
            }
            
            // Stop render video stream
            self.contextPool.media.stopRenderVideo(roomUuid: self.roomId,
                                                   streamUuid: item.streamId)
            
            self.delegate?.onDidStopRenderVideoStream(streamId: item.streamId)
        }
        
        renderViewList.removeValue(forKey: item.streamId)
        
        // Cancel observe widget event
        widgetController.remove(self,
                                widgetId: widgetObjectId)
        
        widgetController.removeObserver(forWidgetSyncFrame: self,
                                        widgetId: widgetObjectId)
    }
    
    func createViewData(with stream: AgoraEduContextStreamInfo) -> FcrWindowRenderViewData {
        let rewardCount = contextPool.user.getUserRewardCount(userUuid: stream.owner.userUuid)
        
        let data = FcrWindowRenderViewData.create(stream: stream,
                                                  rewardCount: rewardCount,
                                                  boardPrivilege: false)
        
        return data
    }
}

extension FcrStreamWindowUIController {
    func updateFrame(widget: AgoraBaseWidget,
                     syncFrame: CGRect,
                     animation: Bool = false) {
        let frame = syncFrame.displayFrameFromSyncFrame(superView: view)
        
        if animation {
            UIView.animate(withDuration: TimeInterval.agora_animation) {
                widget.view.frame = frame
            }
        } else {
            widget.view.frame = frame
        }
    }
    
    func updateViewHierarchy(zIndex: Int,
                             widget: AgoraBaseWidget) {
        guard let index = widgetArray.firstItemIndex(widgetObjectId: widget.info.widgetId) else {
            return
        }
        
        var item = widgetArray[index]
        item.zIndex = zIndex
        
        widgetArray.remove(at: index)
        
        let viewIndex = widgetArray.insertItem(item)
        
        view.insertSubview(widget.view,
                           at: viewIndex)
    }
    
    func createWidgetViewFrame(widget: AgoraBaseWidget,
                               userId: String,
                               zIndex: Int,
                               animation: Bool = false) {
        let widgetObjectId = widget.info.widgetId
        
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
            topWindow.addSubview(widget.view)
            
            widget.view.frame = originationFrame
            
            let destinationFrame = view.convert(displayFrame,
                                                to: topWindow)
            
            UIView.animate(withDuration: TimeInterval.agora_animation) {
                widget.view.frame = destinationFrame
            } completion: { isFinish in
                guard isFinish else {
                    return
                }
                self.updateViewHierarchy(zIndex: zIndex,
                                         widget: widget)
                widget.view.frame = displayFrame
            }
        } else {
            updateViewHierarchy(zIndex: zIndex,
                                widget: widget)
            widget.view.frame = displayFrame
        }
    }
    
    func releaseWidgetViewFrame(widget: AgoraBaseWidget,
                                userId: String,
                                animation: Bool = false,
                                completion: @escaping () -> Void) {
        if let destinationFrame = delegate?.onNeedWindowRenderViewFrameOnTopWindow(userId: userId),
           animation {
            
            let topWindow = UIWindow.ag_topWindow()
            let originationFrame = view.convert(widget.view.frame,
                                                to: topWindow)
            
            topWindow.addSubview(widget.view)
            widget.view.frame = originationFrame
            
            UIView.animate(withDuration: TimeInterval.agora_animation) {
                widget.view.frame = destinationFrame
            } completion: { isFinish in
                guard isFinish else {
                    return
                }
                
                widget.view.removeFromSuperview()
                
                completion()
            }
        } else {
            widget.view.removeFromSuperview()
            
            completion()
        }
    }
    
    func updateRenderView(_ renderView: FcrWindowRenderView,
                          stream: AgoraEduContextStreamInfo) {
        guard stream.videoSourceType == .camera else {
            renderView.videoMaskView.isHidden = true
            renderView.micView.isHidden = true
            renderView.nameLabel.isHidden = true
            return
        }
        
        let data = createViewData(with: stream)
        
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
    }
    
    func createRenderView() -> FcrWindowRenderView {
        let renderView = FcrWindowRenderView(frame: .zero)
        let ui = AgoraUIGroup()
        
        renderView.backgroundColor = ui.color.render_cell_bg_color
        renderView.layer.cornerRadius = ui.frame.render_cell_corner_radius
        renderView.layer.borderWidth = ui.frame.render_cell_border_width
        renderView.layer.borderColor = ui.color.render_mask_border_color
        
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
        createWidget(widgetId,
                     animation: true)
    }
    
    public func onWidgetInactive(_ widgetId: String) {
        releaseWidget(widgetId,
                      animation: true)
    }
}

// MARK: - AgoraWidgetMessageObserver
extension FcrStreamWindowUIController: AgoraWidgetMessageObserver {
    func onMessageReceived(_ message: String,
                           widgetId: String) {
        guard let item = widgetArray.firstItem(widgetObjectId: widgetId),
              let json = message.json(),
              let zIndex = json.keyPath(zIndexKey,
                                        result: Int.self) else {
            return
        }
        
        updateViewHierarchy(zIndex: zIndex,
                            widget: item.object)
    }
}

// MARK: - AgoraWidgetSyncFrameObserver
extension FcrStreamWindowUIController: AgoraWidgetSyncFrameObserver {
    func onWidgetSyncFrameUpdated(_ syncFrame: CGRect,
                                  widgetId: String,
                                  operatorUser: AgoraWidgetUserInfo?) {
        guard operatorUser?.userUuid != userController.getLocalUserInfo().userUuid,
              let item = widgetArray.firstItem(widgetObjectId: widgetId) else {
            return
        }
        
        updateFrame(widget: item.object,
                    syncFrame: syncFrame,
                    animation: true)
    }
}

// MARK: - AgoraEduStreamHandler
extension FcrStreamWindowUIController: AgoraEduStreamHandler {
    func onStreamUpdated(stream: AgoraEduContextStreamInfo,
                         operatorUser: AgoraEduContextUserInfo?) {
        guard let renderView = renderViewList[stream.streamUuid] else {
            return
        }
        
        updateRenderView(renderView,
                         stream: stream)
    }
}

// MARK: - AgoraEduMediaHandler
extension FcrStreamWindowUIController: AgoraEduMediaHandler {
    func onVolumeUpdated(volume: Int,
                         streamUuid: String) {
        guard let renderView = renderViewList[streamUuid] else {
            return
        }
        
        renderView.updateVolume(volume)
    }
}

extension FcrStreamWindowUIController: AgoraEduUserHandler {
    func onUserHandsWave(userUuid: String,
                         duration: Int,
                         payload: [String : Any]?) {
        guard let item = widgetArray.firstItem(userId: userUuid),
              let renderView = renderViewList[item.streamId] else {
            return
        }
        
        renderView.startWaving()
    }
    
    func onUserHandsDown(userUuid: String,
                         payload: [String : Any]?) {
        guard let item = widgetArray.firstItem(userId: userUuid),
              let renderView = renderViewList[item.streamId] else {
            return
        }
        
        renderView.stopWaving()
    }
}

fileprivate extension Array where Element == FcrWindowWidgetItem {
    func firstItemIndex(widgetObjectId: String) -> Int? {
        return firstIndex(where: {return $0.widgetObjectId == widgetObjectId})
    }
    
    func firstItem(widgetObjectId: String) -> FcrWindowWidgetItem? {
        return first(where: {return $0.widgetObjectId == widgetObjectId})
    }
    
    func firstItem(userId: String) -> FcrWindowWidgetItem? {
        return first(where: {return $0.owner == userId})
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
}
