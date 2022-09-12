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
    private lazy var switchCameraButton = UIButton()
    // before
    private lazy var startCountdown = FcrExamStartCountdownView()
    // during
    private lazy var duringCountdown = FcrExamDuringCountdownView()
    // after
    private lazy var endLabel = UILabel()
    
    /**context**/
    private weak var delegate: FcrProctorExamComponentDelegate?
    private let contextPool: AgoraEduContextPool
    private var subRoom: AgoraEduSubRoomContext?
    
    /**data**/
    private var currentFront: Bool = true
    
    @objc public init(contextPool: AgoraEduContextPool,
                      delegate: FcrProctorExamComponentDelegate?) {
        self.contextPool = contextPool
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
        
        localSubRonomCheck()
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

        let userName = contextPool.user.getLocalUserInfo().userName
        nameLabel.text = userName
        nameLabel.sizeToFit()
        
        switchCameraButton.addTarget(self,
                                     action: #selector(onClickSwitchCamera),
                                     for: .touchUpInside)
        
        view.addSubviews([exitButton,
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
            make?.top.equalTo()(self.view)?.offset()(20)
            make?.right.equalTo()(self.view)?.offset()(-20)
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
        
        endLabel.backgroundColor = config.endLabel.backgroundColor
        endLabel.textColor = config.endLabel.textColor
        endLabel.font = config.endLabel.textFont
        
        switchCameraButton.setImage(config.switchCamera.normalImage,
                                    for: .normal)
        switchCameraButton.setImage(config.switchCamera.selectedImage,
                                    for: .highlighted)
    }
}

extension FcrProctorExamComponent: AgoraEduGroupHandler {
    public func onSubRoomListAdded(subRoomList: [AgoraEduContextSubRoomInfo]) {
        // TODO: 分组名规则
        guard let userIdPrefix = contextPool.user.getLocalUserInfo().userUuid.getUserIdPrefix(),
              let info = subRoomList.first(where: {$0.subRoomName == userIdPrefix}) else {
            // TODO: ui,失败
            return
        }
        
        joinSubRoom(subRoomId: info.subRoomUuid)
    }
}

// MARK: - private
private extension FcrProctorExamComponent {
    func checkExamState() {
        let info = contextPool.room.getClassInfo()
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
    
    @objc func onClickSwitchCamera() {
        let deviceType: AgoraEduContextSystemDevice = currentFront ? .backCamera : .frontCamera
        guard contextPool.media.openLocalDevice(systemDevice: deviceType) == nil else {
            return
        }
        currentFront = !currentFront
    }
    
    @objc func onClickExitRoom() {
        let roomState = contextPool.room.getClassInfo().state
        
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
    
    func localSubRonomCheck() {
        // TODO: 检查自己是否有小房间
        guard let userIdPrefix = contextPool.user.getLocalUserInfo().userUuid.getUserIdPrefix() else {
            return
        }
        
        guard let subRoomList = contextPool.group.getSubRoomList() else {
            return
        }
        var localSubRoomId: String?
        
        // TODO: 分组name规则
        for subRoom in subRoomList {
            guard subRoom.subRoomName == userIdPrefix else {
                continue
            }
            localSubRoomId = subRoom.subRoomName
            break
        }
        
        if let `localSubRoomId` = localSubRoomId {
            joinSubRoom(subRoomId: localSubRoomId)
        } else {
            // TODO: 当前context不满足直接添加
            let config = AgoraEduContextSubRoomCreateConfig(subRoomName: userIdPrefix,
                                                            invitationUserList: nil,
                                                            subRoomProperties: nil)
            contextPool.group.addSubRoomList(configs: [config]) {
                
            } failure: { error in
                // TODO: ui,添加失败
            }
        }
    }
    
    func joinSubRoom(subRoomId: String) {
        guard subRoom == nil,
              let localSubRoom = contextPool.group.createSubRoomObject(subRoomUuid: subRoomId) else {
            // TODO: ui 失败
            return
        }
        
        subRoom = localSubRoom
        localSubRoom.joinSubRoom(success: {
            
        }, failure: { error in
            // TODO: ui,失败
        })
    }
}
