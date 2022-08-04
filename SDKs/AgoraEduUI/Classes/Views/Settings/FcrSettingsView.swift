//
//  FcrSettingsView.swift
//  AgoraEduUI
//
//  Created by Cavan on 2022/6/23.
//

import AgoraUIBaseViews
import UIKit

protocol FcrSettingsViewDelegate: NSObjectProtocol {
    func onCameraButtonIsSelected(isFront: Bool)
    func onCameraSwitchIsOn(isOn: Bool)
}

class FcrSettingsView: UIView {
    // Camera
    private let cameraLabel = UILabel(frame: .zero)
    private let cameraDirectionLabel = UILabel(frame: .zero)
    
    private let frontCameraButton = UIButton(type: .custom)
    private let backCameraButton = UIButton(type: .custom)
    
    private let cameraSwitch = UISwitch()
    
    private let sepLine = UIView(frame: .zero)
    
    // Mic
    private let micLabel = UILabel(frame: .zero)
    let micSwitch = UISwitch()
    
    // Speaker
    private let speakerLabel = UILabel(frame: .zero)
    let speakerSwitch = UISwitch()
    
    // Exit
    let exitButton = UIButton(type: .system)
    
    weak var delegate: FcrSettingsViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
        initViewFrame()
        updateViewProperties()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setCameraIsSelected(_ isSelected: Bool,
                             isFront: Bool) {
        if isFront {
            frontCameraButton.isSelected = isSelected
            backCameraButton.isSelected = !isSelected
        } else {
            frontCameraButton.isSelected = !isSelected
            backCameraButton.isSelected = isSelected
        }
    }
    
    func getFrontCameraIsSelected() -> Bool {
        return frontCameraButton.isSelected
    }
    
    func setCamereSwitchIsOn(_ isOn: Bool) {
        cameraSwitch.isOn = isOn
        
        frontCameraButton.isEnabled = isOn
        backCameraButton.isEnabled = isOn
    }
}

extension FcrSettingsView: AgoraUIContentContainer {
    func initViews() {
        let config = UIConfig.setting
        // Camera
        addSubview(cameraLabel)
        addSubview(cameraSwitch)
        cameraLabel.agora_enable = config.camera.enable
        cameraLabel.agora_visible = config.camera.visible
        cameraSwitch.agora_enable = config.camera.enable
        cameraSwitch.agora_visible = config.camera.visible
        
        addSubview(cameraDirectionLabel)
        addSubview(frontCameraButton)
        addSubview(backCameraButton)
        cameraDirectionLabel.agora_enable = config.camera.direction.enable
        cameraDirectionLabel.agora_visible = config.camera.direction.visible
        frontCameraButton.agora_enable = config.camera.direction.enable
        frontCameraButton.agora_visible = config.camera.direction.visible
        backCameraButton.agora_enable = config.camera.direction.enable
        backCameraButton.agora_visible = config.camera.direction.visible
        
        frontCameraButton.isEnabled = cameraSwitch.isOn
        backCameraButton.isEnabled = cameraSwitch.isOn
        
        cameraSwitch.addTarget(self,
                               action: #selector(onCameraSwitchChanged(_:)),
                               for: .touchUpInside)
        
        frontCameraButton.addTarget(self,
                                    action: #selector(onFrontCameraPressed(_:)),
                                    for: .touchUpInside)
        
        backCameraButton.addTarget(self,
                                   action: #selector(onBackCameraPressed(_:)),
                                   for: .touchUpInside)
        
        // Sep
        addSubview(sepLine)
        
        // Mic
        addSubview(micLabel)
        addSubview(micSwitch)
        micLabel.agora_enable = config.microphone.enable
        micLabel.agora_visible = config.microphone.visible
        micSwitch.agora_enable = config.microphone.enable
        micSwitch.agora_visible = config.microphone.visible
        
        // Speaker
        addSubview(speakerLabel)
        addSubview(speakerSwitch)
        speakerLabel.agora_enable = config.speaker.enable
        speakerLabel.agora_visible = config.speaker.visible
        speakerSwitch.agora_enable = config.speaker.enable
        speakerSwitch.agora_visible = config.speaker.visible

        // Exit
        addSubview(exitButton)
        exitButton.agora_enable = config.exit.enable
        exitButton.agora_visible = config.exit.visible
    }
    
    func initViewFrame() {
        // Camera
        cameraLabel.mas_makeConstraints { make in
            make?.top.left().equalTo()(16)
        }
        
        cameraSwitch.mas_makeConstraints { make in
            make?.right.equalTo()(-16)
            make?.width.equalTo()(40)
            make?.height.equalTo()(20)
            make?.centerY.equalTo()(cameraLabel)?.offset()(-5)
        }
        
        cameraDirectionLabel.mas_makeConstraints { make in
            make?.left.equalTo()(cameraLabel)
            make?.top.equalTo()(cameraLabel.mas_bottom)?.offset()(20)
        }
        
        frontCameraButton.mas_makeConstraints { make in
            make?.width.equalTo()(40)
            make?.height.equalTo()(22)
            make?.right.equalTo()(backCameraButton.mas_left)?.offset()(-5)
            make?.centerY.equalTo()(backCameraButton)
        }

        backCameraButton.mas_makeConstraints { make in
            make?.width.equalTo()(40)
            make?.height.equalTo()(22)
            make?.right.equalTo()(cameraSwitch)
            make?.centerY.equalTo()(cameraDirectionLabel)
        }
        
        sepLine.mas_makeConstraints { make in
            make?.top.equalTo()(cameraDirectionLabel.mas_bottom)?.offset()(17)
            make?.left.equalTo()(16)
            make?.right.equalTo()(-16)
            make?.height.equalTo()(1)
        }
        
        // Mic
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
        
        // Speaker
        speakerLabel.mas_makeConstraints { make in
            make?.left.equalTo()(cameraLabel)
            make?.top.equalTo()(micLabel.mas_bottom)?.offset()(18)
        }
        
        speakerSwitch.mas_makeConstraints { make in
            make?.right.equalTo()(-16)
            make?.width.equalTo()(40)
            make?.height.equalTo()(20)
            make?.centerY.equalTo()(speakerLabel)?.offset()(-5)
        }
        
        // Exit
        exitButton.mas_makeConstraints { make in
            make?.left.equalTo()(15)
            make?.right.equalTo()(-15)
            make?.height.equalTo()(30)
            make?.bottom.equalTo()(-16)
        }
        
        cameraSwitch.transform = CGAffineTransform(scaleX: 0.75,
                                                   y: 0.75)
        
        micSwitch.transform = CGAffineTransform(scaleX: 0.75,
                                                y: 0.75)
        
        speakerSwitch.transform = CGAffineTransform(scaleX: 0.75,
                                                    y: 0.75)
    }
    
    func updateViewProperties() {
        let config = UIConfig.setting
        
        // Camera
        cameraLabel.text = "fcr_media_camera".agedu_localized()
        cameraLabel.textColor = config.camera.title.color
        cameraLabel.font = config.camera.title.font
        
        cameraDirectionLabel.text = "fcr_media_camera_direction".agedu_localized()
        cameraDirectionLabel.textColor = config.camera.direction.titleColor
        cameraDirectionLabel.font = config.camera.direction.font
        
        cameraSwitch.onTintColor = config.camera.tintColor
        
        frontCameraButton.titleLabel?.font = config.camera.direction.font
        frontCameraButton.setTitle("fcr_media_camera_direction_front".agedu_localized(),
                                   for: .normal)
        
        backCameraButton.titleLabel?.font = config.camera.direction.font
        backCameraButton.setTitle("fcr_media_camera_direction_back".agedu_localized(),
                               for: .normal)
        
        for button in [frontCameraButton, backCameraButton] {
            button.setTitleColor(config.camera.direction.selectedLabelColor,
                                 for: .selected)
            button.setTitleColor(config.camera.direction.normalLabelColor,
                                 for: .normal)
            let normalColorImage = UIImage(color: config.camera.direction.normalBackgroundColor,
                                           size: CGSize(width: 1,
                                                        height: 1))
            let selectedColorImage = UIImage(color: config.camera.direction.selectedBackgroundColor,
                                           size: CGSize(width: 1,
                                                        height: 1))
                                           
            button.setBackgroundImage(normalColorImage,
                                      for: .normal)
            button.setBackgroundImage(selectedColorImage,
                                      for: .selected)
            
            button.layer.cornerRadius = config.camera.direction.cornerRadius
            button.clipsToBounds = true
        }
        
        // Sep
        sepLine.backgroundColor = FcrUIColorGroup.systemDividerColor
        
        // Mic
        micLabel.textColor = config.microphone.title.color
        micLabel.text = "fcr_media_mic".agedu_localized()
        micLabel.font = config.microphone.title.font
        
        micSwitch.onTintColor = config.microphone.tintColor
        
        // Speaker
        speakerLabel.textColor = config.speaker.title.color
        speakerLabel.text = "fcr_media_speaker".agedu_localized()
        speakerLabel.font = config.speaker.title.font
        
        speakerSwitch.onTintColor = config.speaker.tintColor
        
        // Exit
        exitButton.titleLabel?.font = config.exit.titleFont
        exitButton.setTitle("fcr_room_leave_room".agedu_localized(),
                            for: .normal)
        exitButton.backgroundColor = config.exit.backgroundColor
        exitButton.layer.cornerRadius = config.exit.cornerRadius
        exitButton.clipsToBounds = true
        exitButton.setTitleColor(config.exit.titleColor,
                                 for: .normal)
    }
}

private extension FcrSettingsView {
    @objc private func onCameraSwitchChanged(_ sender: UISwitch) {
        frontCameraButton.isEnabled = sender.isOn
        backCameraButton.isEnabled = sender.isOn
        
        delegate?.onCameraSwitchIsOn(isOn: sender.isOn)
    }
    
    @objc private func onFrontCameraPressed(_ sender: UIButton) {
        guard sender.isSelected == false else {
            return
        }
        
        setCameraIsSelected(true,
                            isFront: true)
        
        delegate?.onCameraButtonIsSelected(isFront: true)
    }
    
    @objc private func onBackCameraPressed(_ sender: UIButton) {
        guard sender.isSelected == false else {
            return
        }
        
        setCameraIsSelected(true,
                            isFront: false)
        
        delegate?.onCameraButtonIsSelected(isFront: false)
    }
}
