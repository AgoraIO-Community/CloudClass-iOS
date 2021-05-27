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
    var handsUp: AgoraHandsUpUIController?
    var privateChat: AgoraPrivateChatController?
    var userList: AgoraUserListUIController?
    
    // variable
    var isFullScreen = false
    var coHostCount = 0
    
    // 距离上面的值， 等于navView的高度
    var renderTop: CGFloat = AgoraKitDeviceAssistant.OS.isPad ? 44 : 34

    public init(viewType: AgoraEduContextAppType,
                contextPool: AgoraEduContextPool) {
        self.viewType = viewType
        self.contextPool = contextPool
        super.init()

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
        case .small: fallthrough
        case .lecture:
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
        guard let y = room?.containerView.frame.maxY else {
            return
        }
        //                if var properties = contextPool.widget.getAgoraWidgetProperties(type: .im) {
        //
        //                }
        
        var properties = [String: Any]()
        let userInfo = contextPool.user.getLocalUserInfo()
        let roomInfo = contextPool.room.getRoomInfo()
        properties["userName"] = userInfo.userName
        properties["userUuid"] = userInfo.userUuid
        properties["roomUuid"] = roomInfo.roomUuid
        properties["roomName"] = roomInfo.roomName
        properties["chatRoomId"] = "148364667715585"
        properties["avatarurl"] = "https://image.baidu.com/search/detail?ct=503316480&z=1&ipn=d&word=%E5%AE%B6%E8%BE%89%E5%9F%B9%E4%BC%98&step_word=&hs=0&pn=0&spn=0&di=4180&pi=0&rn=1&tn=baiduimagedetail&is=0%2C0&istype=0&ie=utf-8&oe=utf-8&in=&cl=2&lm=-1&st=undefined&cs=1237126975%2C2001019500&os=2332624552%2C3941347092&simid=3415651148%2C346922647&adpicid=0&lpn=0&ln=255&fr=&fmq=1622031016324_R&fm=&ic=undefined&s=undefined&hd=undefined&latest=undefined&copyright=undefined&se=&sme=&tab=0&width=0&height=0&face=undefined&ist=&jit=&cg=&bdtype=0&oriquery=&objurl=https%3A%2F%2Fgimg2.baidu.com%2Fimage_search%2Fsrc%3Dhttp%3A%2F%2Fhiphotos.baidu.com%2Fdoc%2Fpic%2Fitem%2Fb8389b504fc2d562d2b0c3ceee1190ef76c66c5c.jpg%26refer%3Dhttp%3A%2F%2Fhiphotos.baidu.com%26app%3D2002%26size%3Df9999%2C10000%26q%3Da80%26n%3D0%26g%3D0n%26fmt%3Djpeg%3Fsec%3D1624623030%26t%3D940fb50962a66774a1187b56b16cecba&fromurl=ippr_z2C%24qAzdH3FAzdH3F6jpyrj_z%26e3Bojgh7_z%26e3Bkwt17_z%26e3Bv54AzdH3F5AzdH3F3iry%3Fpwk%3D8%2651%3D8%26etjo%3Da%26rwy%3Da%26vt1%3D80%26rg%3Dda&gsm=1&rpstart=0&rpnum=0&islist=&querylist=&force=undefined"
        
        info.properties = properties
        
        let chat = contextPool.widget.createWidget(with: info)
        chat.addMessageObserver(self)
        appView.addSubview(chat.containerView)
        
        chat.containerView.agora_y = y
        chat.containerView.agora_right = 250
        chat.containerView.agora_width = 500
        chat.containerView.agora_safe_bottom = 0
        
        self.hxChat = chat
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
            layoutSmallView(isFullScreen,
                            coHostsCount: self.coHostCount)
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
            resetSmallHandsUpLayout(isFullScreen)
        case .lecture:
            resetLectureHandsUpLayout(isFullScreen)
        default:
            break
        }
    }
}

// MARK: - AgoraSmallRenderUIControllerDelegate
extension AgoraUIManager: AgoraSmallRenderUIControllerDelegate {
    func renderController(_ controller: AgoraSmallRenderUIController,
                          didUpdateCoHosts coHosts: [AgoraEduContextUserDetailInfo]) {
        self.coHostCount = coHosts.count
        
        switch viewType {
        case .small:
            self.layoutSmallView(self.isFullScreen,
                                 coHostsCount: self.coHostCount)
            
            if let _ = coHosts.first(where: {$0.isSelf == true}) {
                handsUp?.isCoHost = true
            } else {
                handsUp?.isCoHost = false
            }
        case .lecture:
            self.layoutLectureView(self.isFullScreen,
                                   coHostsCount: self.coHostCount)
            
            if let _ = coHosts.first(where: {$0.isSelf == true}) {
                handsUp?.isCoHost = true
            } else {
                handsUp?.isCoHost = false
            }
        default:
            break
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
