//
//  AgoraChatPanelView.swift
//  AgoraEduSDK
//
//  Created by SRS on 2021/1/31.
//

import AgoraEduContext
import AgoraUIEduBaseViews.AgoraFiles.AgoraRefresh
import AgoraUIBaseViews

@objcMembers public class AgoraUIChatView: AgoraBaseUIView,
                                           UIGestureRecognizerDelegate,
                                           UITableViewDelegate,
                                           UITableViewDataSource {
    enum ChatType {
        case roomMessage, conversation
    }
        
    public var scaleTouchBlock: ((_ min: Bool) -> Void)?
    public weak var context: AgoraEduMessageContext?
    
    public var showMinBtn = true {
        didSet {
            if let btn = self.titleView.viewWithTag(ButtonTag) as? AgoraBaseUIButton {
                btn.isHidden = !showMinBtn
            }
        }
    }
    
    public var showDefaultText = true {
        didSet {
            if let label = self.defaultTableView.viewWithTag(LabelTag) as? AgoraBaseUILabel {
                label.isHidden = !showDefaultText
            }
        }
    }
    
    @objc lazy public var resignFirstResponderGesture: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(tapRecognized(_:)))
        tapGesture.cancelsTouchesInView = false
        tapGesture.isEnabled = true
        tapGesture.delegate = self
        return tapGesture
    }()
    
    public var isMin: Bool = true {
        didSet {
            self.resizeView()
        }
    }
    
    public var hasConversation: Bool = false {
        didSet {
            if hasConversation {
                titleViewHasConversation()
                fetchAllTypeHistoryMessage()
            } else {
                titleViewWithoutConversation()
                fetchHistoryMessage()
            }
        }
    }
    
    public var peerHasPermissiom: Bool = false {
        didSet {
            checkPeerHasPermission(peerHasPermissiom)
        }
    }
    
    private var unreadNum: Int = 0 {
        didSet {
            let label = self.minView.viewWithTag(LabelTag) as! AgoraBaseUILabel
            label.isHidden = true
            if (self.isMin && unreadNum > 0) {
                
                let num = unreadNum > 99 ? "99+" : "\(unreadNum)"
                
                label.isHidden = false
                label.text = "\(num)"
                
                let rect: CGRect = ("\(num)").boundingRect(with: CGSize(width: CGFloat(MAXFLOAT),
                                                                        height: label.agora_height),
                                                           options: .usesLineFragmentOrigin ,
                                                           attributes: [NSAttributedString.Key.font:label.font!],
                                                           context: nil)
                
                label.agora_width = (rect.width > label.agora_width) ? rect.size.width + 4 : label.agora_width
            }
        }
    }
    
    private var chatModels: [AgoraEduContextChatInfo] = [] {
        didSet {
            updateChatTableView()
        }
    }
    
    private var conversationModels: [AgoraEduContextChatInfo] = [] {
        didSet {
            updateChatTableView()
        }
    }
    
    private var chatType: ChatType = .roomMessage {
        didSet {
            updateChatTableView()
            checkPeerHasPermission(peerHasPermissiom)
        }
    }
    
    fileprivate let LabelTag = 99
    fileprivate let ImageTag = 100
    fileprivate let ButtonTag = 101
    fileprivate let InoutCellID = "InoutCellID"
    fileprivate let MessageCellID = "MessageCellID"
    fileprivate let PerPageCount = 100
    
    fileprivate var originalBottom: CGFloat?
    
    fileprivate lazy var maxView: AgoraBaseUIView = {
        let view = AgoraBaseUIView()
        view.backgroundColor = UIColor.white
        view.layer.shadowColor = UIColor(red: 0.18,
                                         green: 0.25,
                                         blue: 0.57,
                                         alpha: 0.15).cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowOpacity = 1
        view.layer.shadowRadius = 6

        return view
    }()
    
    fileprivate lazy var minView: AgoraBaseUIButton = {
        let btn = AgoraBaseUIButton(type: .custom)
        btn.setImage(AgoraKitImage("chat_toast"), for: .normal)
        btn.addTarget(self, action: #selector(onMaxTouchEvent), for: .touchUpInside)
        
        let redLabel = AgoraBaseUILabel()
        redLabel.tag = LabelTag
        redLabel.textAlignment = .center
        redLabel.textColor = UIColor.white
        
        redLabel.font = UIFont.boldSystemFont(ofSize: 8)
        redLabel.backgroundColor = UIColor(red: 240/255.0, green:76/255.0, blue: 54/255.0, alpha: 1)
        btn.addSubview(redLabel)
        
        redLabel.agora_height = AgoraKitDeviceAssistant.OS.isPad ? 14 : 9
        redLabel.agora_width = redLabel.agora_height
        redLabel.agora_right = redLabel.agora_width * 0.4
        redLabel.agora_y = 0
        
        redLabel.clipsToBounds = true
        redLabel.layer.cornerRadius = redLabel.agora_height * 0.5
             
        btn.isHidden = true
        return btn
    }()
    
    fileprivate lazy var titleView: AgoraBaseUIView = {
        let view = AgoraBaseUIView()
        view.backgroundColor = UIColor.clear
        
        let lineV = AgoraBaseUIView()
        lineV.backgroundColor = UIColor(red: 236/255.0, green:236/255.0, blue: 241/255.0, alpha: 1)
        view.addSubview(lineV)
        lineV.agora_x = 0
        lineV.agora_right = 0
        lineV.agora_bottom = 0
        lineV.agora_height = 1
        
        return view
    }()
    
    fileprivate lazy var defaultTableView: AgoraBaseUIView = {
        let v = AgoraBaseUIView()

        let imageV = AgoraBaseUIImageView(image: AgoraKitImage("chat_empty"))
        v.addSubview(imageV)
        imageV.agora_center_x = 0
        imageV.agora_center_y = 0
        imageV.agora_width = 90
        imageV.agora_height = 80
        
        let label = AgoraBaseUILabel()
        label.textColor = UIColor(rgb: 0x7D8798)
        label.textAlignment = .center
        label.text = AgoraKitLocalizedString("ChatEmptyText")
        label.font = UIFont.systemFont(ofSize: 13)
        label.tag = LabelTag
        v.addSubview(label)
        label.agora_x = 0
        label.agora_right = 0
        label.agora_height = 20
        label.agora_center_y = (imageV.agora_height + label.agora_height) * 0.5
        
        return v
    }()
    
    fileprivate lazy var chatPermissionStateView: AgoraBaseUIView = {
        let v = AgoraBaseUIView()
        v.backgroundColor = UIColor(rgb: 0xF9F9FC)
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor(rgb: 0xECECF1).cgColor
    
        let label = AgoraBaseUILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor(rgb: 0x191919)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        
        let attr = NSMutableAttributedString()
        
        let textArt = NSAttributedString(string: AgoraKitLocalizedString("ChatMuteTagText"))
       
        let imageAttachment = NSTextAttachment()
        let image = AgoraKitImage("chat_mute_tag")
        imageAttachment.image = image
        imageAttachment.bounds = CGRect(x: 0, y: -5, width: 18, height: 18)
        let imgAttr = NSAttributedString(attachment: imageAttachment)
        
        attr.append(imgAttr)
        attr.append(NSAttributedString(string: " "))
        attr.append(textArt)
        label.attributedText = attr
        
        v.addSubview(label)
        label.agora_x = 10
        label.agora_right = 10
        label.agora_y = 0
        label.agora_bottom = 0
        
        v.isHidden = true

        return v
    }()
    
    fileprivate lazy var chatTableView: AgoraBaseUITableView = {
        let tableView = AgoraBaseUITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = UIColor.white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 59
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.separatorStyle = .none
        tableView.register(AgoraChatPanelMessageCell.self, forCellReuseIdentifier: MessageCellID)
                        
        tableView.agora_header = AgoraRefreshNormalHeader(refreshingBlock: {[weak self] in
            guard let `self` = self else {
                return
            }
            
            self.fetchHistoryMessage()
        })
        
        let header = tableView.agora_header as? AgoraRefreshNormalHeader
        header?.stateLabel?.isHidden = true
        header?.loadingView?.style = .gray
        
        return tableView
    }()
    
    fileprivate lazy var chatView: AgoraBaseUIView = {
        let view = AgoraBaseUIView()
        view.clipsToBounds = true
        
        view.addSubview(self.titleView)
        self.titleView.agora_x = 0
        self.titleView.agora_right = 0
        self.titleView.agora_y = 0
        self.titleView.agora_height = 44
        
        view.addSubview(self.chatTableView)
//        self.chatTableView.agora_x = 0
//        self.chatTableView.agora_right = 0
//        self.chatTableView.agora_y = self.titleView.agora_height
//        self.chatTableView.agora_bottom = 0

        view.addSubview(self.defaultTableView)
        self.defaultTableView.agora_center_x = 0
        self.defaultTableView.agora_center_y = 20
        self.defaultTableView.agora_width = 90
        self.defaultTableView.agora_height = 100
        
        return view
    }()

    fileprivate weak var textField: AgoraBaseUITextField?
    
    fileprivate lazy var sendView: AgoraBaseUIView = {
        let view = AgoraBaseUIView()
        view.clipsToBounds = true
        view.backgroundColor = UIColor.clear

        let sendContentView = AgoraBaseUIView()
        sendContentView.backgroundColor = UIColor(rgb: 0xF9F9FC)
        view.addSubview(sendContentView)
        sendContentView.agora_x = 0
        sendContentView.agora_right = 0
        sendContentView.agora_y = 0
        sendContentView.agora_bottom = 0
        
        let btn = AgoraBaseUIButton(type: .custom)
        btn.setTitle(AgoraKitLocalizedString("ChatSendText"), for: .normal)
        btn.backgroundColor = UIColor(red: 0.21, green: 0.48, blue: 0.96, alpha: 1)
        btn.clipsToBounds = true
        btn.tag = ButtonTag
        btn.addTarget(self, action: #selector(onSendTouchEvent), for: .touchUpInside)
        sendContentView.addSubview(btn)
        btn.agora_right = 15
        btn.agora_resize(80, 30)
        btn.agora_center_y = 0
        btn.layer.cornerRadius = btn.agora_height * 0.5

        let textField = AgoraBaseUITextField()
        textField.attributedPlaceholder = NSAttributedString(string: AgoraKitLocalizedString("ChatPlaceholderText"),
                                                             attributes:[NSAttributedString.Key.foregroundColor: UIColor(red: 125/255.0,
                                                                                                                         green: 135/255.0,
                                                                                                                         blue: 152/255.0,
                                                                                                                         alpha: 1)])
        textField.font = UIFont.systemFont(ofSize: 13)
        textField.returnKeyType = .send
        textField.delegate = self
        sendContentView.addSubview(textField)
        self.textField = textField
        
        textField.agora_x = 15
        textField.agora_right = 0
        textField.agora_y = 0
        textField.agora_bottom = 0
        
        return view
    }()
    
    private weak var tabSelectView: AgoraTabSelectView?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.initView()
        self.initLayout()
        self.resizeView()
        self.keyboardNotification()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func didMoveToWindow() {
        super.didMoveToWindow()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.updateSendViewBezier()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: UIGestureRecognizerDelegate
    @objc internal func tapRecognized(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            self.window?.resignFirstResponder()
            self.window?.endEditing(true)
        }
    }
    
    // MARK: keyboard action
    @objc fileprivate func keyboardDidShow(_ notification: NSNotification) {
        if let rect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            if (self.originalBottom == nil) {
                self.originalBottom = max(self.agora_bottom, self.agora_safe_bottom)
            }
            self.agora_safe_bottom = rect.size.height + 5
        }
    }
    @objc fileprivate func keyboardWillHidden(_ notification: NSNotification) {
        if let bottom = self.originalBottom {
            self.agora_safe_bottom = bottom
        }
    }
    
    // MARK: touch event
    @objc fileprivate func onSendTouchEvent() {
        
        let message = self.textField?.text ?? ""
        
        if message.count > 0 {
            switch chatType {
            case .roomMessage:
                context?.sendRoomMessage(message)
            case .conversation:
                context?.sendConversationMessage(message)
            }
        }
        
        self.textField?.text = nil
        self.textField?.resignFirstResponder()
    }
    
    @objc fileprivate func onMinTouchEvent() {
        if self.scaleTouchBlock != nil {
            self.isMin = true
            self.scaleTouchBlock?(self.isMin)
        }
    }
    @objc fileprivate func onMaxTouchEvent() {
        if self.scaleTouchBlock != nil {
            self.isMin = false
            self.scaleTouchBlock?(self.isMin)
        }
    }
    
    // MARK: UITableViewDelegate & UITableViewDataSource
    public func numberOfSections(in tableView: UITableView) -> Int {
        switch chatType {
        case .roomMessage:  return chatModels.count
        case .conversation: return conversationModels.count
        }
    }
    
    public func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var chatModel: AgoraEduContextChatInfo
        
        switch chatType {
        case .roomMessage:  chatModel = chatModels[indexPath.section]
        case .conversation: chatModel = conversationModels[indexPath.section]
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: MessageCellID,
                                                 for: indexPath) as! AgoraChatPanelMessageCell
        cell.updateView(model: chatModel)
        cell.retryTouchBlock = { [weak self] (infoModel: AgoraEduContextChatInfo?) -> Void in
            guard let `self` = self,
                  let model = infoModel else {
                return
            }
            
            switch self.chatType {
            case .roomMessage:
                self.context?.resendRoomMessage(model.message,
                                                messageId: model.id)
            case .conversation:
                self.context?.resendConversationMessage(model.message,
                                                        messageId: model.id)
            }
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    public func tableView(_ tableView: UITableView,
                          heightForRowAt indexPath: IndexPath) -> CGFloat {
        var chatModel: AgoraEduContextChatInfo
        
        switch chatType {
        case .roomMessage:  chatModel = chatModels[indexPath.section]
        case .conversation: chatModel = conversationModels[indexPath.section]
        }
        
        return chatModel.cellHeight
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

// MARK: Keyboard
private extension AgoraUIChatView {
    func keyboardNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardDidShow(_ :)),
                                               name: UIResponder.keyboardDidShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHidden(_ :)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
}

// MARK: Rect
private extension AgoraUIChatView {
    func initView() {
        self.backgroundColor = UIColor.clear
        self.addSubview(self.maxView)
        self.addSubview(self.minView)

        self.maxView.addSubview(self.sendView)
        self.maxView.addSubview(self.chatView)
        self.maxView.addSubview(self.chatPermissionStateView)
    }
    
    func updateSendViewBezier() {
        if self.isMin {
            return
        }
        
        let maskPath = UIBezierPath(roundedRect: self.sendView.bounds,
                                    byRoundingCorners: [UIRectCorner.topLeft, UIRectCorner.topRight],
                                    cornerRadii: self.sendView.bounds.size)
        
        let roundLayer = CAShapeLayer()
        roundLayer.frame = self.sendView.bounds
        roundLayer.path = maskPath.cgPath
        self.sendView.layer.mask = roundLayer;
        
        let lineLayer = CAShapeLayer()
        lineLayer.frame = self.sendView.bounds
        lineLayer.path = maskPath.cgPath
        lineLayer.lineWidth = 1
        lineLayer.strokeColor = UIColor(rgb: 0xECECF1).cgColor
        lineLayer.fillColor = UIColor.clear.cgColor
        self.sendView.layer.addSublayer(lineLayer)
    }
    
    func initLayout() {
        self.maxView.agora_x = 0
        self.maxView.agora_y = 0
        self.maxView.agora_bottom = 0
        self.maxView.agora_right = 0

        self.sendView.agora_bottom = 0
        self.sendView.agora_x = 0
        self.sendView.agora_right = 0
        self.sendView.agora_height = 60

        self.chatView.agora_x = 0
        self.chatView.agora_right = 0
        self.chatView.agora_bottom = self.sendView.agora_bottom + self.sendView.agora_height
        self.chatView.agora_y = 0
        self.chatView.layer.cornerRadius = 4

        self.minView.agora_x = 0
        self.minView.agora_y = 0
        self.minView.agora_right = 0
        self.minView.agora_bottom = 0
        
        self.chatPermissionStateView.agora_x = 0
        self.chatPermissionStateView.agora_right = 0
        self.chatPermissionStateView.agora_y = self.titleView.agora_height + self.titleView.agora_y - 1
        self.chatPermissionStateView.agora_height = 32
    }
    
    func resizeView() {
        if (self.isMin) {
            self.minView.isHidden = false
       
            self.unreadNum = 0
        
            self.maxView.isHidden = true
            self.textField?.agora_right = 0
            self.chatView.agora_bottom = 0
  
        } else {
            self.minView.isHidden = true
            self.maxView.isHidden = false
            
            let sendBtn = self.sendView.viewWithTag(ButtonTag) as! AgoraBaseUIButton
            self.textField?.agora_right = sendBtn.agora_width + sendBtn.agora_right + 10

            let gap: CGFloat = 8
            self.chatView.agora_bottom = self.sendView.agora_bottom + self.sendView.agora_height + gap
        }
    }
}

// MARK: Title view
private extension AgoraUIChatView {
    func titleViewWithoutConversation() {
        let label = AgoraBaseUILabel()
        label.textColor = UIColor(red: 25/255.0,
                                  green:25/255.0,
                                  blue: 25/255.0,
                                  alpha: 1)
        label.font = UIFont.systemFont(ofSize: 13)
        label.tag = LabelTag
    
        let chatMsg = AgoraKitLocalizedString("ChatText")
        label.text = chatMsg
        titleView.addSubview(label)
        
        label.agora_x = 15
        label.agora_y = 0
        label.agora_bottom = 0
        label.agora_width = 100

        let btn = AgoraBaseUIButton(type: .custom)
        btn.setImage(AgoraKitImage("chat_min"), for: .normal)
        btn.addTarget(self,
                      action: #selector(onMinTouchEvent),
                      for: .touchUpInside)
        titleView.addSubview(btn)
        btn.tag = ButtonTag
        
        btn.agora_center_y = 0
        btn.agora_right = 15
        btn.agora_resize(24, 24)
    }
    
    func titleViewHasConversation() {
        let view = AgoraTabSelectView(frame: .zero)
        view.selectDelegate = self
        view.alignment = .left
        view.underlineColor = UIColor(rgb: 0x357BF6)
        
        view.selectedTitle = AgoraTabSelectView.TitleProperty(color: UIColor(rgb: 0x191919),
                                                              font: UIFont.systemFont(ofSize: 13, weight: .bold))
        view.unselectedTitle = AgoraTabSelectView.TitleProperty(color: UIColor(rgb: 0x7B88A0),
                                                                font: UIFont.systemFont(ofSize: 13))
        
        view.underlineHeight = 2
        view.underlineExtralWidth = 10
        view.insets = UIEdgeInsets(top: 0,
                                   left: 14,
                                   bottom: 0,
                                   right: 14)
        
        titleView.addSubview(view)
        
        view.agora_x = 0
        view.agora_y = 0
        view.agora_right = 0
        view.agora_bottom = 0
        
        let chat = AgoraKitLocalizedString("ChatText")
        let conversation = AgoraKitLocalizedString("ChatConversation")
        view.update([chat, conversation])
        
        tabSelectView = view
        
        let btn = AgoraBaseUIButton(type: .custom)
        btn.setImage(AgoraKitImage("chat_min"),
                     for: .normal)
        btn.addTarget(self,
                      action: #selector(onMinTouchEvent),
                      for: .touchUpInside)
        titleView.addSubview(btn)
        btn.tag = ButtonTag
        
        btn.agora_center_y = 0
        btn.agora_right = 15
        btn.agora_resize(24, 24)
    }
}

private extension AgoraUIChatView {
    func fetchHistoryMessage() {
        switch chatType {
        case .roomMessage:
            context?.fetchHistoryMessages(self.chatModels.first?.id ?? "0",
                                          count: self.PerPageCount)
        case .conversation:
            context?.fetchConversationHistoryMessages(self.conversationModels.first?.id ?? "0",
                                                      count: self.PerPageCount)
        }
    }
    
    func fetchAllTypeHistoryMessage() {
        context?.fetchHistoryMessages(self.chatModels.first?.id ?? "0",
                                      count: self.PerPageCount)
        
        context?.fetchConversationHistoryMessages(self.conversationModels.first?.id ?? "0",
                                                  count: self.PerPageCount)
    }
    
    func updateChatTableView() {
        chatTableView.reloadData()
        
        switch chatType {
        case .roomMessage:
            defaultTableView.isHidden = !(chatModels.count == 0)
        case .conversation:
            defaultTableView.isHidden = !(conversationModels.count == 0)
        }
    }
    
    func checkPeerHasPermission(_ permission: Bool) {
        guard chatType == .roomMessage else {
            let sendBtn = sendView.viewWithTag(ButtonTag) as? AgoraBaseUIButton
            sendBtn?.isEnabled = true
            textField?.isUserInteractionEnabled = true
            
            
            textField?.attributedPlaceholder = NSAttributedString(string: AgoraKitLocalizedString("ChatPlaceholderText"),
                                                                  attributes:[NSAttributedString.Key.foregroundColor: UIColor(red: 125/255.0,
                                                                                                                              green: 135/255.0,
                                                                                                                              blue: 152/255.0,
                                                                                                                              alpha: 1)])
            chatPermissionStateView.isHidden = true
            return
        }
        
        textField?.isUserInteractionEnabled = permission
        chatPermissionStateView.isHidden = permission
        let sendBtn = sendView.viewWithTag(ButtonTag) as? AgoraBaseUIButton
        sendBtn?.isEnabled = permission
        
        if permission {
            textField?.attributedPlaceholder = NSAttributedString(string: AgoraKitLocalizedString("ChatPlaceholderText"),
                                                                  attributes:[NSAttributedString.Key.foregroundColor: UIColor(red: 125/255.0,
                                                                                                                              green: 135/255.0,
                                                                                                                              blue: 152/255.0,
                                                                                                                              alpha: 1)])
        } else {
            textField?.attributedPlaceholder = NSAttributedString(string: AgoraKitLocalizedString("ChatSilencedPlaceholderText"),
                                                                  attributes:[NSAttributedString.Key.foregroundColor: UIColor(red: 125/255.0,
                                                                                                                              green: 135/255.0,
                                                                                                                              blue: 152/255.0,
                                                                                                                              alpha: 1)])
        }
    }
}

extension AgoraUIChatView: AgoraTabSelectViewDelegate {
    public func view(_ view: AgoraTabSelectView,
                     didSelectTab index: Int) {
        let roomMessage = 0
        let conversation = 1
        
        switch index {
        case roomMessage:
            chatType = .roomMessage
        case conversation:
            chatType = .conversation
        default:
            break
        }
    }
}

// MARK: UITextFieldDelegate
extension AgoraUIChatView: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.onSendTouchEvent()
        return true
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        self.window?.becomeFirstResponder()
        self.window?.addGestureRecognizer(self.resignFirstResponderGesture)
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        self.window?.removeGestureRecognizer(self.resignFirstResponderGesture)
    }
}

// MARK: Private
extension AgoraUIChatView {
    public func resizeChatViewFrame() {
        chatView.layoutIfNeeded()
        chatTableView.frame = CGRect(x: 0,
                                     y: self.titleView.agora_height,
                                     width: self.chatView.frame.width,
                                     height: self.chatView.frame.height - self.titleView.agora_height)
    }
}

private extension AgoraUIChatView {
    func scrollToBottom() {
        var section: Int
        
        switch chatType {
        case .roomMessage:
            if chatModels.count <= 1 {
                return
            }
            section = chatModels.count - 1
        case .conversation:
            if conversationModels.count <= 1 {
                return
            }
            section = conversationModels.count - 1
        }
        
        let indexPath = IndexPath(row: 0,
                                  section: section)
//        chatTableView.scrollToRow(at: indexPath,
//                                  at: .bottom,
//                                  animated: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.chatTableView.scrollToRow(at: indexPath,
                                           at: .bottom,
                                           animated: false)
        }
    }
}

// MARK: AgoraEduMessageHandler
public extension AgoraUIChatView {
    func onAddRoomMessage(_ info: AgoraEduContextChatInfo) {
        if info.from == .remote {
            chatModels.append(info)
            scrollToBottom()
            if (self.isMin) {
                self.unreadNum += 1
            }
            
            if hasConversation,
               chatType == .conversation {
                tabSelectView?.needRemind(true,
                                          index: 0)
            }
        } else {
            onSendRoomMessageResult(nil,
                                    info: info)
        }
    }
    
    func onAddConversationMessage(_ info: AgoraEduContextChatInfo) {
        if info.from == .remote {
            conversationModels.append(info)
            scrollToBottom()
            
            if (self.isMin) {
                self.unreadNum += 1
            }
            
            if chatType == .roomMessage {
                tabSelectView?.needRemind(true,
                                          index: 1)
            }
        } else {
            onSendConversationMessageResult(nil,
                                            info: info)
        }
    }
    
    func onSendRoomMessageResult(_ error: AgoraEduContextError?,
                                 info: AgoraEduContextChatInfo?) {
        if let err = error {
            AgoraUtils.showToast(message: err.message)
            return
        }
        
        guard let messageInfo = info else {
            return
        }
        
        // 更新对应的cell
        if let index = try? self.chatModels.firstIndex(where: { (chatInfo) -> Bool in
            return chatInfo.id == messageInfo.id
        }) {
            let indexPath = IndexPath(row: 0, section: index)
            self.chatModels[index] = messageInfo
            self.chatTableView.reloadSections(IndexSet(indexPath),
                                              with: .automatic)
        } else {
            self.chatModels.append(messageInfo)
            // 第一次接受到自己发送的数据，需要滚动下最下面
            if info!.sendState == .inProgress {
                self.scrollToBottom()
            }
        }
    }
    
    func onSendConversationMessageResult(_ error: AgoraEduContextError?,
                                         info: AgoraEduContextChatInfo?) {
        if let `error` = error {
            AgoraUtils.showToast(message: error.message)
            return
        }
        
        guard let messageInfo = info else {
            return
        }
        
        // 更新对应的cell
        if let index = try? self.conversationModels.firstIndex(where: { (chatInfo) -> Bool in
            return chatInfo.id == messageInfo.id
        }) {
            let indexPath = IndexPath(row: 0, section: index)
            self.conversationModels[index] = messageInfo
            self.chatTableView.reloadSections(IndexSet(indexPath),
                                              with: .automatic)
        } else {
            self.conversationModels.append(messageInfo)
            // 第一次接受到自己发送的数据，需要滚动下最下面
            if info!.sendState == .inProgress {
                self.scrollToBottom()
            }
        }
    }
    
    // 1/2
    func onFetchHistoryMessagesResult(_ error: AgoraEduContextError?,
                                      list: [AgoraEduContextChatInfo]?) {
        self.chatTableView.agora_header?.endRefreshing()
        
        if let err = error {
            AgoraUtils.showToast(message: err.message)
            return
        }
        
        if let infos = list {
            self.chatModels.insert(contentsOf: infos, at: 0)
        }
    }
    
    func onFetchConversationHistoryMessagesResult(_ error: AgoraEduContextError?,
                                                  list: [AgoraEduContextChatInfo]?) {
        chatTableView.agora_header?.endRefreshing()
        
        if let err = error {
            AgoraUtils.showToast(message: err.message)
            return
        }
        
        if let infos = list {
            conversationModels.insert(contentsOf: infos,
                                      at: 0)
        }
    }
    
    func onUpdateChatPermission(_ allow: Bool) {
        peerHasPermissiom = allow
    }
}
