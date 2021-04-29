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

@objcMembers public class AgoraUIManager: NSObject {
    public let viewType: AgoraEduContextAppType
    public let contextPool: AgoraEduContextPool
    public let appView = AgoraBaseUIView(frame: .zero)
    
    var room: AgoraRoomUIController?
    var whiteBoard: AgoraWhiteBoardUIController?
    var chat: AgoraChatUIController?
    var shareScreen: AgoraScreenUIController?
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
        initControllers()
        addContainerViews()
        layoutContainerViews()
    }
    
    func loadView() {
        appView.backgroundColor = UIColor(rgb: 0xf8f8fc)
    }
    
    func initControllers() {
        self.room = AgoraRoomUIController(contextProvider: self,
                                          eventRegister: self)
        
        self.whiteBoard = AgoraWhiteBoardUIController(viewType: viewType,
                                                     delegate: self,
                                                     contextProvider: self,
                                                     eventRegister: self)
        
        self.chat = AgoraChatUIController(viewType: viewType,
                                          delegate: self,
                                          contextProvider: self,
                                          eventRegister: self)
    
        self.shareScreen = AgoraScreenUIController(viewType: viewType,
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

extension AgoraUIManager: AgoraChatUIControllerDelegate {
    func chatController(_ controller: AgoraChatUIController,
                        didUpdateSize min: Bool) {
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
