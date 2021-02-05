//
//  AgoraToolView.swift
//  AgoraEduSDK
//
//  Created by SRS on 2021/1/29.
//

import UIKit
import EduSDK

@objcMembers public class MenuConfig: NSObject {
    public var imageName = ""
    public var touchBlock: (() -> Void)?
}

@objcMembers public class AgoraToolView: AgoraBaseView {
    
    public var leftTouchBlock: (() -> Void)?
    
    fileprivate let LabelTag: Int = 99
    fileprivate let ImageViewTag: Int = 100
    fileprivate let ButtonTagStart: Int = 101
    
    fileprivate lazy var leftBtn: AgoraBaseUIButton = {
        let btn = AgoraBaseUIButton(type: .custom)
        btn.addTarget(self, action: #selector(onLeftTouchEvent), for: .touchUpInside)
        btn.setImage(AgoraImageWithName("left", self.classForCoder), for: .normal)
        return btn
    }()
    
    fileprivate lazy var classInfoLabel: AgoraBaseUILabel = {
        let label = AgoraBaseUILabel()
        label.isHidden = true
    
        label.font = UIFont.boldSystemFont(ofSize: AgoraDeviceAssistant.OS.isPad ? 18 : 10)
        label.text = "课程ID："
        label.textColor = UIColor.white
        return label
    }()
    
    fileprivate lazy var timeView: AgoraBaseView = {
        
        let view = AgoraBaseView()
        view.isHidden = true
        
        let redView = AgoraBaseView()
        redView.backgroundColor = UIColor(red: 243/255.0, green: 76/255.0, blue: 118/255.0, alpha: 1)
        redView.clipsToBounds = true
        redView.layer.borderColor = UIColor.white.cgColor
        view.addSubview(redView)
        if AgoraDeviceAssistant.OS.isPad {
            redView.layer.borderWidth = 2
            redView.agora_x = 0
            redView.agora_center_y = 0
            redView.agora_resize(11, 11)
            redView.layer.cornerRadius = 5
        } else {
            redView.layer.borderWidth = 1
            redView.agora_x = 0
            redView.agora_center_y = 0
            redView.agora_resize(6, 6)
            redView.layer.cornerRadius = 3
        }
        
        let label = AgoraBaseUILabel()
        label.font = UIFont.boldSystemFont(ofSize: AgoraDeviceAssistant.OS.isPad ? 18 : 10)
        label.text = ""
        label.tag = LabelTag
        label.textColor = UIColor.white
        view.addSubview(label)
        
        if AgoraDeviceAssistant.OS.isPad {
            label.agora_x = 15
            label.agora_center_y = 0
            label.agora_resize(20, 17)
            label.agora_right = 0
        } else {
            label.agora_x = 10
            label.agora_center_y = 0
            label.agora_resize(20, 10)
            label.agora_right = 0
        }

        return view
    }()
    
    fileprivate lazy var signalView: AgoraBaseView = {
        
        let view = AgoraBaseView()
        
        let imageView = AgoraBaseUIImageView(image: AgoraImageWithName("signal_1", self.classForCoder))
        imageView.tag = ImageViewTag
        view.addSubview(imageView)
        if AgoraDeviceAssistant.OS.isPad {
            imageView.agora_x = 0
            imageView.agora_center_y = 0
            imageView.agora_resize(40, 40)
        } else {
            imageView.agora_x = 0
            imageView.agora_center_y = 0
            imageView.agora_resize(20, 20)
        }
        
        let label = AgoraBaseUILabel()
        label.font = UIFont.boldSystemFont(ofSize: AgoraDeviceAssistant.OS.isPad ? 17 : 9)
        label.textColor = UIColor(red: 205/255.0, green: 241/255.0, blue: 96/255.0, alpha: 1)
        label.tag = LabelTag
        label.text = "优"
        view.addSubview(label)
        if AgoraDeviceAssistant.OS.isPad {
            label.agora_x = 47
            label.agora_center_y = 0
            label.agora_resize(20, 17)
            label.agora_right = 5
        } else {
            label.agora_x = 23
            label.agora_center_y = 0
            label.agora_resize(9, 9)
            label.agora_right = 3
        }

        return view
    }()
    
    fileprivate var menuConfigs: [MenuConfig] = []

    public convenience init(menuConfigs: [MenuConfig]) {
        self.init()
        self.menuConfigs = menuConfigs
        self.initView()
        self.initLayout()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initView()
        self.initLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
// MARK: Rect
extension AgoraToolView {
    fileprivate func initView() {
        self.backgroundColor = UIColor(red: 29/255.0, green: 53/255.0, blue: 173/255.0, alpha: 1)
        
        self.addSubview(self.leftBtn)
        self.addSubview(self.classInfoLabel)
        self.addSubview(self.timeView)
        self.addSubview(self.signalView)

        self.menuConfigs.reverse()
        for (index, menuConfig) in self.menuConfigs.enumerated() {
            
            let btn = AgoraBaseUIButton(type: .custom)
            btn.addTarget(self, action: #selector(onConfigTouchEvent(_ :)), for: .touchUpInside)
            btn.tag = index + ButtonTagStart
            btn.setImage(AgoraImageWithName(menuConfig.imageName, self.classForCoder), for: .normal)
            self.addSubview(btn)
        }
    }
    
    fileprivate func initLayout() {
        
        if AgoraDeviceAssistant.OS.isPad {
            self.leftBtn.agora_x = 39
            self.leftBtn.agora_bottom = 17
            self.leftBtn.agora_resize(137, 42)
            
            self.classInfoLabel.agora_x = self.leftBtn.agora_x + self.leftBtn.agora_width + 45
            self.classInfoLabel.agora_bottom = 17
            self.classInfoLabel.agora_resize(0, 42)
            
            self.timeView.agora_x = self.classInfoLabel.agora_x + self.classInfoLabel.agora_width + 35
            self.timeView.agora_bottom = 17
            self.timeView.agora_height = 42

            self.signalView.agora_x = self.timeView.agora_x + self.timeView.agora_width + 45
            self.signalView.agora_bottom = 17
            self.signalView.agora_height = 42

            for (index, _) in self.menuConfigs.enumerated() {
                let btn = self.viewWithTag(index + ButtonTagStart) as! AgoraBaseUIButton
                btn.agora_resize(40, 40)
                btn.agora_right = CGFloat(39 + (Int(btn.agora_width) + 39) * index)
                btn.agora_bottom = 19
            }
            
        } else {
            self.leftBtn.agora_x = 25
            self.leftBtn.agora_bottom = 9
            self.leftBtn.agora_resize(83, 26)
            
            self.classInfoLabel.agora_x = self.leftBtn.agora_x + self.leftBtn.agora_width + 40
            self.classInfoLabel.agora_y = 0
            self.classInfoLabel.agora_bottom = 0
            self.classInfoLabel.agora_width = 0
            
            self.timeView.agora_x = self.classInfoLabel.agora_x + self.classInfoLabel.agora_width + 15
            self.timeView.agora_y = 0
            self.timeView.agora_bottom = 0
            
            self.signalView.agora_x = self.timeView.agora_x + self.timeView.agora_width + 32
            self.signalView.agora_bottom = self.leftBtn.agora_bottom
            self.signalView.agora_height = 26

            for (index, _) in self.menuConfigs.enumerated() {
                let btn = self.viewWithTag(index + ButtonTagStart) as! AgoraBaseUIButton
                btn.agora_resize(32, 32)
                btn.agora_right = CGFloat(28 + (Int(btn.agora_width) + 9) * index)
                btn.agora_bottom = 6
            }
        }
    }
    
    public func updateSignal(_ quality: AgoraRTENetworkQuality) {
        let signalImgView = self.signalView.viewWithTag(ImageViewTag) as! AgoraBaseUIImageView
        signalImgView.image = AgoraImageWithName("signal_3", self.classForCoder)
        let signalLabel = self.signalView.viewWithTag(LabelTag) as! AgoraBaseUILabel
        switch quality {
        case .high:
            signalImgView.image = AgoraImageWithName("signal_1", self.classForCoder)
            signalLabel.text = "优"
            signalLabel.textColor = UIColor(red: 205/255.0, green: 241/255.0, blue: 96/255.0, alpha: 1)
        case .middle:
            signalImgView.image = AgoraImageWithName("signal_2", self.classForCoder)
            signalLabel.text = "良"
            signalLabel.textColor = UIColor(red: 241/255.0, green: 167/255.0, blue: 62/255.0, alpha: 1)
        case .low:
            signalImgView.image = AgoraImageWithName("signal_3", self.classForCoder)
            signalLabel.text = "差"
            signalLabel.textColor = UIColor(red: 240/255.0, green: 76/255.0, blue: 54/255.0, alpha: 1)
        default:
            signalImgView.image = AgoraImageWithName("signal_3", self.classForCoder)
            signalLabel.text = "差"
            signalLabel.textColor = UIColor(red: 240/255.0, green: 76/255.0, blue: 54/255.0, alpha: 1)
        }
    }
    public func updateClassID(_ classID: String) {
        let classString = "课程ID: \(classID)"
        self.classInfoLabel.text = classString
        self.classInfoLabel.isHidden = false
        self.classInfoLabel.sizeToFit()
        let classSize = self.classInfoLabel.frame.size
        self.classInfoLabel.agora_width = classSize.width + 1
        self.timeView.agora_x = self.classInfoLabel.agora_x + self.classInfoLabel.agora_width + (AgoraDeviceAssistant.OS.isPad ? 35 : 17)
        
        self.updateTime()
    }
    
    public func updateTime() {
        
        let timeString = "距离上课还有：10分11秒"
   
        let timeLabel = self.timeView.viewWithTag(LabelTag) as! AgoraBaseUILabel
        self.timeView.isHidden = false
        timeLabel.text = timeString
        timeLabel.sizeToFit()
        let timeSize = timeLabel.frame.size
        timeLabel.agora_width = timeSize.width + 1
        self.signalView.agora_x = self.timeView.agora_x + timeLabel.agora_width + (AgoraDeviceAssistant.OS.isPad ? 50 : 30)
    }
}

// MARK: UIButton Event
extension AgoraToolView {
    @objc fileprivate func onLeftTouchEvent() {
        // confirm
        self.leftTouchBlock?()
    }
    
    @objc fileprivate func onConfigTouchEvent(_ sender: UIButton) {
        let menuConfig = self.menuConfigs[sender.tag - ButtonTagStart]
        menuConfig.touchBlock?()
    }
}
