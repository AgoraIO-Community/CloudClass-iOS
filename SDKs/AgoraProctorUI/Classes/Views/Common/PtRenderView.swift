//
//  FcrProctorRenderView.swift
//  AgoraProctorUI
//
//  Created by DoubleCircle on 2022/9/4.
//

import AgoraUIBaseViews

class PtRenderView: UIView {
    
    private lazy var avatarNameLabel = UILabel()
    private lazy var avatarImageView = UIImageView()
    
    func setUserName(_ name: String) {
        avatarNameLabel.text = name.firstCharacterAsString
    }
    
    func setAvartarImage(_ imageUrl: String) {
        let url = URL(string: imageUrl)
        avatarImageView.sd_setImage(with: url)
    }
    
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

// MARK: - AgoraUIContentContainer
extension PtRenderView: AgoraUIContentContainer {
    func initViews() {
        clipsToBounds = true
        avatarNameLabel.textAlignment = .center
        addSubviews([avatarNameLabel,
                     avatarImageView])
    }
    
    func initViewFrame() {
        avatarNameLabel.mas_makeConstraints { make in
            make?.centerX.equalTo()(self)
            make?.top.equalTo()(148)
            make?.width.height().equalTo()(100)
        }
        
        avatarImageView.mas_makeConstraints { make in
            make?.centerX.equalTo()(self)
            make?.top.equalTo()(148)
            make?.width.height().equalTo()(100)
        }
    }
    
    func updateViewProperties() {
        let config = UIConfig.render
        
        backgroundColor = config.backgroundColor
        layer.cornerRadius = config.cornerRadius
        
        let avatarConfig = UIConfig.render.avatar
        
        avatarNameLabel.backgroundColor = avatarConfig.backgroundColor
        avatarNameLabel.textColor = avatarConfig.titleColor
        avatarNameLabel.layer.borderColor = avatarConfig.borderColor.cgColor
        avatarNameLabel.font = avatarConfig.titleFont
        avatarNameLabel.layer.borderWidth = avatarConfig.borderWidth
    }
}
