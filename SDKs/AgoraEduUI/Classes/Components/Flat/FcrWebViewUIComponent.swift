//
//  AgoraWebViewUIController.swift
//  AgoraEduUI
//
//  Created by DoubleCircle on 2022/5/24.
//

import AgoraEduContext
import AgoraWidget
import UIKit

class FcrWebViewUIComponent: UIViewController {
    /**context**/
    private var userController: AgoraEduUserContext {
        if let `subRoom` = subRoom {
            return subRoom.user
        } else {
            return contextPool.user
        }
    }
    
    private var widgetController: AgoraEduWidgetContext {
        if let `subRoom` = subRoom {
            return subRoom.widget
        } else {
            return contextPool.widget
        }
    }
    
    private var contextPool: AgoraEduContextPool
    private var subRoom: AgoraEduSubRoomContext?
    
    // widgetArray index is equal to view.subViews index
    fileprivate var widgetArray = [FcrWebViewWidgetItem]()
    
    private lazy var previousNonContainFrame: CGRect = self.defaultSyncFrame()
    private var localBoardAuth = false {
        didSet {
            guard localBoardAuth != oldValue else {
                return
            }
            handleLocalBoardAuth()
        }
    }
    
    private let zIndexKey = "zIndex"
    private let zBoardAuthKey = "boardAuth"
    /** 记录当前已有zIndex中的最大值*/
    private var currentMaxZIndex = 0
    
    init(context: AgoraEduContextPool,
         subRoom: AgoraEduSubRoomContext? = nil) {
        self.contextPool = context
        self.subRoom = subRoom
        
        super.init(nibName: nil,
                   bundle: nil)
    }
    
    public func openWebView(urlString: String,
                            resourceId: String) {
        let widgetId = resourceId.makeWidgetId()
        guard widgetArray.firstItem(widgetId: widgetId) == nil else {
            return
        }
        let zIndex = (currentMaxZIndex + 1)
        currentMaxZIndex += 1
        let properties: [String: Any] = ["webViewUrl": urlString,
                                          zIndexKey: zIndex]
        
        let defaultSyncFrame = defaultSyncFrame()

        widgetController.setWidgetActive(widgetId,
                                         ownerUuid: nil,
                                         roomProperties: properties,
                                         syncFrame: defaultSyncFrame,
                                         success: nil)
    }
    
    deinit {
        print("\(#function): \(self.classForCoder)")
    }
    
    override func loadView() {
        view = AgoraBaseUIContainer()
        view.backgroundColor = .clear
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
    }
}

// MARK: - AgoraUIActivity
extension FcrWebViewUIComponent: AgoraUIActivity {
    func viewWillActive() {
        widgetController.add(self)
        widgetController.add(self,
                             widgetId: WebViewWidgetId)
        widgetController.add(self,
                             widgetId: kBoardWidgetId)
        
        createAllActiveWidgets()
        
        guard widgetArray.count > 0 else {
            return
        }
        
        view.isHidden = false
    }
    
    func viewWillInactive() {
        widgetController.remove(self)
        widgetController.remove(self,
                                widgetId: kBoardWidgetId)
        releaseAllWidgets()
        
        view.isHidden = true
    }
}

// MARK: - AgoraEduRoomHandler
extension FcrWebViewUIComponent: AgoraEduRoomHandler {
    func onJoinRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        viewWillActive()
    }
}

extension FcrWebViewUIComponent: AgoraEduSubRoomHandler {
    func onJoinSubRoomSuccess(roomInfo: AgoraEduContextSubRoomInfo) {
        viewWillActive()
    }
}

// MARK: - AgoraWidgetActivityObserver
extension FcrWebViewUIComponent: AgoraWidgetActivityObserver {
    public func onWidgetActive(_ widgetId: String) {
        createWidget(widgetId)
    }
    
    public func onWidgetInactive(_ widgetId: String) {
        releaseWidget(widgetId)
    }
}

// MARK: - AgoraWidgetSyncFrameObserver
extension FcrWebViewUIComponent: AgoraWidgetSyncFrameObserver {
    func onWidgetSyncFrameUpdated(_ syncFrame: CGRect,
                                  widgetId: String,
                                  operatorUser: AgoraWidgetUserInfo?) {
        guard operatorUser?.userUuid != userController.getLocalUserInfo().userUuid,
              let item = widgetArray.firstItem(widgetId: widgetId) else {
            return
        }
        
        handleSyncFrame(widget: item.object,
                        syncFrame: syncFrame)
    }
}

// MARK: - AgoraWidgetMessageObserver
extension FcrWebViewUIComponent: AgoraWidgetMessageObserver {
    func onMessageReceived(_ message: String,
                           widgetId: String) {
        if let item = widgetArray.firstItem(widgetId: widgetId),
           let signal = message.toWebViewSignal() {
            switch signal {
            case .viewZIndexChanged(let zIndex):
                handleZIndexChanged(zIndex: zIndex,
                                    widget: item.object)
            case .scale:
                handleScale(widget: item.object)
            case .close:
                handleCloseWidget(widgetId: widgetId)
            default:
                break
            }
        }
        
        if widgetId == kBoardWidgetId,
           let signal = message.toBoardSignal(),
           case .GetBoardGrantedUsers(let list) = signal {
            handleBoardGrantedUsers(userList: list)
        }
    }
}

// MARK: - Widget create & relase
private extension FcrWebViewUIComponent {
    func createAllActiveWidgets() {
        let allWidgetActivity = widgetController.getAllWidgetActivity()
        
        guard allWidgetActivity.count > 0 else {
            return
        }
        
        for (widgetId, activityNumber) in allWidgetActivity {
            let active = activityNumber.boolValue
            
            guard (widgetId.hasPrefix(WebViewWidgetId) || widgetId.hasPrefix(MediaPlayerWidgetId)),
                  active == true else {
                continue
            }
            
            createWidget(widgetId)
        }
    }
    
    func releaseAllWidgets() {
        for item in widgetArray {
            releaseWidget(item.widgetId)
        }
    }
    
    func createWidget(_ widgetId: String) {
        guard UIConfig.webView.enable,
              widgetArray.firstItem(widgetId: widgetId) == nil else {
            return
        }
        
        var config: AgoraWidgetConfig
        
        if widgetId.hasPrefix(WebViewWidgetId),
           let webViewConfig = widgetController.getWidgetConfig(WebViewWidgetId) {
            config = webViewConfig
        } else if widgetId.hasPrefix(MediaPlayerWidgetId),
          let mediaConfig = widgetController.getWidgetConfig(MediaPlayerWidgetId) {
            config = mediaConfig
        } else {
            return
        }
        
        config.widgetId = widgetId
        
        let widget = widgetController.create(config)
        
        var zIndex = 0
        if let properties = widget.info.roomProperties as? Dictionary<String, Any>,
           let index = properties["zIndex"] as? Int {
            zIndex = index
        }
        if zIndex > currentMaxZIndex {
            currentMaxZIndex = zIndex
        }
        
        let item = FcrWebViewWidgetItem(widgetId: widgetId,
                                        object: widget,
                                        zIndex: zIndex)
        
        widgetArray.append(item)
        
        view.isHidden = false
        
        view.addSubview(widget.view)
        widget.view.id = widgetId
        
        handleSyncFrame(widget: widget,
                        syncFrame: widget.info.syncFrame)
        
        handleZIndexChanged(zIndex: zIndex,
                            widget: widget)
        
        // 白板授权
        if userController.getLocalUserInfo().userRole == .teacher || localBoardAuth {
            addViewGestures(widget: widget)
            sendMessage(widgetId: widget.info.widgetId,
                        signal: .boardAuth(true))
        }
        
        widgetController.add(self,
                             widgetId: widgetId)
        
        widgetController.addObserver(forWidgetSyncFrame: self,
                                     widgetId: widgetId)
    }
    
    func releaseWidget(_ widgetId: String) {
        guard let index = widgetArray.firstItemIndex(widgetId: widgetId) else {
            return
        }
        let widget = widgetArray[index].object
        widget.view.removeFromSuperview()
        
        widgetArray.remove(at: index)
        
        if widgetArray.count == 0 {
            view.isHidden = true
            currentMaxZIndex = 0
        } else {
            view.isHidden = false
        }
        
        widgetController.remove(self,
                                widgetId: widgetId)
        widgetController.removeObserver(forWidgetSyncFrame: self,
                                        widgetId: widgetId)
    }
}

extension FcrWebViewUIComponent: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldReceive event: UIEvent) -> Bool {
        guard let view = gestureRecognizer.view as? AgoraBaseUIContainer else {
            return false
        }

        handleZIndexNeedChange(widgetId: view.id)
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - Private
private extension FcrWebViewUIComponent {
    func addViewGestures(widget: AgoraBaseWidget) {
        let dragGesture = UIPanGestureRecognizer(target: self,
                                                 action:#selector(dragGesture(gesture:)))
        let touchGesture = UITapGestureRecognizer(target: self,
                                                  action: #selector(touchGesture(gesture:)))
        touchGesture.delegate = self
        widget.view.addGestureRecognizers([dragGesture,touchGesture])
    }
    
    func removeViewGestures(widget: AgoraBaseWidget) {
        widget.view.removeGestureRecognizers()
    }
    
    func handleSyncFrame(widget: AgoraBaseWidget,
                         syncFrame: CGRect) {
        if syncFrame != CGRect.fullScreenSyncFrameValue() {
            previousNonContainFrame = syncFrame
        }
        let frame = syncFrame.displayFrameFromSyncFrame(superView: view)

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
    
    func handleZIndexChanged(zIndex: Int,
                             widget: AgoraBaseWidget) {
        guard let index = widgetArray.firstItemIndex(widgetId: widget.info.widgetId) else {
            return
        }
        
        if currentMaxZIndex < zIndex {
            currentMaxZIndex = zIndex
        }
        var item = widgetArray[index]
        item.zIndex = zIndex
        
        widgetArray.remove(at: index)
        
        let viewIndex = widgetArray.insertItem(item)
        
        view.insertSubview(widget.view,
                           at: viewIndex)
    }
    
    func handleZIndexNeedChange(widgetId: String) {
        guard let item = widgetArray.firstItem(widgetId: widgetId),
              currentMaxZIndex > item.zIndex else {
            return
        }
        
        let finalZIndex = currentMaxZIndex + 1
        currentMaxZIndex += 1
        handleZIndexChanged(zIndex: finalZIndex,
                            widget: item.object)
        sendMessage(widgetId: item.object.info.widgetId,
                    signal: .updateViewZIndex(finalZIndex))
    }
    
    func handleScale(widget: AgoraBaseWidget) {
        guard let syncFrame = getFinalScaleSyncFrame(widgetId: widget.info.widgetId) else {
            return
        }
        handleSyncFrame(widget: widget,
                        syncFrame: syncFrame)
        widgetController.updateWidgetSyncFrame(syncFrame,
                                               widgetId: widget.info.widgetId,
                                               success: nil)
    }
    
    func handlePosition(widgetId: String) {
        guard let syncFrame = getFinalPositionSyncFrame(widgetId: widgetId) else {
            return
        }
        widgetController.updateWidgetSyncFrame(syncFrame,
                                               widgetId: widgetId,
                                               success: nil)
    }
    
    func handleCloseWidget(widgetId: String) {
        releaseWidget(widgetId)
        widgetController.setWidgetInactive(widgetId,
                                           isRemove: false,
                                           success: nil)
    }
    
    func handleBoardGrantedUsers(userList: [String]) {
        let localUser = userController.getLocalUserInfo()
        guard localUser.userRole != .teacher else {
            return
        }

        localBoardAuth = userList.contains(localUser.userUuid)
    }
    
    func handleLocalBoardAuth() {
        let widgetList = widgetArray.map({return $0.object})
        for widget in widgetList {
            if localBoardAuth {
                addViewGestures(widget: widget)
            } else {
                removeViewGestures(widget: widget)
            }
            sendMessage(widgetId: widget.info.widgetId,
                        signal: .boardAuth(localBoardAuth))
        }
    }
    
    func sendMessage(widgetId: String,
                     signal: AgoraWebViewWidgetSignal) {
        guard let message = signal.toMessageString() else {
            return
        }
        widgetController.sendMessage(toWidget: widgetId,
                                     message: message)
    }
    
    func defaultSyncFrame() -> CGRect {
        let width = AgoraFit.scale(364)
        let height = AgoraFit.scale(218)
        let left = (view.width - width) / 2
        let top = (view.height - height) / 2
        let defaultFrame = CGRect(x: left,
                                  y: top,
                                  width: width,
                                  height: height)
        return defaultFrame.syncFrameFromDisplayFrame(superView: view)
    }
    
    func getFinalScaleSyncFrame(widgetId: String) -> CGRect? {
        guard let widget = widgetArray.firstItem(widgetId: widgetId)?.object else {
            return nil
        }
        
        var finalFrame: CGRect = .zero
        
        if widget.view.frame.size != view.size {
            // 先保留当前syncFrame
            let currentSyncFrame = widgetController.getWidgetSyncFrame(widgetId)
            previousNonContainFrame = currentSyncFrame
            // 全屏模式
            finalFrame = CGRect(x: 0,
                                y: 0,
                                width: 1,
                                height: 1)
        } else {
            finalFrame = previousNonContainFrame
        }
        
        return finalFrame
    }
    
    func getFinalPositionSyncFrame(widgetId: String) -> CGRect? {
        guard let widget = widgetArray.firstItem(widgetId: widgetId)?.object else {
            return nil
        }
        let displayFrame = widget.view.frame
        
        let syncFrame = displayFrame.syncFrameFromDisplayFrame(superView: view)
        return syncFrame
    }
    
    // actions
    @objc private func touchGesture(gesture: UITapGestureRecognizer) {
        
    }
    
    @objc private func dragGesture(gesture: UIPanGestureRecognizer) {
        guard let targetView = gesture.view as? AgoraBaseUIContainer else {
            return
        }

        let point = gesture.translation(in: view)
        
        let viewWidth = targetView.width
        let viewHeight = targetView.height
        
        let transLeft = targetView.frame.minX + point.x
        let transTop = targetView.frame.minY + point.y
        
        switch gesture.state {
        case .changed:
            var finalLeft = (transLeft >= 0) ? transLeft : 0
            finalLeft = (finalLeft + viewWidth <= view.width) ? finalLeft : (view.width - viewWidth)
            
            var finalTop = (transTop >= 0) ? transTop : 0
            finalTop = (finalTop + viewHeight <= view.height) ? finalTop : (view.height - viewHeight)
            targetView.mas_updateConstraints { make in
                make?.left.equalTo()(finalLeft)
                make?.top.equalTo()(finalTop)
            }
        case .recognized: fallthrough
        case .ended:
            handlePosition(widgetId: targetView.id)
        default:
            break
        }
        gesture.setTranslation(.zero,
                               in: view)
    }
}

fileprivate extension Array where Element == FcrWebViewWidgetItem {
    func firstItemIndex(widgetId: String) -> Int? {
        return firstIndex(where: {return $0.widgetId == widgetId})
    }
    
    func firstItem(widgetId: String) -> FcrWebViewWidgetItem? {
        return first(where: {return $0.widgetId == widgetId})
    }
    
    mutating func insertItem(_ item: FcrWebViewWidgetItem) -> Int {
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
    func makeWidgetId() -> String {
        return "\(WebViewWidgetId)-\(self)"
    }
}
