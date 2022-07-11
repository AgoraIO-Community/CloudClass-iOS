//
//  FcrSettingsView.swift
//  AgoraEduUI
//
//  Created by Cavan on 2022/6/23.
//

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
        // Camera
        addSubview(cameraLabel)
        addSubview(cameraSwitch)
        addSubview(cameraDirectionLabel)
        addSubview(frontCameraButton)
        addSubview(backCameraButton)
        
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
        
        // Speaker
        addSubview(speakerLabel)
        addSubview(speakerSwitch)

        // Exit
        addSubview(exitButton)
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
        
        
        let switchTintColor = FcrUIColorGroup.fcr_icon_fill_color
        let labelFont = FcrUIFontGroup.fcr_font13
        let labelColor = FcrUIColorGroup.fcr_text_level1_color
        
        // Camera
        cameraLabel.text = "fcr_media_camera".agedu_localized()
        cameraLabel.textColor = labelColor
        cameraLabel.font = labelFont
        
        cameraDirectionLabel.text = "fcr_media_camera_direction".agedu_localized()
        cameraDirectionLabel.textColor = FcrUIColorGroup.fcr_text_level3_color
        cameraDirectionLabel.font = labelFont
        
        cameraSwitch.onTintColor = switchTintColor
        
        frontCameraButton.titleLabel?.font = labelFont
        frontCameraButton.setTitle("fcr_media_camera_direction_front".agedu_localized(),
                                   for: .normal)
        
        backCameraButton.titleLabel?.font = labelFont
        backCameraButton.setTitle("fcr_media_camera_direction_back".agedu_localized(),
                               for: .normal)
        
        for button in [frontCameraButton, backCameraButton] {
            button.setTitleColor(FcrUIColorGroup.fcr_text_contrast_color,
                                 for: .selected)
            button.setTitleColor(FcrUIColorGroup.fcr_text_level2_color,
                                 for: .normal)
            let normalColorImage = UIImage(color: FcrUIColorGroup.fcr_icon_normal_color.withAlphaComponent(0.1),
                                           size: CGSize(width: 1,
                                                        height: 1))
            let selectedColorImage = UIImage(color: FcrUIColorGroup.fcr_icon_fill_color,
                                           size: CGSize(width: 1,
                                                        height: 1))
                                           
            button.setBackgroundImage(normalColorImage,
                                      for: .normal)
            button.setBackgroundImage(selectedColorImage,
                                      for: .selected)
            
            button.layer.cornerRadius = FcrUIFrameGroup.fcr_toast_corner_radius
            button.clipsToBounds = true
        }
        
        // Sep
        sepLine.backgroundColor = FcrUIColorGroup.fcr_system_divider_color
        
        // Mic
        micLabel.textColor = labelColor
        micLabel.text = "fcr_media_mic".agedu_localized()
        micLabel.font = labelFont
        
        micSwitch.onTintColor = switchTintColor
        
        // Speaker
        speakerLabel.textColor = labelColor
        speakerLabel.text = "fcr_media_speaker".agedu_localized()
        speakerLabel.font = labelFont
        
        speakerSwitch.onTintColor = switchTintColor
        
        // Exit
        exitButton.titleLabel?.font = labelFont
        exitButton.setTitle("fcr_room_leave_room".agedu_localized(),
                            for: .normal)
        exitButton.backgroundColor = FcrUIColorGroup.fcr_icon_fill_color
        exitButton.layer.cornerRadius = FcrUIFrameGroup.fcr_button_corner_radius
        exitButton.clipsToBounds = true
        exitButton.setTitleColor(FcrUIColorGroup.fcr_text_contrast_color,
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
