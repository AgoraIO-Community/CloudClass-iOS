//
//  PaintingSettingViewController.swift
//  AgoraEduUI
//
//  Created by HeZhengQing on 2021/9/25.
//

import AgoraEduContext
import SwifterSwift
import UIKit

class AgoraSettingUIController: UIViewController {
    /** SDK环境*/
    private var contextPool: AgoraEduContextPool
    
    private var subRoom: AgoraEduSubRoomContext?
    
    public let suggestSize = CGSize(width: 201,
                                    height: 220)
    
    private weak var roomDelegate: AgoraClassRoomManagement?
    
    // views
    private lazy var contentView = UIView()
    
    private lazy var cameraLabel = UILabel(frame: .zero)
    
    private lazy var cameraSwitch = UISwitch()
    
    private lazy var directionLabel = UILabel(frame: .zero)
    
    private lazy var frontCamButton = UIButton(type: .custom)
    
    private lazy var backCamButton = UIButton(type: .custom)
    
    private lazy var sepLine = UIView(frame: .zero)
    
    private lazy var micLabel = UILabel(frame: .zero)
    
    private lazy var micSwitch = UISwitch()
    
    private lazy var audioLabel = UILabel(frame: .zero)
    
    private lazy var audioSwitch = UISwitch()
        
    private lazy var exitButton = UIButton(type: .system)
    
    private var isCamerOn: Bool = false {
        didSet {
            guard isCamerOn != oldValue else {
                return
            }
            cameraSwitch.isOn = isCamerOn
            frontCamButton.isEnabled = isCamerOn
            backCamButton.isEnabled = isCamerOn
        }
    }
    
    init(context: AgoraEduContextPool,
         subRoom: AgoraEduSubRoomContext? = nil,
         roomDelegate: AgoraClassRoomManagement? = nil) {
        self.contextPool = context
        self.subRoom = subRoom
        self.roomDelegate = roomDelegate
        
        super.init(nibName: nil,
                   bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("\(#function): \(self.classForCoder)")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initViews()
        initViewFrame()
        updateViewProperties()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setup()
        contextPool.media.registerMediaEventHandler(self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        contextPool.media.unregisterMediaEventHandler(self)
    }
}

@objc extension AgoraSettingUIController: AgoraUIActivity, AgoraUIContentContainer {
    // AgoraUIActivity
    func viewWillActive() {
        
    }
    
    func viewWillInactive() {
        
    }
    
    //AgoraUIContentContainer
    func initViews() {
        view.addSubview(contentView)
        
        cameraLabel.text = "fcr_media_camera".agedu_localized()
        contentView.addSubview(cameraLabel)
        
        cameraSwitch.transform = CGAffineTransform(scaleX: 0.75,
                                                   y: 0.75)
        cameraSwitch.addTarget(self,
                               action: #selector(onClickCameraSwitch(_:)),
                               for: .touchUpInside)
        contentView.addSubview(cameraSwitch)
        
        directionLabel.text = "fcr_media_camera_direction".agedu_localized()
        contentView.addSubview(directionLabel)
        
        frontCamButton.isSelected = true
        frontCamButton.setTitle("fcr_media_camera_direction_front".agedu_localized(),
                                for: .normal)

        frontCamButton.addTarget(self,
                                 action: #selector(onClickFrontCamera(_:)),
                                 for: .touchUpInside)
        contentView.addSubview(frontCamButton)
        
        backCamButton.setTitle("fcr_media_camera_direction_back".agedu_localized(),
                               for: .normal)
        backCamButton.addTarget(self,
                                action: #selector(onClickBackCamera(_:)),
                                for: .touchUpInside)
        contentView.addSubview(backCamButton)
        
        contentView.addSubview(sepLine)
        
        micLabel.text = "fcr_media_mic".agedu_localized()

        contentView.addSubview(micLabel)
        
        micSwitch.transform = CGAffineTransform(scaleX: 0.75,
                                                y: 0.75)
        micSwitch.addTarget(self,
                            action: #selector(onClickMicSwitch(_:)),
                            for: .touchUpInside)
        contentView.addSubview(micSwitch)
        
        audioLabel.text = "fcr_media_speaker".agedu_localized()
        contentView.addSubview(audioLabel)
        
        audioSwitch.transform = CGAffineTransform(scaleX: 0.75,
                                                  y: 0.75)
        audioSwitch.addTarget(self,
                              action: #selector(onClickAudioSwitch(_:)),
                              for: .touchUpInside)
        contentView.addSubview(audioSwitch)

        exitButton.setTitle("fcr_room_leave_room".agedu_localized(),
                            for: .normal)
        exitButton.addTarget(self,
                             action: #selector(onClickExit(_:)),
                             for: .touchUpInside)
        contentView.addSubview(exitButton)
    }
    
    func initViewFrame() {
        contentView.mas_makeConstraints { make in
            make?.width.equalTo()(201)
            make?.height.equalTo()(220)
            make?.left.right().top().bottom().equalTo()(0)
        }
        cameraLabel.mas_makeConstraints { make in
            make?.top.left().equalTo()(16)
        }
        cameraSwitch.mas_makeConstraints { make in
            make?.right.equalTo()(-16)
            make?.width.equalTo()(40)
            make?.height.equalTo()(20)
            make?.centerY.equalTo()(cameraLabel)?.offset()(-5)
        }
        directionLabel.mas_makeConstraints { make in
            make?.left.equalTo()(cameraLabel)
            make?.top.equalTo()(cameraLabel.mas_bottom)?.offset()(20)
        }
        backCamButton.mas_makeConstraints { make in
            make?.width.equalTo()(40)
            make?.height.equalTo()(22)
            make?.right.equalTo()(cameraSwitch)
            make?.centerY.equalTo()(directionLabel)
        }
        frontCamButton.mas_makeConstraints { make in
            make?.width.equalTo()(40)
            make?.height.equalTo()(22)
            make?.right.equalTo()(backCamButton.mas_left)?.offset()(-5)
            make?.centerY.equalTo()(backCamButton)
        }
        sepLine.mas_makeConstraints { make in
            make?.top.equalTo()(directionLabel.mas_bottom)?.offset()(17)
            make?.left.equalTo()(16)
            make?.right.equalTo()(-16)
            make?.height.equalTo()(1)
        }
        micLabel.mas_makeConstraints { make in
            make?.left.equalTo()(cameraLabel)
            make?.top.equalTo()(sepLine.mas_bottom)?.offset()(16)
        }
        micSwitch.mas_makeConstraints { make in
            make?.right.equalTo()(-16)
            make?.width.equalTo()(40)
            make?.height.equalTo()(20)
            make?.centerY.equalTo()(micLabel)?.offset()(-5)
        }
        audioLabel.mas_makeConstraints { make in
            make?.left.equalTo()(cameraLabel)
            make?.top.equalTo()(micLabel.mas_bottom)?.offset()(18)
        }
        audioSwitch.mas_makeConstraints { make in
            make?.right.equalTo()(-16)
            make?.width.equalTo()(40)
            make?.height.equalTo()(20)
            make?.centerY.equalTo()(audioLabel)?.offset()(-5)
        }
        exitButton.mas_makeConstraints { make in
            make?.left.equalTo()(15)
            make?.right.equalTo()(-15)
            make?.height.equalTo()(30)
            make?.bottom.equalTo()(-16)
        }
        
    }
    
    func updateViewProperties() {
        let ui = AgoraUIGroup()
        
        ui.color.borderSet(layer: view.layer)
        contentView.backgroundColor = ui.color.setting_bg_color
        contentView.layer.cornerRadius = ui.frame.setting_corner_radius
        contentView.clipsToBounds = true
        
        exitButton.setBackgroundImage(
            UIImage(color: ui.color.setting_exit_button_color,
                    size: CGSize(width: 1,
                                 height: 1)),
            for: .normal)
        
        let switchTintColor = ui.color.setting_switch_tint_color
        cameraSwitch.onTintColor = switchTintColor
        micSwitch.onTintColor = switchTintColor
        audioSwitch.onTintColor = switchTintColor
        
        sepLine.backgroundColor = ui.color.setting_sep_color
        
        directionLabel.textColor = ui.color.setting_direction_label_color
        
        let labelFont = ui.frame.setting_camera_font
        cameraLabel.font = labelFont
        directionLabel.font = labelFont
        frontCamButton.titleLabel?.font = labelFont
        backCamButton.titleLabel?.font = labelFont
        micLabel.font = labelFont
        audioLabel.font = labelFont
        exitButton.titleLabel?.font = labelFont
        
        for button in [frontCamButton, backCamButton] {
            button.setTitleColor(ui.color.setting_button_selected_title_color,
                                 for: .selected)
            button.setTitleColor(ui.color.setting_button_normal_title_color,
                                 for: .normal)
            button.setBackgroundImage(UIImage(color: ui.color.setting_camera_button_normal_bg_color,
                                              size: CGSize(width: 1,
                                                           height: 1)),
                                      for: .normal)
            button.setBackgroundImage(UIImage(color: ui.color.setting_camera_button_selected_bg_color,
                                              size: CGSize(width: 1,
                                                           height: 1)),
                                      for: .selected)
            
            button.layer.cornerRadius = ui.frame.setting_camera_button_corner_radius
            button.clipsToBounds = true
        }
        
        exitButton.setTitleColor(ui.color.setting_button_normal_title_color,
                                 for: .normal)
        exitButton.layer.cornerRadius = ui.frame.setting_exit_corner_radius
        exitButton.clipsToBounds = true
        
        let labelColor = ui.color.setting_label_color
        cameraLabel.textColor = labelColor
        micLabel.textColor = labelColor
        audioLabel.textColor = labelColor
    }
}
// MARK: - Private
private extension AgoraSettingUIController {
    func setup() {
        updateCameraState()
        if let d = contextPool.media.getLocalDevices(deviceType: .mic).first {
            contextPool.media.getLocalDeviceState(device: d) { state in
                micSwitch.isOn = (state == .open)
            } failure: { error in
            }
        }
        if let d = contextPool.media.getLocalDevices(deviceType: .speaker).first {
            contextPool.media.getLocalDeviceState(device: d) { state in
                audioSwitch.isOn = (state == .open)
            } failure: { error in
            }
        }
    }
    
    func updateCameraState() {
        var isCamerStateOpen = false
        let cameras = contextPool.media.getLocalDevices(deviceType: .camera)
        for camera in cameras {
            if camera.deviceName.contains(kFrontCameraStr) {
                contextPool.media.getLocalDeviceState(device: camera) { state in
                    frontCamButton.isSelected = (state == .open)
                    backCamButton.isSelected = !(state == .open)
                    if state == .open {
                        isCamerStateOpen = true
                    }
                } failure: { error in
                }
            } else if camera.deviceName.contains(kBackCameraStr) {
                contextPool.media.getLocalDeviceState(device: camera) { state in
                    backCamButton.isSelected = (state == .open)
                    frontCamButton.isSelected = !(state == .open)
                    if state == .open {
                        isCamerStateOpen = true
                    }
                } failure: { error in
                }
            }
        }
        self.isCamerOn = isCamerStateOpen
    }
}

extension AgoraSettingUIController: AgoraEduMediaHandler {
    func onLocalDeviceStateUpdated(device: AgoraEduContextDeviceInfo,
                                   state: AgoraEduContextDeviceState) {
        if device.deviceType == .camera {
            updateCameraState()
        } else if device.deviceType == .mic {
            micSwitch.isOn = (state == .open)
        } else if device.deviceType == .speaker {
            audioSwitch.isOn = (state == .open)
        }
    }
}

// MARK: - Actions
private extension AgoraSettingUIController {
    @objc func onClickCameraSwitch(_ sender: UISwitch) {
        guard contextPool.user.getLocalUserInfo().userRole != .observer else {
            return
        }
        self.isCamerOn = sender.isOn
        let devices = contextPool.media.getLocalDevices(deviceType: .camera)
        var camera: AgoraEduContextDeviceInfo?
        if frontCamButton.isSelected {
            camera = devices.first(where: {$0.deviceName.contains(kFrontCameraStr)})
        } else if backCamButton.isSelected {
            camera = devices.first(where: {$0.deviceName.contains(kBackCameraStr)})
        }
        if let c = camera {
            if sender.isOn {
                self.contextPool.media.openLocalDevice(device: c)
            } else {
                self.contextPool.media.closeLocalDevice(device: c)
            }
        }
    }
    
    @objc func onClickMicSwitch(_ sender: UISwitch) {
        guard contextPool.user.getLocalUserInfo().userRole != .observer,
              let d = self.contextPool.media.getLocalDevices(deviceType: .mic).first else {
            return
        }
        if sender.isOn {
            self.contextPool.media.openLocalDevice(device: d)
        } else {
            self.contextPool.media.closeLocalDevice(device: d)
        }
    }
    
    @objc func onClickAudioSwitch(_ sender: UISwitch) {
        guard let d = self.contextPool.media.getLocalDevices(deviceType: .speaker).first else {
            return
        }
        if sender.isOn {
            self.contextPool.media.openLocalDevice(device: d)
        } else {
            self.contextPool.media.closeLocalDevice(device: d)
        }
    }
    
    @objc func onClickExit(_ sender: UIButton) {
        if let sub = subRoom {
            AgoraAlertModel()
                .setTitle("fcr_group_back_exit".agedu_localized())
                .setStyle(.Choice)
                .addAction(action: AgoraAlertAction(title: "fcr_group_back_to_main_room".agedu_localized(), action: {
                    self.roomDelegate?.exitClassRoom(reason: .normal,
                                                     roomType: .sub)
                }))
                .addAction(action: AgoraAlertAction(title: "fcr_group_exit_room".agedu_localized(), action: {
                    self.roomDelegate?.exitClassRoom(reason: .normal,
                                                     roomType: .main)
                    
                }))
                .show(in: self)
        } else {
            AgoraAlertModel()
                .setTitle("fcr_room_class_leave_class_title".agedu_localized())
                .setMessage("fcr_room_exit_warning".agedu_localized())
                .addAction(action: AgoraAlertAction(title: "fcr_room_class_leave_cancel".agedu_localized(), action:nil))
                .addAction(action: AgoraAlertAction(title: "fcr_room_class_leave_sure".agedu_localized(), action: {
                    self.roomDelegate?.exitClassRoom(reason: .normal,
                                                     roomType: .main)
                }))
                .show(in: self)
        }
    }
    
    @objc func onClickFrontCamera(_ sender: UIButton) {
        guard sender.isSelected == false else {
            return
        }
        sender.isSelected = true
        backCamButton.isSelected = false
        let devices = self.contextPool.media.getLocalDevices(deviceType: .camera)
        if let camera = devices.first(where: {$0.deviceName.contains(kFrontCameraStr)}),
           contextPool.user.getLocalUserInfo().userRole != .observer {
            contextPool.media.openLocalDevice(device: camera)
        }
    }
    
    @objc func onClickBackCamera(_ sender: UIButton) {
        guard sender.isSelected == false else {
            return
        }
        sender.isSelected = true
        frontCamButton.isSelected = false
        let devices = self.contextPool.media.getLocalDevices(deviceType: .camera)
        if let camera = devices.first(where: {$0.deviceName.contains(kBackCameraStr)}),
           contextPool.user.getLocalUserInfo().userRole != .observer {
            contextPool.media.openLocalDevice(device: camera)
        }
    }
}
