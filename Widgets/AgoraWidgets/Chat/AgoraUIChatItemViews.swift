//
//  AgoraUIChatItemViews.swift
//  AgoraWidgets
//
//  Created by Cavan on 2021/7/21.
//

import AgoraUIBaseViews
import AgoraUIEduBaseViews

class AgoraChatSendView: AgoraBaseUIView {
    private var archView: AgoraBaseUIView
    let textField: AgoraBaseUITextField
    let sendButton: AgoraBaseUIButton
    
    override init(frame: CGRect) {
        let sendContentView = AgoraBaseUIView()
        sendContentView.backgroundColor = UIColor(rgb: 0xF9F9FC)
        
        let button = AgoraBaseUIButton(type: .custom)
        self.sendButton = button
        
        let textField = AgoraBaseUITextField()
        self.textField = textField
        
        let archView = AgoraBaseUIView()
        self.archView = archView
        
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        
        // button
        let buttonText = GetWidgetLocalizableString(object: self,
                                                    key: "ChatSendText")
        button.setTitle(buttonText,
                        for: .normal)
        button.backgroundColor = UIColor(red: 0.21,
                                         green: 0.48,
                                         blue: 0.96,
                                         alpha: 1)
        button.clipsToBounds = true
        
        // textField
        let text = GetWidgetLocalizableString(object: self,
                                              key: "ChatPlaceholderText")
        let color = UIColor(red: 125 / 255.0,
                            green: 135 / 255.0,
                            blue: 152 / 255.0,
                            alpha: 1)
        let placeholder = NSAttributedString(string: text,
                                             attributes:[NSAttributedString.Key.foregroundColor: color])
        
        textField.attributedPlaceholder = placeholder
        textField.font = UIFont.systemFont(ofSize: 13)
        textField.returnKeyType = .send
        
        // archView
        archView.backgroundColor = UIColor(rgb: 0xF9F9FC)
        archView.layer.cornerRadius = 18
        archView.layer.borderWidth = 1
        archView.layer.borderColor = UIColor(rgb: 0xECECF1).cgColor
        
        addSubview(archView)
        archView.agora_x = 0
        archView.agora_right = 0
        archView.agora_y = -9
        archView.agora_bottom = -9
        
        addSubview(sendContentView)
        sendContentView.agora_x = 0
        sendContentView.agora_right = 0
        sendContentView.agora_y = 0
        sendContentView.agora_bottom = 0
        
        sendContentView.addSubview(button)
        button.agora_right = 15
        button.agora_resize(80, 30)
        button.agora_center_y = 0
        button.layer.cornerRadius = button.agora_height * 0.5
        
        sendContentView.addSubview(textField)
        textField.agora_x = 15
        textField.agora_right = 110
        textField.agora_y = 0
        textField.agora_bottom = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AgoraChatMinView: AgoraBaseUIButton {
    private(set) var label: AgoraBaseUILabel
    
    override init(frame: CGRect) {
        let redLabel = AgoraBaseUILabel()
        redLabel.textAlignment = .center
        redLabel.textColor = .white
        
        redLabel.font = UIFont.boldSystemFont(ofSize: 8)
        redLabel.backgroundColor = UIColor(red: 240 / 255.0,
                                           green:76 / 255.0,
                                           blue: 54 / 255.0,
                                           alpha: 1)
        
        self.label = redLabel
        
        super.init(frame: frame)
        
        isHidden = true
        
        addSubview(redLabel)
        
        redLabel.agora_height = UIDevice.current.isPad ? 14 : 9
        redLabel.agora_width = redLabel.agora_height
        redLabel.agora_right = redLabel.agora_width * 0.4
        redLabel.agora_y = 0
        
        redLabel.clipsToBounds = true
        redLabel.layer.cornerRadius = redLabel.agora_height * 0.5
        
        let image = GetWidgetImage(object: self,
                                   "chat_toast")
        setImage(image,
                 for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AgoraChatTableView: AgoraBaseUITableView {
    override init(frame: CGRect,
                  style: UITableView.Style) {
        super.init(frame: frame,
                   style: style)
        
        backgroundColor = .white
        estimatedRowHeight = 59
        estimatedSectionHeaderHeight = 0
        estimatedSectionFooterHeight = 0
        separatorStyle = .none
        
        register(AgoraChatPanelMessageCell.self,
                 forCellReuseIdentifier: AgoraChatPanelMessageCell.MessageCellID)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func scrollToBottom(index: Int) {
        scrollToRow(at: IndexPath(row: 0,
                                  section: index),
                    at: .middle,
                    animated: true)
    }
}

class AgoraChatPlaceHolderView: AgoraBaseUIView {
    var label: AgoraBaseUILabel
    
    override init(frame: CGRect) {
        let label = AgoraBaseUILabel()
        label.textColor = UIColor(rgb: 0x7D8798)
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 13)
        
        self.label = label
        
        super.init(frame: frame)
        
        let text = GetWidgetLocalizableString(object: self,
                                              key: "ChatEmptyText")
        label.text = text
        
        let image = GetWidgetImage(object: self,
                                   "chat_empty")
        let imageV = AgoraBaseUIImageView(image: image)
        
        addSubview(imageV)
        imageV.agora_center_x = 0
        imageV.agora_center_y = 0
        imageV.agora_width = 90
        imageV.agora_height = 80
        
        addSubview(label)
        label.agora_x = 0
        label.agora_right = 0
        label.agora_height = 20
        label.agora_center_y = (imageV.agora_height + label.agora_height) * 0.5
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AgoraPermissionStateView: AgoraBaseUIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor(rgb: 0xF9F9FC)
        layer.borderWidth = 1
        layer.borderColor = UIColor(rgb: 0xECECF1).cgColor
        
        let label = AgoraBaseUILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor(rgb: 0x191919)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        
        let attr = NSMutableAttributedString()
        
        let textArt = NSAttributedString(string: GetWidgetLocalizableString(object: self,
                                                                            key: "ChatMuteTagText"))
        
        let imageAttachment = NSTextAttachment()
        let image = GetWidgetImage(object: self,
                                   "chat_mute_tag")
        imageAttachment.image = image
        imageAttachment.bounds = CGRect(x: 0,
                                        y: -5,
                                        width: 18,
                                        height: 18)
        let imgAttr = NSAttributedString(attachment: imageAttachment)
        
        attr.append(imgAttr)
        attr.append(NSAttributedString(string: " "))
        attr.append(textArt)
        label.attributedText = attr
        
        addSubview(label)
        label.agora_x = 10
        label.agora_right = 10
        label.agora_y = 0
        label.agora_bottom = 0
        
        isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AgoraChatTitleView: AgoraBaseUIView {
    private(set) var minButton: AgoraBaseUIButton
    
    override init(frame: CGRect) {
        let button = AgoraBaseUIButton(type: .custom)
        self.minButton = button
        
        super.init(frame: frame)
        
        let image = GetWidgetImage(object: self,
                                   "chat_min")
        button.setImage(image,
                        for: .normal)
        
        
        backgroundColor = .clear
        
        let lineView = AgoraBaseUIView()
        lineView.backgroundColor = UIColor(red: 236 / 255.0,
                                           green: 236 / 255.0,
                                           blue: 241 / 255.0,
                                           alpha: 1)
        addSubview(lineView)
        lineView.agora_x = 0
        lineView.agora_right = 0
        lineView.agora_bottom = 0
        lineView.agora_height = 1
        
        addSubview(button)
        
        button.agora_center_y = 0
        button.agora_right = 15
        button.agora_resize(24,
                            24)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AgoraChatMaxView: AgoraBaseUIView {
    let titleView = AgoraChatTitleView(frame: .zero)
    let chatTableView = AgoraChatTableView(frame: .zero,
                                           style: .grouped)
    
    private lazy var chatPermissionStateView = AgoraPermissionStateView(frame: .zero)
    
    private(set) lazy var chatPlaceHolderView = AgoraChatPlaceHolderView(frame: .zero)
    
    private(set) weak var tabSelectView: AgoraTabSelectView?
    
    let sendView = AgoraChatSendView(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleView)
        titleView.agora_x = 0
        titleView.agora_right = 0
        titleView.agora_y = 0
        titleView.agora_height = 44
        
        addSubview(chatTableView)
        chatTableView.agora_x = 0
        chatTableView.agora_right = 0
        chatTableView.agora_y = self.titleView.agora_height
        chatTableView.agora_bottom = 69
        
        addSubview(chatPlaceHolderView)
        chatPlaceHolderView.agora_center_x = 0
        chatPlaceHolderView.agora_center_y = 20
        chatPlaceHolderView.agora_width = 90
        chatPlaceHolderView.agora_height = 100
        
        addSubview(sendView)
        sendView.agora_bottom = 0
        sendView.agora_x = 0
        sendView.agora_right = 0
        sendView.agora_height = 60
        
        addSubview(chatPermissionStateView)
        chatPermissionStateView.agora_x = 0
        chatPermissionStateView.agora_right = 0
        chatPermissionStateView.agora_y = titleView.agora_height + titleView.agora_y - 1
        chatPermissionStateView.agora_height = 32
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 群聊时有禁言状态
    func roomChatIfHasPermission(_ permission: Bool) {
        sendView.textField.isUserInteractionEnabled = permission
        chatPermissionStateView.isHidden = permission
        let sendButton = sendView.sendButton
        sendButton.isEnabled = permission
        
        if permission {
            let text = GetWidgetLocalizableString(object: self,
                                                  key: "ChatPlaceholderText")
            let color = UIColor(red: 125 / 255.0,
                                green: 135 / 255.0,
                                blue: 152 / 255.0,
                                alpha: 1)
            let placeholder = NSAttributedString(string: text,
                                                 attributes: [NSAttributedString.Key.foregroundColor: color])
            
            sendView.textField.attributedPlaceholder = placeholder
        } else {
            let text = GetWidgetLocalizableString(object: self,
                                                  key: "ChatSilencedPlaceholderText")
            let color = UIColor(red: 125 / 255.0,
                                green: 135 / 255.0,
                                blue: 152 / 255.0,
                                alpha: 1)
            let placeholder = NSAttributedString(string: text,
                                                 attributes: [NSAttributedString.Key.foregroundColor: color])
            
            sendView.textField.attributedPlaceholder = placeholder
        }
    }
    
    // 单聊无禁言状态
    func conversationChatWithoutPermission() {
        let sendButton = sendView.sendButton
        sendButton.isEnabled = true
        sendView.textField.isUserInteractionEnabled = true
        
        let text = GetWidgetLocalizableString(object: self,
                                              key: "ChatPlaceholderText")
        let color = UIColor(red: 125 / 255.0,
                            green: 135 / 255.0,
                            blue: 152 / 255.0,
                            alpha: 1)
        let placeholder = NSAttributedString(string: text,
                                             attributes: [NSAttributedString.Key.foregroundColor: color])
        
        sendView.textField.attributedPlaceholder = placeholder
        chatPermissionStateView.isHidden = true
    }
    
    func titleViewWithoutConversation() {
        let label = AgoraBaseUILabel()
        label.textColor = UIColor(red: 25 / 255.0,
                                  green:25 / 255.0,
                                  blue: 25 / 255.0,
                                  alpha: 1)
        label.font = UIFont.systemFont(ofSize: 13)
        
        let chatMsg = GetWidgetLocalizableString(object: self,
                                                 key: "ChatText")
        label.text = chatMsg
        titleView.addSubview(label)
        
        label.agora_x = 15
        label.agora_y = 0
        label.agora_bottom = 0
        label.agora_width = 100
    }
    
    func titleViewHasConversation() {
        let view = AgoraTabSelectView(frame: .zero)
        view.alignment = .left
        view.underlineColor = UIColor(rgb: 0x357BF6)
        
        view.selectedTitle = AgoraTabSelectView.TitleProperty(color: UIColor(rgb: 0x191919),
                                                              font: UIFont.systemFont(ofSize: 13,
                                                                                      weight: .bold))
        view.unselectedTitle = AgoraTabSelectView.TitleProperty(color: UIColor(rgb: 0x7B88A0),
                                                                font: UIFont.systemFont(ofSize: 13))
        
        view.underlineHeight = 2
        view.underlineExtralWidth = 10
        view.insets = UIEdgeInsets(top: 0,
                                   left: 14,
                                   bottom: 0,
                                   right: 14)
        
        titleView.insertSubview(view,
                                belowSubview: titleView.minButton)
        
        view.agora_x = 0
        view.agora_y = 0
        view.agora_right = 0
        view.agora_bottom = 0
        
        let chatText = GetWidgetLocalizableString(object: self,
                                                  key: "ChatText")
        
        let chat = chatText
        
        let conversationText = GetWidgetLocalizableString(object: self,
                                                          key: "ChatConversation")
        
        let conversation = conversationText
        view.update([chat,
                     conversation])
        
        tabSelectView = view
    }
}
