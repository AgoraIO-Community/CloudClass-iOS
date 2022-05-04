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
    
    public weak var roomDelegate: AgoraClassRoomManagement?
    
    private var contentView: UIView!
    
    private var cameraLabel: UILabel!
    
    private var cameraSwitch: UISwitch!
    
    private var directionLabel: UILabel!
    
    private var frontCamButton: UIButton!
    
    private var backCamButton: UIButton!
    
    private var sepLine: UIView!
    
    private var micLabel: UILabel!
    
    private var micSwitch: UISwitch!
    
    private var audioLabel: UILabel!
    
    private var audioSwitch: UISwitch!
        
    private var exitButton: UIButton!
    
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
        
        createViews()
        createConstraint()
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

// MARK: - Creations
private extension AgoraSettingUIController {
    func createViews() {
        let group = AgoraColorGroup()
        let switchTintColor = group.setting_switch_tint_color
        let exitColor = group.setting_exit_button_color
        
        group.borderSet(layer: view.layer)
        
        contentView = UIView()
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 10.0
        contentView.clipsToBounds = true
        view.addSubview(contentView)
        
        cameraLabel = UILabel(frame: .zero)
        cameraLabel.text = "fcr_media_camera".agedu_localized()
        cameraLabel.font = UIFont.systemFont(ofSize: 13)
        cameraLabel.textColor = UIColor(hex: 0x191919)
        contentView.addSubview(cameraLabel)
        
        cameraSwitch = UISwitch()
        cameraSwitch.onTintColor = switchTintColor
        cameraSwitch.transform = CGAffineTransform(scaleX: 0.75,
                                                   y: 0.75)
        cameraSwitch.addTarget(self,
                               action: #selector(onClickCameraSwitch(_:)),
                               for: .touchUpInside)
        contentView.addSubview(cameraSwitch)
        
        directionLabel = UILabel(frame: .zero)
        directionLabel.text = "fcr_media_camera_direction".agedu_localized()
        directionLabel.font = UIFont.systemFont(ofSize: 13)
        directionLabel.textColor = UIColor(hex: 0x677386)
        contentView.addSubview(directionLabel)
        
        frontCamButton = UIButton(type: .custom)
        frontCamButton.isSelected = true
        frontCamButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        frontCamButton.setTitleColor(.white,
                                     for: .selected)
        frontCamButton.setTitleColor(UIColor(hex: 0xB5B5C9),
                                     for: .normal)
        frontCamButton.setTitle("fcr_media_camera_direction_front".agedu_localized(),
                                for: .normal)
        frontCamButton.setBackgroundImage(UIImage(color: UIColor(hex: 0xF4F4F8) ?? .white,
                                                  size: CGSize(width: 1,
                                                               height: 1)),
                                          for: .normal)
        frontCamButton.setBackgroundImage(UIImage(color: UIColor(hex: 0x7B88A0) ?? .white,
                                                  size: CGSize(width: 1,
                                                               height: 1)),
                                          for: .selected)
        frontCamButton.addTarget(self,
                                 action: #selector(onClickFrontCamera(_:)),
                                 for: .touchUpInside)
        frontCamButton.layer.cornerRadius = 4
        frontCamButton.clipsToBounds = true
        contentView.addSubview(frontCamButton)
        
        backCamButton = UIButton(type: .custom)
        backCamButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        backCamButton.setTitleColor(.white,
                                    for: .selected)
        backCamButton.setTitleColor(UIColor(hex: 0xB5B5C9),
                                    for: .normal)
        backCamButton.setBackgroundImage(UIImage(color: UIColor(hex: 0xF4F4F8) ?? .white,
                                                 size: CGSize(width: 1,
                                                              height: 1)),
                                         for: .normal)
        backCamButton.setBackgroundImage(UIImage(color: UIColor(hex: 0x7B88A0) ?? .white,
                                                 size: CGSize(width: 1,
                                                              height: 1)),
                                         for: .selected)
        backCamButton.setTitle("fcr_media_camera_direction_back".agedu_localized(),
                               for: .normal)
        backCamButton.addTarget(self,
                                action: #selector(onClickBackCamera(_:)),
                                for: .touchUpInside)
        backCamButton.layer.cornerRadius = 4
        backCamButton.clipsToBounds = true
        contentView.addSubview(backCamButton)
        
        sepLine = UIView(frame: .zero)
        sepLine.backgroundColor = UIColor(hex: 0xECECF1)
        contentView.addSubview(sepLine)
        
        micLabel = UILabel(frame: .zero)
        micLabel.text = "fcr_media_mic".agedu_localized()
        micLabel.font = UIFont.systemFont(ofSize: 13)
        micLabel.textColor = UIColor(hex: 0x191919)
        contentView.addSubview(micLabel)
        
        micSwitch = UISwitch()
        micSwitch.onTintColor = switchTintColor
        micSwitch.transform = CGAffineTransform(scaleX: 0.75,
                                                y: 0.75)
        micSwitch.addTarget(self,
                            action: #selector(onClickMicSwitch(_:)),
                            for: .touchUpInside)
        contentView.addSubview(micSwitch)
        
        audioLabel = UILabel(frame: .zero)
        audioLabel.text = "fcr_media_speaker".agedu_localized()
        audioLabel.font = UIFont.systemFont(ofSize: 13)
        audioLabel.textColor = UIColor(hex: 0x191919)
        contentView.addSubview(audioLabel)
        
        audioSwitch = UISwitch()
        audioSwitch.onTintColor = switchTintColor
        audioSwitch.transform = CGAffineTransform(scaleX: 0.75,
                                                  y: 0.75)
        audioSwitch.addTarget(self,
                              action: #selector(onClickAudioSwitch(_:)),
                              for: .touchUpInside)
        contentView.addSubview(audioSwitch)
        
        exitButton = UIButton(type: .system)
        exitButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        exitButton.setTitleColor(.white,
                                 for: .normal)
        exitButton.setTitle("fcr_room_leave_room".agedu_localized(),
                            for: .normal)
        exitButton.setBackgroundImage(
            UIImage(color: exitColor,
                    size: CGSize(width: 1, height: 1)),
            for: .normal)
        exitButton.addTarget(self,
                             action: #selector(onClickExit(_:)),
                             for: .touchUpInside)
        exitButton.layer.cornerRadius = 6
        exitButton.clipsToBounds = true
        contentView.addSubview(exitButton)
    }
    
    func createConstraint() {
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
}
