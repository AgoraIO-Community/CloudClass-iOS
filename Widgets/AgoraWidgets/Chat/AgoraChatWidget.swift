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
//    private let vm = AgoraChatVM()
    private let perPageCount = 100
    
    // State
    private var chatType: ChatType = .room {
        didSet {
            switch chatType {
            case .room:
                chatView.maxView.roomChatIfHasPermission(hasRoomChatPermission)
            case .conversation:
                chatView.maxView.conversationChatWithoutPermission()
            }
            
            placeHolderNeedHidden()
        }
    }
    
    private var hasRoomChatPermission: Bool = true {
        didSet {
            switch chatType {
            case .room:
                chatView.maxView.roomChatIfHasPermission(hasRoomChatPermission)
                AgoraToast.toast(msg: roomSilencedChanged(hasRoomChatPermission: hasRoomChatPermission))
            case .conversation:
                chatView.maxView.conversationChatWithoutPermission()
            }
        }
    }
    
    // View
    private let chatView = AgoraUIChatView(frame: .zero)
    
    // Context
//    private weak var context: AgoraEduMessageContext?
    
//    public required override init(widgetId: String,
//                                  properties: [AnyHashable: Any]?) {
//        super.init(widgetId: widgetId,
//                   properties: properties)
//
//        initViews()
//        initLayout()
//        keyboardNotification()
//
////        if let contextPool = properties?["contextPool"] as? AgoraEduContextPool {
////            context = contextPool.chat
////            initData()
////        }
//    }
    
    public override func onMessageReceived(_ message: String) {
        guard let dic = message.json() else {
            return
        }
        
        if let isMin = dic["isMinSize"] as? Bool {
            chatView.isMin = isMin
        }
        
        if let hasConversation = dic["hasConversation"] as? Bool {
            chatView.hasConversation = hasConversation
//            chatView.maxView.tabSelectView?.selectDelegate = self
        }
        
        if let showMinButton = dic["showMinButton"] as? Bool {
            chatView.maxView.titleView.minButton.isHidden = !showMinButton
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Private
private extension AgoraChatWidget {
    func initViews() {
        view.backgroundColor = .clear
        view.addSubview(chatView)
        
//        chatView.maxView.chatTableView.delegate = self
//        chatView.maxView.chatTableView.dataSource = self
        
        let header = AgoraRefreshNormalHeader(refreshingBlock: { [weak self] in
            guard let `self` = self else {
                return
            }
            
//            self.fetchHistoryMessage()
        })
        
        header.stateLabel?.isHidden = true
        header.loadingView?.style = .gray
        
        chatView.maxView.chatTableView.agora_header = header
        
//        chatView.maxView.sendView.textField.delegate = self
        chatView.maxView.sendView.sendButton.addTarget(self,
                                                       action: #selector(sendChatMessage),
                                                       for: .touchUpInside)
        
        chatView.minView.addTarget(self,
                                   action: #selector(maximize),
                                   for: .touchUpInside)
        
        chatView.maxView.titleView.minButton.addTarget(self,
                                                       action: #selector(minimize),
                                                       for: .touchUpInside)
    }
    
    func initLayout() {
        chatView.agora_x = 0
        chatView.agora_y = 0
        chatView.agora_right = 0
        chatView.agora_bottom = 0
    }
    
    func initData() {
//        context?.registerEventHandler(self)
//        fetchAllTypeHistoryMessage()
    }
    
    func keyboardNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(agoraKeyboardDidShow(_ :)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(agoraKeyboardWillHidden(_ :)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    // Keyboard
    @objc func agoraKeyboardDidShow(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let rect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let durationValue = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber else {
            return
        }
        
        chatView.agora_y = -rect.size.height
        chatView.agora_bottom = rect.size.height - UIScreen.agora_safe_area_bottom
        
        let duration = durationValue.doubleValue
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func agoraKeyboardWillHidden(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let durationValue = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber else {
            return
        }
        
        chatView.agora_y = 0
        chatView.agora_bottom = 0
        
        let duration = durationValue.doubleValue
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    func placeHolderNeedHidden() {
//        switch chatType {
//        case .room:
//            chatView.maxView.chatPlaceHolderView.isHidden = (vm.roomMessages.count != 0)
//        case .conversation:
//            chatView.maxView.chatPlaceHolderView.isHidden = (vm.conversationMessages.count != 0)
//        default:
//            return
//        }
    }
}

// MARK: - UI action
private extension AgoraChatWidget {
    @objc func maximize() {
        chatView.isMin = false
        
        let isMin = ["isMinSize": 0]
        if let message = isMin.jsonString() {
            self.sendMessage(message)
        }
    }
    
    @objc func minimize() {
        chatView.isMin = true
        
        let isMin = ["isMinSize": 1]
        if let message = isMin.jsonString() {
            self.sendMessage(message)
        }
    }
    
    @objc func sendChatMessage() {
        guard let message = chatView.maxView.sendView.textField.text,
              message.count > 0 else {
            chatView.endEditing(true)
            return
        }
        
//        switch chatType {
//        case .room:
//            context?.sendRoomMessage(message)
//        case .conversation:
//            context?.sendConversationMessage(message)
//        }
        
        chatView.maxView.sendView.textField.text = nil
    }
}

// MARK: - AgoraEduMessageHandler
//extension AgoraChatWidget: AgoraEduMessageHandler {
//    @objc public func onAddRoomMessage(_ info: AgoraEduContextChatInfo) {
//        vm.appendRoomMessages([info])
//
//        switch chatType {
//        case .conversation:
//            chatView.maxView.tabSelectView?.needRemind(true,
//                                                       index: 0)
//        case .room:
//            let index = vm.roomMessages.count - 1
//
//            DispatchQueue.main.async { [weak self] in
//                guard let `self` = self else {
//                    return
//                }
//
//                self.chatView.maxView.chatTableView.reloadData()
//            }
//
//            DispatchQueue.main.async { [weak self] in
//                guard let `self` = self else {
//                    return
//                }
//
//                self.chatView.maxView.chatTableView.scrollToBottom(index: index)
//            }
//        }
//
//        if (chatView.isMin) {
//            chatView.unreadNum += 1
//        }
//
//        placeHolderNeedHidden()
//    }
//
//    // 收到提问消息
//    @objc public func onAddConversationMessage(_ info: AgoraEduContextChatInfo) {
//        vm.appendConversationMessages([info])
//
//        switch chatType {
//        case .conversation:
//            let index = vm.conversationMessages.count - 1
//
//            DispatchQueue.main.async { [weak self] in
//                guard let `self` = self else {
//                    return
//                }
//
//                self.chatView.maxView.chatTableView.reloadData()
//            }
//
//            DispatchQueue.main.async { [weak self] in
//                guard let `self` = self else {
//                    return
//                }
//
//                self.chatView.maxView.chatTableView.scrollToBottom(index: index)
//            }
//        case .room:
//            chatView.maxView.tabSelectView?.needRemind(true,
//                                                       index: 1)
//        }
//
//        if (chatView.isMin) {
//            chatView.unreadNum += 1
//        }
//
//        placeHolderNeedHidden()
//    }
//
//    @objc public func onSendRoomMessageResult(_ error: AgoraEduContextError?,
//                                              info: AgoraEduContextChatInfo) {
//        if chatType == .room {
//            chatView.maxView.chatTableView.agora_header?.endRefreshing()
//        }
//
//        if let `error` = error {
//            AgoraToast.toast(msg: error.message)
//        }
//
//        placeHolderNeedHidden()
//
//        DispatchQueue.main.async { [weak self] in
//            guard let `self` = self else {
//                return
//            }
//            self.chatView.maxView.chatTableView.reloadData()
//        }
//    }
//
//    // 本地发送提问消息结果（包含首次和后面重发），如果error不为空，代表失败
//    @objc public func onSendConversationMessageResult(_ error: AgoraEduContextError?,
//                                                      info: AgoraEduContextChatInfo?) {
//        if chatType == .conversation {
//            chatView.maxView.chatTableView.agora_header?.endRefreshing()
//        }
//
//        if let `error` = error {
//            AgoraToast.toast(msg: error.message)
//        }
//
//        placeHolderNeedHidden()
//
//        DispatchQueue.main.async { [weak self] in
//            guard let `self` = self else {
//                return
//            }
//            self.chatView.maxView.chatTableView.reloadData()
//        }
//    }
//
//    @objc public func onFetchHistoryMessagesResult(_ error: AgoraEduContextError?,
//                                                   list: [AgoraEduContextChatInfo]?) {
//        if let `list` = list {
//            vm.insertRoomMessage(list)
//
//            if chatType == .room {
//                chatView.maxView.chatTableView.agora_header?.endRefreshing()
//                chatView.maxView.chatTableView.reloadData()
//            }
//        }
//
//        if let `error` = error {
//            AgoraToast.toast(msg: error.message)
//        }
//
//        placeHolderNeedHidden()
//    }
//
//    @objc public func onFetchConversationHistoryMessagesResult(_ error: AgoraEduContextError?,
//                                                               list: [AgoraEduContextChatInfo]?) {
//        if let `list` = list {
//            vm.insertConversationMessage(list)
//
//            if chatType == .conversation {
//                chatView.maxView.chatTableView.agora_header?.endRefreshing()
//                chatView.maxView.chatTableView.reloadData()
//            }
//        }
//
//        if let `error` = error {
//            AgoraToast.toast(msg: error.message)
//        }
//
//        placeHolderNeedHidden()
//    }
//
//    @objc public func onUpdateChatPermission(_ allow: Bool) {
//        hasRoomChatPermission = allow
//    }
//
//    @objc public func onUpdateLocalChatPermission(_ allow: Bool,
//                                                  toUser: AgoraEduContextUserInfo,
//                                                  operatorUser: AgoraEduContextUserInfo) {
//        var text: String
//
//        if allow {
//            text = localUnsilenced(operatorUser: operatorUser.userName)
//        } else {
//            text = localSilenced(operatorUser: operatorUser.userName)
//        }
//
//        hasRoomChatPermission = allow
//        AgoraToast.toast(msg: text)
//    }
//
//    @objc public func onUpdateRemoteChatPermission(_ allow: Bool,
//                                                   toUser: AgoraEduContextUserInfo,
//                                                   operatorUser: AgoraEduContextUserInfo) {
//        var text: String
//
//        if allow {
//            text = remoteUnsilenced(toUser.userName,
//                                    operatorUser: operatorUser.userName)
//        } else {
//            text = remoteSilenced(toUser.userName,
//                                  operatorUser: operatorUser.userName)
//        }
//
//        AgoraToast.toast(msg: text)
//    }
//}

// MARK: - Pull history messages
//private extension AgoraChatWidget {
//    func fetchHistoryMessage() {
//        switch chatType {
//        case .room:
//            let messageId = vm.roomMessages.first?.info.id ?? "0"
//            context?.fetchHistoryMessages(messageId,
//                                          count: perPageCount)
//        case .conversation:
//            let messageId = vm.conversationMessages.first?.info.id ?? "0"
//            context?.fetchConversationHistoryMessages(messageId,
//                                                      count: perPageCount)
//        }
//    }
//
//    func fetchAllTypeHistoryMessage() {
//        let roomMessageId = vm.roomMessages.first?.info.id ?? "0"
//        context?.fetchHistoryMessages(roomMessageId,
//                                      count: perPageCount)
//
//        let conversationMessageId = vm.roomMessages.first?.info.id ?? "0"
//        context?.fetchConversationHistoryMessages(conversationMessageId,
//                                                  count: perPageCount)
//    }
//}

// MARK: - UITableViewDataSource
//extension AgoraChatWidget: UITableViewDataSource {
//    public func numberOfSections(in tableView: UITableView) -> Int {
//        switch chatType {
//        case .room:         return vm.roomMessages.count
//        case .conversation: return vm.conversationMessages.count
//        }
//    }
//
//    public func tableView(_ tableView: UITableView,
//                          numberOfRowsInSection section: Int) -> Int {
//        return 1
//    }
//
//    public func tableView(_ tableView: UITableView,
//                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        var item: AgoraChatItem
//
//        switch chatType {
//        case .room:         item = vm.roomMessages[indexPath.section]
//        case .conversation: item = vm.conversationMessages[indexPath.section]
//        }
//
//        let cell = tableView.dequeueReusableCell(withIdentifier: AgoraChatPanelMessageCell.MessageCellID,
//                                                 for: indexPath) as! AgoraChatPanelMessageCell
//
//        cell.updateView(model: item)
//        cell.delegate = self
//        cell.index = indexPath.section
//        cell.selectionStyle = .none
//        return cell
//    }
//}

// MARK: - UITableViewDelegate
//extension AgoraChatWidget: UITableViewDelegate {
//    public func tableView(_ tableView: UITableView,
//                          heightForRowAt indexPath: IndexPath) -> CGFloat {
//        var item: AgoraChatItem
//
//        switch chatType {
//        case .room:         item = vm.roomMessages[indexPath.section]
//        case .conversation: item = vm.conversationMessages[indexPath.section]
//        }
//
//        return item.cellHeight
//    }
//
//    public func tableView(_ tableView: UITableView,
//                          heightForHeaderInSection section: Int) -> CGFloat {
//        return 1
//    }
//
//    public func tableView(_ tableView: UITableView,
//                          heightForFooterInSection section: Int) -> CGFloat {
//        return 7
//    }
//}

//extension AgoraChatWidget: AgoraChatPanelMessageCellDelegate {
//    func chatCell(_ cell: AgoraBaseUITableViewCell,
//                  didTapRetryOn index: Int) {
//        switch chatType {
//        case .room:
//            let message = vm.roomMessages[index].info
//            context?.resendRoomMessage(message.message,
//                                       messageId: message.id)
//        case .conversation:
//            let message = vm.conversationMessages[index].info
//            context?.resendConversationMessage(message.message,
//                                               messageId: message.id)
//        }
//    }
//}

//extension AgoraChatWidget: AgoraTabSelectViewDelegate {
//    public func view(_ view: AgoraTabSelectView,
//                     didSelectTab index: Int) {
//        let room = 0
//        let conversation = 1
//
//        switch index {
//        case room:
//            chatType = .room
//        case conversation:
//            chatType = .conversation
//        default:
//            return
//        }
//
//        chatView.maxView.chatTableView.reloadData()
//    }
//}

// MARK: - UITextFieldDelegate
//extension AgoraChatWidget: UITextFieldDelegate {
//    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        sendChatMessage()
//        return true
//    }
//
//    public func textFieldDidBeginEditing(_ textField: UITextField) {
//        chatView.addFirstResponderGesture()
//    }
//
//    public func textFieldDidEndEditing(_ textField: UITextField) {
//        chatView.removeFirstResponderGesture()
//    }
//}
