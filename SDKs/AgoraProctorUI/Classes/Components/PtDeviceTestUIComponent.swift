//
//  PtDeviceTestUIComponent.swift
//  AgoraProctorUI
//
//  Created by LYY on 2022/9/6.
//

import AgoraUIBaseViews
import AgoraEduCore
import AVFoundation

@objc public protocol PtDeviceTestUIComponentDelegate: NSObjectProtocol {
    func onDeviceTestJoinExamSuccess()
    func onDeviceTestExit()
}

class PtDeviceTestUIComponent: PtUIComponent {
    /**view**/
    private lazy var contentView = PtDeviceTestView(frame: .zero)
    /**context**/
    private weak var delegate: PtDeviceTestUIComponentDelegate?
    private let contextPool: AgoraEduContextPool
    
    /**data**/
    private var currentFront: Bool = true
    
    @objc public init(contextPool: AgoraEduContextPool,
                      delegate: PtDeviceTestUIComponentDelegate?) {
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
        
        contextPool.room.registerRoomEventHandler(self)
        
        checkCameraState()
        setAvatarInfo()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationWillEnterForeground(_:)),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension PtDeviceTestUIComponent: AgoraEduRoomHandler {
    public func onJoinRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        delegate?.onDeviceTestJoinExamSuccess()
    }
}

// MARK: - AgoraUIContentContainer
extension PtDeviceTestUIComponent: AgoraUIContentContainer {
    public func initViews() {
        view.addSubview(contentView)
        
        contentView.exitButton.addTarget(self,
                                         action: #selector(onClickExitRoom),
                                         for: .touchUpInside)
        
        contentView.titleLabel.text = "pt_exam_prep_label_device_test".pt_localized()
        
        let greet = "pt_exam_prep_label_hello".pt_localized()
        let userName = contextPool.user.getLocalUserInfo().userName
        let finalGreet = greet.replacingOccurrences(of: String.pt_localized_replacing_x(),
                                                    with: userName)
        contentView.greetLabel.text = finalGreet
        
        contentView.switchCameraButton.addTarget(self,
                                                 action: #selector(onClickSwitchCamera),
                                                 for: .touchUpInside)
        
        contentView.enterButton.setTitle("pt_sub_room_button_join_exam".pt_localized(),
                                         for: .normal)
        contentView.enterButton.addTarget(self,
                                          action: #selector(onClickEnterRoom),
                                          for: .touchUpInside)
    }
    
    public func initViewFrame() {
        contentView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
    }
    
    public func updateViewProperties() {
        let config = UIConfig.deviceTest
        
        view.backgroundColor = config.backgroundColor
    }
}

// MARK: - private
private extension PtDeviceTestUIComponent {
    @objc func onClickExitRoom() {
        contextPool.room.unregisterRoomEventHandler(self)
        
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
        contextPool.room.joinRoom {
            AgoraLoading.hide()
        } failure: { error in
            AgoraLoading.hide()
            AgoraToast.toast(message: "fcr_room_tips_join_failed".pt_localized())
        }
    }
    
    func setAvatarInfo() {
        // avatar
        let userInfo = self.contextPool.user.getLocalUserInfo()
        guard let userIdPrefix = userInfo.userUuid.getUserIdPrefix() else {
            return
        }
        
        contentView.renderView.setUserName(userInfo.userName)
        let mainUserId = userIdPrefix.joinUserId(.main)
        if let props = contextPool.user.getUserProperties(userUuid: mainUserId),
           let avatarUrl = props["avatar"] as? String {
            contentView.renderView.setAvartarImage(avatarUrl)
        }
    }
    
    func applicationDidEnterForeground(notification: NSNotification) {
        checkCameraState()
    }
    
    func checkCameraState() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] auth in
            guard let `self` = self else {
                return
            }
            
            guard auth else {
                self.contentView.updateEnterable(false)
                return
            }
            let userId = self.contextPool.user.getLocalUserInfo().userUuid
            
            let renderConfig = AgoraEduContextRenderConfig()
            renderConfig.mode = .hidden
            let streamId = "0"
            
            if self.contextPool.media.openLocalDevice(systemDevice: .frontCamera) == nil,
               self.contextPool.media.startRenderVideo(view: self.contentView.renderView,
                                                       renderConfig: renderConfig,
                                                       streamUuid: streamId) == nil {
                self.contentView.updateEnterable(true)
            } else {
                self.contentView.updateEnterable(false)
            }
        }
    }
}

// MARK: - UIApplicationDelegate
extension PtDeviceTestUIComponent: UIApplicationDelegate {
    public func applicationWillEnterForeground(_ application: UIApplication) {
        checkCameraState()
    }
}
