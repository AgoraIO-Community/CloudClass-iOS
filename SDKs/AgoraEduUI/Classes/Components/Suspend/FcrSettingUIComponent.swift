//
//  PaintingSettingViewController.swift
//  AgoraEduUI
//
//  Created by HeZhengQing on 2021/9/25.
//

import AgoraUIBaseViews
import AgoraEduCore
import UIKit

class FcrSettingUIComponent: FcrUIComponent {
    /**context*/
    private let mediaController: AgoraEduMediaContext
    private let subRoom: AgoraEduSubRoomContext?
    private weak var exitDelegate: FcrUISceneExit?
    
    // Views
    private lazy var contentView = FcrSettingsView()
    
    public let suggestSize = CGSize(width: 201,
                                    height: 220)
            
    init(mediaController: AgoraEduMediaContext,
         subRoom: AgoraEduSubRoomContext? = nil,
         exitDelegate: FcrUISceneExit? = nil) {
        self.mediaController = mediaController
        self.subRoom = subRoom
        self.exitDelegate = exitDelegate
        
        super.init(nibName: nil,
                   bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
        initViewFrame()
        updateViewProperties()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setContentViewState()
    }
}

@objc extension FcrSettingUIComponent: AgoraUIActivity, AgoraUIContentContainer {
    // AgoraUIActivity
    func viewWillActive() {
        setContentViewState()
    }
    
    func viewWillInactive() {
        
    }
    
    // AgoraUIContentContainer
    func initViews() {
        view.addSubview(contentView)
        
        contentView.delegate = self
        
        contentView.micSwitch.addTarget(self,
                                        action: #selector(onClickMicSwitch(_:)),
                                        for: .touchUpInside)
        
        contentView.speakerSwitch.addTarget(self,
                                            action: #selector(onClickSpeakerSwitch(_:)),
                                            for: .touchUpInside)
        
        contentView.exitButton.addTarget(self,
                                         action: #selector(onClickExitButton(_:)),
                                         for: .touchUpInside)
    }
    
    func initViewFrame() {
        contentView.mas_makeConstraints { make in
            make?.width.equalTo()(201)
            make?.height.equalTo()(220)
            make?.left.right().top().bottom().equalTo()(0)
        }
    }
    
    func updateViewProperties() {
        let config = UIConfig.setting
        
        view.agora_enable = config.enable
        view.agora_visible = config.visible
        
        view.layer.shadowColor = config.shadow.color
        view.layer.shadowOffset = config.shadow.offset
        view.layer.shadowOpacity = config.shadow.opacity
        view.layer.shadowRadius = config.shadow.radius
        
        contentView.backgroundColor = config.backgroundColor
        contentView.layer.cornerRadius = config.cornerRadius
        contentView.clipsToBounds = true
    }
}

// MARK: - FcrSettingsViewDelegate
extension FcrSettingUIComponent: FcrSettingsViewDelegate {
    func onCameraSwitchIsOn(isOn: Bool) {
        switch isOn {
        case true:
            if contentView.getFrontCameraIsSelected() {
                mediaController.openLocalDevice(systemDevice: .frontCamera)
            } else {
                mediaController.openLocalDevice(systemDevice: .backCamera)
            }
        case false:
            if contentView.getFrontCameraIsSelected() {
                mediaController.closeLocalDevice(systemDevice: .frontCamera)
            } else {
                mediaController.closeLocalDevice(systemDevice: .backCamera)
            }
        }
    }
    
    func onCameraButtonIsSelected(isFront: Bool) {
        if isFront {
            mediaController.openLocalDevice(systemDevice: .frontCamera)
        } else {
            mediaController.openLocalDevice(systemDevice: .backCamera)
        }
    }
}

// MARK: - Actions
private extension FcrSettingUIComponent {
    @objc func onClickMicSwitch(_ sender: UISwitch) {
        if sender.isOn {
            mediaController.openLocalDevice(systemDevice: .mic)
        } else {
            mediaController.closeLocalDevice(systemDevice: .mic)
        }
    }
    
    @objc func onClickSpeakerSwitch(_ sender: UISwitch) {
        if sender.isOn {
            mediaController.openLocalDevice(systemDevice: .speaker)
        } else {
            mediaController.closeLocalDevice(systemDevice: .speaker)
        }
    }
    
    @objc func onClickExitButton(_ sender: UIButton) {
        if let sub = subRoom {
            let title = "fcr_group_back_exit".agedu_localized()
            
            let backToMainRoomTitle = "fcr_group_back_to_main_room".agedu_localized()
            let backToMainRoomAction = AgoraAlertAction(title: backToMainRoomTitle) { [weak self] in
                self?.exitDelegate?.exitScene(reason: .normal,
                                                  type: .sub)
            }
            
            let exitRoomTitle = "fcr_group_exit_room".agedu_localized()
            let exitRoomAction = AgoraAlertAction(title: exitRoomTitle) { [weak self] in
                self?.exitDelegate?.exitScene(reason: .normal,
                                                 type: .main)
            }
            
            AgoraAlertModel()
                .setTitle(title)
                .setStyle(.Choice)
                .addAction(action: backToMainRoomAction)
                .addAction(action: exitRoomAction)
                .show(in: self)
        } else {
            let title = "fcr_room_class_leave_class_title".agedu_localized()
            let message = "fcr_room_exit_warning".agedu_localized()
            
            let cancelTitle = "fcr_room_class_leave_cancel".agedu_localized()
            let cancelAction = AgoraAlertAction(title: cancelTitle)
            
            let leaveTitle = "fcr_room_class_leave_sure".agedu_localized()
            let leaveAction = AgoraAlertAction(title: leaveTitle) { [weak self] in
                self?.exitDelegate?.exitScene(reason: .normal,
                                                  type: .main)
            }
            
            AgoraAlertModel()
                .setTitle(title)
                .setMessage(message)
                .addAction(action: cancelAction)
                .addAction(action: leaveAction)
                .show(in: self)
        }
    }
}

// MARK: - Private
private extension FcrSettingUIComponent {
    func setContentViewState() {
        // Camera
        var frontCameraIsOpen = false
        var backCameraIsOpen = false
        
        let cameraList = mediaController.getLocalDevices(deviceType: .camera)
        
        for item in cameraList {
            mediaController.getLocalDeviceState(device: item) { [weak self] (state) in
                if item.deviceName.contains("front") {
                    frontCameraIsOpen = (state == .open)
                } else {
                    backCameraIsOpen = (state == .open)
                }
            } failure: { _ in
                
            }
        }
        
        if frontCameraIsOpen || backCameraIsOpen {
            contentView.setCamereSwitchIsOn(true)
            
            contentView.setCameraIsSelected(frontCameraIsOpen,
                                            isFront: true)
        } else {
            contentView.setCamereSwitchIsOn(false)
            
            contentView.setCameraIsSelected(true,
                                            isFront: true)
        }
        
        // Mic
        let micList = mediaController.getLocalDevices(deviceType: .mic)
        
        for item in micList {
            mediaController.getLocalDeviceState(device: item) { [weak self] (state) in
                self?.contentView.micSwitch.isOn = (state == .open)
            } failure: { _ in
                
            }
        }
        
        // Speaker
        let speakerList = mediaController.getLocalDevices(deviceType: .speaker)
        
        for item in speakerList {
            mediaController.getLocalDeviceState(device: item) { [weak self] (state) in
                self?.contentView.speakerSwitch.isOn = (state == .open)
            } failure: { _ in
                
            }
        }
    }
}
