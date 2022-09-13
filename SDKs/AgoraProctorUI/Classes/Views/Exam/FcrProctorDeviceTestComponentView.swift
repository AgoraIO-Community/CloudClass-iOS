//
//  FcrProctorDeviceTestComponentView.swift
//  AgoraProctorUI
//
//  Created by DoubleCircle on 2022/9/12.
//

import AgoraUIBaseViews

class FcrProctorDeviceTestComponentView: UIView {
    /**views**/
    private lazy var backgroundImageView = UIImageView()
    private(set) lazy var exitButton = UIButton()
    private(set) lazy var titleLabel = UILabel()
    private(set) lazy var greetLabel = UILabel()
    private(set) lazy var stateLabel = UILabel()
    private lazy var bottomView = UIView()
    private(set) lazy var enterButton = UIButton()
    private(set) lazy var renderView = FcrProctorRenderView()
    private(set) lazy var noAccessView = FcrDeviceTestNOAccessView()
    private(set) lazy var switchCameraButton = UIButton()
    private lazy var switchCameraLabel = UILabel()
    
    func updateEnterable(_ able: Bool) {
        if able {
            noAccessView.agora_visible = false
            switchCameraButton.agora_visible = true
            switchCameraLabel.agora_visible = true
            
            enterButton.isUserInteractionEnabled = true
            enterButton.alpha = 1
            enterButton.mas_remakeConstraints { make in
                make?.centerX.equalTo()(0)
                make?.width.mas_greaterThanOrEqualTo()(200)
                make?.height.equalTo()(46)
                make?.bottom.equalTo()(-40)
            }
        } else {
            noAccessView.agora_visible = true
            switchCameraButton.agora_visible = false
            switchCameraLabel.agora_visible = false
            
            enterButton.isUserInteractionEnabled = false
            enterButton.alpha = 0.5
            enterButton.mas_remakeConstraints { make in
                make?.centerX.equalTo()(0)
                make?.width.mas_greaterThanOrEqualTo()(200)
                make?.height.equalTo()(46)
                make?.bottom.equalTo()(-209)
            }
        }
    }
}

extension FcrProctorDeviceTestComponentView: AgoraUIContentContainer {
    public func initViews() {
        backgroundImageView.contentMode = .scaleAspectFill
        
        titleLabel.sizeToFit()
        
        switchCameraLabel.text = "fcr_device_switch".fcr_proctor_localized()
        
        enterButton.sizeToFit()
        enterButton.setTitle("fcr_device_enter".fcr_proctor_localized(),
                             for: .normal)
        
        addSubviews([backgroundImageView,
                     exitButton,
                     titleLabel,
                     greetLabel,
                     stateLabel,
                     renderView,
                     switchCameraButton,
                     switchCameraLabel,
                     bottomView,
                     enterButton,
                     noAccessView])
    }
    
    public func initViewFrame() {
        backgroundImageView.mas_makeConstraints { make in
            make?.left.right().top().equalTo()(0)
        }
        
        exitButton.mas_makeConstraints { make in
            make?.top.equalTo()(42)
            make?.left.equalTo()(16)
            make?.width.height().equalTo()(40)
        }
        
        titleLabel.mas_makeConstraints { make in
            make?.centerX.equalTo()(0)
            make?.centerY.equalTo()(exitButton.mas_centerY)
        }
        
        greetLabel.mas_makeConstraints { make in
            make?.top.equalTo()(exitButton.mas_bottom)?.offset()(30)
            make?.left.equalTo()(30)
            make?.right.mas_greaterThanOrEqualTo()(-30)
        }
        
        stateLabel.mas_makeConstraints { make in
            make?.top.equalTo()(greetLabel.mas_bottom)?.offset()(11)
            make?.left.equalTo()(greetLabel.mas_left)
            make?.right.mas_greaterThanOrEqualTo()(-30)
        }
        
        renderView.mas_makeConstraints { make in
            make?.top.equalTo()(stateLabel.mas_bottom)?.offset()(33)
            make?.left.right().bottom().equalTo()(0)
        }
        
        switchCameraButton.mas_makeConstraints { make in
            make?.centerX.equalTo()(self)
            make?.width.height().equalTo()(70)
            make?.bottom.equalTo()(-156)
        }
        
        switchCameraLabel.mas_makeConstraints { make in
            make?.centerX.equalTo()(self)
            make?.top.equalTo()(switchCameraButton.mas_bottom)?.offset()(12)
        }
        
        bottomView.mas_makeConstraints { make in
            make?.left.right().bottom().equalTo()(0)
            make?.height.equalTo()(211)
        }
        
        enterButton.mas_makeConstraints { make in
            make?.centerX.equalTo()(0)
            make?.width.mas_greaterThanOrEqualTo()(200)
            make?.height.equalTo()(46)
            make?.bottom.equalTo()(-40)
        }
        
        noAccessView.mas_makeConstraints { make in
            make?.top.equalTo()(renderView.mas_top)?.offset()(148)
            make?.left.right().bottom().equalTo()(0)
        }
    }
    
    public func updateViewProperties() {
        let config = UIConfig.deviceTest
        
        backgroundColor = config.backgroundColor
        
        backgroundImageView.image = config.backgroundImage
        exitButton.setImage(config.exitButton.image,
                            for: .normal)
        exitButton.backgroundColor = config.exitButton.backgroundColor
        exitButton.layer.cornerRadius = config.exitButton.cornerRadius
        
        greetLabel.font = config.greetLabel.font
        greetLabel.textColor = config.greetLabel.color
        
        stateLabel.font = config.stateLabel.font
        stateLabel.textColor = config.stateLabel.color
        
        titleLabel.font = config.titleLabel.font
        titleLabel.textColor = config.titleLabel.color
        
        enterButton.backgroundColor = config.enterButton.backgroundColor
        enterButton.layer.cornerRadius = config.enterButton.cornerRadius
        enterButton.setTitleColorForAllStates(config.enterButton.titleColor)
        enterButton.titleLabel?.font = config.enterButton.titleFont
        
        switchCameraButton.setImage(config.switchCamera.normalImage,
                                    for: .normal)
        switchCameraButton.setImage(config.switchCamera.selectedImage,
                                    for: .highlighted)
        switchCameraLabel.textColor = config.switchCamera.labelColor
        switchCameraLabel.font = config.switchCamera.labelFont
    }
}
