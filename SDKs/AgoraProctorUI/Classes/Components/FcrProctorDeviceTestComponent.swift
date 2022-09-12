//
//  FcrProctorDeviceTestComponent.swift
//  AgoraProctorUI
//
//  Created by LYY on 2022/9/6.
//

import AgoraUIBaseViews
import AgoraEduContext

@objc public protocol FcrProctorDeviceTestComponentDelegate: NSObjectProtocol {
    func onDeviceTestJoinExamSuccess()
    func onDeviceTestExit()
}

@objc public class FcrProctorDeviceTestComponent: UIViewController {
    /**view**/
    private lazy var contentView = FcrProctorDeviceTestComponentView()
    /**context**/
    private weak var delegate: FcrProctorDeviceTestComponentDelegate?
    private let contextPool: AgoraEduContextPool
    
    /**data**/
    private var currentFront: Bool = true
    
    @objc public init(contextPool: AgoraEduContextPool,
                      delegate: FcrProctorDeviceTestComponentDelegate?) {
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
        checkDeviceState()
        
        contextPool.room.registerRoomEventHandler(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FcrProctorDeviceTestComponent: AgoraEduRoomHandler {
    public func onClassStateUpdated(state: AgoraEduContextClassState) {
        updateRoomInfo()
    }
}

// MARK: - AgoraUIContentContainer
extension FcrProctorDeviceTestComponent: AgoraUIContentContainer {
    public func initViews() {
        view.addSubview(contentView)
        
        contentView.exitButton.addTarget(self,
                             action: #selector(onClickExitRoom),
                             for: .touchUpInside)
        
        contentView.titleLabel.text = "fcr_device_device".fcr_invigilator_localized()
        
        let greet = "fcr_device_greet".fcr_invigilator_localized()
        let userName = contextPool.user.getLocalUserInfo().userName
        let finalGreet = greet.replacingOccurrences(of: String.agedu_localized_replacing_x(),
                                                    with: userName)
        contentView.greetLabel.text = finalGreet
        
        updateRoomInfo()
        
        contentView.switchCameraButton.addTarget(self,
                                                 action: #selector(onClickSwitchCamera),
                                                 for: .touchUpInside)
                
        contentView.enterButton.setTitle("fcr_device_enter".fcr_invigilator_localized(),
                                         for: .normal)
        contentView.enterButton.addTarget(self,
                                          action: #selector(onClickEnterRoom),
                                          for: .touchUpInside)
    }
    
    public func initViewFrame() {
        contentView.mas_makeConstraints { make in
            make?.left.right().top().equalTo()(0)
        }
    }
    
    public func updateViewProperties() {
        let config = UIConfig.deviceTest
        
        view.backgroundColor = config.backgroundColor
    }
}

// MARK: - private
private extension FcrProctorDeviceTestComponent {
    @objc func onClickExitRoom() {
        let streamId = "0"
        contextPool.media.stopRenderVideo(streamUuid: streamId)

        self.delegate?.onDeviceTestExit()
    }
    
    @objc func onClickSwitchCamera() {
        let deviceType: AgoraEduContextSystemDevice = currentFront ? .backCamera : .frontCamera
        guard contextPool.media.openLocalDevice(systemDevice: deviceType) == nil else {
            return
        }
        currentFront = !currentFront
    }
    
    @objc func onClickEnterRoom() {
        AgoraLoading.loading()
        contextPool.room.joinRoom { [weak self] in
            guard let `self` = self else {
                return
            }
            self.delegate?.onDeviceTestJoinExamSuccess()
        } failure: { error in
            AgoraLoading.hide()
            // TODO: ui, join main room fail
        }
    }
    
    func checkDeviceState() {
        let userId = contextPool.user.getLocalUserInfo().userUuid
        
        guard contextPool.media.openLocalDevice(systemDevice: .frontCamera) == nil else {
            contentView.updateEnterable(false)
            return
        }
        
        let renderConfig = AgoraEduContextRenderConfig()
        renderConfig.mode = .hidden
        let streamId = "0"
        
        let error = contextPool.media.startRenderVideo(view: contentView.renderView,
                                                       renderConfig: renderConfig,
                                                       streamUuid: streamId)
        
        guard error == nil else {
            contentView.updateEnterable(false)
            return
        }
        contentView.updateEnterable(true)
    }
}


// MARK: - private
private extension FcrProctorDeviceTestComponent {
    func updateRoomInfo() {
        var state = ""
        let roomInfo = contextPool.room.getRoomInfo()
        let classInfo = contextPool.room.getClassInfo()
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
        contentView.stateLabel.text = finalState
    }
}
