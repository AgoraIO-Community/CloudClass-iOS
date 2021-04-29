//
//  AgoraChatUIController.swift
//  AgoraUIEduAppViews
//
//  Created by SRS on 2021/4/16.
//

import Foundation
import AgoraUIEduBaseViews
import AgoraUIBaseViews
import AgoraEduContext

protocol AgoraChatUIControllerDelegate: NSObjectProtocol {
    func chatController(_ controller: AgoraChatUIController,
                         didUpdateSize min: Bool)
}

class AgoraChatUIController: NSObject, AgoraUIController {

    var containerView = AgoraUIControllerContainer(frame: .zero)
    // 距离上面的值， 等于navView的高度
    var renderTop: CGFloat = AgoraKitDeviceAssistant.OS.isPad ? 44 : 34
    
    private let chatView = AgoraUIChatView(frame: .zero)
    
    private(set) var viewType: AgoraEduContextAppType
    private weak var delegate: AgoraChatUIControllerDelegate?
    private weak var contextProvider: AgoraControllerContextProvider?
    private weak var eventRegister: AgoraControllerEventRegister?
    
    init(viewType: AgoraEduContextAppType,
         delegate: AgoraChatUIControllerDelegate,
         contextProvider: AgoraControllerContextProvider,
         eventRegister: AgoraControllerEventRegister) {

        self.viewType = viewType
        self.delegate = delegate
        self.contextProvider = contextProvider
        self.eventRegister = eventRegister
        
        super.init()
        initViews()
        initLayout()
        initData()
    }
    
    private func initData() {
        self.eventRegister?.controllerRegisterChatEvent(self)
        chatView.context = self.contextProvider?.controllerNeedChatContext()
        
        self.initChatViewBehavior()
    }
    
    public func updateChatStyle(_ isFullScreen: Bool){
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

// MARK: - Private
extension AgoraChatUIController {
    
    private func initChatViewBehavior() {
        let isPad = AgoraKitDeviceAssistant.OS.isPad
        let kAgoraScreenHeight: CGFloat = min(UIScreen.agora_width, UIScreen.agora_height)
        
        let chatPanelViewMaxWidth: CGFloat = isPad ? 300 : 200
        let chatPanelViewMaxHeight: CGFloat = isPad ? 400 : kAgoraScreenHeight - 34 - renderTop - 10
        let chatPanelViewMinWidth: CGFloat = 56
        let chatPanelViewMinHeight: CGFloat = chatPanelViewMinWidth
        
        chatView.scaleTouchBlock = { [weak self](isMin) in
            
            guard let `self` = self else {
                return
            }
            
            self.containerView.agora_width = isMin ? chatPanelViewMinWidth : chatPanelViewMaxWidth
            self.containerView.agora_height = isMin ? chatPanelViewMinHeight : chatPanelViewMaxHeight
            self.delegate?.chatController(self, didUpdateSize: isMin)
            UIView.animate(withDuration: 0.35) {
                self.containerView.superview?.layoutIfNeeded()
            } completion: { (_) in
                self.chatView.resizeChatViewFrame()
            }
        }
    }
    
    private func initViews() {
        containerView.backgroundColor = .clear
        containerView.addSubview(chatView)
    }
    
    private func initLayout() {
        chatView.agora_x = 0
        chatView.agora_y = 0
        chatView.agora_right = 0
        chatView.agora_bottom = 0
    }
}

// MARK: - AgoraEduMessageHandler
extension AgoraChatUIController: AgoraEduMessageHandler {
    public func onShowChatTips(_ message: String) {
        AgoraUtils.showToast(message: message)
    }
    
    public func onAddRoomMessage(_ info: AgoraEduContextChatInfo) {
        chatView.onAddRoomMessage(info)
    }
    public func onSendRoomMessageResult(_ error: AgoraEduContextError?, info: AgoraEduContextChatInfo?) {
        chatView.onSendRoomMessageResult(error, info: info)
    }
    public func onFetchHistoryMessagesResult(_ error: AgoraEduContextError?, list: [AgoraEduContextChatInfo]?) {
        chatView.onFetchHistoryMessagesResult(error, list: list)
    }
    
    public func onUpdateChatPermission(_ allow: Bool) {
        chatView.onUpdateChatPermission(allow)
    }
}
