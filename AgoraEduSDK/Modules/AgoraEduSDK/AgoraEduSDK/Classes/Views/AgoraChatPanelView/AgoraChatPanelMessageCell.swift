//
//  AgoraChatPanelMessageCell.swift
//  AgoraEduSDK
//
//  Created by SRS on 2021/1/31.
//

import Foundation

@objcMembers public class AgoraChatPanelMessageCell: AgoraBaseCell {
    
    fileprivate let LabelTag = 99
    fileprivate let LoadingBtnTag = 100
    fileprivate let LoadingViewTag = 101
    
    fileprivate lazy var mineLabel: AgoraBaseLabel = {
        let label = self.nickLabel()
        label.text = " : 我"
        return label
    }()
    fileprivate lazy var remoteLabel: AgoraBaseLabel = {
        let label = self.nickLabel()
        label.text = "老师 : "
        return label
    }()
    fileprivate lazy var messageSourceLabel: AgoraBaseLabel = {
        let label = self.messageLabel()
        return label
    }()
    fileprivate lazy var messageTargetLabel: AgoraBaseLabel = {
        let label = self.messageLabel()
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
    fileprivate lazy var failView: AgoraBaseView = {
        let view = self.loadingView()
        let btn = view.viewWithTag(LoadingBtnTag) as! AgoraBaseButton
        btn.addTarget(self, action: #selector(onFailTouchEvent), for: .touchUpInside)
        btn.setImage(AgoraImageWithName("chat_tag", self.classForCoder), for: .normal)
        view.isHidden = true
        return view
    }()
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initView()
        initLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        initView()
        initLayout()
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
        self.contentView.backgroundColor = UIColor.white
        
//        self.
        
//        self.contentView.addSubview(self.inoutView)
    }
    
    fileprivate func initLayout() {
//        self.inoutView.height = AgoraDeviceAssistant.OS.isPad ? 35 : 25
//        self.inoutView.centerX = 0
//        self.inoutView.centerY = 0
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
    

