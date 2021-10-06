//
//  AgoraEduUI.swift
//  AgoraEduUI
//
//  Created by SRS on 2021/3/13.
//

import AgoraUIEduBaseViews
import AgoraUIBaseViews
import AgoraEduContext
import AudioToolbox
import AgoraExtApp
import AgoraWidget

@objcMembers public class AgoraEduUI: NSObject {
    public let viewType: AgoraEduContextRoomType
    public let contextPool: AgoraEduContextPool
    public let appView = AgoraBaseUIView(frame: .zero)
    
    var room: AgoraRoomUIController?
    var set: AgoraSetUIController?
    var whiteBoard: AgoraWhiteBoardUIController?
    var chat: AgoraBaseWidget?
    var shareScreen: AgoraScreenUIController?
    // 1v1
    var render1V1: Agora1V1RenderUIController?
    // small
    var renderSmall: AgoraSmallRenderUIController?
    // lecture
    var renderLecture: AgoraLectureRenderUIController?
    var handsUp: AgoraHandsUpUIController?
    var privateChat: AgoraPrivateChatController?
    var userList: AgoraUserListUIController?
    // painting small
    var paintingSmall: PaintingRoomViewController?
    
    // variable
    var isFullScreen = false {
        didSet {
            guard oldValue != isFullScreen else {
                return
            }
            
            switch viewType {
            case .oneToOne:
                layout1V1FullScreen(isFullScreen)
            case .small:
                layoutSmallView()
            case .lecture:
                layoutLectureView(isFullScreen: isFullScreen)
            case .paintingSmall:
                layoutPaintingView()
            @unknown default:
                break
            }
        }
    }
    
    var hasCoHosts = false {
        didSet {
            guard oldValue != hasCoHosts else {
                return
            }
            
            switch viewType {
            case .oneToOne:
                break
            case .small:
                layoutSmallView()
            case .lecture:
                layoutLectureView(hasCoHosts: hasCoHosts)
            case .paintingSmall:
                layoutPaintingView()
            @unknown default:
                break
            }
        }
    }
    
    var teacherIn = false {
        didSet {
            switch viewType {
            case .oneToOne:
                break
            case .lecture:
                break
            case .small:
                layoutSmallView()
            case .paintingSmall:
                layoutPaintingView()
            @unknown default:
                break
            }
        }
    }
    
    var isHyChat = false
    
    // 距离上面的值， 等于navView的高度
    var renderTop: CGFloat = AgoraKitDeviceAssistant.OS.isPad ? 44 : 34
    
    public init(viewType: AgoraEduContextRoomType,
                contextPool: AgoraEduContextPool,
                region: String) {
        self.viewType = viewType
        self.contextPool = contextPool
        super.init()
        
        loadView()
        initWidgets()
        initControllers(region: region)
        addContainerViews()
        layoutContainerViews()
        registerObservers()
        
        // 监听事件都设置后，加入房间
        controllerNeedRoomContext().joinClassroom()
    }
    
    deinit {
        print("ui deinit")
    }
    
    func loadView() {
        appView.backgroundColor = UIColor(rgb: 0xf8f8fc)
    }
    
    func initControllers(region: String) {
        self.room = AgoraRoomUIController(contextProvider: self,
                                          delegate: self)
        
        self.set = AgoraSetUIController(contextProvider: self)
        
        self.whiteBoard = AgoraWhiteBoardUIController(viewType: viewType,
                                                      delegate: self,
                                                      contextProvider: self)
        
        self.shareScreen = AgoraScreenUIController(viewType: viewType,
                                                   delegate: self,
                                                   contextProvider: self)
        
        switch viewType {
        case .oneToOne:
            self.render1V1 = Agora1V1RenderUIController(viewType: viewType,
                                                        contextProvider: self)
        case .small:
            self.renderSmall = AgoraSmallRenderUIController(viewType: viewType,
                                                            contextProvider: self,
                                                            delegate: self)
            
            self.handsUp = AgoraHandsUpUIController(viewType: viewType,
                                                    contextProvider: self)
            
            self.privateChat = AgoraPrivateChatController(viewType: viewType,
                                                          contextProvider: self)
            
            self.userList = AgoraUserListUIController(viewType: viewType,
                                                      contextProvider: self,
                                                      region: region)
            self.userList?.delegate = whiteBoard
        case .lecture:
            self.renderLecture = AgoraLectureRenderUIController(viewType: viewType,
                                                                contextProvider: self,
                                                                delegate: self)
            
            self.handsUp = AgoraHandsUpUIController(viewType: viewType,
                                                    contextProvider: self)
            
            self.privateChat = AgoraPrivateChatController(viewType: viewType,
                                                          contextProvider: self)
            
            self.userList = AgoraUserListUIController(viewType: viewType,
                                                      contextProvider: self,
                                                      region: region)
            self.userList?.delegate = whiteBoard
        case .paintingSmall:
            
            self.handsUp = AgoraHandsUpUIController(viewType: viewType,
                                                    contextProvider: self)
            
            self.privateChat = AgoraPrivateChatController(viewType: viewType,
                                                          contextProvider: self)
            
            self.userList = AgoraUserListUIController(viewType: viewType,
                                                      contextProvider: self,
                                                      region: region)
            self.userList?.delegate = whiteBoard
        @unknown default:
            break
        }
    }
    
    func checkIsShowHyChat() {
        guard let widgetInfos = contextPool.widget.getWidgetInfos() else {
            return
        }
        
        for info in widgetInfos where info.widgetId == "HyChatWidget" {
            isHyChat = true
        }
    }
    
    func initWidgets() {
        checkIsShowHyChat()
        
        guard let widgetInfos = contextPool.widget.getWidgetInfos() else {
            return
        }
        
        for info in widgetInfos {
            switch info.widgetId {
            case "AgoraChatWidget":
                guard !isHyChat else {
                    continue
                }
                
                info.properties = ["contextPool": contextPool]
                let chat = contextPool.widget.create(with: info)
                chat.addMessageObserver(self)
                
                let hasConversation = (viewType == .oneToOne ? 0 : 1)
                if let message = ["hasConversation": hasConversation].jsonString() {
                    chat.widgetDidReceiveMessage(message)
                }
                
                let isMin = (viewType == .lecture ? 0 : 1)
                if let message = ["isMinSize": isMin].jsonString() {
                    chat.widgetDidReceiveMessage(message)
                }
                
                self.chat = chat
            default:
                break
            }
        }
    }
    
    func addContainerViews() {
        switch viewType {
        case .oneToOne:
            add1V1ContainerViews()
        case .small:
            addSmallContainerViews()
        case .lecture:
            addLectureContainerViews()
        case .paintingSmall:
            addPaintingContainerViews()
        @unknown default:
            break
        }
    }
    
    func layoutContainerViews() {
        switch viewType {
        case .oneToOne:
            layout1V1ContainerViews()
        case .small:
            layoutSmallContainerViews()
        case .lecture:
            layoutLectureContainerViews()
        case .paintingSmall:
            layoutPaintingContainerViews()
        @unknown default:
            break
        }
        
        appView.layoutIfNeeded()
    }
    
    func registerObservers() {
        if let roomController = room {
            controllerRegisterRoomEvent(roomController)
        }
        if let setController = set {
            controllerRegisterDeviceEvent(setController)
            controllerRegisterUserEvent(setController)
        }
        if let whiteBoardController = whiteBoard {
            controllerRegisterWhiteBoardEvent(whiteBoardController)
            controllerRegisterWhiteBoardPageControlEvent(whiteBoardController)
        }
        if let shareScreenController = shareScreen {
            controllerRegisterScreenEvent(shareScreenController)
        }
        if let render1V1Controller = render1V1 {
            controllerRegisterUserEvent(render1V1Controller)
        }
        if let renderSmallController = renderSmall {
            controllerRegisterUserEvent(renderSmallController)
        }
        if let renderLectureController = renderLecture {
            controllerRegisterUserEvent(renderLectureController)
        }
        if let handsUpController = handsUp {
            controllerRegisterHandsUpEvent(handsUpController)
        }
        if let privateChatController = privateChat {
            controllerRegisterPrivateChatEvent(privateChatController)
        }
        if let userListController = userList {
            controllerRegisterUserEvent(userListController)
        }
        
        // for create hy chat
        contextPool.room.registerEventHandler(self)
    }
}

// MARK: - AgoraControllerContextProvider
extension AgoraEduUI: AgoraControllerContextProvider {
    func controllerNeedWhiteBoardContext() -> AgoraEduWhiteBoardContext {
        return contextPool.whiteBoard
    }
    
    func controllerNeedWhiteBoardToolContext() -> AgoraEduWhiteBoardToolContext {
        return contextPool.whiteBoardTool
    }
    
    func controllerNeedWhiteBoardPageControlContext() -> AgoraEduWhiteBoardPageControlContext {
        return contextPool.whiteBoardPageControl
    }
    
    func controllerNeedRoomContext() -> AgoraEduRoomContext {
        return contextPool.room
    }
    
    func controllerNeedDeviceContext() -> AgoraEduDeviceContext {
        return contextPool.device
    }
    
    func controllerNeedChatContext() -> AgoraEduMessageContext {
        return contextPool.chat
    }
    
    func controllerNeedUserContext() -> AgoraEduUserContext {
        return contextPool.user
    }
    
    func controllerNeedHandsUpContext() -> AgoraEduHandsUpContext {
        return contextPool.handsUp
    }
    
    func controllerNeedPrivateChatContext() -> AgoraEduPrivateChatContext {
        return contextPool.privateChat
    }
    
    func controllerNeedScreenContext() -> AgoraEduScreenShareContext {
        return contextPool.screenSharing
    }
    
    func controllerNeedExtAppContext() -> AgoraEduExtAppContext {
        return contextPool.extApp
    }
    
    func controllerNeedMediaContext() -> AgoraEduMediaContext {
        return contextPool.media
    }
}

// MARK: - AgoraControllerEventRegister
extension AgoraEduUI: AgoraControllerEventRegister {
    func controllerRegisterDeviceEvent(_ handler: AgoraEduDeviceHandler) {
        contextPool.device.registerDeviceEventHandler(handler)
    }
    
    func controllerRegisterWhiteBoardEvent(_ handler: AgoraEduWhiteBoardHandler) {
        contextPool.whiteBoard.registerBoardEventHandler(handler)
    }
    
    func controllerRegisterWhiteBoardPageControlEvent(_ handler: AgoraEduWhiteBoardPageControlHandler) {
        contextPool.whiteBoardPageControl.registerPageControlEventHandler(handler)
    }
    
    func controllerRegisterRoomEvent(_ handler: AgoraEduRoomHandler) {
        contextPool.room.registerEventHandler(handler)
    }
    
    func controllerRegisterChatEvent(_ handler: AgoraEduMessageHandler) {
        contextPool.chat.registerEventHandler(handler)
    }
    
    func controllerRegisterPrivateChatEvent(_ handler: AgoraEduPrivateChatHandler) {
        contextPool.privateChat.registerEventHandler(handler)
    }
    
    func controllerRegisterUserEvent(_ handler: AgoraEduUserHandler) {
        contextPool.user.registerEventHandler(handler)
    }
    
    func controllerRegisterHandsUpEvent(_ handler: AgoraEduHandsUpHandler) {
        contextPool.handsUp.registerEventHandler(handler)
    }
    
    func controllerRegisterScreenEvent(_ handler: AgoraEduScreenShareHandler) {
        contextPool.screenSharing.registerEventHandler(handler)
    }
}

// MARK: - AgoraRoomUIControllerDelegate
extension AgoraEduUI: AgoraRoomUIControllerDelegate {
    func roomController(_ controller: AgoraRoomUIController,
                        didClicked button: AgoraBaseUIButton) {
        guard let v = set?.containerView,
              let navBar = room?.containerView else {
            return
        }
        
        if v.superview != nil {
            v.removeFromSuperview()
        } else {
            room?.updateSetInteraction(enabled: false)
            
            appView.addSubview(v)
            
            v.agora_height = 256
            v.agora_y = -v.agora_height
            v.agora_width = 280
            v.agora_safe_right = 0
            appView.layoutIfNeeded()
            
            v.agora_y = navBar.agora_height + 3
            
            UIView.animate(withDuration: 0.55,
                           delay: 0,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 0.8,
                           options: .curveEaseInOut) {
                self.appView.layoutIfNeeded()
            } completion: { (_) in
                self.room?.updateSetInteraction(enabled: true)
            }
        }
    }
}

// MARK: - AgoraScreenUIControllerDelegate
extension AgoraEduUI: AgoraScreenUIControllerDelegate {
    func screenController(_ controller: AgoraScreenUIController,
                          didUpdateState state: AgoraEduContextScreenShareState) {
        let sharing = (state != .stop)
        whiteBoard?.needTransparent = sharing
    }
    
    func screenController(_ controller: AgoraScreenUIController,
                          didSelectScreen selected: Bool) {
        whiteBoard?.needTransparent = selected
    }
}

// MARK: - AgoraWhiteBoardUIControllerDelegate
extension AgoraEduUI: AgoraWhiteBoardUIControllerDelegate {
    func whiteBoard(_ controller: AgoraWhiteBoardUIController,
                    willUpdateDisplayMode isFullScreen: Bool) {
        if viewType == .lecture,
           let `chat` = self.chat,
           let message = ["showMinButton": isFullScreen].jsonString() {
            chat.widgetDidReceiveMessage(message)
        }
        
        self.isFullScreen = isFullScreen
    }
    
    func whiteBoard(_ controller: AgoraWhiteBoardUIController,
                    didPresseStudentListButton button: UIButton) {
        userList?.updateUserListViewVisible()
    }
}

// MARK: - AgoraWidgetDelegate
extension AgoraEduUI: AgoraWidgetDelegate {
    public func widget(_ widget: AgoraBaseWidget,
                       didSendMessage message: String) {
        switch widget.widgetId {
        case "AgoraChatWidget":
            agoraChatWidgetMessageHandle(message: message)
        case "HyChatWidget":
            hyChatWidgetMessageHandle(message: message)
        default:
            break
        }
    }
    
    func agoraChatWidgetMessageHandle(message: String) {
        guard let dic = message.json(),
              let isMin = dic["isMinSize"] as? Bool else {
            return
        }
        
        switch viewType {
        case .oneToOne:
            resetOneToOneAgoraChatLayout(isMin: isMin)
        case .small:
            resetSmallAgoraChatLayout(isMin: isMin)
            resetSmallHandsUpLayout()
        case .lecture:
            resetLectureAgoraChatLayout(isMin: isMin)
            resetLectureHandsUpLayout(isFullScreen)
        default:
            break
        }
    }
    
    func hyChatWidgetMessageHandle(message: String) {
        switch viewType {
        case .small:
            resetSmallHandsUpLayout()
        case .lecture:
            resetLectureHandsUpLayout(isFullScreen)
        default:
            break
        }
    }
}

// MARK: - AgoraSmallRenderUIControllerDelegate
extension AgoraEduUI: AgoraSmallRenderUIControllerDelegate {
    func renderSmallController(_ controller: AgoraSmallRenderUIController,
                               didUpdateCoHosts coHosts: [AgoraEduContextUserDetailInfo]) {
        hasCoHosts = (coHosts.count > 0 ? true : false)
        
        if let _ = coHosts.first(where: {$0.isSelf == true}) {
            handsUp?.isCoHost = true
        } else {
            handsUp?.isCoHost = false
        }
    }
    
    func renderSmallController(_ controller: AgoraSmallRenderUIController,
                               didUpdateTeacherIn teacherIn: Bool) {
        if self.teacherIn != teacherIn  {
            self.teacherIn = teacherIn
        }
    }
}

// MARK: - AgoraLectureRenderUIControllerDelegate
extension AgoraEduUI: AgoraLectureRenderUIControllerDelegate {
    func renderLectureController(_ controller: AgoraLectureRenderUIController,
                                 didUpdateCoHosts coHosts: [AgoraEduContextUserDetailInfo]) {
        hasCoHosts = (coHosts.count > 0 ? true : false)

        if let _ = coHosts.first(where: {$0.isSelf == true}) {
            handsUp?.isCoHost = true
        } else {
            handsUp?.isCoHost = false
        }
    }
}

// MARK: - AgoraEduRoomHandler
extension AgoraEduUI: AgoraEduRoomHandler {
    public func onClassroomJoined() {
        createHxChat()
        createCountDownExtApp()
    }
    
    // ExtApp
    func createCountDownExtApp() {
        guard let extAppInfos = contextPool.extApp.getExtAppInfos(),
              let info = extAppInfos.first(where: {$0.appIdentifier == "io.agora.countdown"}) else {
            return
        }
        
        contextPool.extApp.willLaunchExtApp(info.appIdentifier)
    }
    
    // Widget
    func createHxChat() {
        guard isHyChat else {
            return
        }
        
        guard let widgetInfos = contextPool.widget.getWidgetInfos(),
              let info = widgetInfos.first(where: {$0.widgetId == "HyChatWidget"}) else {
            return
        }
        
        let userInfo = contextPool.user.getLocalUserInfo()
        let roomInfo = contextPool.room.getRoomInfo()
        
        guard let userProperties = userInfo.userProperties else {
            return
        }
        
        var properties = [String: Any]()
        
        if let flexProps = userProperties["flexProps"] as? [String: Any],
           let url = flexProps["avatarurl"] as? String {
            properties["avatarurl"] = url
        }
        
        properties["userName"] = userInfo.userName
        properties["userUuid"] = userInfo.userUuid
        properties["roomUuid"] = roomInfo.roomUuid
        properties["roomName"] = roomInfo.roomName
        properties["password"] = userInfo.userUuid
        
        if let imProperties = contextPool.widget.getAgoraWidgetProperties(type: .im),
           let hxProperties = imProperties["huanxin"] as? [String: Any],
           let appKey = hxProperties["appKey"] as? String,
           let chatRoomId = hxProperties["chatRoomId"] as? String {
            properties["appkey"] = appKey
            properties["chatRoomId"] = chatRoomId
        }
        
        info.properties = properties
        
        let chat = contextPool.widget.create(with: info)
        chat.addMessageObserver(self)
        appView.addSubview(chat.containerView)
        
        self.chat = chat
        
        let isPad: Bool = UIDevice.current.isPad
        let chatRightGap: CGFloat = 10
        
        var chatY: CGFloat
        var chatRight: CGFloat
        let chatBottom: CGFloat = 0
        let chatWidth: CGFloat = isPad ? 300 : 200
        
        switch viewType {
        case .oneToOne:
            guard let `render1V1` = self.render1V1 else {
                return
            }
            
            chatY = isPad ? 210 : 150
            chatRight = render1V1.containerView.agora_width + chatRightGap
        case .small:
            guard let `whiteBoard` = self.whiteBoard else {
                return
            }
            
            chatY = whiteBoard.containerView.agora_safe_y
            chatRight = chatRightGap
        case .lecture:
            chatY = isPad ? 210 : 150
            chatRight = 0
        @unknown default:
            return
        }
        
        chat.containerView.agora_safe_y = chatY
        chat.containerView.agora_safe_right = chatRight
        chat.containerView.agora_width = chatWidth
        chat.containerView.agora_safe_bottom = chatBottom
        
        if viewType != .lecture {
            chat.widgetDidReceiveMessage("min")
        }
        
        if viewType == .small {
            resetSmallHandsUpLayout()
        }
        
        if viewType == .lecture {
            resetLectureHandsUpLayout(isFullScreen)
        }
    }
}

extension Dictionary {
    func jsonString() -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: self,
                                                     options: .prettyPrinted) else {
            return nil
        }
        
        guard let jsonString = String(data: data,
                                      encoding: .utf8) else {
            return nil
        }
        return jsonString
    }
}

extension String {
    func json() -> [String: Any]? {
        guard let data = self.data(using: .utf8) else {
            return nil
        }
        
        return data.json()
    }
}

extension Data {
    func json() -> [String: Any]? {
        guard let object = try? JSONSerialization.jsonObject(with: self,
                                                             options: [.mutableContainers]) else {
            return nil
        }
        
        guard let dic = object as? [String: Any] else {
            return nil
        }
        
        return dic
    }
}
