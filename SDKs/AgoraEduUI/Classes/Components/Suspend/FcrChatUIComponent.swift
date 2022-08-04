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

protocol FcrChatUIComponentDelegate: NSObjectProtocol {
    // 更新聊天红点显示状态
    func updateChatRedDot(isShow: Bool)
}

class FcrChatUIComponent: UIViewController {
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
    
    public weak var delegate: FcrChatUIComponentDelegate?
            
    init(context: AgoraEduContextPool,
         subRoom: AgoraEduSubRoomContext? = nil,
         delegate: FcrChatUIComponentDelegate? = nil) {
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
extension FcrChatUIComponent: AgoraUIActivity, AgoraUIContentContainer {
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
extension FcrChatUIComponent: AgoraEduRoomHandler {
    func onJoinRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        viewWillActive()
    }
}

// MARK: - AgoraEduSubRoomHandler
extension FcrChatUIComponent: AgoraEduSubRoomHandler {
    func onJoinSubRoomSuccess(roomInfo: AgoraEduContextSubRoomInfo) {
        viewWillActive()
    }
}

// MARK: - AgoraWidgetMessageObserver
extension FcrChatUIComponent: AgoraWidgetMessageObserver {
    func onMessageReceived(_ message: String,
                           widgetId: String) {
        guard widgetId == EasemobWidgetId || widgetId == AgoraChatWidgetId else {
            return
        }

        if let signal = message.toChatSignal() {
            switch signal {
            case .messageReceived:
                guard !isVisible else {
                    return
                }
                redDotShow = true
            case .error(let string):
                AgoraToast.toast(message: string,
                                 type: .error)
            }
        }
    }
}

// MARK: - Creations
private extension FcrChatUIComponent {
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
        
        let userInfo = userController.getLocalUserInfo()
        
        // avatarUrl set
        if let flexProps = userController.getUserProperties(userUuid: userInfo.userUuid),
           let url = flexProps["avatarUrl"] as? String {
            if let extraInfo = config.extraInfo {
                var newExtra = config.extraInfo as! Dictionary<String, Any>
                newExtra["avatarUrl"] = url
                config.extraInfo = newExtra
            } else {
                config.extraInfo = ["avatarUrl": url]
            }
        }
        
        let widget = widgetController.create(config)
        
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
        
        widgetController.add(self,
                             widgetId: widgetId)
        
        return widget
    }
    
    func releaseWidget() {
        widget?.view.removeFromSuperview()
        widget = nil
    }
}
