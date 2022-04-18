//
//  AgoraChatUIController.swift
//  AgoraEduUI
//
//  Created by Cavan on 2021/12/9.
//

import AgoraEduContext
import AgoraWidget
import Masonry
import UIKit

protocol AgoraChatUIControllerDelegate: NSObjectProtocol {
    // 更新聊天红点显示状态
    func updateChatRedDot(isShow: Bool)
}

class AgoraChatUIController: UIViewController {
    /** SDK环境*/
    private var contextPool: AgoraEduContextPool!
    private var subRoom: AgoraEduSubRoomContext?
    private var widget: AgoraBaseWidget?
    
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
    
    public let suggestSize = CGSize(width: 200,
                                    height: 287)
    
    public weak var delegate: AgoraChatUIControllerDelegate?
    
    private var chatWidgetId: String?
    
    // public
    public var hideTopBar = false
    
    public var hideMiniButton = false
    
    public var hideAnnouncement = false
    
    public var hideInput = false
        
    private var redDotShow: Bool = false {
        didSet {
            if redDotShow != oldValue {
                self.delegate?.updateChatRedDot(isShow: redDotShow)
            }
        }
    }
    
    init(context: AgoraEduContextPool,
         subRoom: AgoraEduSubRoomContext? = nil) {
        super.init(nibName: nil,
                   bundle: nil)
        self.contextPool = context
        self.subRoom = subRoom
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.redDotShow = false
    }
    
    func viewWillActive() {
        createWidget()
    }
    
    func viewWillInactive() {
        releaseWidget()
    }
}

extension AgoraChatUIController: AgoraEduRoomHandler {
    func onJoinRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        createWidget()
    }
}

extension AgoraChatUIController: AgoraEduSubRoomHandler {
    func onJoinSubRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        createWidget()
    }
}

// MARK: - AgoraWidgetMessageObserver
extension AgoraChatUIController: AgoraWidgetMessageObserver {
    func onMessageReceived(_ message: String,
                           widgetId: String) {
        guard let w = chatWidgetId,
              w == widgetId else {
            return
        }
        
        if message == "chatWidgetDidReceiveMessage",
           isVisible == false {
            self.redDotShow = true
        }
    }
}

// MARK: - Creations
private extension AgoraChatUIController {
    func createWidget() {
        let EM = EasemobWidgetId
        let RTM = AgoraChatWidgetId
        
        if let chatConfig = widgetController.getWidgetConfig(EM) {
            let w = widgetController.create(chatConfig)
            view.addSubview(w.view)
            let userInfo = userController.getLocalUserInfo()
            
            if let flexProps = userController.getUserProperties(userUuid: userInfo.userUuid),
               let url = flexProps["avatarurl"] as? String,
               let message = ["avatarurl": url].jsonString() {
                widgetController.sendMessage(toWidget: EM,
                                             message: message)
            }
            
            if hideTopBar {
                widgetController.sendMessage(toWidget: EM,
                                             message: "hideTopBar")
            }
            
            if hideMiniButton {
                widgetController.sendMessage(toWidget: EM,
                                             message: "hideMiniButton")
            }
            
            if hideAnnouncement {
                widgetController.sendMessage(toWidget: EM,
                                             message: "hideAnnouncement")
            }
            
            if hideInput {
                widgetController.sendMessage(toWidget: EM,
                                             message: "hideInput")
            }
            widget = w
            chatWidgetId = EM
            widgetController.add(self,
                                 widgetId: EM)
            
        } else if let chatConfig = widgetController.getWidgetConfig(RTM) {
            
            let w = widgetController.create(chatConfig)
            view.addSubview(w.view)
            if let param = ["view": ["hideTopBar": hideTopBar,
                                     "hideInput": hideInput]].jsonString() {
                widgetController.sendMessage(toWidget: RTM,
                                             message: param)
            }
            
            widget = w
            chatWidgetId = RTM
            widgetController.add(self,
                                 widgetId: RTM)
        }
        
        widget?.view.mas_makeConstraints { make in
            make?.top.left().right().bottom().equalTo()(0)
        }
    }
    
    func releaseWidget() {
        widget?.view.removeFromSuperview()
        widget = nil
    }
}
