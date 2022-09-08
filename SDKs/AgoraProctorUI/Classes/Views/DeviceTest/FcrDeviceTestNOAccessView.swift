//
//  FcrDeviceTestNOAccessView.swift
//  AgoraProctorUI
//
//  Created by LYY on 2022/9/6.
//

import AgoraUIBaseViews

class FcrDeviceTestNOAccessView: UIView {
    private lazy var titleLabel = UILabel()
    private lazy var contentLabel = UILabel()
    private lazy var card = UIView()
    private lazy var avatarNameLabel = UILabel()
    private lazy var avatarImageView = UIImageView()
    private lazy var imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initViews()
        initViewFrame()
        updateViewProperties()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        avatarNameLabel.layer.cornerRadius = avatarNameLabel.frame.width / 2
        avatarNameLabel.layer.masksToBounds = true
        
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
        avatarImageView.layer.masksToBounds = true
    }
}

extension FcrDeviceTestNOAccessView: AgoraUIContentContainer {
    func initViews() {
        titleLabel.text = "fcr_device_no_access_title".fcr_invigilator_localized()
        contentLabel.text = "fcr_device_no_access_content".fcr_invigilator_localized()
        contentLabel.numberOfLines = 0
        
        addSubviews([card,
                     imageView,
                     titleLabel,
                     contentLabel,
                     avatarNameLabel,
                     avatarImageView])
    }
    
    func initViewFrame() {
        card.mas_makeConstraints { make in
            make?.left.equalTo()(10)
            make?.right.bottom().equalTo()(-10)
            make?.height.equalTo()(159)
        }
        
        imageView.mas_makeConstraints { make in
            make?.top.equalTo()(card)?.offset()(-17.5)
            make?.right.equalTo()(card)?.offset()(-14.25)
            make?.width.height().equalTo()(100)
        }
        
        titleLabel.mas_makeConstraints { make in
            make?.left.equalTo()(card.mas_left)?.offset()(20)
            make?.top.equalTo()(card.mas_top)?.offset()(30)
            make?.right.equalTo()(imageView.mas_right)?.offset()(-20)
        }
        
        contentLabel.mas_makeConstraints { make in
            make?.left.equalTo()(titleLabel.mas_left)
            make?.top.equalTo()(titleLabel.mas_bottom)?.offset()(24)
            make?.right.equalTo()(card.mas_right)?.offset()(-20)
        }
        
        avatarNameLabel.mas_makeConstraints { make in
            make?.centerX.equalTo()(self)
            make?.top.equalTo()(self)
            make?.width.height().equalTo()(100)
        }
        
        avatarImageView.mas_makeConstraints { make in
            make?.centerX.equalTo()(self)
            make?.top.equalTo()(self)
            make?.width.height().equalTo()(100)
        }
    }
    
    func updateViewProperties() {
        let config = UIConfig.deviceTest.noAccess
        
        backgroundColor = config.backgroundColor
        
        card.backgroundColor = config.cardBackgroundColor
        card.layer.cornerRadius = config.cornerRadius
        
        titleLabel.font = config.titleFont
        titleLabel.textColor = config.titleColor
        
        contentLabel.font = config.contentFont
        contentLabel.textColor = config.contentColor
        
        imageView.image = config.image
        
        let avatarConfig = UIConfig.deviceTest.avatar
        
        avatarNameLabel.backgroundColor = avatarConfig.backgroundColor
        avatarNameLabel.textColor = avatarConfig.titleColor
        avatarNameLabel.layer.borderColor = avatarConfig.borderColor.cgColor
        avatarNameLabel.font = avatarConfig.titleFont
        avatarNameLabel.layer.borderWidth = avatarConfig.borderWidth
    }
}

