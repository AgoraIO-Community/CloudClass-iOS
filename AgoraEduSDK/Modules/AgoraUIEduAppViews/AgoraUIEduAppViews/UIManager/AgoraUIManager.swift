//
//  AgoraUIManager.swift
//  AgoraUIManager
//
//  Created by SRS on 2021/3/13.
//

import AgoraUIBaseViews
import AgoraUIEduBaseViews
import AudioToolbox
import AgoraExtApp
import AgoraEduContext
import AgoraWidget

// 用于判断是否显示测试页面
public var isDebug = false

@objcMembers public class AgoraUIManager: NSObject {
    public let viewType: AgoraEduContextAppType
    public let contextPool: AgoraEduContextPool
    public let appView = AgoraBaseUIView(frame: .zero)
    
    var room: AgoraRoomUIController?
    var set: AgoraSetUIController?
    var whiteBoard: AgoraWhiteBoardUIController?
    var chat: AgoraEduWidget?
    var shareScreen: AgoraScreenUIController?
    var hxChat: AgoraBaseWidget?
    
    // 1v1
    var render1V1: Agora1V1RenderUIController?
    // small
    var renderSmall: AgoraSmallRenderUIController?
    // lecture
    var renderLecture: AgoraLectureRenderUIController?
    var handsUp: AgoraHandsUpUIController?
    var privateChat: AgoraPrivateChatController?
    var userList: AgoraUserListUIController?
    
    // variable
    var isFullScreen = true
    var coHostCount = 0
    
    // 距离上面的值， 等于navView的高度
    var renderTop: CGFloat = AgoraKitDeviceAssistant.OS.isPad ? 44 : 34

    public init(viewType: AgoraEduContextAppType,
                contextPool: AgoraEduContextPool) {
        self.viewType = viewType
        self.contextPool = contextPool
        super.init()

        if isDebug {
            let bundle = Bundle(for: AgoraUIManager.classForCoder())
            if let v = bundle.loadNibNamed("DebugView", owner: nil , options: nil)?.first as? DebugView {
                v.contextPool = contextPool
                appView.addSubview(v)
            }
            return
        }
        
        self.controllerNeedRoomContext().joinClassroom()
        loadView()
        initWidgets()
        initControllers()
        addContainerViews()
        layoutContainerViews()
        observeEvents()
    }
    
    func loadView() {
        appView.backgroundColor = UIColor(rgb: 0xf8f8fc)
    }
    
    func initControllers() {
        self.room = AgoraRoomUIController(contextProvider: self,
                                          eventRegister: self,
                                          delegate: self)
        
        self.set = AgoraSetUIController(contextProvider: self,
                                         eventRegister: self)
        
        self.whiteBoard = AgoraWhiteBoardUIController(viewType: viewType,
                                                     delegate: self,
                                                     contextProvider: self,
                                                     eventRegister: self)
        
        self.shareScreen = AgoraScreenUIController(viewType: viewType,
                                                   delegate: self,
                                                   contextProvider: self,
                                                   eventRegister: self)

        switch viewType {
        case .oneToOne:
            self.render1V1 = Agora1V1RenderUIController(viewType: viewType,
                                                        contextProvider: self,
                                                        eventRegister: self)
        case .small:
            self.renderSmall = AgoraSmallRenderUIController(viewType: viewType,
                                                                contextProvider: self,
                                                                eventRegister: self,
                                                                delegate: self)
            
            self.handsUp = AgoraHandsUpUIController(viewType: viewType,
                                                    contextProvider: self,
                                                    eventRegister: self)
            
            self.privateChat = AgoraPrivateChatController(viewType: viewType,
                                                          contextProvider: self,
                                                          eventRegister: self)
            
            self.userList = AgoraUserListUIController(viewType: viewType,
                                                      contextProvider: self,
                                                      eventRegister: self)
        case .lecture:
            self.renderLecture = AgoraLectureRenderUIController(viewType: viewType,
                                                            contextProvider: self,
                                                            eventRegister: self,
                                                            delegate: self)
            
            self.handsUp = AgoraHandsUpUIController(viewType: viewType,
                                                    contextProvider: self,
                                                    eventRegister: self)
            
            self.privateChat = AgoraPrivateChatController(viewType: viewType,
                                                          contextProvider: self,
                                                          eventRegister: self)
            
            self.userList = AgoraUserListUIController(viewType: viewType,
                                                      contextProvider: self,
                                                      eventRegister: self)
        }
    }
    
    func initWidgets() {
        guard let widgetInfos = contextPool.widget.getWidgetInfos() else {
            return
        }
        
        for info in widgetInfos {
            switch info.widgetId {
            case "AgoraChatWidget":
                let chat = contextPool.widget.createWidget(info: info,
                                                       contextPool: contextPool)
                chat.addMessageObserver(self)

                if let message = ["hasConversation": (viewType != .oneToOne ? 1 : 0)].jsonString() {
                    chat.widgetDidReceiveMessage(message)
                }
//
                chat.containerView.isHidden = true
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
        }
    }
    
    func observeEvents() {
        contextPool.room.registerEventHandler(self)
    }
}

// MARK: - AgoraControllerContextProvider
extension AgoraUIManager: AgoraControllerContextProvider {
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
        return contextPool.shareScreen
    }
    
    func controllerNeedExtAppContext() -> AgoraEduExtAppContext {
        return contextPool.extApp
    }
}

// MARK: - AgoraControllerEventRegister
extension AgoraUIManager: AgoraControllerEventRegister {
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
        contextPool.shareScreen.registerEventHandler(handler)
    }
}

extension AgoraUIManager: AgoraEduRoomHandler {
    public func onClassroomJoined() {
        guard let widgetInfos = contextPool.widget.getWidgetInfos() else {
            return
        }
        
        for info in widgetInfos {
            switch info.widgetId {
            case "Chat":
                createHxChat(info: info)
            default:
                break
            }
        }
    }
    
    func createHxChat(info: AgoraWidgetInfo) {
        let userInfo = contextPool.user.getLocalUserInfo()
        let roomInfo = contextPool.room.getRoomInfo()
        
        guard let y = room?.containerView.frame.maxY,
              let userProperties = userInfo.userProperties,
              let `whiteBoard` = self.whiteBoard else {
            return
        }
        
        let avatarurl = userProperties["avatarurl"]
        
        var properties = [String: Any]()
        
        properties["userName"] = userInfo.userName
        properties["userUuid"] = userInfo.userUuid
        properties["roomUuid"] = roomInfo.roomUuid
        properties["roomName"] = roomInfo.roomName
        properties["password"] = userInfo.userUuid
        properties["avatarurl"] = avatarurl
        
        if let imProperties = contextPool.widget.getAgoraWidgetProperties(type: .im),
           let hxProperties = imProperties["huanxin"] as? [String: Any],
           let appKey = hxProperties["appKey"] as? String,
           let chatRoomId = hxProperties["chatRoomId"] as? String {
            properties["appkey"] = appKey
            properties["chatRoomId"] = chatRoomId
        }
        
        info.properties = properties
        
        let chat = contextPool.widget.createWidget(with: info)
        chat.addMessageObserver(self)
        self.appView.addSubview(chat.containerView)
        
        //        chat.containerView.agora_equal_to_superView(attribute: .top)
        //        chat.containerView.agora_equal_to_superView(attribute: .left)
        //        chat.containerView.agora_equal_to_superView(attribute: .right)
        //        chat.containerView.agora_equal_to_superView(attribute: .bottom,
        //                                                      constant: -90)
        let isPad: Bool = UIDevice.current.model == "iPad"
        switch self.viewType {
        case .lecture:
            chat.containerView.agora_safe_y = isPad ? 210:150;
        case .small:
            chat.containerView.agora_safe_y = self.whiteBoard?.containerView.agora_safe_y ?? 100;
        default:
            break;
        }
        chat.containerView.agora_safe_bottom = 0
        chat.containerView.agora_width = isPad ? 300:200
        chat.containerView.agora_safe_right = 10
        
        self.hxChat = chat
        chat.widgetDidReceiveMessage("min")
    }
}

// MARK: - AgoraRoomUIControllerDelegate
extension AgoraUIManager: AgoraRoomUIControllerDelegate {
    func roomController(_ controller: AgoraRoomUIController,
                         didClicked button: AgoraBaseUIButton) {
        
        //
        if let v = self.set?.containerView, let navBar = self.room?.containerView {
            if v.superview != nil {
                v.removeFromSuperview()
            } else {
                self.room?.updateSetInteraction(enabled: false)
                
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
}

// MARK: - AgoraScreenUIControllerDelegate
extension AgoraUIManager: AgoraScreenUIControllerDelegate {
    func screenController(_ controller: AgoraScreenUIController,
                          didUpdateState state: AgoraEduContextScreenShareState) {
        let sharing = (state != .stop)
        self.whiteBoard?.updateBoardViewOpaque(sharing: sharing)
    }
    
    func screenController(_ controller: AgoraScreenUIController,
                          didSelectScreen selected: Bool) {
        self.whiteBoard?.updateBoardViewOpaque(sharing: selected)
    }
}

// MARK: - AgoraWhiteBoardUIControllerDelegate
extension AgoraUIManager: AgoraWhiteBoardUIControllerDelegate {
    func whiteBoard(_ controller: AgoraWhiteBoardUIController,
                    willUpdateDisplayMode isFullScreen: Bool) {
        self.isFullScreen = isFullScreen
        
        switch viewType {
        case .oneToOne:
            layout1V1FullScreen(isFullScreen)
        case .small:
            layoutSmallView(isFullScreen)
        case .lecture:
            layoutLectureView(isFullScreen,
                              coHostsCount: self.coHostCount)
        }
    }
    
    func whiteBoard(_ controller: AgoraWhiteBoardUIController,
                    didPresseStudentListButton button: UIButton) {
        self.userList?.updateUserListViewVisible()
    }
}

extension AgoraUIManager: AgoraWidgetDelegate {
    public func widget(_ widget: AgoraBaseWidget,
                       didSendMessage message: String) {
        switch widget.widgetId {
        case "AgoraChatWidget":
            chatViewMessageHandle(message: message)
        case "Chat":
            do {
                switch self.viewType {
                case .small:
                    self.resetSmallHandsUpLayout()
                case .lecture:
                    self.resetLectureHandsUpLayout(self.isFullScreen)
                default:
                    break
                }
            }
        default:
            break
        }
    }
    
    func chatViewMessageHandle(message: String) {
        guard let dic = message.json(),
              let _ = dic["isMinSize"] as? Int else {
            return
        }
        
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
extension AgoraUIManager: AgoraSmallRenderUIControllerDelegate {
    func renderSmallController(_ controller: AgoraSmallRenderUIController,
                               didUpdateCoHosts coHosts: [AgoraEduContextUserDetailInfo]) {
        self.coHostCount = coHosts.count

        if let _ = coHosts.first(where: {$0.isSelf == true}) {
            handsUp?.isCoHost = true
        } else {
            handsUp?.isCoHost = false
        }
    }
}
// MARK: - AgoraLectureRenderUIControllerDelegate
extension AgoraUIManager: AgoraLectureRenderUIControllerDelegate {
    
    func renderLectureController(_ controller: AgoraLectureRenderUIController,
                                 didUpdateCoHosts coHosts: [AgoraEduContextUserDetailInfo]) {
        self.coHostCount = coHosts.count
        
        self.layoutLectureView(self.isFullScreen,
                               coHostsCount: self.coHostCount)
        
        if let _ = coHosts.first(where: {$0.isSelf == true}) {
            handsUp?.isCoHost = true
        } else {
            handsUp?.isCoHost = false
        }
    }
}

extension Dictionary {
    func jsonString() -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: self,
                                                    options: JSONSerialization.WritingOptions.prettyPrinted) else {
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
