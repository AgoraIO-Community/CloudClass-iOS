//
//  PaintingSettingViewController.swift
//  AgoraEduUI
//
//  Created by HeZhengQing on 2021/9/25.
//

import AgoraUIBaseViews
import AgoraEduCore
import AgoraWidget
import UIKit

protocol FcrSettingUIComponentDelegate: NSObjectProtocol {
    func onShowShareView(_ view: UIView)
}

class FcrSettingUIComponent: FcrUIComponent {
    /**context*/
    private let mediaController: AgoraEduMediaContext
    private let widgetController: AgoraEduWidgetContext
    private let isSubRoom: Bool
    private weak var exitDelegate: FcrUISceneExit?
    private weak var delegate: FcrSettingUIComponentDelegate?
    
    // Views
    private lazy var contentView = FcrSettingsView()
    
    private lazy var shareLinkWidget: AgoraBaseWidget? = {
        guard let config = widgetController.getWidgetConfig(kShareLinkWidgetId) else {
            return nil
        }
        return widgetController.create(config)
    }()
    
    public let suggestSize = CGSize(width: 201,
                                    height: 285)
        
    init(mediaController: AgoraEduMediaContext,
         widgetController: AgoraEduWidgetContext,
         isSubRoom: Bool = false,
         delegate: FcrSettingUIComponentDelegate,
         exitDelegate: FcrUISceneExit? = nil) {
        self.mediaController = mediaController
        self.widgetController = widgetController
        self.isSubRoom = isSubRoom
        self.exitDelegate = exitDelegate
        self.delegate = delegate
        
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
    func onClickShare() {
        guard let view = shareLinkWidget?.view else {
            return
        }
        delegate?.onShowShareView(view)
    }
    
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
        if isSubRoom {
            let title = "fcr_group_back_exit".edu_ui_localized()
            
            let backToMainRoomTitle = "fcr_group_back_to_main_room".edu_ui_localized()
            let exitRoomTitle = "fcr_group_exit_room".edu_ui_localized()
            
            let cancelTitle = "fcr_room_class_leave_cancel".edu_ui_localized()
            let cancelAction = AgoraAlertAction(title: cancelTitle)
            
            let leaveTitle = "fcr_room_class_leave_sure".edu_ui_localized()
            let leaveAction = AgoraAlertAction(title: leaveTitle) { [weak self] optionIndex in
                switch optionIndex {
                case 0:
                    self?.exitDelegate?.exitScene(reason: .normal,
                                                  type: .sub)
                default:
                    self?.exitDelegate?.exitScene(reason: .normal,
                                                  type: .main)
                }
            }
            
            showAlert(title: title,
                      contentList: [backToMainRoomTitle, exitRoomTitle],
                      actions: [cancelAction, leaveAction])
        } else {
            let title = "fcr_room_class_leave_class_title".edu_ui_localized()
            let message = "fcr_room_exit_warning".edu_ui_localized()
            
            let cancelTitle = "fcr_room_class_leave_cancel".edu_ui_localized()
            let cancelAction = AgoraAlertAction(title: cancelTitle)
            
            let leaveTitle = "fcr_room_class_leave_sure".edu_ui_localized()
            let leaveAction = AgoraAlertAction(title: leaveTitle) { [weak self] _ in
                self?.exitDelegate?.exitScene(reason: .normal,
                                              type: .main)
            }
            
            showAlert(title: title,
                      contentList: [message],
                      actions: [cancelAction, leaveAction])
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
