//
//  AgoraChatPanelMessageCell.swift
//  AgoraEduSDK
//
//  Created by SRS on 2021/1/31.
//

import Foundation
import EduSDK

public enum AgoraChatLoadingState: Int {
    case none = 1, loading, success, failure
}

@objc public enum AgoraChatMessageType: Int {
    case text = 0, userInout
}

@objcMembers public class AgoraChatMessageModel: NSObject {
    public var messageId = 0
    public var message = ""
    public var translateMessage = ""
    public var userName = ""
    
    public var type:AgoraChatMessageType = .text
    
    public var isSelf = false
    public var translateState: AgoraChatLoadingState = .none
    public var sendState: AgoraChatLoadingState = .none
    
    public var cellHeight: CGFloat = 0
}

@objcMembers public class AgoraChatPanelMessageCell: AgoraBaseCell {
    
    fileprivate let LoadingBtnTag = 101
    fileprivate let LoadingViewTag = 102
    
    fileprivate lazy var mineLabel: AgoraBaseLabel = {
        let label = self.nickLabel()
        label.text = ""
        return label
    }()
    fileprivate lazy var remoteLabel: AgoraBaseLabel = {
        let label = self.nickLabel()
        label.text = ""
        return label
    }()
    fileprivate lazy var messageSourceLabel: AgoraBaseLabel = {
        let label = self.messageLabel()
        label.numberOfLines = 0
        return label
    }()
    fileprivate lazy var messageTargetLabel: AgoraBaseLabel = {
        let label = self.messageLabel()
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    fileprivate lazy var translateView: AgoraBaseView = {
        let view = self.loadingView()
        let btn = view.viewWithTag(LoadingBtnTag) as! AgoraBaseButton
        btn.addTarget(self, action: #selector(onTranslateTouchEvent), for: .touchUpInside)
        btn.setImage(AgoraImageWithName("chat_translate", self.classForCoder), for: .normal)
        btn.setImage(AgoraImageWithName("chat_translate_forbid", self.classForCoder), for: .selected)
        btn.isSelected = true
        return view
    }()
    fileprivate lazy var translateLineView: AgoraBaseView = {
        let view = AgoraBaseView()
        view.backgroundColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 0.5)
        view.isHidden = true
        return view
    }()
    fileprivate lazy var failView: AgoraBaseView = {
        let view = self.loadingView()
        let btn = view.viewWithTag(LoadingBtnTag) as! AgoraBaseButton
        btn.addTarget(self, action: #selector(onFailTouchEvent), for: .touchUpInside)
        btn.setImage(AgoraImageWithName("chat_tag", self.classForCoder), for: .normal)
        view.isHidden = true
        return view
    }()
    
    fileprivate lazy var chatContentView: AgoraBaseView = {
        let view = AgoraBaseView()
        view.backgroundColor = UIColor(red: 19/255.0, green: 25/255.0, blue: 111/255.0, alpha: 0.5)
        view.clipsToBounds = true
        return view
    }()
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        initView()
    }
    
    public func updateCell(_ text: String) {
//        let label = self.inoutView.viewWithTag(LabelTag) as! AgoraBaseLabel
//        label.text = "text"
//        label.sizeToFit()
//        let size = label.frame.size
//        label.width = size.width
    }
}

// MARK: Rect
extension AgoraChatPanelMessageCell {
    fileprivate func initView() {
        self.contentView.backgroundColor = UIColor.clear
        
        self.contentView.addSubview(self.chatContentView)
        
        self.chatContentView.addSubview(self.mineLabel)
        self.chatContentView.addSubview(self.remoteLabel)
        self.chatContentView.addSubview(self.translateView)
        self.chatContentView.addSubview(self.messageSourceLabel)
        self.chatContentView.addSubview(self.translateLineView)
        self.chatContentView.addSubview(self.messageTargetLabel)
        self.contentView.addSubview(self.failView)
    }
    fileprivate func initLayout() {
        
        self.chatContentView.x = 0
        self.chatContentView.right = 0
        self.chatContentView.y = 0
        self.chatContentView.bottom = 0
        
        self.mineLabel.right = 11
        self.mineLabel.y = 15
        self.mineLabel.width = 0
        self.mineLabel.height = 0
        
        self.remoteLabel.x = 11
        self.remoteLabel.y = 15
        self.remoteLabel.width = 0
        self.remoteLabel.height = 0
        
        self.translateView.x = self.mineLabel.right
        self.translateView.y = 0
        self.translateView.width = 19
        self.translateView.height = 19
        
        self.translateLineView.x = self.mineLabel.right
        self.translateLineView.y = 0
        self.translateLineView.right = self.mineLabel.right
        self.translateLineView.height = 1
        
        self.failView.bottom = 0
        self.failView.x = 0
        self.failView.resize(15, 15)
    }

    public func updateView(model: AgoraChatMessageModel) {
        
        // translateView
        let translateBtn = self.translateView.viewWithTag(LoadingBtnTag) as! AgoraBaseButton
        let translateLoading = self.translateView.viewWithTag(LoadingViewTag) as! UIActivityIndicatorView
        if (model.translateState == .loading) {
            translateBtn.isHidden = true
            translateLoading.isHidden = false
            translateLoading.startAnimating()
            
        } else if (model.translateState == .none || model.translateState == .failure) {
            translateBtn.isHidden = false
            translateBtn.isSelected = false
            translateBtn.isUserInteractionEnabled = true
            translateLoading.isHidden = true
            
        }  else if (model.translateState == .success) {
            translateBtn.isHidden = false
            translateBtn.isSelected = true
            translateBtn.isUserInteractionEnabled = false
            translateLoading.isHidden = true
        }

        // ---
        let sizeGap: CGFloat = 8
        let translateViewSize = CGSize(width: 19, height:19)
        let maxWidth = self.frame.width - sizeGap * 2 - self.failView.width
        let translateLineViewGap: CGFloat = 10
        
        var nickSize = CGSize(width: 0, height:0)
        if (model.isSelf) {
            // mineLabel
            self.mineLabel.isHidden = false
            self.remoteLabel.isHidden = true
            self.mineLabel.text = " : " + model.userName
            self.mineLabel.sizeToFit()
            nickSize = self.mineLabel.frame.size;
            self.mineLabel.width = nickSize.width + 1
            self.mineLabel.height = nickSize.height + 1
        } else {
            // remoteLabel
            self.mineLabel.isHidden = true
            self.remoteLabel.isHidden = false
            self.remoteLabel.text = model.userName + " : "
            self.remoteLabel.sizeToFit()
            nickSize = self.remoteLabel.frame.size;
            self.remoteLabel.width = nickSize.width + 1
            self.remoteLabel.height = nickSize.height + 1
        }
        
        // sourceMessage
        let maxSourceWidth = maxWidth - translateViewSize.width - nickSize.width - self.mineLabel.right * 3;
        let messageHeight: CGFloat = 15
        // messageSource
        self.messageSourceLabel.text = model.message
        let sourceSize =  self.messageSourceLabel.sizeThatFits(CGSize(width: maxSourceWidth, height: 1000))
        self.messageSourceLabel.clearConstraint()
        self.messageSourceLabel.width = sourceSize.width + 1
        self.messageSourceLabel.height = sourceSize.height + 1
        self.messageSourceLabel.y = self.mineLabel.y
        if (model.isSelf) {
            self.messageSourceLabel.right = self.mineLabel.right + self.mineLabel.width + 2
        } else {
            self.messageSourceLabel.x = self.remoteLabel.width + 2
        }
        
        var cellHeight = sourceSize.height + self.mineLabel.y + translateLineViewGap
        
        // targetMessage
        let maxTargetWidth = maxWidth - self.mineLabel.right * 2;
        var targetSize = CGSize(width: 0, height: 0)
        self.messageTargetLabel.isHidden = true
        self.translateLineView.isHidden = true
        if (!model.translateMessage.isEmpty) {
            self.messageTargetLabel.text = model.translateMessage
            targetSize =  self.messageTargetLabel.sizeThatFits(CGSize(width: maxTargetWidth, height: 1000))
            
            self.messageTargetLabel.isHidden = false
            self.translateLineView.isHidden = false
            self.translateLineView.y = self.messageSourceLabel.y + self.messageSourceLabel.height + translateLineViewGap
            
            self.messageTargetLabel.clearConstraint()
            self.messageTargetLabel.width = targetSize.width + 1
            self.messageTargetLabel.height = targetSize.height + 1
            self.messageTargetLabel.y = translateLineViewGap + self.translateLineView.y
            if (model.isSelf) {
                self.messageTargetLabel.right = self.mineLabel.right
            } else {
                self.messageTargetLabel.x = self.mineLabel.right
            }
            
            cellHeight += targetSize.height + self.mineLabel.y + translateLineViewGap
        }
        
        // chatContentView
        let firstLineWidth = sourceSize.width + self.mineLabel.right * 3 + self.translateView.width + nickSize.width
        let secondLineWidth = targetSize.width + self.mineLabel.right * 2
        let contentWidth = firstLineWidth > secondLineWidth ? firstLineWidth : secondLineWidth
        if (model.isSelf) {
            self.chatContentView.right = sizeGap
            self.chatContentView.x = self.frame.width - contentWidth - sizeGap
        } else {
            self.chatContentView.right = self.frame.width - contentWidth - sizeGap
            self.chatContentView.x = sizeGap
        }
        
        // failView
        let failBtn = self.failView.viewWithTag(LoadingBtnTag) as! AgoraBaseButton
        let failLoading = self.failView.viewWithTag(LoadingViewTag) as! UIActivityIndicatorView
        if (model.sendState == .success) {
            self.failView.isHidden = true
        } else if (model.sendState == .failure) {
            self.failView.isHidden = false
            failBtn.isHidden = false
            failLoading.stopAnimating()
        } else if (model.sendState == .loading) {
            self.failView.isHidden = false
            failBtn.isHidden = true
            failLoading.startAnimating()
        }
        self.failView.x = self.chatContentView.x - self.failView.width
        self.failView.y = cellHeight - self.failView.height
        
        model.cellHeight = cellHeight
        
        // translateView
        self.translateView.clearConstraint()
        if (model.isSelf) {
            self.translateView.x = self.mineLabel.right
            self.translateView.y = self.messageSourceLabel.y + self.messageSourceLabel.height + 2
            
        } else {
            self.translateView.x = contentWidth - self.translateView.width - self.mineLabel.right
            self.translateView.y = self.messageSourceLabel.y + self.messageSourceLabel.height + 2
        }
    }
}

// MARK: TouchEvent
extension AgoraChatPanelMessageCell {
    @objc fileprivate func onTranslateTouchEvent() {
        
    }
    @objc fileprivate func onFailTouchEvent() {
        
    }
}

// MARK: Private
extension AgoraChatPanelMessageCell {
    fileprivate func nickLabel() -> AgoraBaseLabel {
        let label = AgoraBaseLabel()
        label.textColor = UIColor(red: 233/255.0, green: 190/255.0, blue: 54/255.0, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 17)
        return label
    }
    fileprivate func messageLabel() -> AgoraBaseLabel {
        let label = AgoraBaseLabel()
        label.text = ""
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 17)
        return label
    }
    fileprivate func loadingView() -> AgoraBaseView {
        
        let view = AgoraBaseView()
        view.backgroundColor = UIColor.clear
        
        let btn = AgoraBaseButton(type: .custom)
        btn.tag = LoadingBtnTag
        view.addSubview(btn)
        btn.move(0, 0)
        btn.right = 0
        btn.bottom = 0
    
        let indicatorView = UIActivityIndicatorView()
        indicatorView.tag = LoadingViewTag
        indicatorView.isHidden = true
        view.addSubview(indicatorView)
        NSLayoutConstraint.activate([
            indicatorView.topAnchor.constraint(equalTo: self.superview!.topAnchor),
            indicatorView.bottomAnchor.constraint(equalTo: self.superview!.bottomAnchor),
            indicatorView.leftAnchor.constraint(equalTo: self.superview!.leftAnchor),
            indicatorView.rightAnchor.constraint(equalTo: self.superview!.rightAnchor)
        ])

        return view
    }
}
    

