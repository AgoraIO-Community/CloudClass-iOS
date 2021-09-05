//
//  AgoraChatPanelView.swift
//  AgoraEduSDK
//
//  Created by SRS on 2021/1/31.
//

import AgoraUIEduBaseViews.AgoraFiles.AgoraRefresh
import AgoraUIBaseViews
import AgoraEduContext

class AgoraUIChatView: AgoraBaseUIView,
                       UIGestureRecognizerDelegate,
                       UITextFieldDelegate {
    var scaleTouchBlock: ((_ min: Bool) -> Void)?
    
    var showMinBtn = true {
        didSet {
            if let btn = titleView.viewWithTag(ButtonTag) as? AgoraBaseUIButton {
                btn.isHidden = !showMinBtn
            }
        }
    }
    
    var showDefaultText = true {
        didSet {
            chatPlaceHolderView.label.isHidden = !showDefaultText
        }
    }
    
    var isMin: Bool = true {
        didSet {
            resizeView()
        }
    }
    
    var hasConversation: Bool = false {
        didSet {
            if hasConversation {
                titleViewHasConversation()
            } else {
                titleViewWithoutConversation()
            }
        }
    }
    
    var unreadNum: Int = 0 {
        didSet {
            let label = minView.label
            label.isHidden = true
            
            if (isMin && unreadNum > 0) {
                let num = unreadNum > 99 ? "99+" : "\(unreadNum)"
                
                label.isHidden = false
                label.text = "\(num)"
                
                let size = CGSize(width: CGFloat(MAXFLOAT),
                                  height: label.agora_height)
                let rect = ("\(num)").boundingRect(with: size,
                                                   options: .usesLineFragmentOrigin,
                                                   attributes: [NSAttributedString.Key.font: label.font!],
                                                   context: nil)
                
                label.agora_width = (rect.width > label.agora_width) ? rect.size.width + 4 : label.agora_width
            }
        }
    }
    
    private let ImageTag = 100
    private let ButtonTag = 101
    private let InoutCellID = "InoutCellID"
    
    private var originalBottom: CGFloat?
    
    private(set) lazy var chatTableView = AgoraChatTableView(frame: .zero,
                                                             style: .grouped)
    
    private lazy var maxView: AgoraBaseUIView = {
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
    
    private lazy var minView: AgoraUIChatMinView = {
        let view = AgoraUIChatMinView(frame: .zero)
        view.addTarget(self,
                      action: #selector(onMaxTouchEvent),
                      for: .touchUpInside)
        return view
    }()
    
    @objc lazy var resignFirstResponderGesture: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(tapRecognized(_:)))
        tapGesture.cancelsTouchesInView = false
        tapGesture.isEnabled = true
        tapGesture.delegate = self
        return tapGesture
    }()
    
    private lazy var titleView: AgoraBaseUIView = {
        let view = AgoraBaseUIView()
        view.backgroundColor = UIColor.clear
        
        let lineV = AgoraBaseUIView()
        lineV.backgroundColor = UIColor(red: 236 / 255.0,
                                        green: 236 / 255.0,
                                        blue: 241 / 255.0,
                                        alpha: 1)
        view.addSubview(lineV)
        lineV.agora_x = 0
        lineV.agora_right = 0
        lineV.agora_bottom = 0
        lineV.agora_height = 1
        
        return view
    }()
    
    private(set) lazy var chatPlaceHolderView = AgoraChatPlaceHolderView(frame: .zero)
    
    private lazy var chatPermissionStateView = AgoraPermissionStateView(frame: .zero)
    
    private lazy var chatView: AgoraBaseUIView = {
        let view = AgoraBaseUIView()
        view.clipsToBounds = true
        
        view.addSubview(titleView)
        titleView.agora_x = 0
        titleView.agora_right = 0
        titleView.agora_y = 0
        titleView.agora_height = 44
        
        view.addSubview(chatTableView)
        chatTableView.agora_x = 0
        chatTableView.agora_right = 0
        chatTableView.agora_y = self.titleView.agora_height
        chatTableView.agora_bottom = 0

        view.addSubview(chatPlaceHolderView)
        chatPlaceHolderView.agora_center_x = 0
        chatPlaceHolderView.agora_center_y = 20
        chatPlaceHolderView.agora_width = 90
        chatPlaceHolderView.agora_height = 100
        
        return view
    }()
    
    private(set) lazy var sendView = AgoraUIChatSendView(frame: .zero)
    
    private(set) weak var tabSelectView: AgoraTabSelectView?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
        initLayout()
        resizeView()
        keyboardNotification()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func didMoveToWindow() {
        super.didMoveToWindow()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.updateSendViewBezier()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func addFirstResponderGesture() {
        window?.becomeFirstResponder()
        window?.addGestureRecognizer(self.resignFirstResponderGesture)
    }
    
    func removeFirstResponderGesture() {
        window?.removeGestureRecognizer(self.resignFirstResponderGesture)
    }
    
    // 群聊时有禁言状态
    func roomChatIfHasPermission(_ permission: Bool) {
        sendView.textField.isUserInteractionEnabled = permission
        chatPermissionStateView.isHidden = permission
        let sendButton = sendView.sendButton
        sendButton.isEnabled = permission
        
        if permission {
            sendView.textField.attributedPlaceholder = NSAttributedString(string: AgoraKitLocalizedString("ChatPlaceholderText"),
                                                                  attributes:[NSAttributedString.Key.foregroundColor: UIColor(red: 125 / 255.0,
                                                                                                                              green: 135 / 255.0,
                                                                                                                              blue: 152 / 255.0,
                                                                                                                              alpha: 1)])
        } else {
            sendView.textField.attributedPlaceholder = NSAttributedString(string: AgoraKitLocalizedString("ChatSilencedPlaceholderText"),
                                                                  attributes:[NSAttributedString.Key.foregroundColor: UIColor(red: 125 / 255.0,
                                                                                                                              green: 135 / 255.0,
                                                                                                                              blue: 152 / 255.0,
                                                                                                                              alpha: 1)])
        }
    }
    
    // 单聊无禁言状态
    func conversationChatWithoutPermission() {
        let sendButton = sendView.sendButton
        sendButton.isEnabled = true
        sendView.textField.isUserInteractionEnabled = true
        
        sendView.textField.attributedPlaceholder = NSAttributedString(string: AgoraKitLocalizedString("ChatPlaceholderText"),
                                                                      attributes:[NSAttributedString.Key.foregroundColor: UIColor(red: 125 / 255.0,
                                                                                                                                  green: 135 / 255.0,
                                                                                                                                  blue: 152 / 255.0,
                                                                                                                                  alpha: 1)])
        chatPermissionStateView.isHidden = true
    }
    
    // UI events
    @objc func onMinTouchEvent() {
        if self.scaleTouchBlock != nil {
            self.isMin = true
            self.scaleTouchBlock?(self.isMin)
        }
    }
    
    @objc func onMaxTouchEvent() {
        if self.scaleTouchBlock != nil {
            self.isMin = false
            self.scaleTouchBlock?(self.isMin)
        }
    }
    
    // Keyboard
    @objc func keyboardDidShow(_ notification: NSNotification) {
        if let rect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            if (originalBottom == nil) {
                originalBottom = max(agora_bottom,
                                     agora_safe_bottom)
            }
            
            agora_safe_bottom = rect.size.height + 5
        }
    }
    
    @objc func keyboardWillHidden(_ notification: NSNotification) {
        if let bottom = originalBottom {
            agora_safe_bottom = bottom
        }
    }
    
    // Gesture
    @objc func tapRecognized(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            self.window?.resignFirstResponder()
            self.window?.endEditing(true)
        }
    }
}

// MARK: - Keyboard
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

// MARK: - Rect
private extension AgoraUIChatView {
    func initView() {
        backgroundColor = UIColor.clear
        addSubview(maxView)
        addSubview(minView)

        maxView.addSubview(sendView)
        maxView.addSubview(chatView)
        maxView.addSubview(chatPermissionStateView)
    }
    
    func initLayout() {
        maxView.agora_x = 0
        maxView.agora_y = 0
        maxView.agora_bottom = 0
        maxView.agora_right = 0

        sendView.agora_bottom = 0
        sendView.agora_x = 0
        sendView.agora_right = 0
        sendView.agora_height = 60

        chatView.agora_x = 0
        chatView.agora_right = 0
        chatView.agora_bottom = sendView.agora_bottom + sendView.agora_height
        chatView.agora_y = 0
        chatView.layer.cornerRadius = 4

        minView.agora_x = 0
        minView.agora_y = 0
        minView.agora_right = 0
        minView.agora_bottom = 0
        
        chatPermissionStateView.agora_x = 0
        chatPermissionStateView.agora_right = 0
        chatPermissionStateView.agora_y = titleView.agora_height + titleView.agora_y - 1
        chatPermissionStateView.agora_height = 32
    }
    
    func updateSendViewBezier() {
        if isMin {
            return
        }
        
        let maskPath = UIBezierPath(roundedRect: sendView.bounds,
                                    byRoundingCorners: [.topLeft,
                                                        .topRight],
                                    cornerRadii: sendView.bounds.size)
        
        let roundLayer = CAShapeLayer()
        roundLayer.frame = sendView.bounds
        roundLayer.path = maskPath.cgPath
        sendView.layer.mask = roundLayer;
        
        let lineLayer = CAShapeLayer()
        lineLayer.frame = sendView.bounds
        lineLayer.path = maskPath.cgPath
        lineLayer.lineWidth = 1
        lineLayer.strokeColor = UIColor(rgb: 0xECECF1).cgColor
        lineLayer.fillColor = UIColor.clear.cgColor
        sendView.layer.addSublayer(lineLayer)
    }
    
    func resizeView() {
        if (isMin) {
            minView.isHidden = false
       
            unreadNum = 0
        
            maxView.isHidden = true
            sendView.textField.agora_right = 0
            chatView.agora_bottom = 0
        } else {
            minView.isHidden = true
            maxView.isHidden = false
            
            let sendBtn = sendView.sendButton
            sendView.textField.agora_right = sendBtn.agora_width + sendBtn.agora_right + 10

            let gap: CGFloat = 8
            chatView.agora_bottom = sendView.agora_bottom + sendView.agora_height + gap
        }
    }
}

// MARK: - Title view
private extension AgoraUIChatView {
    func titleViewWithoutConversation() {
        let label = AgoraBaseUILabel()
        label.textColor = UIColor(red: 25/255.0,
                                  green:25/255.0,
                                  blue: 25/255.0,
                                  alpha: 1)
        label.font = UIFont.systemFont(ofSize: 13)
    
        let chatMsg = AgoraKitLocalizedString("ChatText")
        label.text = chatMsg
        titleView.addSubview(label)
        
        label.agora_x = 15
        label.agora_y = 0
        label.agora_bottom = 0
        label.agora_width = 100

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
    
    func titleViewHasConversation() {
        let view = AgoraTabSelectView(frame: .zero)
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

// MARK: - Private
extension AgoraUIChatView {
    func resizeChatViewFrame() {
        chatView.layoutIfNeeded()
        chatTableView.frame = CGRect(x: 0,
                                     y: titleView.agora_height,
                                     width: chatView.frame.width,
                                     height: chatView.frame.height - titleView.agora_height)
    }
}
