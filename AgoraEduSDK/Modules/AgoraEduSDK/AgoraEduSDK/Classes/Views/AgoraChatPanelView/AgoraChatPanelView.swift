//
//  AgoraChatPanelView.swift
//  AgoraEduSDK
//
//  Created by SRS on 2021/1/31.
//

import UIKit

@objcMembers public class AgoraChatPanelView: AgoraBaseView {
    
    public var isMin: Bool = false {
        didSet {
            self.resizeView()
        }
    }
    
    public var chatModels: [AgoraChatMessageModel] = [] {
        didSet {
            self.chatTableView.reloadData()
        }
    }
    
    fileprivate let LabelTag = 99
    fileprivate let ImageTag = 100
    fileprivate let InoutCellID = "InoutCellID"
    fileprivate let MessageCellID = "MessageCellID"
    
    fileprivate lazy var titleView: AgoraBaseView = {
        let view = AgoraBaseView()
        view.backgroundColor = UIColor.clear
        
        let label = AgoraBaseLabel()
        label.textColor = UIColor(red: 254/255.0, green:254/255.0, blue: 254/255.0, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 14)
        label.tag = LabelTag
        label.text = "聊天（0）"
        view.addSubview(label)
        label.sizeToFit()
        
        let labelSize = label.frame.size
        let imgSzie = CGSize(width: 14, height: 14)
        let offsetX = (labelSize.width + 3 + imgSzie.width) * 0.5
        
        let imageView = AgoraBaseImageView(image: AgoraImageWithName("chat_tag", self.classForCoder))
        view.addSubview(imageView)
        imageView.centerX = -(offsetX - imgSzie.width)
        imageView.centerY = 0
        imageView.resize(imgSzie.width, imgSzie.height)
        
        label.x = imageView.centerX + imgSzie.width * 0.5 + imageView.width + 3
        label.width = labelSize.width + 1
        label.y = 0
        label.bottom = 0
        
        let btn = AgoraBaseButton(type: .custom)
        btn.setImage(AgoraImageWithName("chat_min", self.classForCoder), for: .normal)
        btn.addTarget(self, action: #selector(onMinTouchEvent), for: .touchUpInside)
        view.addSubview(btn)
        btn.centerY = 0
        btn.right = 5
        btn.resize(20, 20)
        
        return view
    }()
    fileprivate lazy var chatTableView: AgoraBaseTableView = {
        let tableView = AgoraBaseTableView(frame: .zero, style: .plain)
        tableView.backgroundColor = UIColor(red: 19/255.0, green: 25/255.0, blue: 111/255.0, alpha: 0.6)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(AgoraChatPanelInOutCell.self, forCellReuseIdentifier: InoutCellID)
        tableView.register(AgoraChatPanelMessageCell.self, forCellReuseIdentifier: MessageCellID)
        
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
        self.titleView.height = 30
        
        view.addSubview(self.chatTableView)
        self.chatTableView.x = 0
        self.chatTableView.right = 0
        self.chatTableView.y = self.titleView.height
        self.chatTableView.height = 206
        
        return view
    }()
    
    fileprivate lazy var sendView: AgoraBaseView = {
        let view = AgoraBaseView()
        view.clipsToBounds = true
        view.backgroundColor = UIColor(red: 19/255.0, green: 25/255.0, blue: 111/255.0, alpha: 1)
        
        let sendContentView = AgoraBaseView()
        sendContentView.clipsToBounds = true
        sendContentView.backgroundColor = UIColor.white
        view.addSubview(sendContentView)
        sendContentView.x = AgoraDeviceAssistant.OS.isPad ? 8 : 8
        sendContentView.right = AgoraDeviceAssistant.OS.isPad ? 8 : 8
        sendContentView.height = AgoraDeviceAssistant.OS.isPad ? 28 : 28
        sendContentView.bottom = AgoraDeviceAssistant.OS.isPad ? 10 : 10
        sendContentView.layer.cornerRadius = sendContentView.height * 0.3
        
        let btn = AgoraBaseButton(type: .custom)
        btn.setImage(AgoraImageWithName("chat_send", self.classForCoder), for: .normal)
        btn.addTarget(self, action: #selector(onSendTouchEvent), for: .touchUpInside)
        sendContentView.addSubview(btn)
        btn.right = 3
        btn.resize(22, 22)
        btn.centerY = 0
        
        let textField = AgoraBaseTextField()
        textField.attributedPlaceholder = NSAttributedString(string:" 请输入你想说的话",attributes:[NSAttributedString.Key.foregroundColor: UIColor(red: 194/255.0, green: 213/255.0, blue: 229/255.0, alpha: 1)])
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.returnKeyType = .send
        textField.delegate = self
        sendContentView.addSubview(textField)
        textField.x = AgoraDeviceAssistant.OS.isPad ? 10 : 10
        textField.right = btn.right + btn.width + 5
        textField.y = 0
        textField.bottom = 0
            
        return view
    }()
    
//    convenience public init(delegate: AgoraPageControlProtocol?) {
//        self.init(frame: CGRect.zero)
//        self.delegate = delegate
//    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initView()
        self.initLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: UITableViewDelegate & UITableViewDataSource
extension AgoraChatPanelView: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatModels.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let chatModel = chatModels[indexPath.row]
        if (chatModel.type == .userInout) {
            let cell = tableView.dequeueReusableCell(withIdentifier: InoutCellID, for: indexPath) as! AgoraChatPanelInOutCell
            cell.updateCell("Nancy（老师）加入教室！")
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
        
        let chatModel = chatModels[indexPath.row]
        if (chatModel.type == .userInout) {
            return 35
        } else {
            if (chatModel.cellHeight > 0) {
                return chatModel.cellHeight
            }
        }

        return UITableView.automaticDimension
    }
}


// MARK: Rect
extension AgoraChatPanelView {
    fileprivate func initView() {
        self.backgroundColor = UIColor.clear

        self.addSubview(self.chatView)
        self.addSubview(self.sendView)
    }
    
    fileprivate func initLayout() {
        
        self.sendView.bottom = 0
        self.sendView.x = 0
        self.sendView.right = 0
        self.sendView.height = 58
        self.layer.cornerRadius = self.chatView.height * 0.1
        
        let gap: CGFloat = 12
        
        self.chatView.x = 0
        self.chatView.right = 0
        self.chatView.bottom = self.sendView.bottom + self.sendView.height + gap
        self.chatView.y = 0
        self.chatView.height = 296
        self.layer.cornerRadius = self.chatView.height * 0.1
    }
    
    fileprivate func resizeView() {
        
    }
}

// MARK: UITextFieldDelegate
extension AgoraChatPanelView: UITextFieldDelegate {
    
}

// MARK: TouchEvent
extension AgoraChatPanelView {
    @objc fileprivate func onSendTouchEvent() {
        
    }
    
    @objc fileprivate func onMinTouchEvent() {
            
    }
}

