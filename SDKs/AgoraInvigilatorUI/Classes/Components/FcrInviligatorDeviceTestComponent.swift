//
//  FcrInviligatorDeviceTestComponent.swift
//  AgoraInvigilatorUI
//
//  Created by LYY on 2022/9/6.
//

import AgoraUIBaseViews
import AgoraEduContext

@objc public protocol FcrInviligatorDeviceTestComponentDelegate: NSObjectProtocol {
    func onDeviceTestJoinExamSuccess()
    func onDeviceTestExit()
}

@objc public class FcrInviligatorDeviceTestComponent: UIViewController {
    /**views**/
    private lazy var backgroundImageView = UIImageView()
    private lazy var exitButton = UIButton()
    private lazy var titleLabel = UILabel()
    private lazy var greetLabel = UILabel()
    private lazy var stateLabel = UILabel()
    private lazy var bottomView = UIView()
    private lazy var enterButton = UIButton()
    private lazy var renderView = FcrInviligatorRenderView()
    private lazy var accessView = FcrInvigilatorCameraNOAccessView()
    
    /**data**/
    private weak var delegate: FcrInviligatorDeviceTestComponentDelegate?
    private let roomController: AgoraEduRoomContext
    private let userController: AgoraEduUserContext
    private let mediaController: AgoraEduMediaContext
    private let streamController: AgoraEduStreamContext
    
    @objc public init(roomController: AgoraEduRoomContext,
                      userController: AgoraEduUserContext,
                      mediaController: AgoraEduMediaContext,
                      streamController: AgoraEduStreamContext,
                      delegate: FcrInviligatorDeviceTestComponentDelegate?) {
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
        checkDeviceState()
        
        roomController.registerRoomEventHandler(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FcrInviligatorDeviceTestComponent: AgoraEduRoomHandler {
    public func onClassStateUpdated(state: AgoraEduContextClassState) {
        updateRoomInfo()
    }
}

// MARK: - AgoraUIContentContainer
extension FcrInviligatorDeviceTestComponent: AgoraUIContentContainer {
    public func initViews() {
        view.backgroundColor = .black
        backgroundImageView.contentMode = .scaleAspectFill
        
        titleLabel.text = "fcr_device_device".fcr_invigilator_localized()
        titleLabel.sizeToFit()
        
        let greet = "fcr_device_greet".fcr_invigilator_localized()
        let userName = userController.getLocalUserInfo().userName
        let finalGreet = greet.replacingOccurrences(of: String.agedu_localized_replacing_x(),
                                                 with: userName)
        greetLabel.text = finalGreet

        updateRoomInfo()
        
        enterButton.sizeToFit()
        enterButton.setTitle("fcr_device_enter".fcr_invigilator_localized(),
                             for: .normal)

        view.addSubviews([backgroundImageView,
                     exitButton,
                     titleLabel,
                     greetLabel,
                     stateLabel,
                     bottomView,
                     enterButton])
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
    }
    
    public func updateViewProperties() {
        let config = UIConfig.deviceTest
        
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
    }
}

// MARK: - private
private extension FcrInviligatorDeviceTestComponent {
    @objc func onClickExitRoom() {
        dismiss(animated: true)
    }
    
    @objc func onClickEnterRoom() {
        roomController.joinRoom { [weak self] in
            guard let `self` = self else {
                return
            }
            self.delegate?.onDeviceTestJoinExamSuccess()
        } failure: { error in
            // TODO: join fail
        }
    }
    
    func checkDeviceState() {
        guard mediaController.openLocalDevice(systemDevice: .frontCamera) == nil else {
            accessView.agora_visible = true
            return
        }
        if let _ =  {
            accessView.agora_visible = true
        } else {
            let config = AgoraEduContextRenderConfig()
            let userId = userController.getLocalUserInfo().userUuid
            let streamId = streamController.getStreamList(userUuid: userId)?.first
            mediaController.startRenderVideo(view: renderView,
                                             renderConfig: config,
                                             streamUuid: <#T##String#>)
        }
    }
}


// MARK: - private
private extension FcrInviligatorDeviceTestComponent {
    func updateRoomInfo() {
        var state = ""
        let roomInfo = roomController.getRoomInfo()
        let classInfo = roomController.getClassInfo()
        switch classInfo.state {
        case .before:
            state = "fcr_device_state_will_start".fcr_invigilator_localized()
        case .during:
            state = "fcr_device_state_already_start".fcr_invigilator_localized()
        default:
            return
        }
        let finalState = state.replacingOccurrences(of: String.agedu_localized_replacing_x(),
                                                    with: roomInfo.roomName)
        stateLabel.text = finalState
    }
}
