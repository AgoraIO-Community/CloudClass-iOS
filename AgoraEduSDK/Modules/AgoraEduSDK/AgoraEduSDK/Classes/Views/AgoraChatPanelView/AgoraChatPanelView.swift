//
//  AgoraChatPanelView.swift
//  AgoraEduSDK
//
//  Created by SRS on 2021/1/31.
//

import UIKit

@objcMembers public class AgoraChatPanelView: AgoraBaseView {
    
    public var scaleTouchBlock: ((_ min: Bool) -> Void)?
    
    public var isMin: Bool = false {
        didSet {
            self.resizeView()
        }
    }
    
    public var chatModels: [AgoraChatMessageModel] = [] {
        didSet {
            let label = self.titleView.viewWithTag(LabelTag) as! AgoraBaseLabel
            label.text = "聊天（\(chatModels.count)）"
            
            // fix Constraint warning
            self.chatView.layoutIfNeeded()
            self.chatTableView.frame = CGRect(x: 0, y: self.titleView.height, width: self.chatView.frame.width, height: self.chatView.frame.height - self.titleView.height)
            self.chatTableView.reloadData()
        }
    }
    
    public var unreadNum: Int = 0 {
        didSet {
            let label = self.minView.viewWithTag(LabelTag) as! AgoraBaseLabel
            label.isHidden = true
            if (self.isMin && unreadNum > 0) {
                label.isHidden = false
                label.text = "\(unreadNum)"
                
                let rect: CGRect = ("\(unreadNum)").boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: label.height), options: .usesLineFragmentOrigin , attributes: [NSAttributedString.Key.font:label.font], context: nil)
                
                label.width = rect.size.width + (AgoraDeviceAssistant.OS.isPad ? 8 : 4)
            }
        }
    }
    
    fileprivate let LabelTag = 99
    fileprivate let ImageTag = 100
    fileprivate let ButtonTag = 101
    fileprivate let InoutCellID = "InoutCellID"
    fileprivate let MessageCellID = "MessageCellID"
    
    fileprivate var originalBottom: CGFloat = 0
    
    fileprivate lazy var maxView: AgoraBaseView = {
        let view = AgoraBaseView()
        view.backgroundColor = UIColor.clear
        return view
    }()
    fileprivate lazy var minView: AgoraBaseButton = {
        let btn = AgoraBaseButton(type: .custom)
        btn.setImage(AgoraImageWithName("chat_toast", self.classForCoder), for: .normal)
        btn.addTarget(self, action: #selector(onMaxTouchEvent), for: .touchUpInside)
        
        let redLabel = AgoraBaseLabel()
        redLabel.tag = LabelTag
        redLabel.textAlignment = .center
        redLabel.textColor = UIColor.white
        
        redLabel.font = UIFont.boldSystemFont(ofSize: AgoraDeviceAssistant.OS.isPad ? 12 : 8)
        redLabel.backgroundColor = UIColor(red: 240/255.0, green:76/255.0, blue: 54/255.0, alpha: 1)
        btn.addSubview(redLabel)
        
        redLabel.height = AgoraDeviceAssistant.OS.isPad ? 16 : 9
        redLabel.width = redLabel.height
        redLabel.right = -redLabel.width * 0.3
        redLabel.y = 0
        
        redLabel.clipsToBounds = true
        redLabel.layer.cornerRadius = redLabel.height * 0.5
             
        btn.isHidden = true
        return btn
    }()
    
    fileprivate lazy var titleView: AgoraBaseView = {
        let view = AgoraBaseView()
        view.backgroundColor = UIColor.clear
        
        let label = AgoraBaseLabel()
        label.textColor = UIColor(red: 254/255.0, green:254/255.0, blue: 254/255.0, alpha: 1)
        label.font = UIFont.systemFont(ofSize: AgoraDeviceAssistant.OS.isPad ? 14 : 9)
        label.tag = LabelTag
        label.text = "聊天（0）"
        view.addSubview(label)
        label.sizeToFit()

        let labelSize = label.frame.size
        let imgSzie = AgoraDeviceAssistant.OS.isPad ? CGSize(width: 14, height: 14) : CGSize(width: 9, height: 9)
        let offsetX = (labelSize.width + 3 + imgSzie.width) * 0.5

        let imageView = AgoraBaseImageView(image: AgoraImageWithName("chat_tag", self.classForCoder))
        view.addSubview(imageView)
        imageView.centerX = -(offsetX - imgSzie.width)
        imageView.centerY = 0
        imageView.resize(imgSzie.width, imgSzie.height)
        
        label.centerX = imageView.centerX + labelSize.width * 0.5 + imageView.width + 3
        label.width = labelSize.width + 1
        label.y = 0
        label.bottom = 0
        
        let btn = AgoraBaseButton(type: .custom)
        btn.setImage(AgoraImageWithName("chat_min", self.classForCoder), for: .normal)
        btn.addTarget(self, action: #selector(onMinTouchEvent), for: .touchUpInside)
        view.addSubview(btn)
        
        if AgoraDeviceAssistant.OS.isPad {
            btn.centerY = 0
            btn.right = 5
            btn.resize(20, 20)
        } else {
            btn.centerY = 0
            btn.right = 5
            btn.resize(13, 13)
        }
        return view
    }()
    fileprivate lazy var chatTableView: AgoraBaseTableView = {
        let tableView = AgoraBaseTableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = UIColor(red: 19/255.0, green: 25/255.0, blue: 111/255.0, alpha: 0.6)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.separatorStyle = .none
        tableView.register(AgoraChatPanelInOutCell.self, forCellReuseIdentifier: InoutCellID)
        tableView.register(AgoraChatPanelMessageCell.self, forCellReuseIdentifier: MessageCellID)
        tableView.backgroundColor = UIColor.clear
        return tableView
    }()
    fileprivate lazy var chatView: AgoraBaseView = {
        let view = AgoraBaseView()
        view.clipsToBounds = true
        view.backgroundColor = UIColor(red: 19/255.0, green: 25/255.0, blue: 111/255.0, alpha: 0.6)
        
        view.addSubview(self.titleView)
        self.titleView.x = 0
        self.titleView.right = 0
        self.titleView.y = 0
        self.titleView.height = AgoraDeviceAssistant.OS.isPad ? 30 : 23
        
        view.addSubview(self.chatTableView)
//        self.chatTableView.x = 0
//        self.chatTableView.right = 0
//        self.chatTableView.y = self.titleView.height
//        self.chatTableView.bottom = 0
        
        return view
    }()

    fileprivate weak var textField: AgoraBaseTextField?
    fileprivate lazy var sendView: AgoraBaseView = {
        let view = AgoraBaseView()
        view.clipsToBounds = true
        view.backgroundColor = UIColor(red: 19/255.0, green: 25/255.0, blue: 111/255.0, alpha: 0.6)
        
        let sendContentView = AgoraBaseView()
        sendContentView.clipsToBounds = true
        sendContentView.backgroundColor = UIColor.white
        view.addSubview(sendContentView)
        sendContentView.x = AgoraDeviceAssistant.OS.isPad ? 8 : 6
        sendContentView.right = AgoraDeviceAssistant.OS.isPad ? 8 : 6
        sendContentView.height = AgoraDeviceAssistant.OS.isPad ? 28 : 19
        sendContentView.bottom = AgoraDeviceAssistant.OS.isPad ? 12 : 7
        sendContentView.layer.cornerRadius = sendContentView.height * 0.3
        
        let btn = AgoraBaseButton(type: .custom)
        btn.setImage(AgoraImageWithName("chat_send", self.classForCoder), for: .normal)
        btn.tag = ButtonTag
        btn.addTarget(self, action: #selector(onSendTouchEvent), for: .touchUpInside)
        sendContentView.addSubview(btn)
        if AgoraDeviceAssistant.OS.isPad {
            btn.right = 3
            btn.resize(22, 22)
            btn.centerY = 0
        } else {
            btn.right = 3
            btn.resize(15, 15)
            btn.centerY = 0
        }

        let textField = AgoraBaseTextField()
        textField.attributedPlaceholder = NSAttributedString(string:" 请输入你想说的话",attributes:[NSAttributedString.Key.foregroundColor: UIColor(red: 194/255.0, green: 213/255.0, blue: 229/255.0, alpha: 1)])
        textField.font = UIFont.systemFont(ofSize: AgoraDeviceAssistant.OS.isPad ? 14 : 9)
        textField.returnKeyType = .send
        textField.delegate = self
        sendContentView.addSubview(textField)
        self.textField = textField
        
        textField.x = AgoraDeviceAssistant.OS.isPad ? 10 : 5
        textField.right = AgoraDeviceAssistant.OS.isPad ? 30 : 23
        textField.y = 0
        textField.bottom = 0
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initView()
        self.initLayout()
        self.keyboardNotification()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: UITableViewDelegate & UITableViewDataSource
extension AgoraChatPanelView: UITableViewDelegate, UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return chatModels.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let chatModel = chatModels[indexPath.section]
        if (chatModel.type == .userInout) {
            let cell = tableView.dequeueReusableCell(withIdentifier: InoutCellID, for: indexPath) as! AgoraChatPanelInOutCell
            cell.updateCell(chatModel.message)
            cell.selectionStyle = .none
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: MessageCellID, for: indexPath) as! AgoraChatPanelMessageCell
            cell.updateView(model: chatModel)
            cell.selectionStyle = .none
            return cell
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let chatModel = chatModels[indexPath.section]
        if (chatModel.type == .userInout) {
            return AgoraDeviceAssistant.OS.isPad ? 35 : 20
        }
        
        return chatModel.cellHeight
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }

    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return AgoraDeviceAssistant.OS.isPad ? 12 : 7
    }
}

// MARK: Keyboard
extension AgoraChatPanelView {
    fileprivate func keyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(_ :)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHidden(_ :)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc fileprivate func keyboardDidShow(_ notification: NSNotification) {
        if let rect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            self.originalBottom = self.bottom
            self.bottom = rect.size.height + 5
        }
    }
    @objc fileprivate func keyboardWillHidden(_ notification: NSNotification) {
        self.bottom = self.originalBottom
    }
}

// MARK: Rect
extension AgoraChatPanelView {
    fileprivate func initView() {
        self.backgroundColor = UIColor.clear

        self.addSubview(self.maxView)
        self.addSubview(self.minView)

        self.maxView.addSubview(self.sendView)
        self.maxView.addSubview(self.chatView)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.onMinTouchEvent()
        }
    }
    
    fileprivate func initLayout() {
        
        self.maxView.x = 0
        self.maxView.y = 0
        self.maxView.bottom = 0
        self.maxView.right = 0

        self.sendView.bottom = 0
        self.sendView.x = 0
        self.sendView.right = 0
        self.sendView.height = AgoraDeviceAssistant.OS.isPad ? 54 : 32
        self.sendView.layer.cornerRadius = self.sendView.height * 0.2

        let gap: CGFloat = AgoraDeviceAssistant.OS.isPad ? 12 : 8
        
        self.chatView.x = 0
        self.chatView.right = 0
        self.chatView.bottom = self.sendView.bottom + self.sendView.height + gap
        self.chatView.y = 0
        self.chatView.layer.cornerRadius = AgoraDeviceAssistant.OS.isPad ? 10 : 8

        self.minView.x = 0
        self.minView.y = 0
        self.minView.right = 0
        self.minView.bottom = 0
    }
    
    fileprivate func resizeView() {
        if (self.isMin) {
            self.minView.isHidden = false
       
            self.unreadNum = 0
        
            self.maxView.isHidden = true
            self.textField?.right = 0
            self.chatView.bottom = 0

//            self.chatTableView.clearConstraint()
            
        } else {
            self.minView.isHidden = true
            
            self.maxView.isHidden = false
            self.textField?.right = AgoraDeviceAssistant.OS.isPad ? 30 : 23
            
            let gap: CGFloat = AgoraDeviceAssistant.OS.isPad ? 12 : 8
            self.chatView.bottom = self.sendView.bottom + self.sendView.height + gap
        }
    }
}

// MARK: UITextFieldDelegate
extension AgoraChatPanelView: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let content = textField.text ?? ""
        if content.count > 0 {
            self.onSendTouchEvent()
            
        } else {
            textField.text = nil
            textField.resignFirstResponder()
        }
        return true
    }
}

// MARK: TouchEvent
extension AgoraChatPanelView {
    @objc fileprivate func onSendTouchEvent() {
        //
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
}

