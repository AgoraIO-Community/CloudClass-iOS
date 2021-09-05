//
//  AgoraUIChatItemViews.swift
//  AgoraWidgets
//
//  Created by Cavan on 2021/7/21.
//

import AgoraUIBaseViews
import AgoraUIEduBaseViews

class AgoraUIChatSendView: AgoraBaseUIView {
    var textField: AgoraBaseUITextField
    var sendButton: AgoraBaseUIButton
    
    override init(frame: CGRect) {
        let sendContentView = AgoraBaseUIView()
        sendContentView.backgroundColor = UIColor(rgb: 0xF9F9FC)
        
        let button = AgoraBaseUIButton(type: .custom)
        button.setTitle(AgoraKitLocalizedString("ChatSendText"),
                     for: .normal)
        button.backgroundColor = UIColor(red: 0.21,
                                      green: 0.48,
                                      blue: 0.96,
                                      alpha: 1)
        button.clipsToBounds = true
        self.sendButton = button

        let textField = AgoraBaseUITextField()
        
        textField.attributedPlaceholder = NSAttributedString(string: AgoraKitLocalizedString("ChatPlaceholderText"),
                                                             attributes:[NSAttributedString.Key.foregroundColor: UIColor(red: 125/255.0,
                                                                                                                         green: 135/255.0,
                                                                                                                         blue: 152/255.0,
                                                                                                                         alpha: 1)])
        textField.font = UIFont.systemFont(ofSize: 13)
        textField.returnKeyType = .send
        self.textField = textField
       
        super.init(frame: frame)
        
        clipsToBounds = true
        backgroundColor = UIColor.clear
        
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
        self.textField = textField
        
        textField.agora_x = 15
        textField.agora_right = 0
        textField.agora_y = 0
        textField.agora_bottom = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AgoraUIChatMinView: AgoraBaseUIButton {
    private(set) var label: AgoraBaseUILabel
    
    override init(frame: CGRect) {
        let redLabel = AgoraBaseUILabel()
        redLabel.textAlignment = .center
        redLabel.textColor = UIColor.white
        
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
             
        setImage(AgoraKitImage("chat_toast"),
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
        let imageV = AgoraBaseUIImageView(image: AgoraKitImage("chat_empty"))
        
        let label = AgoraBaseUILabel()
        label.textColor = UIColor(rgb: 0x7D8798)
        label.textAlignment = .center
        label.text = AgoraKitLocalizedString("ChatEmptyText")
        label.font = UIFont.systemFont(ofSize: 13)
        
        self.label = label
        
        super.init(frame: frame)
        
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
        
        let textArt = NSAttributedString(string: AgoraKitLocalizedString("ChatMuteTagText"))
       
        let imageAttachment = NSTextAttachment()
        let image = AgoraKitImage("chat_mute_tag")
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
