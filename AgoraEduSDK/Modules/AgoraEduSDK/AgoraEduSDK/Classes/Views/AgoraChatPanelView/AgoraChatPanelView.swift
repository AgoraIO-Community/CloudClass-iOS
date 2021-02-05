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
    
    public var unreadNum: Int = 0 {
        didSet {
            let label = self.minView.viewWithTag(LabelTag) as! AgoraBaseUILabel
            label.isHidden = true
            if (self.isMin && unreadNum > 0) {
                label.isHidden = false
                label.text = "\(unreadNum)"
                
                let rect: CGRect = ("\(unreadNum)").boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: label.agora_height), options: .usesLineFragmentOrigin , attributes: [NSAttributedString.Key.font:label.font!], context: nil)
                
                label.agora_width = rect.size.width + (AgoraDeviceAssistant.OS.isPad ? 8 : 4)
            }
        }
    }
    fileprivate var chatModels: [AgoraChatMessageInfoModel] = [] {
        didSet {
            let label = self.titleView.viewWithTag(LabelTag) as! AgoraBaseUILabel
            label.text = "聊天（\(chatModels.count)）"
            
            // fix Constraint warning
            self.chatView.layoutIfNeeded()
            self.chatTableView.frame = CGRect(x: 0, y: self.titleView.agora_height, width: self.chatView.frame.width, height: self.chatView.frame.height - self.titleView.agora_height)
            self.scrollToBottom()
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
    fileprivate lazy var minView: AgoraBaseUIButton = {
        let btn = AgoraBaseUIButton(type: .custom)
        btn.setImage(AgoraImageWithName("chat_toast", self.classForCoder), for: .normal)
        btn.addTarget(self, action: #selector(onMaxTouchEvent), for: .touchUpInside)
        
        let redLabel = AgoraBaseUILabel()
        redLabel.tag = LabelTag
        redLabel.textAlignment = .center
        redLabel.textColor = UIColor.white
        
        redLabel.font = UIFont.boldSystemFont(ofSize: AgoraDeviceAssistant.OS.isPad ? 12 : 8)
        redLabel.backgroundColor = UIColor(red: 240/255.0, green:76/255.0, blue: 54/255.0, alpha: 1)
        btn.addSubview(redLabel)
        
        redLabel.agora_height = AgoraDeviceAssistant.OS.isPad ? 16 : 9
        redLabel.agora_width = redLabel.agora_height
        redLabel.agora_right = -redLabel.agora_width * 0.3
        redLabel.agora_y = 0
        
        redLabel.clipsToBounds = true
        redLabel.layer.cornerRadius = redLabel.agora_height * 0.5
             
        btn.isHidden = true
        return btn
    }()
    
    fileprivate lazy var titleView: AgoraBaseView = {
        let view = AgoraBaseView()
        view.backgroundColor = UIColor.clear
        
        let label = AgoraBaseUILabel()
        label.textColor = UIColor(red: 254/255.0, green:254/255.0, blue: 254/255.0, alpha: 1)
        label.font = UIFont.systemFont(ofSize: AgoraDeviceAssistant.OS.isPad ? 14 : 12)
        label.tag = LabelTag
        label.text = "聊天（100）"
        view.addSubview(label)
        label.sizeToFit()

        let labelSize = label.frame.size
        let imgSzie = AgoraDeviceAssistant.OS.isPad ? CGSize(width: 14, height: 14) : CGSize(width: 13, height: 13)
        let offsetX = (labelSize.width + 3 + imgSzie.width) * 0.5

        let imageView = AgoraBaseUIImageView(image: AgoraImageWithName("chat_tag", self.classForCoder))
        view.addSubview(imageView)
        imageView.agora_center_x = -(offsetX - imgSzie.width)
        imageView.agora_center_y = 0
        imageView.agora_resize(imgSzie.width, imgSzie.height)
        
        label.agora_center_x = imageView.agora_center_x + labelSize.width * 0.5 + imageView.agora_width + 3
        label.agora_width = labelSize.width + 1
        label.agora_y = 0
        label.agora_bottom = 0
        
        let btn = AgoraBaseUIButton(type: .custom)
        btn.setImage(AgoraImageWithName("chat_min", self.classForCoder), for: .normal)
        btn.addTarget(self, action: #selector(onMinTouchEvent), for: .touchUpInside)
        view.addSubview(btn)
        
        if AgoraDeviceAssistant.OS.isPad {
            btn.agora_center_y = 0
            btn.agora_right = 5
            btn.agora_resize(20, 20)
        } else {
            btn.agora_center_y = 0
            btn.agora_right = 5
            btn.agora_resize(20, 20)
        }
        return view
    }()
    fileprivate lazy var chatTableView: AgoraBaseUITableView = {
        let tableView = AgoraBaseUITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = UIColor(red: 19/255.0, green: 25/255.0, blue: 111/255.0, alpha: 0.6)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 59
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
        self.titleView.agora_x = 0
        self.titleView.agora_right = 0
        self.titleView.agora_y = 0
        self.titleView.agora_height = AgoraDeviceAssistant.OS.isPad ? 30 : 34
        
        view.addSubview(self.chatTableView)
//        self.chatTableView.x = 0
//        self.chatTableView.right = 0
//        self.chatTableView.y = self.titleView.height
//        self.chatTableView.bottom = 0
        
        return view
    }()

    fileprivate weak var textField: AgoraBaseUITextField?
    fileprivate lazy var sendView: AgoraBaseView = {
        let view = AgoraBaseView()
        view.clipsToBounds = true
        view.backgroundColor = UIColor(red: 19/255.0, green: 25/255.0, blue: 111/255.0, alpha: 0.6)
        
        let sendContentView = AgoraBaseView()
        sendContentView.clipsToBounds = true
        sendContentView.backgroundColor = UIColor.white
        view.addSubview(sendContentView)
        sendContentView.agora_x = AgoraDeviceAssistant.OS.isPad ? 8 : 8
        sendContentView.agora_right = AgoraDeviceAssistant.OS.isPad ? 8 : 8
        sendContentView.agora_height = AgoraDeviceAssistant.OS.isPad ? 28 : 21
        sendContentView.agora_bottom = AgoraDeviceAssistant.OS.isPad ? 12 : 6
        sendContentView.layer.cornerRadius = sendContentView.agora_height * 0.3
        
        let btn = AgoraBaseUIButton(type: .custom)
        btn.setImage(AgoraImageWithName("chat_send", self.classForCoder), for: .normal)
        btn.tag = ButtonTag
        btn.addTarget(self, action: #selector(onSendTouchEvent), for: .touchUpInside)
        sendContentView.addSubview(btn)
        if AgoraDeviceAssistant.OS.isPad {
            btn.agora_right = 3
            btn.agora_resize(22, 22)
            btn.agora_center_y = 0
        } else {
            btn.agora_right = 3
            btn.agora_resize(17, 17)
            btn.agora_center_y = 0
        }

        let textField = AgoraBaseUITextField()
        textField.attributedPlaceholder = NSAttributedString(string:" 请输入你想说的话",attributes:[NSAttributedString.Key.foregroundColor: UIColor(red: 194/255.0, green: 213/255.0, blue: 229/255.0, alpha: 1)])
        textField.font = UIFont.systemFont(ofSize: AgoraDeviceAssistant.OS.isPad ? 14 : 10)
        textField.returnKeyType = .send
        textField.delegate = self
        sendContentView.addSubview(textField)
        self.textField = textField
        
        textField.agora_x = AgoraDeviceAssistant.OS.isPad ? 10 : 5
        textField.agora_right = AgoraDeviceAssistant.OS.isPad ? 30 : 23
        textField.agora_y = 0
        textField.agora_bottom = 0
        return view
    }()
    
    fileprivate var vm: AgoraChatPanelVM?

    public convenience init(httpConfig: AgoraHTTPConfig) {
        self.init(frame: .zero)
        
        vm = AgoraChatPanelVM(httpConfig: httpConfig)
        vm?.getMessageList(successBlock: {[weak self] (models) in
            self?.chatModels = models
        }, failureBlock: { (errMsg) in
            // errToast
        })
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initView()
        self.initLayout()
        self.keyboardNotification()
    }
    
    public func inoutChatMessage(_ user: AgoraChatUserInfoModel, left: Bool = true) {
        var roleStr = ""
        if (user.role == .student) {
            roleStr = "（学生）"
        } else if (user.role == .teacher) {
            roleStr = "（老师）"
        } else if (user.role == .assistant) {
            roleStr = "（助教）"
        }
        var endStr = "进入教室"
        if left {
            endStr = "离开教室"
        }
        
        let model = AgoraChatMessageInfoModel()
        model.type = .userInout
        model.message = "\(user.userName)\(roleStr)\(endStr)"
        
        self.vm?.models.append(model)
        self.chatModels = self.vm?.models ?? []
    }
    
    public func receivedChatMessage(_ model: AgoraChatMessageInfoModel) {
        self.vm?.models.append(model)
        self.chatModels = self.vm?.models ?? []
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
            cell.translateTouchBlock = {[weak self] (infoModel: AgoraChatMessageInfoModel?) -> Void in
                self?.vm?.translateMessage(model: infoModel, successBlock: {[weak self] in
                    self?.chatTableView.reloadData()
                }, failureBlock: {[weak self] (errMsg) in
                    self?.chatTableView.reloadData()
                })
            }
            cell.retryTouchBlock = {[weak self] (infoModel: AgoraChatMessageInfoModel?) -> Void in
                self?.vm?.sendMessage(model: infoModel, successBlock: {[weak self] in
                    self?.chatTableView.reloadData()
                }, failureBlock: {[weak self] (errMsg) in
                    self?.chatTableView.reloadData()
                })
            }
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
            self.originalBottom = self.agora_bottom
            self.agora_bottom = rect.size.height + 5
        }
    }
    @objc fileprivate func keyboardWillHidden(_ notification: NSNotification) {
        self.agora_bottom = self.originalBottom
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
    }
    
    fileprivate func initLayout() {
        
        self.maxView.agora_x = 0
        self.maxView.agora_y = 0
        self.maxView.agora_bottom = 0
        self.maxView.agora_right = 0

        self.sendView.agora_bottom = 0
        self.sendView.agora_x = 0
        self.sendView.agora_right = 0
        self.sendView.agora_height = AgoraDeviceAssistant.OS.isPad ? 54 : 35
        self.sendView.layer.cornerRadius = self.sendView.agora_height * 0.2

        let gap: CGFloat = AgoraDeviceAssistant.OS.isPad ? 12 : 8
        
        self.chatView.agora_x = 0
        self.chatView.agora_right = 0
        self.chatView.agora_bottom = self.sendView.agora_bottom + self.sendView.agora_height + gap
        self.chatView.agora_y = 0
        self.chatView.layer.cornerRadius = AgoraDeviceAssistant.OS.isPad ? 10 : 8

        self.minView.agora_x = 0
        self.minView.agora_y = 0
        self.minView.agora_right = 0
        self.minView.agora_bottom = 0
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
            self.textField?.agora_right = AgoraDeviceAssistant.OS.isPad ? 30 : 23
            
            let gap: CGFloat = AgoraDeviceAssistant.OS.isPad ? 12 : 8
            self.chatView.agora_bottom = self.sendView.agora_bottom + self.sendView.agora_height + gap
        }
    }
}

// MARK: UITextFieldDelegate
extension AgoraChatPanelView: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.onSendTouchEvent()
        return true
    }
}

// MARK: TouchEvent
extension AgoraChatPanelView {
    @objc fileprivate func onSendTouchEvent() {
        
        vm?.agoraChatMessageInfoModel(msg: self.textField?.text, block: { [weak self] (messageInfoModel) in
            
            guard let `self` = self else {
                return
            }
            
            let model = self.vm?.sendMessage(model: messageInfoModel, successBlock: {[weak self] in
                
                self?.chatTableView.reloadData()
                
            }, failureBlock: {[weak self] (msgError) in
                //
                self?.chatTableView.reloadData()
            })
            
            if(model != nil) {
                self.chatModels = self.vm?.models ?? []
            }
        })

        self.textField?.text = nil
        self.textField?.resignFirstResponder()
    }
    
    fileprivate func scrollToBottom() {
        self.chatTableView.reloadData()
        
        if (self.chatModels.count <= 1) {
            return
        }
        
        let indexPath = IndexPath(row: 0, section: self.chatModels.count - 1)
        self.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
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

