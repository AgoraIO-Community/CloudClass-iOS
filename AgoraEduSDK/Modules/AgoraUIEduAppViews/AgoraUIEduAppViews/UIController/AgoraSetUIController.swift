//
//  AgoraSetUIController.swift
//  AgoraUIEduAppViews
//
//  Created by SRS on 2021/5/17.
//

import Foundation
import AgoraUIEduBaseViews
import AgoraUIBaseViews
import AgoraEduContext

protocol AgoraSetUIControllerDelegate: NSObjectProtocol {
    func setUIController(_ controller: AgoraSetUIController,
                         didStateChanged close: Bool)
}

class AgoraSetUIController: NSObject, AgoraUIController {
    // Contexts
    private var roomContext: AgoraEduRoomContext? {
        return contextProvider?.controllerNeedRoomContext()
    }

    private let setView = AgoraUISettingView(frame: .zero)

    private weak var contextProvider: AgoraControllerContextProvider?
    private weak var eventRegister: AgoraControllerEventRegister?
    private weak var delegate: AgoraSetUIControllerDelegate?
    
    var containerView = AgoraUIControllerContainer(frame: .zero)
    
    public init(contextProvider: AgoraControllerContextProvider,
                eventRegister: AgoraControllerEventRegister,
                delegate: AgoraSetUIControllerDelegate) {
        self.contextProvider = contextProvider
        self.eventRegister = eventRegister
        self.delegate = delegate
        
        super.init()
        initViews()
        initLayout()
        observeEvent(register: eventRegister)
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
    
    func observeEvent(register: AgoraControllerEventRegister) {
        register.controllerRegisterDeviceEvent(self)
    }
    
    func observeUI() {
        setView.leaveClassBlock = { [unowned self] in
            self.existClassAlert()
            self.containerView.isHidden = true
        }
        setView.cameraStateBlock = { [unowned self] (open: Bool) in
            self.contextProvider?.controllerNeedDeviceContext().setCameraDeviceEnable(enable: open)
        }
        setView.micStateBlock = { [unowned self] (open: Bool) in
            self.contextProvider?.controllerNeedDeviceContext().setMicDeviceEnable(enable: open)
        }
        setView.speakerStateBlock = { [unowned self] (open: Bool) in
            self.contextProvider?.controllerNeedDeviceContext().setSpeakerEnable(enable: open)
        }
        setView.switchCameraBlock = { [unowned self] in
            self.contextProvider?.controllerNeedDeviceContext().switchCameraFacing()
        }
    }
}

extension AgoraSetUIController: AgoraEduDeviceHandler {
    @objc func onCameraDeviceEnableChanged(enabled: Bool) {
        self.setView.updateCameraState(enabled)
    }
    @objc func onCameraFacingChanged(facing: EduContextCameraFacing) {
        self.setView.updateCameraFacing(facing)
    }
    @objc func onMicDeviceEnabledChanged(enabled: Bool) {
        self.setView.updateMicroState(enabled)
    }
    @objc func onSpeakerEnabledChanged(enabled: Bool) {
        self.setView.updateSpeakerState(enabled)
    }
    @objc func onDeviceTips(message: String) {
        AgoraUtils.showToast(message: message)
    }
}

private extension AgoraSetUIController {
    func existClassAlert() {
        let leftButtonLabel = AgoraAlertLabelModel()
        leftButtonLabel.text = AgoraKitLocalizedString("CancelText")
        
        let leftButton = AgoraAlertButtonModel()
        leftButton.titleLabel = leftButtonLabel
        leftButton.tapActionBlock = { [unowned self] (index) -> Void in
            self.delegate?.setUIController(self,
                                           didStateChanged: true)
        }
        
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
