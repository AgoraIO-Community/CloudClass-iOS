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
    private lazy var renderView = FcrProctorRenderView()
    private(set) lazy var switchCameraButton = UIButton()
    // before
    private lazy var startCountdown = FcrExamStartCountdownView()
    // during
    private lazy var duringCountdown = FcrExamDuringCountdownView()
    // after
    private lazy var endLabel = UILabel()
    
    func updateViewWithState(_ info: FcrExamExamStateInfo) {
        switch info.state {
        case .before:
            startCountdown.agora_visible = true
            duringCountdown.agora_visible = false
            endLabel.agora_visible = false
        case .during:
            startCountdown.agora_visible = false
            duringCountdown.agora_visible = true
            endLabel.agora_visible = false
            
            duringCountdown.updateTimeInfo(startTime: info.startTime,
                                           duration: info.duration)
            duringCountdown.startTimer()
        case .after:
            startCountdown.agora_visible = false
            duringCountdown.agora_visible = true
            endLabel.agora_visible = true
            duringCountdown.updateTimeInfo(startTime: info.startTime,
                                           duration: info.duration)
            duringCountdown.startTimer()
        }
    }
}

// MARK: - AgoraUIContentContainer
extension FcrProctorExamComponentView: AgoraUIContentContainer {
        public func initViews() {
            backgroundImageView.contentMode = .scaleAspectFill

            nameLabel.sizeToFit()
            
            addSubviews([exitButton,
                         nameLabel,
                         leaveButton,
                         renderView,
                         switchCameraButton,
                         startCountdown,
                         duringCountdown,
                         endLabel])
            
            switchCameraButton.agora_visible = false
            startCountdown.agora_visible = false
            duringCountdown.agora_visible = false
            endLabel.agora_visible = false
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
            
            nameLabel.mas_makeConstraints { make in
                make?.centerX.equalTo()(0)
                make?.centerY.equalTo()(exitButton.mas_centerY)
            }
            
            renderView.mas_makeConstraints { make in
                make?.top.equalTo()(nameLabel.mas_bottom)?.offset()(33)
                make?.left.right().bottom().equalTo()(0)
            }
            
            switchCameraButton.mas_makeConstraints { make in
                make?.top.equalTo()(self)?.offset()(20)
                make?.right.equalTo()(self)?.offset()(-20)
                make?.width.height().equalTo()(70)
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
            leaveButton.layer.cornerRadius = config.leaveButton.cornerRadius
            leaveButton.setTitleColorForAllStates(config.leaveButton.titleColor)
            leaveButton.titleLabel?.font = config.leaveButton.titleFont
            
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
            
            switchCameraButton.setImage(config.switchCamera.normalImage,
                                        for: .normal)
            switchCameraButton.setImage(config.switchCamera.selectedImage,
                                        for: .highlighted)
        }
}
