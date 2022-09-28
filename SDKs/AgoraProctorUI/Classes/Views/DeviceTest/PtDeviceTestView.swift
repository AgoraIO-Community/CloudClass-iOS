//
//  PtDeviceTestUIComponentView.swift
//  AgoraProctorUI
//
//  Created by DoubleCircle on 2022/9/12.
//

import AgoraUIBaseViews

class PtDeviceTestView: UIView {
    /**views**/
    private lazy var backgroundImageView = UIImageView()
    private(set) lazy var exitButton = UIButton()
    private(set) lazy var titleLabel = UILabel()
    private(set) lazy var greetLabel = UILabel()
    private(set) lazy var stateLabel = UILabel()
    private lazy var bottomView = UIView()
    private(set) lazy var enterButton = UIButton()
    private(set) lazy var renderView = PtRenderView()
    private(set) lazy var noAccessView = PtDeviceTestNOAccessView()
    private(set) lazy var switchCameraButton = UIButton()
    private lazy var switchCameraLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initViews()
        initViewFrame()
        updateViewProperties()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateEnterable(_ able: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else {
                return
            }
            if able {
                self.noAccessView.agora_visible = false
                self.switchCameraButton.agora_visible = true
                self.switchCameraLabel.agora_visible = true
                
                self.enterButton.isUserInteractionEnabled = true
                self.enterButton.alpha = 1
                self.enterButton.mas_remakeConstraints { make in
                    make?.centerX.equalTo()(0)
                    make?.width.mas_greaterThanOrEqualTo()(200)
                    make?.height.equalTo()(46)
                    make?.bottom.equalTo()(-40)
                }
            } else {
                self.noAccessView.agora_visible = true
                self.switchCameraButton.agora_visible = false
                self.switchCameraLabel.agora_visible = false
                
                self.enterButton.isUserInteractionEnabled = false
                self.enterButton.alpha = 0.5
                self.enterButton.mas_remakeConstraints { make in
                    make?.centerX.equalTo()(0)
                    make?.width.mas_greaterThanOrEqualTo()(200)
                    make?.height.equalTo()(46)
                    make?.bottom.equalTo()(-209)
                }
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        enterButton.layer.cornerRadius = enterButton.bounds.height / 2
        enterButton.layer.masksToBounds = true
        
        switchCameraButton.layer.cornerRadius = switchCameraButton.bounds.height / 2
        
        let config = UIConfig.deviceTest.bottomMask
        let bgLayer1 = CAGradientLayer()
        bgLayer1.colors = [config.startColor.cgColor,
                           config.endColor.cgColor]
        bgLayer1.frame = bottomView.bounds
        bgLayer1.startPoint = CGPoint(x: 0.5,
                                      y: 0)
        bgLayer1.endPoint = CGPoint(x: 0.5,
                                    y: 1)
        bottomView.layer.addSublayer(bgLayer1)
    }
}

extension PtDeviceTestView: AgoraUIContentContainer {
    public func initViews() {
        backgroundImageView.contentMode = .scaleAspectFill
        
        titleLabel.sizeToFit()
        
        stateLabel.text = "pt_device_test_label_check_screen".pt_localized()
        
        switchCameraLabel.text = "pt_exam_prep_label_switch_camera".pt_localized()
        
        enterButton.setTitle("pt_sub_room_button_join_exam".pt_localized(),
                             for: .normal)
        
        addSubviews([backgroundImageView,
                     exitButton,
                     titleLabel,
                     greetLabel,
                     stateLabel,
                     renderView,
                     bottomView,
                     switchCameraButton,
                     switchCameraLabel,
                     enterButton,
                     noAccessView])
    }
    
    public func initViewFrame() {
        backgroundImageView.mas_makeConstraints { make in
            make?.left.right().top().equalTo()(0)
            make?.height.equalTo()(262.5)
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
        
        bottomView.mas_makeConstraints { make in
            make?.left.right().bottom().equalTo()(0)
            make?.height.equalTo()(211)
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
        enterButton.setTitleColorForAllStates(config.enterButton.titleColor)
        enterButton.titleLabel?.font = config.enterButton.titleFont
        
        switchCameraButton.backgroundColor = config.switchCamera.backgroundColor
        switchCameraButton.setImage(config.switchCamera.normalImage,
                                    for: .normal)
        switchCameraButton.setImage(config.switchCamera.selectedImage,
                                    for: .highlighted)
        switchCameraLabel.textColor = config.switchCamera.labelColor
        switchCameraLabel.font = config.switchCamera.labelFont
    }
}
