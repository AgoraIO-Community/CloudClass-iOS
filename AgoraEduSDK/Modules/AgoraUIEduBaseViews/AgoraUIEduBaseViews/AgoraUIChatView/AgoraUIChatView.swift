//
//  AgoraChatPanelView.swift
//  AgoraEduSDK
//
//  Created by SRS on 2021/1/31.
//

import AgoraEduContext
import AgoraUIEduBaseViews.AgoraFiles.AgoraRefresh
import AgoraUIBaseViews

@objcMembers public class AgoraUIChatView: AgoraBaseUIView {
    
    public var scaleTouchBlock: ((_ min: Bool) -> Void)?
    public weak var context: AgoraEduMessageContext? {
        didSet {
            context?.fetchHistoryMessages(self.chatModels.first?.id ?? 0, count: PerPageCount)
        }
    }
    
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
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapRecognized(_:)))
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
    
    fileprivate var unreadNum: Int = 0 {
        didSet {
            let label = self.minView.viewWithTag(LabelTag) as! AgoraBaseUILabel
            label.isHidden = true
            if (self.isMin && unreadNum > 0) {
                
                let num = unreadNum > 99 ? "99+" : "\(unreadNum)"
                
                label.isHidden = false
                label.text = "\(num)"
                
                let rect: CGRect = ("\(num)").boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: label.agora_height), options: .usesLineFragmentOrigin , attributes: [NSAttributedString.Key.font:label.font!], context: nil)
                
                label.agora_width = (rect.width > label.agora_width) ? rect.size.width + 4 : label.agora_width
            }
        }
    }
    fileprivate var chatModels: [AgoraEduContextChatInfo] = [] {
        didSet {
            self.chatTableView.reloadData()
            self.defaultTableView.isHidden = !(chatModels.count == 0)
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
        view.layer.shadowColor = UIColor(red: 0.18, green: 0.25, blue: 0.57, alpha: 0.15).cgColor
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
        
        let label = AgoraBaseUILabel()
        label.textColor = UIColor(red: 25/255.0, green:25/255.0, blue: 25/255.0, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 13)
        label.tag = LabelTag
    
        let chatMsg = AgoraKitLocalizedString("ChatText")
        label.text = chatMsg
        view.addSubview(label)
        
        label.agora_x = 15
        label.agora_y = 0
        label.agora_bottom = 0
        label.agora_width = 100

        let btn = AgoraBaseUIButton(type: .custom)
        btn.setImage(AgoraKitImage("chat_min"), for: .normal)
        btn.addTarget(self, action: #selector(onMinTouchEvent), for: .touchUpInside)
        view.addSubview(btn)
        btn.tag = ButtonTag
        
        btn.agora_center_y = 0
        btn.agora_right = 15
        btn.agora_resize(24, 24)
        
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
            self.context?.fetchHistoryMessages(self.chatModels.first?.id ?? 0, count: self.PerPageCount)
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
                                                             attributes:[NSAttributedString.Key.foregroundColor: UIColor(red: 125/255.0, green: 135/255.0, blue: 152/255.0, alpha: 1)])
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
}

// MARK: UITableViewDelegate & UITableViewDataSource
extension AgoraUIChatView: UITableViewDelegate, UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return chatModels.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let chatModel = chatModels[indexPath.section]
        let cell = tableView.dequeueReusableCell(withIdentifier: MessageCellID, for: indexPath) as! AgoraChatPanelMessageCell
        cell.updateView(model: chatModel)
        cell.retryTouchBlock = {[weak self] (infoModel: AgoraEduContextChatInfo?) -> Void in
            guard let `self` = self, let model = infoModel else {
                return
            }
            self.context?.resendRoomMessage(model.message, messageId: model.id)
        }
        cell.selectionStyle = .none
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let chatModel = chatModels[indexPath.section]
        return chatModel.cellHeight
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }

    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 7
    }
}

// MARK: Keyboard
extension AgoraUIChatView {
    fileprivate func keyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(_ :)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHidden(_ :)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
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
}

// MARK: Rect
extension AgoraUIChatView {
    fileprivate func initView() {
        self.backgroundColor = UIColor.clear
        self.addSubview(self.maxView)
        self.addSubview(self.minView)

        self.maxView.addSubview(self.sendView)
        self.maxView.addSubview(self.chatView)
        self.maxView.addSubview(self.chatPermissionStateView)
    }
    
    fileprivate func updateSendViewBezier() {

        if self.isMin {
            return
        }
        
        let maskPath = UIBezierPath(roundedRect: self.sendView.bounds,
                                    byRoundingCorners: [UIRectCorner.topLeft, UIRectCorner.topRight], cornerRadii: self.sendView.bounds.size)
        
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
    
    fileprivate func initLayout() {
        
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
    
    fileprivate func resizeView() {
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

// MARK: TouchEvent
extension AgoraUIChatView {
    @objc fileprivate func onSendTouchEvent() {

        let message = self.textField?.text ?? ""
        if message.count > 0 {
            self.context?.sendRoomMessage(message)
        }
        
        self.textField?.text = nil
        self.textField?.resignFirstResponder()
    }
    
    fileprivate func scrollToBottom() {

        if (self.chatModels.count <= 1) {
            return
        }
        
        let indexPath = IndexPath(row: 0, section: self.chatModels.count - 1)
        self.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
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
}

// MARK: AgoraEduMessageHandler
extension AgoraUIChatView {
    
    public func onAddRoomMessage(_ info: AgoraEduContextChatInfo) {
        if info.from == .remote {
            self.chatModels.append(info)
            self.scrollToBottom()
            if (self.isMin) {
                self.unreadNum += 1
            }
        } else {
            self.onSendRoomMessageResult(nil, info: info)
        }
    }
    
    public func onSendRoomMessageResult(_ error: AgoraEduContextError?, info: AgoraEduContextChatInfo?) {
        
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
            self.chatTableView.reloadSections(IndexSet(indexPath), with: .automatic)
        } else {
            self.chatModels.append(messageInfo)
            // 第一次接受到自己发送的数据，需要滚动下最下面
            if info!.sendState == .inProgress {
                self.scrollToBottom()
            }
        }
    }
    
    // 1/2
    public func onFetchHistoryMessagesResult(_ error: AgoraEduContextError?, list: [AgoraEduContextChatInfo]?) {
        
        self.chatTableView.agora_header?.endRefreshing()
        
        if let err = error {
            AgoraUtils.showToast(message: err.message)
            return
        }
        
        if let infos = list {
            self.chatModels.insert(contentsOf: infos, at: 0)
        }
    }
    
    public func onUpdateChatPermission(_ allow: Bool) {
        
        let sendBtn = self.sendView.viewWithTag(ButtonTag) as? AgoraBaseUIButton
        sendBtn?.isEnabled = allow
        
        self.textField?.text = ""
        self.textField?.placeholder = allow ? AgoraKitLocalizedString("ChatPlaceholderText") : AgoraKitLocalizedString("ChatDisableText")
        self.textField?.isEnabled = allow

        self.chatPermissionStateView.isHidden = allow
    }
}

// MARK: UIGestureRecognizerDelegate
extension AgoraUIChatView: UIGestureRecognizerDelegate {
    @objc internal func tapRecognized(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            self.window?.resignFirstResponder()
            self.window?.endEditing(true)
        }
    }
}
