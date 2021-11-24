 //
//  AgoraChatPanelMessageCell.swift
//  AgoraEduSDK
//
//  Created by SRS on 2021/1/31.
//

import AgoraUIEduBaseViews
import AgoraUIBaseViews
import AgoraEduContext
import Foundation

protocol AgoraChatPanelMessageCellDelegate: NSObjectProtocol {
    func chatCell(_ cell: AgoraBaseUITableViewCell,
                  didTapRetryOn index: Int)
}

class AgoraChatPanelMessageCell: AgoraBaseUITableViewCell {
    static let MessageCellID = "MessageCellID"

    private let LoadingBtnTag = 101
    private let LoadingViewTag = 102
    
    private lazy var mineLabel: AgoraBaseUILabel = {
        let label = self.nickLabel()
        label.text = ""
        label.textAlignment = .right
        return label
    }()
    
    private lazy var remoteLabel: AgoraBaseUILabel = {
        let label = self.nickLabel()
        label.text = ""
        return label
    }()
    
    private lazy var messageSourceLabel: AgoraBaseUILabel = {
        let label = self.messageLabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping
        return label
    }()
    
    private lazy var failView: AgoraBaseUIView = {
        let view = self.loadingView()
        let btn = view.viewWithTag(LoadingBtnTag) as! AgoraBaseUIButton
//        btn.addTarget(self,
//                      action: #selector(onFailTouchEvent),
//                      for: .touchUpInside)
        
        let image = GetWidgetImage(object: self,
                                   "chat_error")
        btn.setImage(image,
                     for: .normal)
        btn.imageView?.contentMode = .scaleToFill
        
        view.isHidden = true
        return view
    }()
    
    private lazy var chatContentView: AgoraBaseUIView = {
        let view = AgoraBaseUIView()
        view.clipsToBounds = true
        view.layer.borderWidth = 1
        return view
    }()
    
    weak var delegate: AgoraChatPanelMessageCellDelegate?
    var index: Int = 0
    
    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(style: style,
                   reuseIdentifier: reuseIdentifier)
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

//    func updateView(model: AgoraChatItem) {
//        switch model.info.from {
//        case .local:
//            chatContentView.backgroundColor = UIColor(rgb: 0xE1EBFC)
//            chatContentView.layer.borderColor = UIColor.clear.cgColor
//            
//            mineLabel.isHidden = false
//            remoteLabel.isHidden = true
//            mineLabel.attributedText = nickAttributedString(text: model.info.user.userName)
//            
//            // failView
//            updateFaileView(sendState: model.info.sendState)
//        case .remote:
//            chatContentView.backgroundColor = .white
//            chatContentView.layer.borderColor = UIColor(rgb: 0xECECF1).cgColor
//            
//            mineLabel.isHidden = true
//            remoteLabel.isHidden = false
//            remoteLabel.attributedText = nickAttributedString(text: model.info.user.userName)
//            
//            // failView
//            failView.isHidden = true
//        }
//        
//        // message source label
//        messageSourceLabel.font = model.font
//        messageSourceLabel.text = model.info.message
//        messageSourceLabel.agora_x = model.messageLabelRect.origin.x
//        messageSourceLabel.agora_y = model.messageLabelRect.origin.y
//        messageSourceLabel.agora_width = model.messageLabelRect.size.width
//        messageSourceLabel.agora_height = model.messageLabelRect.size.height
//
//        chatContentView.agora_clear_constraint()
//        
//        // message content view
//        if (model.info.from == .local) {
//            chatContentView.agora_y = model.messageContentViewRect.origin.y
//            chatContentView.agora_right = model.messageContentViewRect.origin.x
//            chatContentView.agora_width = model.messageContentViewRect.width
//            
//            // failView
//            let contentViewMaxRightX =  model.messageContentViewRect.origin.x + model.messageContentViewRect.width
//            let failViewMaxRightX = model.failViewAndContentViewGap + model.failViewRect.width
//            failView.agora_x = model.cellWidth - contentViewMaxRightX - failViewMaxRightX
//            failView.agora_y = model.failViewRect.origin.y
//            failView.agora_width = model.failViewRect.width
//            failView.agora_height = model.failViewRect.height
//        } else {
//            chatContentView.agora_x = model.messageContentViewRect.origin.x
//            chatContentView.agora_y = model.messageContentViewRect.origin.y
//            chatContentView.agora_width = model.messageContentViewRect.width
//        }
//        
//        chatContentView.agora_height = model.messageContentViewRect.size.height
//        chatContentView.layer.cornerRadius = model.messageContentViewRect.size.width * 0.04
//    }
    
    // MARK: action
//    @objc fileprivate func onFailTouchEvent() {
//        delegate?.chatCell(self,
//                           didTapRetryOn: index)
//    }
}

// MARK: Rect
private extension AgoraChatPanelMessageCell {
    func initView() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(chatContentView)
        contentView.addSubview(mineLabel)
        contentView.addSubview(remoteLabel)
        contentView.addSubview(failView)
        
        chatContentView.addSubview(messageSourceLabel)
    }
    
    func initLayout() {
        let GapX: CGFloat = 7
        let GapY: CGFloat = 4
        
        mineLabel.agora_x = GapX
        mineLabel.agora_y = GapY
        mineLabel.agora_right = mineLabel.agora_x
        mineLabel.agora_height = 18

        remoteLabel.agora_x = GapX
        remoteLabel.agora_y = GapY
        remoteLabel.agora_right = GapX
        remoteLabel.agora_height = 18
    }
}

// MARK: - Private
private extension AgoraChatPanelMessageCell {
    func nickAttributedString (text: String) -> NSAttributedString {
        let attr: NSMutableAttributedString = NSMutableAttributedString(string: text)
        return attr
    }

    func nickLabel() -> AgoraBaseUILabel {
        let label = AgoraBaseUILabel()
        label.textColor = UIColor(rgb: 0x586376)
         
        return label
    }
    
    func messageLabel() -> AgoraBaseUILabel {
        let label = AgoraBaseUILabel()
        label.text = ""
        label.textColor = UIColor(rgb: 0x191919)
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }
    
    func loadingView() -> AgoraBaseUIView {
        let view = AgoraBaseUIView()
        view.backgroundColor = UIColor.clear
        
        let btn = AgoraBaseUIButton(type: .custom)
        btn.tag = LoadingBtnTag
        view.addSubview(btn)
        btn.agora_move(0, 0)
        btn.agora_right = 0
        btn.agora_bottom = 0
    
        let indicatorView = UIActivityIndicatorView()
        
        if !UIDevice.current.isPad {
            indicatorView.transform = CGAffineTransform(scaleX: 0.6,
                                                        y: 0.6)
        }
        
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
    
//    func updateFaileView(sendState: AgoraEduContextChatState) {
//        let failBtn = failView.viewWithTag(LoadingBtnTag) as! AgoraBaseUIButton
//        let failLoading = failView.viewWithTag(LoadingViewTag) as! UIActivityIndicatorView
//
//        switch sendState {
//        case .success:
//            failView.isHidden = true
//        case .failure:
//            failBtn.isHidden = false
//            failLoading.isHidden = true
//            failLoading.stopAnimating()
//        case .inProgress:
//            failBtn.isHidden = true
//            failLoading.isHidden = false
//            failLoading.startAnimating()
//        case .default:
//            break
//        }
//    }
}
