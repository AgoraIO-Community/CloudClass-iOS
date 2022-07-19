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
    
    private var redDotShow: Bool = false {
        didSet {
            guard redDotShow != oldValue else {
                return
            }
             
            delegate?.updateChatRedDot(isShow: redDotShow)
        }
    }
    
    /** SDK环境*/
    private var contextPool: AgoraEduContextPool
    private var subRoom: AgoraEduSubRoomContext?
    private var widget: AgoraBaseWidget?
    
    // public
    public let suggestSize = CGSize(width: 200,
                                    height: 287)
    
    public weak var delegate: AgoraChatUIControllerDelegate?
    
    public var hideTopBar = false
    
    public var hideMiniButton = false
    
    public var hideAnnouncement = false
    
    public var hideInput = false
    
    public var hideMuteButton = false
    
    init(context: AgoraEduContextPool,
         subRoom: AgoraEduSubRoomContext? = nil,
         delegate: AgoraChatUIControllerDelegate? = nil) {
        self.contextPool = context
        self.subRoom = subRoom
        self.delegate = delegate
        
        super.init(nibName: nil,
                   bundle: nil)
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
        
        initViews()
        initViewFrame()
        updateViewProperties()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        redDotShow = false
    }
}

// MARK: - AgoraUIActivity
extension AgoraChatUIController: AgoraUIActivity, AgoraUIContentContainer {
    func viewWillActive() {
        createWidget()
    }
    
    func viewWillInactive() {
        releaseWidget()
    }
    
    func initViews() {
        
    }
    
    func initViewFrame() {
        
    }
    
    func updateViewProperties() {
        let config = UIConfig.agoraChat
        view.layer.shadowColor = config.shadow.color
        view.layer.shadowOffset = config.shadow.offset
        view.layer.shadowOpacity = config.shadow.opacity
        view.layer.shadowRadius = config.shadow.radius
    }
}

// MARK: - AgoraEduRoomHandler
extension AgoraChatUIController: AgoraEduRoomHandler {
    func onJoinRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        viewWillActive()
    }
}

// MARK: - AgoraEduSubRoomHandler
extension AgoraChatUIController: AgoraEduSubRoomHandler {
    func onJoinSubRoomSuccess(roomInfo: AgoraEduContextSubRoomInfo) {
        viewWillActive()
    }
}

// MARK: - AgoraWidgetMessageObserver
extension AgoraChatUIController: AgoraWidgetMessageObserver {
    func onMessageReceived(_ message: String,
                           widgetId: String) {
        guard widgetId == EasemobWidgetId || widgetId == AgoraChatWidgetId else {
            return
        }
        
        guard message == "chatWidgetDidReceiveMessage",
              isVisible == false else {
            return
        }
        
        redDotShow = true
    }
}

// MARK: - Creations
private extension AgoraChatUIController {
    func createWidget() {
        if let object = createHyWidget() {
            widget = object
        } else if let object = createAgWidget() {
            widget = object
        }
        
        guard let `widget` = widget else {
            return
        }
        
        view.addSubview(widget.view)
        
        widget.view.mas_makeConstraints { make in
            make?.top.left().right().bottom().equalTo()(0)
        }
    }
    
    func createHyWidget() -> AgoraBaseWidget? {
        let widgetId = EasemobWidgetId
        
        guard let config = widgetController.getWidgetConfig(widgetId) else {
            return nil
        }
        
        let widget = widgetController.create(config)
        let userInfo = userController.getLocalUserInfo()
        
        if let flexProps = userController.getUserProperties(userUuid: userInfo.userUuid),
           let url = flexProps["avatarurl"] as? String,
           let message = ["avatarurl": url].jsonString() {
            widgetController.sendMessage(toWidget: widgetId,
                                         message: message)
        }
        
        if hideTopBar {
            widgetController.sendMessage(toWidget: widgetId,
                                         message: "hideTopBar")
        }
        
        if hideMiniButton {
            widgetController.sendMessage(toWidget: widgetId,
                                         message: "hideMiniButton")
        }
        
        if hideAnnouncement {
            widgetController.sendMessage(toWidget: widgetId,
                                         message: "hideAnnouncement")
        }
        
        if hideInput {
            widgetController.sendMessage(toWidget: widgetId,
                                         message: "hideInput")
        }
        
        if hideMuteButton {
            widgetController.sendMessage(toWidget: widgetId,
                                         message: "hideMuteButton")
        }
        
        widgetController.add(self,
                             widgetId: widgetId)
        
        return widget
    }
    
    func createAgWidget() -> AgoraBaseWidget? {
        let widgetId = AgoraChatWidgetId
        
        guard let config = widgetController.getWidgetConfig(widgetId) else {
            return nil
        }
        
        let widget = widgetController.create(config)
        
        if let param = ["view": ["hideTopBar": hideTopBar,
                                 "hideInput": hideInput]].jsonString() {
            widgetController.sendMessage(toWidget: widgetId,
                                         message: param)
        }
        
        widgetController.add(self,
                             widgetId: widgetId)
        
        return widget
    }
    
    func releaseWidget() {
        widget?.view.removeFromSuperview()
        widget = nil
    }
}
