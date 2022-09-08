//
//  FcrProctorExamComponent.swift
//  AgoraProctorUI
//
//  Created by LYY on 2022/9/1.
//

import AgoraUIBaseViews
import AgoraEduContext

@objc public protocol FcrProctorExamComponentDelegate: NSObjectProtocol {
    func onExamExit()
}

@objc public class FcrProctorExamComponent: UIViewController {
    /**views**/
    private lazy var backgroundImageView = UIImageView()
    private lazy var exitButton = UIButton()
    private lazy var nameLabel = UILabel()
    private lazy var leaveButton = UIButton()
    private lazy var renderView = FcrProctorRenderView()
    // before
    private lazy var startCountdown = FcrExamStartCountdownView()
    // during
    private lazy var duringCountdown = FcrExamDuringCountdownView()
    // after
    private lazy var endLabel = UILabel()
    
    /**context**/
    private weak var delegate: FcrProctorExamComponentDelegate?
    private let roomController: AgoraEduRoomContext
    private let userController: AgoraEduUserContext
    private let mediaController: AgoraEduMediaContext
    private let streamController: AgoraEduStreamContext
    
    @objc public init(roomController: AgoraEduRoomContext,
                      userController: AgoraEduUserContext,
                      mediaController: AgoraEduMediaContext,
                      streamController: AgoraEduStreamContext,
                      delegate: FcrProctorExamComponentDelegate?) {
        self.roomController = roomController
        self.userController = userController
        self.mediaController = mediaController
        self.streamController = streamController
        self.delegate = delegate
        
        super.init(nibName: nil,
                   bundle: nil)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        initViews()
        initViewFrame()
        updateViewProperties()
        checkExamState()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - AgoraEduRoomHandler
extension FcrProctorExamComponent: AgoraEduRoomHandler {
    public func onClassStateUpdated(state: AgoraEduContextClassState) {
        checkExamState()
    }
}

// MARK: - AgoraUIContentContainer
extension FcrProctorExamComponent: AgoraUIContentContainer {
    public func initViews() {
        backgroundImageView.contentMode = .scaleAspectFill
        
        exitButton.addTarget(self,
                             action: #selector(onClickExitRoom),
                             for: .touchUpInside)
        leaveButton.addTarget(self,
                              action: #selector(onClickExitRoom),
                              for: .touchUpInside)

        let userName = userController.getLocalUserInfo().userName
        nameLabel.text = userName
        nameLabel.sizeToFit()
        
        view.addSubviews([exitButton,
                          nameLabel,
                          leaveButton,
                          renderView,
                          startCountdown,
                          duringCountdown,
                          endLabel])
        
        startCountdown.agora_visible = false
        duringCountdown.agora_visible = false
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
        
        view.backgroundColor = config.backgroundColor
        
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
    }
}

// MARK: - private
private extension FcrProctorExamComponent {
    func checkExamState() {
        let info = roomController.getClassInfo()
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
            duringCountdown.agora_visible = false
            endLabel.agora_visible = true
        }
    }
    
    @objc func onClickExitRoom() {
        let roomState = roomController.getClassInfo().state
        
        guard roomState != .after else {
            delegate?.onExamExit()
            return
        }
        
        let title = "fcr_exam_leave_title".fcr_invigilator_localized()
        let message = "fcr_exam_leave_warning".fcr_invigilator_localized()
        
        let cancelTitle = "fcr_exam_leave_cancel".fcr_invigilator_localized()
        let cancelAction = FcrAlertModelAction(title: cancelTitle)
        
        let leaveTitle = "fcr_exam_leave_sure".fcr_invigilator_localized()
        let leaveAction = FcrAlertModelAction(title: leaveTitle) { [weak self] in
            self?.delegate?.onExamExit()
        }
        
        FcrAlertModel()
            .setTitle(title)
            .setMessage(message)
            .addAction(action: cancelAction)
            .addAction(action: leaveAction)
            .show(in: self)
    }
}
