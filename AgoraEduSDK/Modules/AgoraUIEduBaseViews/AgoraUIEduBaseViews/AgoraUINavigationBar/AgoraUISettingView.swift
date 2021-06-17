//
//  AgoraUISettingView.swift
//  AgoraUIEduBaseViews
//
//  Created by SRS on 2021/3/9.
//

import Foundation
import AgoraUIBaseViews
import AgoraEduContext

@objcMembers public class AgoraUISettingView: AgoraBaseUIView {
    public var cameraStateBlock: ((_ open: Bool) -> Void)?
    public var micStateBlock: ((_ open: Bool) -> Void)?
    public var speakerStateBlock: ((_ open: Bool) -> Void)?
    public var switchCameraBlock: (() -> Void)?
    public var leaveClassBlock: (() -> Void)?
    
    fileprivate lazy var titleView: AgoraBaseUIView = {
        let view = AgoraBaseUIView()
        view.backgroundColor = UIColor(rgb: 0xF9F9FC)
        
        let label = AgoraBaseUILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor(rgb: 0x191919)
        label.text = AgoraKitLocalizedString("SetText")
        view.addSubview(label)
        
        label.agora_x = 20
        label.agora_y = 0
        label.agora_width = 100
        label.agora_bottom = 0
        
        let lineV = AgoraBaseUIView()
        lineV.backgroundColor = UIColor(rgb: 0xEEEEF7)
        view.addSubview(lineV)
        
        lineV.agora_x = 0
        lineV.agora_right = 0
        lineV.agora_height = 1
        lineV.agora_bottom = 0
        
        return view
    }()
    
    fileprivate lazy var cameraView: AgoraBaseUIView = {
        let view = self.tagSwitchView(AgoraKitLocalizedString("CameraText"))
        return view
    }()
    
    fileprivate var frontBtn: AgoraBaseUIButton?
    fileprivate var backBtn: AgoraBaseUIButton?
    fileprivate lazy var directionView: AgoraBaseUIView = {
        let view = AgoraBaseUIView()
        view.backgroundColor = UIColor.white

        let label = AgoraBaseUILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor(rgb: 0x677386)
        label.text = AgoraKitLocalizedString("DirectionText")
        view.addSubview(label)
        label.agora_x = 33
        label.agora_width = 120
        label.agora_y = 0
        label.agora_bottom = 0
        
        let bBtn = AgoraBaseUIButton(type: .custom)
        bBtn.setTitle(AgoraKitLocalizedString("BackText"), for: .normal)
        bBtn.backgroundColor = UIColor(rgb:0xF4F4F8)
        bBtn.setTitleColor(UIColor(rgb:0xB5B5C9), for: .normal)
        bBtn.setTitleColor(UIColor.white, for: .selected)
        bBtn.addTarget(self,
                       action: #selector(onTouchDirection(_ :)),
                       for: .touchUpInside)
        bBtn.clipsToBounds = true
        view.addSubview(bBtn)
        self.backBtn = bBtn
        bBtn.agora_right = 20
        bBtn.agora_width = 50
        bBtn.agora_height = 26
        bBtn.agora_center_y = 0
        bBtn.layer.cornerRadius = bBtn.agora_height * 0.2
        
        let fBtn = AgoraBaseUIButton(type: .custom)
        fBtn.setTitle(AgoraKitLocalizedString("FrontText"), for: .normal)
        fBtn.backgroundColor = UIColor(rgb:0x7B88A0)
        fBtn.setTitleColor(UIColor(rgb:0xB5B5C9), for: .normal)
        fBtn.setTitleColor(UIColor.white, for: .selected)
        fBtn.addTarget(self,
                       action: #selector(onTouchDirection(_ :)),
                       for: .touchUpInside)
        fBtn.isSelected = true
        fBtn.clipsToBounds = true
        view.addSubview(fBtn)
        self.frontBtn = fBtn
        fBtn.agora_right = bBtn.agora_right + bBtn.agora_width + 10
        fBtn.agora_width = 50
        fBtn.agora_height = 26
        fBtn.agora_center_y = 0
        fBtn.layer.cornerRadius = fBtn.agora_height * 0.2

        let lineV = AgoraBaseUIView()
        lineV.backgroundColor = UIColor(rgb: 0xE3E3EC)
        view.addSubview(lineV)
        lineV.agora_x = 10
        lineV.agora_right = 10
        lineV.agora_height = 1
        lineV.agora_bottom = 0
   
        return view
    }()
    
    fileprivate lazy var micView: AgoraBaseUIView = {
        let v = self.tagSwitchView(AgoraKitLocalizedString("MicrophoneText"))
        
        let lineV = AgoraBaseUIView()
        lineV.backgroundColor = UIColor(rgb: 0xE3E3EC)
        v.addSubview(lineV)
        lineV.agora_x = 10
        lineV.agora_right = 10
        lineV.agora_height = 1
        lineV.agora_bottom = 0
        
        return v
    }()
    
    fileprivate lazy var speakerView: AgoraBaseUIView = {
        let view = self.tagSwitchView(AgoraKitLocalizedString("SpeakerText"))
        if let switchButton = view.viewWithTag(SwitchTag) as? AgoraBaseUISwitch {
            switchButton.isOn = false
        }

        let line = AgoraBaseUIView()
        line.backgroundColor = UIColor(rgb: 0xE3E3EC)
        view.addSubview(line)
        line.agora_x = 10
        line.agora_right = 10
        line.agora_height = 1
        line.agora_bottom = 0
        
        return view
    }()
    
    fileprivate lazy var leaveView: AgoraBaseUIView = {
        let view = AgoraBaseUIView()
        view.backgroundColor = UIColor.white
        
        let btn = AgoraBaseUIButton(type: .custom)
        btn.setTitle(AgoraKitLocalizedString("LeaveText"),
                     for: .normal)
        btn.setTitleColor(UIColor(rgb:0xF04C36),
                          for: .normal)
        btn.addTarget(self,
                      action: #selector(onTouchLeave(_ :)),
                      for: .touchUpInside)
        btn.clipsToBounds = true
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor(rgb: 0xF04C36).cgColor
        view.addSubview(btn)
        
        btn.agora_x = 20
        btn.agora_right = 20
        btn.agora_height = 30
        btn.agora_center_y = 0
        
        btn.layer.cornerRadius = btn.agora_height * 0.5
        
        return view
    }()
    
    fileprivate lazy var boarderView: AgoraBaseUIView = {
        let view = AgoraBaseUIView()
        view.backgroundColor = UIColor.clear
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(rgb: 0xE3E3EC).cgColor
        
        view.clipsToBounds = true
        view.layer.cornerRadius = 4
        view.isUserInteractionEnabled = false
        
        return view
    }()

    fileprivate let SwitchTag = 100

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.initView()
        self.initLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: touch event
    @objc func onTouchSwitch(_ switchBtn: AgoraBaseUISwitch) {
        if switchBtn == self.cameraView.viewWithTag(SwitchTag) {
            self.cameraStateBlock?(switchBtn.isOn)
            
        } else if switchBtn == self.micView.viewWithTag(SwitchTag) {
            self.micStateBlock?(switchBtn.isOn)
            
        } else if switchBtn == self.speakerView.viewWithTag(SwitchTag) {
            self.speakerStateBlock?(switchBtn.isOn)
        }
    }
    
    private func switchDirectionUI(_ btn: AgoraBaseUIButton) {
        if btn.isSelected {
            return
        }
        
        btn.isSelected = !btn.isSelected
        btn.backgroundColor = btn.isSelected ? UIColor(rgb:0x7B88A0) : UIColor(rgb:0xF4F4F8)
        
        if let otherBtn = ((btn == self.frontBtn) ? self.backBtn : self.frontBtn) {
            
            otherBtn.isSelected = !btn.isSelected
            otherBtn.backgroundColor = btn.isSelected ? UIColor(rgb:0xF4F4F8) : UIColor(rgb:0x7B88A0)
        }
    }
    
    @objc func onTouchDirection(_ btn: AgoraBaseUIButton) {
        if btn.isSelected {
            return
        }
        
        self.switchDirectionUI(btn)
        
        self.switchCameraBlock?()
    }
    
    @objc func onTouchLeave(_ btn: AgoraBaseUIButton) {
        self.leaveClassBlock?()
    }
}

// MARK: Rect
extension AgoraUISettingView {
    fileprivate func initView() {
        self.backgroundColor = UIColor.clear
        self.layer.shadowColor = UIColor(red: 0.18, green: 0.25, blue: 0.57, alpha: 0.15).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 6

        self.addSubview(self.titleView)
        self.addSubview(self.cameraView)
        self.addSubview(self.directionView)
        self.addSubview(self.micView)
        self.addSubview(self.speakerView)
        self.addSubview(self.leaveView)
        self.addSubview(self.boarderView)
    }
    
    fileprivate func initLayout() {
        self.titleView.agora_x = 0
        self.titleView.agora_right = 0
        self.titleView.agora_y = 0
        self.titleView.agora_height = 40
        
        self.cameraView.agora_x = 0
        self.cameraView.agora_right = 0
        self.cameraView.agora_y = self.titleView.agora_y + self.titleView.agora_height
        self.cameraView.agora_height = 40
        
        self.directionView.agora_x = 0
        self.directionView.agora_right = 0
        self.directionView.agora_y = self.cameraView.agora_y + self.cameraView.agora_height
        self.directionView.agora_height = 40
        
        self.micView.agora_x = 0
        self.micView.agora_right = 0
        self.micView.agora_y = self.directionView.agora_y + self.directionView.agora_height
        self.micView.agora_height = 40
        
        self.speakerView.agora_x = 0
        self.speakerView.agora_right = 0
        self.speakerView.agora_y = self.micView.agora_y + self.micView.agora_height
        self.speakerView.agora_height = 40
        
        self.leaveView.agora_x = 0
        self.leaveView.agora_right = 0
        self.leaveView.agora_y = self.speakerView.agora_y + self.speakerView.agora_height
        self.leaveView.agora_height = 60
        
        self.boarderView.agora_x = 0
        self.boarderView.agora_right = 0
        self.boarderView.agora_y = 0
        self.boarderView.agora_bottom = -5
    }
    
    public func updateCameraState(_ enable: Bool) {
        if let switchBtn = self.cameraView.viewWithTag(SwitchTag) as? AgoraBaseUISwitch {
            switchBtn.isOn = enable
        }
    }
    public func updateCameraFacing(_ facing: EduContextCameraFacing) {
        let btn = (facing == EduContextCameraFacing.back) ? self.backBtn : self.frontBtn
        self.switchDirectionUI(btn!)
    }
    public func updateMicroState(_ enable: Bool) {
        if let switchBtn = self.micView.viewWithTag(SwitchTag) as? AgoraBaseUISwitch {
            switchBtn.isOn = enable
        }
    }
    public func updateSpeakerState(_ enable: Bool) {
        if let switchBtn = self.speakerView.viewWithTag(SwitchTag) as? AgoraBaseUISwitch {
            switchBtn.isOn = enable
        }
    }
    
    fileprivate func tagSwitchView(_ tag: String) -> AgoraBaseUIView {
        let view = AgoraBaseUIView()
        view.backgroundColor = UIColor.white
        
        let label = AgoraBaseUILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor(rgb: 0x191919)
        label.text = tag
        view.addSubview(label)
        label.agora_x = 20
        label.agora_width = 120
        label.agora_y = 0
        label.agora_bottom = 0
        
        let switchBtn = AgoraBaseUISwitch()
        switchBtn.isOn = true
        switchBtn.onTintColor = UIColor(rgb:0x357BF6)
        switchBtn.addTarget(self,
                            action: #selector(onTouchSwitch(_ :)),
                            for: .touchUpInside)
        switchBtn.tag = SwitchTag
        view.addSubview(switchBtn)
        
        if !AgoraKitDeviceAssistant.OS.isPad {
            switchBtn.transform = CGAffineTransform(scaleX: 48 /  switchBtn.frame.size.width,
                                                    y: 26 / switchBtn.frame.size.height)
        }
        
        switchBtn.agora_right = 20
        switchBtn.agora_center_y = 0
        
        return view
    }
}
