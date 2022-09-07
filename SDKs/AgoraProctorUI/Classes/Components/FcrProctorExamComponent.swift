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

@objc public class FcrProctorExamComponent: UIViewController,
                                        AgoraUIContentContainer {
    /**views**/
    private lazy var backgroundImageView = UIImageView()
    private lazy var exitButton = UIButton()
    private lazy var nameLabel = UILabel()
    private lazy var countDot = UIView()
    private lazy var countLabel = UILabel()
    private lazy var leaveButton = UIButton()
    private lazy var renderView = FcrProctorRenderView()
    
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
    }
    
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
        
        updateRoomInfo()
        
        view.addSubviews([exitButton,
                          nameLabel,
                          countDot,
                          countLabel,
                          leaveButton,
                          renderView])
    }
    
    public func initViewFrame() {
        
    }
    
    public func updateViewProperties() {
        let config = UIConfig.exam
        
        view.backgroundColor = config.backgroundColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - private
private extension FcrProctorExamComponent {
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
    
    // TODO: updateRoomInfo
    func updateRoomInfo() {
        var state = ""
        let roomInfo = roomController.getRoomInfo()
        let classInfo = roomController.getClassInfo()
//        switch classInfo.state {
//        case .before:
//            state = "fcr_device_state_will_start".fcr_invigilator_localized()
//        case .during:
//            state = "fcr_device_state_already_start".fcr_invigilator_localized()
//        default:
//            return
//        }
//        let finalState = state.replacingOccurrences(of: String.agedu_localized_replacing_x(),
//                                                    with: roomInfo.roomName)
//        stateLabel.text = finalState
    }
}
