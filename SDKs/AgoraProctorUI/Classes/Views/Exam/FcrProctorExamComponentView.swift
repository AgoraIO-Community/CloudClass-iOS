//
//  FcrProctorExamComponentView.swift
//  AgoraProctorUI
//
//  Created by DoubleCircle on 2022/9/12.
//

import AgoraUIBaseViews

class FcrProctorExamComponentView: UIView {
    /**views**/
    private lazy var backgroundImageView = UIImageView()
    private(set) lazy var exitButton = UIButton()
    private(set) lazy var nameLabel = UILabel()
    private(set) lazy var leaveButton = UIButton()
    private(set) lazy var renderView = FcrProctorRenderView()
    private(set) lazy var switchCameraButton = UIButton()
    // before
    private(set) lazy var examNameLabel = UILabel()
    private(set) lazy var beforeExamTipLabel = UILabel()
    private lazy var beforeExamCountdown = FcrExamStartCountdownView(delegate: self)
    // during
    private lazy var duringCountdown = FcrExamDuringCountdownView()
    // after
    private lazy var endLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initViews()
        initViewFrame()
        updateViewProperties()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func animate() {
        self.renderView.mas_makeConstraints { make in
            make?.top.equalTo()(self.nameLabel.mas_bottom)?.offset()(67)
            make?.left.right().equalTo()(0)
            make?.bottom.equalTo()(-111)
        }
        
        UIView.animate(withDuration: TimeInterval.agora_animation) {
            self.layoutIfNeeded()
        }
    }
    
    func updateViewWithState(_ state: FcrProctorUIExamState) {
        switch state {
        case .before:
            examNameLabel.agora_visible = true
            beforeExamTipLabel.agora_visible = true
            duringCountdown.agora_visible = false
            endLabel.agora_visible = false
        case .during(let countdown,
                     let timeInfo):
            examNameLabel.agora_visible = false
            beforeExamTipLabel.agora_visible = false
            beforeExamCountdown.agora_visible = true
            duringCountdown.agora_visible = false
            endLabel.agora_visible = false
            
            if countdown > 0 {
                beforeExamCountdown.startTimer(countdown)
            }
            
            duringCountdown.timeInfo = timeInfo
            duringCountdown.startTimer()
        case .after(let timeInfo):
            beforeExamCountdown.agora_visible = false
            beforeExamTipLabel.agora_visible = false
            duringCountdown.agora_visible = true
            endLabel.agora_visible = true
            duringCountdown.timeInfo = timeInfo
            duringCountdown.startTimer()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        beforeExamTipLabel.layer.cornerRadius = beforeExamTipLabel.bounds.height / 2
        beforeExamTipLabel.layer.masksToBounds = true
        leaveButton.layer.cornerRadius = leaveButton.bounds.height / 2
        switchCameraButton.layer.cornerRadius = switchCameraButton.bounds.height / 2
    }
}

// MARK: - FcrExamStartCountdownViewDelegate
extension FcrProctorExamComponentView: FcrExamStartCountdownViewDelegate {
    func onStartExamTimerStopped() {
        beforeExamCountdown.agora_visible = false
        duringCountdown.agora_visible = true
    }
}

// MARK: - AgoraUIContentContainer
extension FcrProctorExamComponentView: AgoraUIContentContainer {
    public func initViews() {
        backgroundImageView.contentMode = .scaleAspectFill
        
        nameLabel.sizeToFit()
        beforeExamTipLabel.text = "fcr_room_tips_exam_not_started".fcr_proctor_localized()
        beforeExamTipLabel.textAlignment = .center
        leaveButton.setTitle("fcr_exam_leave_title".fcr_proctor_localized(),
                             for: .normal)
        endLabel.text = "fcr_room_label_exam_over".fcr_proctor_localized()
        
        addSubviews([backgroundImageView,
                     exitButton,
                     nameLabel,
                     examNameLabel,
                     leaveButton,
                     renderView,
                     beforeExamTipLabel,
                     beforeExamCountdown,
                     switchCameraButton,
                     duringCountdown,
                     endLabel])
        
        examNameLabel.agora_visible = false
        beforeExamTipLabel.agora_visible = false
        beforeExamCountdown.agora_visible = false
        duringCountdown.agora_visible = false
        endLabel.agora_visible = false
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
        
        examNameLabel.mas_makeConstraints { make in
            make?.centerX.equalTo()(0)
            make?.top.equalTo()(nameLabel.mas_bottom)?.offset()(28)
        }
        
        nameLabel.mas_makeConstraints { make in
            make?.centerX.equalTo()(0)
            make?.centerY.equalTo()(exitButton.mas_centerY)
        }
        
        beforeExamTipLabel.mas_makeConstraints { make in
            make?.centerX.equalTo()(0)
            make?.bottom.equalTo()(renderView.mas_bottom)?.offset()(-66.57)
            make?.width.equalTo()(100)
            make?.height.equalTo()(40)
        }
        
        beforeExamCountdown.mas_makeConstraints { make in
            make?.centerX.equalTo()(0)
            make?.bottom.equalTo()(renderView.mas_bottom)
            make?.width.equalTo()(297)
            make?.height.equalTo()(148)
        }
        
        duringCountdown.mas_makeConstraints { make in
            make?.centerX.equalTo()(0)
            make?.top.equalTo()(nameLabel.mas_bottom)?.offset()(28)
            make?.height.equalTo()(24)
            make?.width.mas_greaterThanOrEqualTo()(83)
        }
        
        renderView.mas_makeConstraints { make in
            make?.top.equalTo()(self.nameLabel.mas_bottom)?.offset()(138)
            make?.left.right().equalTo()(0)
            make?.bottom.equalTo()(0)
        }
        
        switchCameraButton.mas_makeConstraints { make in
            make?.top.equalTo()(renderView)?.offset()(20)
            make?.right.equalTo()(self)?.offset()(-20)
            make?.width.height().equalTo()(50)
        }
        
        leaveButton.mas_makeConstraints { make in
            make?.centerX.equalTo()(0)
            make?.width.mas_greaterThanOrEqualTo()(200)
            make?.height.equalTo()(46)
            make?.bottom.equalTo()(-40)
        }
        
        endLabel.mas_makeConstraints { make in
            make?.centerX.equalTo()(self)
            make?.bottom.equalTo()(renderView.mas_bottom)
            make?.width.equalTo()(200)
            make?.height.equalTo()(48)
        }
    }
    
    public func updateViewProperties() {
        let config = UIConfig.exam
        
        backgroundColor = config.backgroundColor
        
        backgroundImageView.image = config.backgroundImage
        exitButton.setImage(config.exitButton.image,
                            for: .normal)
        exitButton.backgroundColor = config.exitButton.backgroundColor
        exitButton.layer.cornerRadius = config.exitButton.cornerRadius
        
        nameLabel.font = config.nameLabel.font
        nameLabel.textColor = config.nameLabel.color
        
        leaveButton.backgroundColor = config.leaveButton.backgroundColor
        leaveButton.setTitleColorForAllStates(config.leaveButton.titleColor)
        leaveButton.titleLabel?.font = config.leaveButton.titleFont
        
        examNameLabel.textColor = config.examNameLabel.color
        examNameLabel.font = config.examNameLabel.font
        
        beforeExamTipLabel.backgroundColor = config.beforeExamTipLabel.backgroundColor
        beforeExamTipLabel.textColor = config.beforeExamTipLabel.color
        beforeExamTipLabel.font = config.beforeExamTipLabel.font
        
        let maskPath = UIBezierPath.init(roundedRect: CGRect(x: 0,
                                                             y: 0,
                                                             width: 200,
                                                             height: 48),
                                         byRoundingCorners: UIRectCorner(rawValue: UIRectCorner.topLeft.rawValue + UIRectCorner.topRight.rawValue),
                                         cornerRadii: CGSize(width: config.endLabel.cornerRadius,
                                                             height: config.endLabel.cornerRadius))
        let maskLayer = CAShapeLayer.init()
        maskLayer.frame = endLabel.bounds
        maskLayer.path = maskPath.cgPath
        endLabel.layer.mask = maskLayer
        
        endLabel.backgroundColor = config.endLabel.backgroundColor
        endLabel.textColor = config.endLabel.textColor
        endLabel.font = config.endLabel.textFont
        
        switchCameraButton.backgroundColor = config.switchCamera.backgroundColor
        switchCameraButton.setImage(config.switchCamera.normalImage,
                                    for: .normal)
        switchCameraButton.setImage(config.switchCamera.selectedImage,
                                    for: .highlighted)
    }
}
