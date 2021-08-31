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
    public let appContainerView = AgoraBaseUIView(frame: .zero)
    
    var room: AgoraRoomUIController?
    var set: AgoraSetUIController?
    var whiteBoard: AgoraWhiteBoardUIController?
    var chat: AgoraEduWidget?
    var shareScreen: AgoraScreenUIController?
    var hxChat: AgoraBaseWidget?
    
    // TODO: 抽取一个AgoraUIController
    public let menuView = AgoraBaseUIView(frame: .zero)
    
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

    public init(viewType: AgoraEduContextAppType,
                contextPool: AgoraEduContextPool) {
        self.viewType = viewType
        self.contextPool = contextPool
        super.init()

        if isDebug {
            let bundle = Bundle(for: AgoraUIManager.classForCoder())
            if let v = bundle.loadNibNamed("DebugView", owner: nil , options: nil)?.first as? DebugView {
                v.contextPool = contextPool
                appContainerView.addSubview(v)
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
        appView.backgroundColor = UIColor.black
        
        appView.addSubview(appContainerView)
        appContainerView.backgroundColor = UIColor(rgb: 0xF9F9FC)
        
        appContainerView.agora_x = 0
        appContainerView.agora_right = 0
        appContainerView.agora_y = 0
        appContainerView.agora_bottom = 0
    }
    
    func initControllers() {
        self.room = AgoraRoomUIController(contextProvider: self,
                                          eventRegister: self,
                                          delegate: self)
        
        self.set = AgoraSetUIController(contextProvider: self,
                                        eventRegister: self,
                                        delegate: self)
        
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
                                                    eventRegister: self,
                                                    delegate: self)
            
            self.privateChat = AgoraPrivateChatController(viewType: viewType,
                                                          contextProvider: self,
                                                          eventRegister: self)
            
            self.userList = AgoraUserListUIController(viewType: viewType,
                                                      contextProvider: self,
                                                      eventRegister: self,
                                                      delegate: self)
        case .lecture:
            self.renderLecture = AgoraLectureRenderUIController(viewType: viewType,
                                                            contextProvider: self,
                                                            eventRegister: self,
                                                            delegate: self)
            
            self.handsUp = AgoraHandsUpUIController(viewType: viewType,
                                                    contextProvider: self,
                                                    eventRegister: self,
                                                    delegate: self)
            
            self.privateChat = AgoraPrivateChatController(viewType: viewType,
                                                          contextProvider: self,
                                                          eventRegister: self)
            
            self.userList = AgoraUserListUIController(viewType: viewType,
                                                      contextProvider: self,
                                                      eventRegister: self,
                                                      delegate: self)
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
    
// MARK: - AgoraHandsUpUIControllerDelegate
extension AgoraUIManager: AgoraHandsUpUIControllerDelegate {
    func handsUpController(_ controller: AgoraHandsUpUIController, didHandsPressed: Bool) {
        onMenuPressed()
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
        
        roomJoined()
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
        appContainerView.addSubview(chat.containerView)

        let isPad: Bool = UIDevice.current.model == "iPad"
        chat.containerView.agora_safe_bottom = 15
        chat.containerView.agora_width = isPad ? 300:200
        chat.containerView.agora_right = isPad ? 60:50
        chat.containerView.agora_height = isPad ? 400:268
        self.hxChat = chat
        
        self.hxChat?.containerView.isHidden = true
    }
}

// MARK: - AgoraRoomUIControllerDelegate
extension AgoraUIManager: AgoraRoomUIControllerDelegate {
}

// MARK: - AgoraUserListUIControllerDelegate
extension AgoraUIManager: AgoraUserListUIControllerDelegate {
    func userListUIController(_ controller: AgoraUserListUIController,
                              didStateChanged close: Bool) {
        onUserListPressed()
    }
}

// MARK: - AgoraSetUIControllerDelegate
extension AgoraUIManager: AgoraSetUIControllerDelegate {
    func setUIController(_ controller: AgoraSetUIController,
                         didStateChanged close: Bool) {
        onSetPressed()
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
        case .lecture:
            layoutLectureView(isFullScreen,
                              coHostsCount: self.coHostCount)
        default:break
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
            chatViewMessageHandle(message: message)
        default:
            break
        }
    }
    
    func chatViewMessageHandle(message: String) {
        guard let dic = message.json() else {
            return
        }
        
        if let isShowBadge = dic["isShowBadge"] as? Bool {
            // 根据isShowBadge决定是否显示红点
            showBadge(!isShowBadge)
        }
        
        let isMinSize = dic["isMinSize"] as? Int;
        if (isMinSize == nil) {
            return;
        }
        
        switch viewType {
        case .small:
            onChatPressed()
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
