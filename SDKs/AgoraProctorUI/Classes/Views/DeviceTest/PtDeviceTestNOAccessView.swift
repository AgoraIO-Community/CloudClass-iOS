//
//  FcrDeviceTestNOAccessView.swift
//  AgoraProctorUI
//
//  Created by LYY on 2022/9/6.
//

import AgoraUIBaseViews
import SDWebImage

class PtDeviceTestNOAccessView: UIView {
    private lazy var titleLabel = UILabel()
    private lazy var contentLabel = UILabel()
    private lazy var card = UIView()
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
}

extension PtDeviceTestNOAccessView: AgoraUIContentContainer {
    func initViews() {
        titleLabel.text = "pt_exam_prep_label_no_access_camera".pt_localized()
        contentLabel.text = "pt_exam_prep_label_allow_access_camera".pt_localized()
        contentLabel.numberOfLines = 0
        
        addSubviews([card,
                     imageView,
                     titleLabel,
                     contentLabel])
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
    }
}

