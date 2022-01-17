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
    
    public let suggestSize = CGSize(width: 200, height: 287)
    
    public weak var delegate: AgoraChatUIControllerDelegate?
    
    private var chatWidgetId: String?
    
    private var widget: AgoraBaseWidget?
    /** SDK环境*/
    private var contextPool: AgoraEduContextPool!
    // public
    public var hideTopBar = false
    
    public var hideMiniButton = false
    
    public var hideAnnouncement = false
        
    private var redDotShow: Bool = false {
        didSet {
            if redDotShow != oldValue {
                self.delegate?.updateChatRedDot(isShow: redDotShow)
            }
        }
    }
    
    init(context: AgoraEduContextPool) {
        super.init(nibName: nil, bundle: nil)
        contextPool = context
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createWidget()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.redDotShow = false
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
    private func createWidget() {
        let EM = "easemobIM"
        let RTM = "AgoraChatWidget"
        if let chatConfig = contextPool.widget.getWidgetConfig(EM) {
            let w = contextPool.widget.create(chatConfig)
            view.addSubview(w.view)
            let userInfo = contextPool.user.getLocalUserInfo()
            if let flexProps = contextPool.user.getUserProperties(userUuid: userInfo.userUuid),
               let url = flexProps["avatarurl"] as? String,
                let message = ["avatarurl": url].jsonString() {
                    contextPool.widget.sendMessage(toWidget: EM,
                                                   message: message)
            }
            if hideTopBar {
                contextPool.widget.sendMessage(toWidget: EM,
                                               message: "hideTopBar")
            }
            if hideMiniButton {
                contextPool.widget.sendMessage(toWidget: EM,
                                               message: "hideMiniButton")
            }
            if hideAnnouncement {
                contextPool.widget.sendMessage(toWidget: EM,
                                               message: "hideAnnouncement")
            }
            widget = w
            chatWidgetId = EM
            contextPool.widget.add(self, widgetId: EM)
        } else if let chatConfig = contextPool.widget.getWidgetConfig(RTM) {
            
            let w = contextPool.widget.create(chatConfig)
            view.addSubview(w.view)
            if hideTopBar,
               let param = ["view": ["hideTopBar": true]].jsonString() {
                contextPool.widget.sendMessage(toWidget: RTM,
                                               message: param)
            }
            widget = w
            chatWidgetId = RTM
            contextPool.widget.add(self, widgetId: RTM)
        }
        widget?.view.mas_makeConstraints { make in
            make?.top.left().right().bottom().equalTo()(0)
        }
    }
}
