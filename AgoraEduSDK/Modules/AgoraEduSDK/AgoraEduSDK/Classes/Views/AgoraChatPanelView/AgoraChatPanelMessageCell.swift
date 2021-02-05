//
//  AgoraChatPanelMessageCell.swift
//  AgoraEduSDK
//
//  Created by SRS on 2021/1/31.
//

import Foundation
import EduSDK

class AgoraChatPanelMessageCell: AgoraBaseUITableViewCell {
    
    var retryTouchBlock: ((_ infoModel: AgoraChatMessageInfoModel?) -> Void)?
    var translateTouchBlock: ((_ infoModel: AgoraChatMessageInfoModel?) -> Void)?

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
    fileprivate lazy var messageTargetLabel: AgoraBaseUILabel = {
        let label = self.messageLabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping
        label.isHidden = true
        return label
    }()
    fileprivate lazy var translateView: AgoraBaseView = {
        let view = self.loadingView()
        let btn = view.viewWithTag(LoadingBtnTag) as! AgoraBaseUIButton
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
        let btn = view.viewWithTag(LoadingBtnTag) as! AgoraBaseUIButton
        btn.addTarget(self, action: #selector(onFailTouchEvent), for: .touchUpInside)
        btn.setImage(AgoraImageWithName("chat_error", self.classForCoder), for: .normal)
        view.isHidden = true
        return view
    }()
    
    fileprivate lazy var chatContentView: AgoraBaseView = {
        let view = AgoraBaseView()
        view.backgroundColor = UIColor(red: 19/255.0, green: 25/255.0, blue: 111/255.0, alpha: 0.7)
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        return view
    }()
    
    fileprivate var infoModel: AgoraChatMessageInfoModel?
    
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
    
//    static func getCellHeght(model: AgoraChatMessageInfoModel, chatWidth: CGFloat) {
//        let nickLayoutH =  7 * 2 + 18
//
//        //
//        let sizeGap: CGFloat = AgoraDeviceAssistant.OS.isPad ? 8 : 7
//        let translateViewSize = AgoraDeviceAssistant.OS.isPad ? CGSize(width: 22, height:22) : CGSize(width: 13, height:13)
//        let maxWidth = chatWidth - sizeGap * 2 - (AgoraDeviceAssistant.OS.isPad ? 15 : 15) - (AgoraDeviceAssistant.OS.isPad ? 10 : 8)
//        let translateLineViewGap: CGFloat = AgoraDeviceAssistant.OS.isPad ? 10 : 7
//
//        let maxSourceWidth = maxWidth - translateViewSize.width - sizeGap * 2;
//        // messageSource
////        self.messageSourceLabel.text = model.message
////        let sourceSize = self.messageSourceLabel.sizeThatFits(CGSize(width: maxSourceWidth, height: CGFloat(MAXFLOAT)))
////        self.messageSourceLabel.agora_x = sizeGap + 2
////        self.messageSourceLabel.agora_width = sourceSize.width + 1
////        self.messageSourceLabel.agora_height = sourceSize.height + 1
////        self.messageSourceLabel.agora_y = sizeGap
////
////        let nickLayoutH =  7 * 2 + 18
//    }

    func updateView(model: AgoraChatMessageInfoModel) {
        self.infoModel = model
        
        self.updateTranslateView()
        
        // ---
        let sizeGap: CGFloat = AgoraDeviceAssistant.OS.isPad ? 8 : 7
        let translateViewSize = AgoraDeviceAssistant.OS.isPad ? CGSize(width: 22, height:22) : CGSize(width: 13, height:13)
        let maxWidth = self.frame.width - sizeGap * 2 - self.failView.agora_width - (AgoraDeviceAssistant.OS.isPad ? 10 : 8)
        let translateLineViewGap: CGFloat = AgoraDeviceAssistant.OS.isPad ? 10 : 7
        
        if (model.isSelf) {
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
        let maxSourceWidth = maxWidth - translateViewSize.width - sizeGap * 2;
        // messageSource
        self.messageSourceLabel.text = model.message
        let sourceSize = self.messageSourceLabel.sizeThatFits(CGSize(width: maxSourceWidth, height: CGFloat(MAXFLOAT)))
        self.messageSourceLabel.agora_x = sizeGap + 2
        self.messageSourceLabel.agora_width = sourceSize.width + 1
        self.messageSourceLabel.agora_height = sourceSize.height + 1
        self.messageSourceLabel.agora_y = sizeGap
        
        var cellHeight = (self.mineLabel.agora_y * 2 + self.mineLabel.agora_height) + (self.messageSourceLabel.agora_y + self.messageSourceLabel.agora_height) + translateLineViewGap
        
        // targetMessage
        let maxTargetWidth = maxWidth - sizeGap * 2;
        var targetSize = CGSize(width: 0, height: 0)
        self.messageTargetLabel.isHidden = true
        self.translateLineView.isHidden = true
        if (!model.translateMessage.isEmpty) {
            self.messageTargetLabel.text = model.translateMessage
            
            targetSize = self.messageTargetLabel.sizeThatFits(CGSize(width: maxTargetWidth, height: CGFloat(MAXFLOAT)))

            self.messageTargetLabel.isHidden = false
            self.translateLineView.isHidden = false
            self.translateLineView.agora_y = self.messageSourceLabel.agora_y + self.messageSourceLabel.agora_height + translateLineViewGap
            
            self.messageTargetLabel.agora_width = targetSize.width + 1
            self.messageTargetLabel.agora_height = targetSize.height + 1
            self.messageTargetLabel.agora_y = translateLineViewGap + self.translateLineView.agora_y
            self.messageTargetLabel.agora_x = sizeGap

            cellHeight += self.messageTargetLabel.agora_height + self.messageSourceLabel.agora_y + translateLineViewGap
        }
        
        // chatContentView
        let firstLineWidth = self.messageSourceLabel.agora_width + sizeGap * 2.5 + translateViewSize.width
        let secondLineWidth = (self.messageTargetLabel.isHidden ? 0 : self.messageTargetLabel.agora_width) + sizeGap * 2
        let contentWidth = firstLineWidth > secondLineWidth ? firstLineWidth : secondLineWidth
        if (model.isSelf) {
            self.chatContentView.agora_right = sizeGap
            self.chatContentView.agora_x = self.frame.width - contentWidth - sizeGap
        } else {
            self.chatContentView.agora_right = self.frame.width - contentWidth - sizeGap
            self.chatContentView.agora_x = sizeGap
        }
        self.chatContentView.layer.cornerRadius = contentWidth * 0.06

        // failView
        self.failView.isHidden = true
        if (model.isSelf) {
            self.updateFaileView()
            if (model.isSelf) {
                self.failView.agora_x = self.chatContentView.agora_x - self.failView.agora_width - 4
            } else {
                self.failView.agora_x = sizeGap * 2 + contentWidth + 4
            }
            
            self.failView.agora_bottom = self.messageSourceLabel.agora_y
        }
        
        // translateView
        self.translateView.agora_clear_constraint()
        self.translateView.agora_resize(translateViewSize.width, translateViewSize.height)
        if (model.isSelf) {
            self.translateView.agora_x = sizeGap * 1.5 + self.messageSourceLabel.agora_width
            self.translateView.agora_y = self.messageSourceLabel.agora_y + self.messageSourceLabel.agora_height - translateViewSize.height - 1
        } else {
            self.translateView.agora_x = sizeGap * 1.5 + self.messageSourceLabel.agora_width
            self.translateView.agora_y = self.messageSourceLabel.agora_y + self.messageSourceLabel.agora_height - translateViewSize.height - 2
        }
        model.cellHeight = cellHeight
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
        self.chatContentView.addSubview(self.translateView)
        self.chatContentView.addSubview(self.messageSourceLabel)
        self.chatContentView.addSubview(self.translateLineView)
        self.chatContentView.addSubview(self.messageTargetLabel)
        self.contentView.addSubview(self.failView)
    }
    
    fileprivate func initLayout() {
        
        self.mineLabel.agora_x = AgoraDeviceAssistant.OS.isPad ? 11 : 7
        self.mineLabel.agora_y = self.mineLabel.agora_x
        self.mineLabel.agora_right = self.mineLabel.agora_x
        self.mineLabel.agora_height = 18

        self.remoteLabel.agora_x = AgoraDeviceAssistant.OS.isPad ? 11 : 7
        self.remoteLabel.agora_y = self.remoteLabel.agora_x
        self.remoteLabel.agora_right = self.remoteLabel.agora_x
        self.remoteLabel.agora_height = 18
        
        self.chatContentView.agora_x = 0
        self.chatContentView.agora_right = 0
        self.chatContentView.agora_y = self.mineLabel.agora_y * 2 + self.mineLabel.agora_height
        self.chatContentView.agora_bottom = 0

        self.translateView.agora_x = self.mineLabel.agora_right
        self.translateView.agora_y = 0
        self.translateView.agora_width = AgoraDeviceAssistant.OS.isPad ? 22 : 15
        self.translateView.agora_height = self.translateView.agora_width

        self.translateLineView.agora_x = self.mineLabel.agora_x
        self.translateLineView.agora_y = 0
        self.translateLineView.agora_right = self.mineLabel.agora_x
        self.translateLineView.agora_height = 1

        self.failView.agora_bottom = 0
        self.failView.agora_x = 0
        self.failView.agora_resize(AgoraDeviceAssistant.OS.isPad ? 15 : 15, AgoraDeviceAssistant.OS.isPad ? 14 : 14)
    }
}

// MARK: TouchEvent
extension AgoraChatPanelMessageCell {
    @objc fileprivate func onTranslateTouchEvent() {
        //loading
        self.infoModel?.translateState = .loading
        self.updateTranslateView()
        
        self.translateTouchBlock?(self.infoModel)
    }
    @objc fileprivate func onFailTouchEvent() {
        //loading
        self.infoModel?.sendState = .loading
        self.updateFaileView()
    
        self.retryTouchBlock?(self.infoModel)
    }
}

// MARK: Private
extension AgoraChatPanelMessageCell {
    fileprivate func nickAttributedString (model: AgoraChatMessageInfoModel) -> NSAttributedString {
        
        let interval:TimeInterval = TimeInterval(Double(model.sendTime) * 0.001)
        let date = Date(timeIntervalSince1970: interval)
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "HH:mm"
        let timeStr = dateformatter.string(from: date)
        
        let nickStr = model.isSelf ? "我" : (model.fromUser?.userName ?? "")
        
        var range = NSMakeRange(0, 0)
        var totleStr: String = ""
        if model.isSelf {
            totleStr = timeStr + " " + nickStr
            range = NSMakeRange(0, timeStr.count)

        } else {
            totleStr = nickStr + " " + timeStr
            range = NSMakeRange(nickStr.count + 1, timeStr.count)
        }
        
        let attr: NSMutableAttributedString = NSMutableAttributedString(string: totleStr)
        attr.addAttribute(NSAttributedString.Key.font, value:UIFont.systemFont(ofSize:10)
                          , range:range)
        attr.addAttribute(NSAttributedString.Key.foregroundColor, value:UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 0.5)
            , range:range)
        return attr
    }
    
    fileprivate func nickLabel() -> AgoraBaseUILabel {
        let label = AgoraBaseUILabel()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: AgoraDeviceAssistant.OS.isPad ? 17 : 12)
        return label
    }
    fileprivate func messageLabel() -> AgoraBaseUILabel {
        let label = AgoraBaseUILabel()
        label.text = ""
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: AgoraDeviceAssistant.OS.isPad ? 17 : 10)
        return label
    }
    fileprivate func loadingView() -> AgoraBaseView {
        
        let view = AgoraBaseView()
        view.backgroundColor = UIColor.clear
        
        let btn = AgoraBaseUIButton(type: .custom)
        btn.tag = LoadingBtnTag
        view.addSubview(btn)
        btn.agora_move(0, 0)
        btn.agora_right = 0
        btn.agora_bottom = 0
    
        let indicatorView = UIActivityIndicatorView()
        if !AgoraDeviceAssistant.OS.isPad {
            indicatorView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        }
        indicatorView.style = .white
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
    
    fileprivate func updateTranslateView() {
        guard let model = self.infoModel else {
            return
        }
        
        // translateView
        let translateBtn = self.translateView.viewWithTag(LoadingBtnTag) as! AgoraBaseUIButton
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
            
        }  else if (model.translateState == .success || model.sendState != .success) {
            translateBtn.isHidden = false
            translateBtn.isSelected = true
            translateBtn.isUserInteractionEnabled = false
            translateLoading.isHidden = true
        }
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
        } else if (model.sendState == .loading) {
            failBtn.isHidden = true
            failLoading.isHidden = false
            failLoading.startAnimating()
        }
    }
}
    

