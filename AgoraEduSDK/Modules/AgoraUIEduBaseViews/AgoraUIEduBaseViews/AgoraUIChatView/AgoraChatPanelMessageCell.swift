 //
//  AgoraChatPanelMessageCell.swift
//  AgoraEduSDK
//
//  Created by SRS on 2021/1/31.
//

import Foundation
import AgoraUIBaseViews
import AgoraEduContext

fileprivate var Agora_Chat_Cell_Key = "Agora_Chat_Cell_Key"
extension AgoraEduContextChatInfo {
    var cellHeight: CGFloat {
        set {
            objc_setAssociatedObject(self,
                                     &Agora_Chat_Cell_Key,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        get {
            let v = objc_getAssociatedObject(self,
                                             &Agora_Chat_Cell_Key)
            
            if let value = v as? CGFloat {
                return value
            } else {
                return 0
            }
        }
    }
}

class AgoraChatPanelMessageCell: AgoraBaseUITableViewCell {
    
    var retryTouchBlock: ((_ infoModel: AgoraEduContextChatInfo?) -> Void)?

    fileprivate let LoadingBtnTag = 101
    fileprivate let LoadingViewTag = 102
    
    fileprivate lazy var mineLabel: AgoraBaseUILabel = {
        let label = self.nickLabel()
        label.text = ""
        label.textAlignment = .right
        return label
    }()
    fileprivate lazy var remoteLabel: AgoraBaseUILabel = {
        let label = self.nickLabel()
        label.text = ""
        return label
    }()
    fileprivate lazy var messageSourceLabel: AgoraBaseUILabel = {
        let label = self.messageLabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping
        return label
    }()
    fileprivate lazy var failView: AgoraBaseUIView = {
        let view = self.loadingView()
        let btn = view.viewWithTag(LoadingBtnTag) as! AgoraBaseUIButton
        btn.addTarget(self, action: #selector(onFailTouchEvent), for: .touchUpInside)
        btn.setImage(AgoraKitImage("chat_error"), for: .normal)
        view.isHidden = true
        return view
    }()
    
    fileprivate lazy var chatContentView: AgoraBaseUIView = {
        let view = AgoraBaseUIView()
        view.clipsToBounds = true
        view.layer.borderWidth = 1
        return view
    }()
    
    fileprivate var infoModel: AgoraEduContextChatInfo?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initView()
        initLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initView()
        initLayout()
    }

    func updateView(model: AgoraEduContextChatInfo) {
        self.infoModel = model
 
        // ---
        let sizeGapX: CGFloat = 7
        let sizeGapY: CGFloat = 4
        let maxWidth = self.frame.width - sizeGapX * 2 - self.failView.agora_width - 8
        let lineViewGap: CGFloat = 3
        
        if (model.from == .local) {
            // mineLabel
            self.mineLabel.isHidden = false
            self.remoteLabel.isHidden = true
            self.mineLabel.attributedText = self.nickAttributedString(model: model)
        } else {
            // remoteLabel
            self.mineLabel.isHidden = true
            self.remoteLabel.isHidden = false
            self.remoteLabel.attributedText = self.nickAttributedString(model: model)
        }
        
        // sourceMessage
        let maxSourceWidth = maxWidth - sizeGapX * 2;
        // messageSource
        self.messageSourceLabel.text = model.message
        let sourceSize = self.messageSourceLabel.sizeThatFits(CGSize(width: maxSourceWidth, height: CGFloat(MAXFLOAT)))
        self.messageSourceLabel.agora_x = sizeGapX + 2
        self.messageSourceLabel.agora_width = sourceSize.width + 1
        self.messageSourceLabel.agora_height = sourceSize.height + 1
        self.messageSourceLabel.agora_y = sizeGapY
                
        let cellHeight = (self.mineLabel.agora_y * 2 + self.mineLabel.agora_height) + (self.messageSourceLabel.agora_y + self.messageSourceLabel.agora_height) + lineViewGap
                
        // chatContentView
        let contentWidth = self.messageSourceLabel.agora_width + sizeGapX * 2.5
        if (model.from == .local) {
            self.chatContentView.agora_right = sizeGapX
            self.chatContentView.agora_x = self.frame.width - contentWidth - sizeGapX
        } else {
            self.chatContentView.agora_right = self.frame.width - contentWidth - sizeGapX
            self.chatContentView.agora_x = sizeGapX
        }
        self.chatContentView.layer.cornerRadius = contentWidth * 0.04

        if model.from == .local {
            self.chatContentView.backgroundColor = UIColor(rgb: 0xE1EBFC)
            self.chatContentView.layer.borderColor = UIColor.clear.cgColor
        } else {
            self.chatContentView.backgroundColor = UIColor.white
            self.chatContentView.layer.borderColor = UIColor(rgb: 0xECECF1).cgColor
        }
           
        // failView
        self.failView.isHidden = true
        if (model.from == .local) {
            self.updateFaileView()
            self.failView.agora_bottom = self.messageSourceLabel.agora_y
            
            self.failView.agora_x = self.chatContentView.agora_x - self.failView.agora_width - 4
        }
        
        model.cellHeight = cellHeight
    }
    
    // MARK: action
    @objc fileprivate func onFailTouchEvent() {
        self.retryTouchBlock?(self.infoModel)
    }
}

// MARK: Rect
extension AgoraChatPanelMessageCell {
    fileprivate func initView() {
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
        
        self.contentView.addSubview(self.chatContentView)
        self.contentView.addSubview(self.mineLabel)
        self.contentView.addSubview(self.remoteLabel)
        self.chatContentView.addSubview(self.messageSourceLabel)
        self.contentView.addSubview(self.failView)
    }
    
    fileprivate func initLayout() {
        
        let GapX: CGFloat = 7
        let GapY: CGFloat = 4
        
        self.mineLabel.agora_x = GapX
        self.mineLabel.agora_y = GapY
        self.mineLabel.agora_right = self.mineLabel.agora_x
        self.mineLabel.agora_height = 18

        self.remoteLabel.agora_x = GapX
        self.remoteLabel.agora_y = GapY
        self.remoteLabel.agora_right = GapX
        self.remoteLabel.agora_height = 18
        
        self.chatContentView.agora_x = 0
        self.chatContentView.agora_right = 0
        self.chatContentView.agora_y = self.mineLabel.agora_y * 2 + self.mineLabel.agora_height
        self.chatContentView.agora_bottom = 0

        self.failView.agora_bottom = 0
        self.failView.agora_x = 0
        self.failView.agora_resize(15, 14)
    }
}

// MARK: Private
extension AgoraChatPanelMessageCell {
    fileprivate func nickAttributedString (model: AgoraEduContextChatInfo) -> NSAttributedString {
        let attr: NSMutableAttributedString = NSMutableAttributedString(string: model.user?.userName ?? "")
        return attr
    }
    
    fileprivate func nickLabel() -> AgoraBaseUILabel {
        let label = AgoraBaseUILabel()
        label.textColor = UIColor(rgb: 0x586376)
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }
    fileprivate func messageLabel() -> AgoraBaseUILabel {
        let label = AgoraBaseUILabel()
        label.text = ""
        label.textColor = UIColor(rgb: 0x191919)
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }
    fileprivate func loadingView() -> AgoraBaseUIView {
        
        let view = AgoraBaseUIView()
        view.backgroundColor = UIColor.clear
        
        let btn = AgoraBaseUIButton(type: .custom)
        btn.tag = LoadingBtnTag
        view.addSubview(btn)
        btn.agora_move(0, 0)
        btn.agora_right = 0
        btn.agora_bottom = 0
    
        let indicatorView = UIActivityIndicatorView()
//        if !AgoraKitDeviceAssistant.OS.isPad {
//            indicatorView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
//        }
        indicatorView.style = .gray
        indicatorView.tag = LoadingViewTag
        indicatorView.isHidden = true
        view.addSubview(indicatorView)
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            indicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        return view
    }
    
    fileprivate func updateFaileView() {
        guard let model = self.infoModel else {
            return
        }
    
        self.failView.isHidden = false
        
        let failBtn = self.failView.viewWithTag(LoadingBtnTag) as! AgoraBaseUIButton
        let failLoading = self.failView.viewWithTag(LoadingViewTag) as! UIActivityIndicatorView
        if (model.sendState == .success) {
            self.failView.isHidden = true
        } else if (model.sendState == .failure) {
            failBtn.isHidden = false
            failLoading.isHidden = true
            failLoading.stopAnimating()
        } else if (model.sendState == .inProgress) {
            failBtn.isHidden = true
            failLoading.isHidden = false
            failLoading.startAnimating()
        }
    }
}
    

