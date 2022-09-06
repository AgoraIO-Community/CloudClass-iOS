//
//  FcrInvigilatorCameraNOAccessView.swift
//  AgoraInvigilatorUI
//
//  Created by LYY on 2022/9/6.
//

import AgoraUIBaseViews

class FcrInvigilatorCameraNOAccessView: UIView {
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

extension FcrInvigilatorCameraNOAccessView: AgoraUIContentContainer {
    func initViews() {
        titleLabel.text = "fcr_device_no_access_title".fcr_invigilator_localized()
        contentLabel.text = "fcr_device_no_access_content".fcr_invigilator_localized()
        
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
        
        titleLabel.font = config.titleFont
        titleLabel.textColor = config.titleColor
        
        contentLabel.font = config.contentFont
        contentLabel.textColor = config.contentColor
    }
}
