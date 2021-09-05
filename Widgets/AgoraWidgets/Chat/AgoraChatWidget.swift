//
//  AgoraChatUIController.swift
//  AgoraUIEduAppViews
//
//  Created by SRS on 2021/4/16.
//

import AgoraUIBaseViews
import AgoraUIEduBaseViews
import AgoraWidget
import AgoraEduContext

enum ChatType {
    case room, conversation
}

@objcMembers public class AgoraChatWidget: AgoraBaseWidget {
    // 距离上面的值， 等于navView的高度
    private let renderTop: CGFloat = UIDevice.current.isPad ? 44 : 34
    
    // Datasource
    private let vm = AgoraChatVM()
    private let perPageCount = 100
    
    // State
    private var chatType: ChatType = .room {
        didSet {
            switch chatType {
            case .room:
                chatView.roomChatIfHasPermission(hasRoomChatPermission)
            case .conversation:
                chatView.conversationChatWithoutPermission()
            }
            
            placeHolderNeedHidden()
        }
    }
    
    private var hasRoomChatPermission: Bool = true {
        didSet {
            switch chatType {
            case .room:
                chatView.roomChatIfHasPermission(hasRoomChatPermission)
                AgoraUtils.showToast(message: roomSilencedChanged(hasRoomChatPermission: hasRoomChatPermission))
            case .conversation:
                chatView.conversationChatWithoutPermission()
            }
        }
    }
    
    // View
    private let chatView = AgoraUIChatView(frame: .zero)
    
    // Context
    private weak var context: AgoraEduMessageContext?
    
    public required override init(widgetId: String,
                                  properties: [AnyHashable: Any]?) {
        super.init(widgetId: widgetId,
                   properties: properties)
        
        initViews()
        initLayout()
        
        if let contextPool = properties?["contextPool"] as? AgoraEduContextPool {
            context = contextPool.chat
            initData()
        }
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
            chatView.tabSelectView?.selectDelegate = self
        }
    }
}

// MARK: - Private
private extension AgoraChatWidget {
    func initViews() {
        containerView.backgroundColor = .clear
        containerView.addSubview(chatView)
        
        chatView.chatTableView.delegate = self
        chatView.chatTableView.dataSource = self
        
        let header = AgoraRefreshNormalHeader(refreshingBlock: { [weak self] in
            guard let `self` = self else {
                return
            }
            
            self.fetchHistoryMessage()
        })
        
        header.stateLabel?.isHidden = true
        header.loadingView?.style = .gray
        
        chatView.chatTableView.agora_header = header
        
        chatView.sendView.textField.delegate = self
        chatView.sendView.sendButton.addTarget(self,
                                               action: #selector(sendChatMessage),
                                               for: .touchUpInside)
    }
    
    func initLayout() {
        chatView.agora_x = 0
        chatView.agora_y = 0
        chatView.agora_right = 0
        chatView.agora_bottom = 0
    }
    
    func initData() {
        context?.registerEventHandler(self)
        fetchAllTypeHistoryMessage()
        initChatViewBehavior()
    }
    
    func initChatViewBehavior() {
        let isPad = UIDevice.current.isPad
        let kAgoraScreenHeight: CGFloat = min(UIScreen.agora_width,
                                              UIScreen.agora_height)
        
        let chatPanelViewMaxWidth: CGFloat = (isPad ? 300 : 200)
        let chatPanelViewMaxHeight: CGFloat = (isPad ? 400 : kAgoraScreenHeight - 34 - renderTop - 10)
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
        
        if UIDevice.current.isPad {
            chatView.showDefaultText = true
        }
        
        UIView.animate(withDuration: 0.25) {
            
        } completion: { (_) in
            self.chatView.resizeChatViewFrame()
        }
    }
    
    func placeHolderNeedHidden() {
        switch chatType {
        case .room:
            chatView.chatPlaceHolderView.isHidden = (vm.roomMessages.count != 0)
        case .conversation:
            chatView.chatPlaceHolderView.isHidden = (vm.conversationMessages.count != 0)
        default:
            return
        }
    }
}

// MARK: - AgoraEduMessageHandler
extension AgoraChatWidget: AgoraEduMessageHandler {
    @objc public func onAddRoomMessage(_ info: AgoraEduContextChatInfo) {
        vm.appendRoomMessages([info])
        
        switch chatType {
        case .conversation:
            chatView.tabSelectView?.needRemind(true,
                                               index: 0)
        case .room:
            let index = vm.roomMessages.count - 1
            
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else {
                    return
                }
                
                self.chatView.chatTableView.reloadData()
            }
            
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else {
                    return
                }
                
                self.chatView.chatTableView.scrollToBottom(index: index)
            }
        }
        
        if (chatView.isMin) {
            chatView.unreadNum += 1
        }
        
        placeHolderNeedHidden()
    }
    
    // 收到提问消息
    @objc public func onAddConversationMessage(_ info: AgoraEduContextChatInfo) {
        vm.appendConversationMessages([info])
        
        switch chatType {
        case .conversation:
            let index = vm.conversationMessages.count - 1
            
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else {
                    return
                }
                
                self.chatView.chatTableView.reloadData()
            }
            
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else {
                    return
                }
                
                self.chatView.chatTableView.scrollToBottom(index: index)
            }
        case .room:
            chatView.tabSelectView?.needRemind(true,
                                               index: 1)
        }
        
        if (chatView.isMin) {
            chatView.unreadNum += 1
        }
        
        placeHolderNeedHidden()
    }
    
    @objc public func onSendRoomMessageResult(_ error: AgoraEduContextError?,
                                              info: AgoraEduContextChatInfo?) {
        if chatType == .room {
            chatView.chatTableView.agora_header?.endRefreshing()
        }
        
        if let `error` = error {
            AgoraUtils.showToast(message: error.message)
        }
        
        placeHolderNeedHidden()
        
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else {
                return
            }
            self.chatView.chatTableView.reloadData()
        }
    }
    
    // 本地发送提问消息结果（包含首次和后面重发），如果error不为空，代表失败
    @objc public func onSendConversationMessageResult(_ error: AgoraEduContextError?,
                                                      info: AgoraEduContextChatInfo?) {
        if chatType == .conversation {
            chatView.chatTableView.agora_header?.endRefreshing()
        }
        
        if let `error` = error {
            AgoraUtils.showToast(message: error.message)
        }
        
        placeHolderNeedHidden()
        
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else {
                return
            }
            self.chatView.chatTableView.reloadData()
        }
    }
    
    @objc public func onFetchHistoryMessagesResult(_ error: AgoraEduContextError?,
                                                   list: [AgoraEduContextChatInfo]?) {
        if let `list` = list {
            vm.insertRoomMessage(list)
            
            if chatType == .room {
                chatView.chatTableView.agora_header?.endRefreshing()
                chatView.chatTableView.reloadData()
            }
        }
        
        if let `error` = error {
            AgoraUtils.showToast(message: error.message)
        }
        
        placeHolderNeedHidden()
    }
    
    @objc public func onFetchConversationHistoryMessagesResult(_ error: AgoraEduContextError?,
                                                               list: [AgoraEduContextChatInfo]?) {
        if let `list` = list {
            vm.insertConversationMessage(list)
            
            if chatType == .conversation {
                chatView.chatTableView.agora_header?.endRefreshing()
                chatView.chatTableView.reloadData()
            }
        }
        
        if let `error` = error {
            AgoraUtils.showToast(message: error.message)
        }
        
        placeHolderNeedHidden()
    }
    
    @objc public func onUpdateChatPermission(_ allow: Bool) {
        hasRoomChatPermission = allow
    }
    
    @objc public func onUpdateLocalChatPermission(_ allow: Bool,
                                                  toUser: AgoraEduContextUserInfo,
                                                  operatorUser: AgoraEduContextUserInfo) {
        var text: String
        
        if allow {
            text = localUnsilenced(operatorUser: operatorUser.userName)
        } else {
            text = localSilenced(operatorUser: operatorUser.userName)
        }
        
        hasRoomChatPermission = allow
        AgoraUtils.showToast(message: text)
    }
    
    @objc public func onUpdateRemoteChatPermission(_ allow: Bool,
                                                   toUser: AgoraEduContextUserInfo,
                                                   operatorUser: AgoraEduContextUserInfo) {
        var text: String
        
        if allow {
            text = remoteUnsilenced(toUser.userName,
                                    operatorUser: operatorUser.userName)
        } else {
            text = remoteSilenced(toUser.userName,
                                  operatorUser: operatorUser.userName)
        }
        
        AgoraUtils.showToast(message: text)
    }
}

// MARK: - Pull history messages
private extension AgoraChatWidget {
    func fetchHistoryMessage() {
        switch chatType {
        case .room:
            let messageId = vm.roomMessages.first?.info.id ?? "0"
            context?.fetchHistoryMessages(messageId,
                                          count: perPageCount)
        case .conversation:
            let messageId = vm.conversationMessages.first?.info.id ?? "0"
            context?.fetchConversationHistoryMessages(messageId,
                                                      count: perPageCount)
        }
    }

    func fetchAllTypeHistoryMessage() {
        let roomMessageId = vm.roomMessages.first?.info.id ?? "0"
        context?.fetchHistoryMessages(roomMessageId,
                                      count: perPageCount)

        let conversationMessageId = vm.roomMessages.first?.info.id ?? "0"
        context?.fetchConversationHistoryMessages(conversationMessageId,
                                                  count: perPageCount)
    }
}

// MARK: - Send message
private extension AgoraChatWidget {
    @objc func sendChatMessage() {
        guard let message = chatView.sendView.textField.text,
              message.count > 0 else {
            return
        }
        
        switch chatType {
        case .room:
            context?.sendRoomMessage(message)
        case .conversation:
            context?.sendConversationMessage(message)
        }
        
        chatView.sendView.textField.text = nil
        chatView.sendView.textField.resignFirstResponder()
    }
}

// MARK: - UITableViewDataSource
extension AgoraChatWidget: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        switch chatType {
        case .room:         return vm.roomMessages.count
        case .conversation: return vm.conversationMessages.count
        }
    }

    public func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    public func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var item: AgoraChatItem

        switch chatType {
        case .room:         item = vm.roomMessages[indexPath.section]
        case .conversation: item = vm.conversationMessages[indexPath.section]
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: AgoraChatPanelMessageCell.MessageCellID,
                                                 for: indexPath) as! AgoraChatPanelMessageCell
        
        cell.updateView(model: item)
        cell.delegate = self
        cell.index = indexPath.section
        cell.selectionStyle = .none
        return cell
    }
}

// MARK: - UITableViewDelegate
extension AgoraChatWidget: UITableViewDelegate {
    public func tableView(_ tableView: UITableView,
                          heightForRowAt indexPath: IndexPath) -> CGFloat {
        var item: AgoraChatItem
        
        switch chatType {
        case .room:         item = vm.roomMessages[indexPath.section]
        case .conversation: item = vm.conversationMessages[indexPath.section]
        }

        return item.cellHeight
    }
    
    public func tableView(_ tableView: UITableView,
                          heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }

    public func tableView(_ tableView: UITableView,
                          heightForFooterInSection section: Int) -> CGFloat {
        return 7
    }
}

extension AgoraChatWidget: AgoraChatPanelMessageCellDelegate {
    func chatCell(_ cell: AgoraBaseUITableViewCell,
                  didTapRetryOn index: Int) {
        switch chatType {
        case .room:
            let message = vm.roomMessages[index].info
            context?.resendRoomMessage(message.message,
                                       messageId: message.id)
        case .conversation:
            let message = vm.conversationMessages[index].info
            context?.resendConversationMessage(message.message,
                                       messageId: message.id)
        }
    }
}

extension AgoraChatWidget: AgoraTabSelectViewDelegate {
    public func view(_ view: AgoraTabSelectView,
                     didSelectTab index: Int) {
        let room = 0
        let conversation = 1
        
        switch index {
        case room:
            chatType = .room
        case conversation:
            chatType = .conversation
        default:
            return
        }
        
        chatView.chatTableView.reloadData()
    }
}

// MARK: - UITextFieldDelegate
extension AgoraChatWidget: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendChatMessage()
        return true
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        chatView.addFirstResponderGesture()
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        chatView.removeFirstResponderGesture()
    }
}
