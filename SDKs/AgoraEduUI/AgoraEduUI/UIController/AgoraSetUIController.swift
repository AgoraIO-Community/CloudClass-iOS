//
//  AgoraSetUIController.swift
//  AgoraEduUI
//
//  Created by SRS on 2021/5/17.
//

import AgoraUIEduBaseViews
import AgoraUIBaseViews
import AgoraEduContext

class AgoraSetUIController: NSObject, AgoraUIController {
    private var toastShowedStates: [String] = []
    // Contexts
    private var roomContext: AgoraEduRoomContext? {
        return contextProvider?.controllerNeedRoomContext()
    }

    private let setView = AgoraUISettingView(frame: .zero)

    private weak var contextProvider: AgoraControllerContextProvider?
    
    private weak var deviceContext: AgoraEduDeviceContext? {
        return contextProvider?.controllerNeedDeviceContext()
    }
    
    private weak var mediaContext: AgoraEduMediaContext? {
        return contextProvider?.controllerNeedMediaContext()
    }
    
    var containerView = AgoraUIControllerContainer(frame: .zero)
    var localUser: AgoraEduContextUserDetailInfo?
    
    public init(contextProvider: AgoraControllerContextProvider) {
        self.contextProvider = contextProvider
        
        super.init()
        initViews()
        initLayout()
        observeUI()
    }
}

private extension AgoraSetUIController {
    func initViews() {
        containerView.backgroundColor = .clear
        containerView.addSubview(setView)
    }
    
    func initLayout() {
        setView.agora_x = 0
        setView.agora_y = 0
        setView.agora_right = 0
        setView.agora_bottom = 0
    }

    func observeUI() {
        setView.leaveClassBlock = { [unowned self] in
            self.existClassAlert()
            self.containerView.removeFromSuperview()
        }
        
        setView.cameraStateBlock = { [unowned self] (open: Bool) in
            guard let local = self.localUser else {
                return
            }
            
            self.deviceContext?.setCameraDeviceEnable(enable: open)
        }
        
        setView.micStateBlock = { [unowned self] (open: Bool) in
            guard let local = self.localUser else {
                return
            }
            
            self.deviceContext?.setMicDeviceEnable(enable: open)
        }
        
        setView.speakerStateBlock = { [unowned self] (open: Bool) in
            self.deviceContext?.setSpeakerEnable(enable: open)
        }
        
        setView.switchCameraBlock = { [unowned self] in
            self.deviceContext?.switchCameraFacing()
        }
    }
}

extension AgoraSetUIController: AgoraEduDeviceHandler {
    @objc func onCameraDeviceEnableChanged(enabled: Bool) {
        setView.updateCameraState(enabled)
    }
    
    @objc func onCameraFacingChanged(facing: EduContextCameraFacing) {
        let isFront = (facing == .front ? true : false)
        setView.updateCameraFacing(isFront)
    }
    
    @objc func onMicDeviceEnabledChanged(enabled: Bool) {
        setView.updateMicroState(enabled)
    }
    
    @objc func onSpeakerEnabledChanged(enabled: Bool) {
        setView.updateSpeakerState(enabled)
    }
    
    @objc func onDeviceTips(message: String) {
        AgoraUtils.showToast(message: message)
    }
}

extension AgoraSetUIController: AgoraEduUserHandler {
    func onUpdateUserList(_ list: [AgoraEduContextUserDetailInfo]) {
        for user in list where user.isSelf == true {
            localUser = user
        }
    }
}

private extension AgoraSetUIController {
    func existClassAlert() {
        let leftButtonLabel = AgoraAlertLabelModel()
        leftButtonLabel.text = AgoraKitLocalizedString("CancelText")
        
        let leftButton = AgoraAlertButtonModel()
        leftButton.titleLabel = leftButtonLabel
        
        let rightButtonLabel = AgoraAlertLabelModel()
        rightButtonLabel.text = AgoraKitLocalizedString("SureText")
        
        let rightButton = AgoraAlertButtonModel()
        rightButton.titleLabel = rightButtonLabel
        rightButton.tapActionBlock = { [unowned self] (index) -> Void in
            self.roomContext?.leaveRoom()
        }
        
        AgoraUtils.showAlert(imageModel: nil,
                             title: AgoraKitLocalizedString("LeaveClassTitleText"),
                             message: AgoraKitLocalizedString("LeaveClassText"),
                             btnModels: [leftButton, rightButton])
    }
}
