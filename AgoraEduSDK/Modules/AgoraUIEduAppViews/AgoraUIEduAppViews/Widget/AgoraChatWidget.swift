//
//  AgoraChatUIController.swift
//  AgoraUIEduAppViews
//
//  Created by SRS on 2021/4/16.
//

import Foundation
import AgoraUIEduBaseViews
import AgoraUIBaseViews
import AgoraWidget
import AgoraEduContext

public class AgoraChatWidget: AgoraEduWidget, AgoraEduMessageHandler {
    // 距离上面的值， 等于navView的高度
    var renderTop: CGFloat = AgoraKitDeviceAssistant.OS.isPad ? 44 : 34
    
    private let chatView = AgoraUIChatView(frame: .zero)
    
//    public weak var contextPool: AgoraEduContextPool?
//
//    required public init(widgetId: String,
//                         contextPool: AgoraEduContextPool,
//                         properties: [AnyHashable : Any]?) {
//        self.contextPool = contextPool
//        super.init(widgetId: widgetId,
//                   properties: properties)
//        initViews()
//        initLayout()
//        initData()
//    }
    
    public required init(widgetId: String,
                         contextPool: AgoraEduContextPool,
                         properties: [AnyHashable : Any]?) {
        super.init(widgetId: widgetId,
                   contextPool: contextPool,
                   properties: properties)
        initViews()
        initLayout()
        initData()
    }
    
    public override func widgetDidReceiveMessage(_ message: String) {
        guard let dic = message.json() else {
            return
        }
        
        if let type = dic["isFullScreen"] as? Int {
            switch type {
            case 0: // normal
                updateChatStyle(false)
            case 1: // full screen
                updateChatStyle(true)
            default:
                break
            }
        }
        
        if let hasConversation = dic["hasConversation"] as? Bool {
            chatView.hasConversation = hasConversation
        }
    }
    
    @objc public func onShowChatTips(_ message: String) {
        AgoraUtils.showToast(message: message)
    }

    @objc public func onAddRoomMessage(_ info: AgoraEduContextChatInfo) {
        chatView.onAddRoomMessage(info)
    }

    // 收到提问消息
    @objc public func onAddConversationMessage(_ info: AgoraEduContextChatInfo) {
        chatView.onAddConversationMessage(info)
    }

    @objc public func onSendRoomMessageResult(_ error: AgoraEduContextError?,
                                        info: AgoraEduContextChatInfo?) {
        chatView.onSendRoomMessageResult(error, info: info)
    }

    // 本地发送提问消息结果（包含首次和后面重发），如果error不为空，代表失败
    @objc public func onSendConversationMessageResult(_ error: AgoraEduContextError?,
                                                info: AgoraEduContextChatInfo?) {
        chatView.onSendConversationMessageResult(error,
                                                 info: info)
    }

    @objc public func onFetchHistoryMessagesResult(_ error: AgoraEduContextError?,
                                             list: [AgoraEduContextChatInfo]?) {
        chatView.onFetchHistoryMessagesResult(error, list: list)
    }

    @objc public func onUpdateChatPermission(_ allow: Bool) {
        chatView.onUpdateChatPermission(allow)
    }

    @objc public func onFetchConversationHistoryMessagesResult(_ error: AgoraEduContextError?,
                                                         list: [AgoraEduContextChatInfo]?) {
        chatView.onFetchConversationHistoryMessagesResult(error,
                                                          list: list)
    }

    @objc public func onUpdateLocalChatPermission(_ allow: Bool,
                                           toUser: AgoraEduContextUserInfo,
                                           operatorUser: AgoraEduContextUserInfo) {
        let info = AgoraEduContextChatInfo()
        info.from = .local
        info.user = toUser
        
        if allow {
            let text = localUnsilenced(operatorUser: operatorUser.userName)
            info.message = text
        } else {
            let text = localSilenced(operatorUser: operatorUser.userName)
            info.message = text
        }
        
        AgoraUtils.showToast(message: info.message)
        
        chatView.peerHasPermissiom = allow
    }
    
    @objc public func onUpdateRemoteChatPermission(_ allow: Bool,
                                                   toUser: AgoraEduContextUserInfo,
                                                   operatorUser: AgoraEduContextUserInfo) {
        let info = AgoraEduContextChatInfo()
        info.from = .remote
        info.user = toUser
        
        if allow {
            let text = remoteUnsilenced(toUser.userName,
                                        operatorUser: operatorUser.userName)
            info.message = text
        } else {
            let text = remoteSilenced(toUser.userName,
                                      operatorUser: operatorUser.userName)
            info.message = text
        }
        
        AgoraUtils.showToast(message: info.message)
    }
}

// MARK: - Private
private extension AgoraChatWidget {
    func initChatViewBehavior() {
        let isPad = AgoraKitDeviceAssistant.OS.isPad
        let kAgoraScreenHeight: CGFloat = min(UIScreen.agora_width, UIScreen.agora_height)
        
        let chatPanelViewMaxWidth: CGFloat = isPad ? 300 : 200
        let chatPanelViewMaxHeight: CGFloat = isPad ? 400 : kAgoraScreenHeight - 34 - renderTop - 10
        let chatPanelViewMinWidth: CGFloat = 56
        let chatPanelViewMinHeight: CGFloat = chatPanelViewMinWidth
        
        chatView.scaleTouchBlock = { [weak self] (isMin) in
            guard let `self` = self else {
                return
            }
            
            self.containerView.agora_width = isMin ? chatPanelViewMinWidth : chatPanelViewMaxWidth
            self.containerView.agora_height = isMin ? chatPanelViewMinHeight : chatPanelViewMaxHeight
            
            if let message = ["isMinSize": (isMin ? 1 : 0)].jsonString() {
                self.sendMessage(message)
            }
            
            UIView.animate(withDuration: 0.35) {
                self.containerView.superview?.layoutIfNeeded()
            } completion: { (_) in
                self.chatView.resizeChatViewFrame()
            }
        }
    }
    
    func initViews() {
        containerView.backgroundColor = .clear
        containerView.addSubview(chatView)
    }
    
    func initLayout() {
        chatView.agora_x = 0
        chatView.agora_y = 0
        chatView.agora_right = 0
        chatView.agora_bottom = 0
    }
    
    func initData() {
        contextPool?.chat.registerEventHandler(self)
        chatView.context = contextPool?.chat
        
        initChatViewBehavior()
    }
}

private extension AgoraChatWidget {
    func updateChatStyle(_ isFullScreen: Bool) {
        if isFullScreen {
            chatView.showMinBtn = true
            chatView.showDefaultText = true
            
            // 已经在右边了
            if containerView.agora_safe_right > 10 {
                chatView.scaleTouchBlock?(false)
            } else {
                chatView.isMin = true
                chatView.scaleTouchBlock?(true)
            }
        } else {
            chatView.isMin = false
            chatView.showMinBtn = false
            chatView.showDefaultText = false
        }
        
        if AgoraKitDeviceAssistant.OS.isPad {
            chatView.showDefaultText = true
        }
        
        UIView.animate(withDuration: 0.25) {
            
        } completion: { (_) in
            self.chatView.resizeChatViewFrame()
        }
    }
}

private extension AgoraChatWidget {
    func remoteSilenced(_ remoteUser: String,
                        operatorUser: String) -> String {
        if AgoraKitDeviceAssistant.Language.isChinese {
            return "\(remoteUser)被\(operatorUser)禁言了"
        } else {
            return "\(remoteUser) was silenced by \(operatorUser)."
        }
    }
    
    func localSilenced(operatorUser: String) -> String {
       if AgoraKitDeviceAssistant.Language.isChinese {
           return "你被\(operatorUser)禁言了"
       } else {
           return "you were silenced by \(operatorUser)."
       }
    }
    
    func remoteUnsilenced(_ remoteUser: String,
                        operatorUser: String) -> String {
        if AgoraKitDeviceAssistant.Language.isChinese {
            return "\(remoteUser)被\(operatorUser)解除了禁言"
        } else {
            return "\(remoteUser) was allowed to chat by \(operatorUser)."
        }
    }
    
    func localUnsilenced(operatorUser: String) -> String {
       if AgoraKitDeviceAssistant.Language.isChinese {
           return "你被\(operatorUser)解除了禁言"
       } else {
           return "you were allowed to chat by \(operatorUser)."
       }
    }
}
