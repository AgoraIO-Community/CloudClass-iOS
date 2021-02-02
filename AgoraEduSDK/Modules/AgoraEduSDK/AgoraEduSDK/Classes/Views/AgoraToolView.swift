//
//  AgoraToolView.swift
//  AgoraEduSDK
//
//  Created by SRS on 2021/1/29.
//

import UIKit

@objcMembers public class MenuConfig: NSObject {
    public var imageName = ""
    public var touchBlock: (() -> Void)?
}

@objcMembers public class AgoraToolView: AgoraBaseView {
    
    public var leftTouchBlock: (() -> Void)?
    
    fileprivate let LabelTag: Int = 99
    fileprivate let ImageViewTag: Int = 100
    fileprivate let ButtonTagStart: Int = 101
    
    fileprivate lazy var leftBtn: AgoraBaseButton = {
        let btn = AgoraBaseButton(type: .custom)
        btn.addTarget(self, action: #selector(onLeftTouchEvent), for: .touchUpInside)
        btn.setImage(AgoraImageWithName("left", self.classForCoder), for: .normal)
        return btn
    }()
    
    fileprivate lazy var classInfoLabel: AgoraBaseLabel = {
        let label = AgoraBaseLabel()
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
            redView.x = 0
            redView.centerY = 0
            redView.resize(11, 11)
            redView.layer.cornerRadius = 5
        } else {
            redView.layer.borderWidth = 1
            redView.x = 0
            redView.centerY = 0
            redView.resize(6, 6)
            redView.layer.cornerRadius = 3
        }
        
        let label = AgoraBaseLabel()
        label.font = UIFont.boldSystemFont(ofSize: AgoraDeviceAssistant.OS.isPad ? 18 : 10)
        label.text = ""
        label.tag = LabelTag
        label.textColor = UIColor.white
        view.addSubview(label)
        
        if AgoraDeviceAssistant.OS.isPad {
            label.x = 15
            label.centerY = 0
            label.resize(20, 17)
            label.right = 0
        } else {
            label.x = 10
            label.centerY = 0
            label.resize(20, 10)
            label.right = 0
        }

        return view
    }()
    
    fileprivate lazy var signalView: AgoraBaseView = {
        
        let view = AgoraBaseView()
        
        let imageView = AgoraBaseImageView(image: AgoraImageWithName("signal_1", self.classForCoder))
        imageView.tag = ImageViewTag
        view.addSubview(imageView)
        if AgoraDeviceAssistant.OS.isPad {
            imageView.x = 0
            imageView.centerY = 0
            imageView.resize(40, 40)
        } else {
            imageView.x = 0
            imageView.centerY = 0
            imageView.resize(20, 20)
        }
        
        let label = AgoraBaseLabel()
        label.font = UIFont.boldSystemFont(ofSize: AgoraDeviceAssistant.OS.isPad ? 17 : 9)
        label.textColor = UIColor(red: 205/255.0, green: 241/255.0, blue: 96/255.0, alpha: 1)
        label.tag = LabelTag
        label.text = "优"
        view.addSubview(label)
        if AgoraDeviceAssistant.OS.isPad {
            label.x = 47
            label.centerY = 0
            label.resize(20, 17)
            label.right = 5
        } else {
            label.x = 23
            label.centerY = 0
            label.resize(9, 9)
            label.right = 3
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
            
            let btn = AgoraBaseButton(type: .custom)
            btn.addTarget(self, action: #selector(onConfigTouchEvent(_ :)), for: .touchUpInside)
            btn.tag = index + ButtonTagStart
            btn.setImage(AgoraImageWithName(menuConfig.imageName, self.classForCoder), for: .normal)
            self.addSubview(btn)
        }
    }
    
    fileprivate func initLayout() {
        
        if AgoraDeviceAssistant.OS.isPad {
            self.leftBtn.x = 39
            self.leftBtn.bottom = 17
            self.leftBtn.resize(137, 42)
            
            self.classInfoLabel.x = self.leftBtn.x + self.leftBtn.width + 45
            self.classInfoLabel.bottom = 17
            self.classInfoLabel.resize(0, 42)
            
            self.timeView.x = self.classInfoLabel.x + self.classInfoLabel.width + 35
            self.timeView.bottom = 17
            self.timeView.height = 42

            self.signalView.x = self.timeView.x + self.timeView.width + 45
            self.signalView.bottom = 17
            self.signalView.height = 42

            for (index, _) in self.menuConfigs.enumerated() {
                let btn = self.viewWithTag(index + ButtonTagStart) as! AgoraBaseButton
                btn.resize(40, 40)
                btn.right = CGFloat(39 + (Int(btn.width) + 39) * index)
                btn.bottom = 19
            }
            
        } else {
            self.leftBtn.x = 20
            self.leftBtn.bottom = 9
            self.leftBtn.resize(72, 22)
            
            self.classInfoLabel.x = self.leftBtn.x + self.leftBtn.width + 27
            self.classInfoLabel.bottom = 9
            self.classInfoLabel.resize(0, 22)
            
            self.timeView.x = self.classInfoLabel.x + self.classInfoLabel.width + 18
            self.timeView.bottom = 9
            self.timeView.height = 22
            
            self.signalView.x = self.timeView.x + self.timeView.width + 27
            self.signalView.bottom = 9
            self.signalView.height = 22

            for (index, _) in self.menuConfigs.enumerated() {
                let btn = self.viewWithTag(index + ButtonTagStart) as! AgoraBaseButton
                btn.resize(20, 20)
                btn.right = CGFloat(15 + (Int(btn.width) + 15) * index)
                btn.bottom = 10
            }
        }
    }
    
    public func updateView() {
        
        let classString = "课程ID: 122342"
        let timeString = "距离上课还有：10分11秒"
        
        self.classInfoLabel.text = classString
        self.classInfoLabel.isHidden = false
        self.classInfoLabel.sizeToFit()
        let classSize = self.classInfoLabel.frame.size
        self.classInfoLabel.width = classSize.width + 1
        self.timeView.x = self.classInfoLabel.x + self.classInfoLabel.width + (AgoraDeviceAssistant.OS.isPad ? 35 : 17)
        
        let timeLabel = self.timeView.viewWithTag(LabelTag) as! AgoraBaseLabel
        self.timeView.isHidden = false
        timeLabel.text = timeString
        timeLabel.sizeToFit()
        let timeSize = timeLabel.frame.size
        timeLabel.width = timeSize.width + 1
        self.signalView.x = self.timeView.x + timeLabel.width + (AgoraDeviceAssistant.OS.isPad ? 50 : 30)
        
        let signalImgView = self.signalView.viewWithTag(ImageViewTag) as! AgoraBaseImageView
        signalImgView.image = AgoraImageWithName("signal_3", self.classForCoder)
        let signalLabel = self.signalView.viewWithTag(LabelTag) as! AgoraBaseLabel
        signalLabel.text = "差"
        signalLabel.textColor = UIColor(red: 240/255.0, green: 76/255.0, blue: 54/255.0, alpha: 1)
        
        //UIColor(red: 205/255.0, green: 241/255.0, blue: 96/255.0, alpha: 1)
        //UIColor(red: 241/255.0, green: 167/255.0, blue: 62/255.0, alpha: 1)
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
