//
//  AgoraUserView.swift
//  AgoraEduSDK
//
//  Created by SRS on 2021/1/27.
//

import UIKit
import EduSDK

@objcMembers public class AgoraUserView: AgoraBaseView {
    
    public var audioTouchBlock: ((_ mute: Bool) -> Void)?
    public var videoTouchBlock: ((_ mute: Bool) -> Void)?
    public var scaleTouchBlock: ((_ min: Bool) -> Void)?
    
    fileprivate lazy var cupView: AgoraBaseView = {
        let bgColor = UIColor(red: 78/255.0, green: 78/255.0, blue: 78/255.0, alpha: 0.5)
        let textColor = UIColor(red: 255/255.0, green: 217/255.0, blue: 25/255.0, alpha: 1)
        let view = self.roundView(bgColor: bgColor, imgName: "cup", text: "x0", textColor: textColor, textSize: 10)
        view.layer.cornerRadius = 15
        view.isHidden = true
        return view
    }()
    fileprivate lazy var nameView: AgoraBaseView = {
        let bgColor = UIColor(red: 78/255.0, green: 78/255.0, blue: 78/255.0, alpha: 0.5)
        let textColor = UIColor(red: 254/255.0, green: 254/255.0, blue: 254/255.0, alpha: 1)
        let view = self.roundView(bgColor: bgColor, imgName: "role-icon", text: "", textColor: textColor, textSize: 10)
        view.layer.cornerRadius = 15
        return view
    }()
    fileprivate lazy var audioBtn: AgoraBaseButton = {
        let btn = AgoraBaseButton(type: .custom)
        btn.addTarget(self, action: #selector(onAudioTouchEvent), for: .touchUpInside)
        btn.setImage(AgoraImageWithName("audio", self.classForCoder), for: .normal)
        btn.setImage(AgoraImageWithName("audio_mute", self.classForCoder), for: .selected)
        return btn
    }()
    fileprivate lazy var videoBtn: AgoraBaseButton = {
        let btn = AgoraBaseButton(type: .custom)
        btn.addTarget(self, action: #selector(onVideoTouchEvent), for: .touchUpInside)
        btn.setImage(AgoraImageWithName("video", self.classForCoder), for: .normal)
        btn.setImage(AgoraImageWithName("video_mute", self.classForCoder), for: .selected)
        return btn
    }()
    fileprivate lazy var scaleBtn: AgoraBaseButton = {
        let btn = AgoraBaseButton(type: .custom)
        btn.addTarget(self, action: #selector(onScaleTouchEvent), for: .touchUpInside)
        btn.setImage(AgoraImageWithName("scale", self.classForCoder), for: .normal)
        return btn
    }()
    fileprivate var audioEffectView: AgoraBaseView?
    
    fileprivate weak var defaultLabel: AgoraBaseLabel?
    fileprivate weak var defaultImageView: AgoraBaseImageView?
    fileprivate lazy var defaultView: AgoraBaseView = {
        let view = AgoraBaseView()
        view.backgroundColor = UIColor(red: 222/255.0, green: 244/255.0, blue: 255/255.0, alpha: 1)
        
        let imgView = AgoraBaseImageView(image: nil)
        view.addSubview(imgView)
        imgView.resize(60, 60)
        imgView.centerX = 0
        imgView.centerY = -18
        self.defaultImageView = imgView
        
        let label = AgoraBaseLabel()
        label.text = ""
        label.textAlignment = .center
        label.textColor = UIColor(red: 0/255.0, green: 37/255.0, blue: 145/255.0, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 12)
        view.addSubview(label)
        label.x = 0
        label.right = 0
        label.height = 12
        label.centerY = 38
        self.defaultLabel = label

        return view
    }()
    
    fileprivate let RoundLabelTag: Int = 99
    
    public var isMin: Bool = false {
        didSet {
            self.resizeView()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initView()
        initLayout()
    }
    
    public func updateView() {
        
        let role = EduRoleType.student
        
        if (role == .student) {
            self.cupView.isHidden = false
            let cupLabel = self.cupView.viewWithTag(RoundLabelTag) as! AgoraBaseLabel
            cupLabel.text = "x99+"
            
            cupLabel.sizeToFit()
            let cupSize = cupLabel.frame.size
            let _ = cupLabel.resize(cupSize.width + 1, cupSize.height + 1)

            self.audioBtn.isUserInteractionEnabled = true
            self.videoBtn.isHidden = false
            self.videoBtn.isUserInteractionEnabled = true
            
        } else if (role == .teacher) {
            self.cupView.isHidden = true
            
            self.audioBtn.isUserInteractionEnabled = true
            self.videoBtn.isHidden = true
        }
        
        let nameLabel = self.nameView.viewWithTag(RoundLabelTag) as! AgoraBaseLabel
        nameLabel.text = "名字"
        
        nameLabel.sizeToFit()
        let nameSize = nameLabel.frame.size
        let _ = nameLabel.resize(nameSize.width + 1, nameSize.height + 1)
        
//        self.audioImgView.image = UIImage(named: "")
//        self.videoImgView.image = UIImage(named: "")
    
        self.defaultView.isHidden = false
        self.defaultLabel?.text = "没有检测到摄像头"
        //等待外教进入教室…
        //已关闭摄像头
        //外教已离开教室
        //没有检测到摄像头
        self.defaultImageView?.image = AgoraImageWithName("camera_close", self.classForCoder)
    }
    
    public func updateAudio(effect: Int) {
        self.audioEffectView?.removeFromSuperview()
        
        let totleCount = effect / 4
        
        self.audioEffectView = AgoraBaseView()
        self.addSubview(self.audioEffectView!)
        
        audioEffectView?.right = 17
        audioEffectView?.bottom = 39
        audioEffectView?.height = 3 + 4 * 6
        audioEffectView?.width = 16
        
        for index in 0...3 {
            
            var imgName = "audio_tag_0"
            if (index <= totleCount) {
                imgName = "audio_tag_1"
            }
            
            let imgView = AgoraBaseImageView(image:AgoraImageWithName(imgName, self.classForCoder))
            self.audioEffectView?.addSubview(imgView)
            
            imgView.resize(16, 3)
            imgView.x = 0
            imgView.bottom = CGFloat(3 + index * 6)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: UIButton Event
extension AgoraUserView {
 
    @objc fileprivate func onAudioTouchEvent() {
        self.audioBtn.isSelected = !self.audioBtn.isSelected
        self.audioTouchBlock?(self.audioBtn.isSelected)
    }
    
    @objc fileprivate func onVideoTouchEvent() {
        self.videoBtn.isSelected = !self.videoBtn.isSelected
        self.videoTouchBlock?(self.videoBtn.isSelected)
    }
    
    @objc fileprivate func onScaleTouchEvent() {
        self.isMin = !isMin
        self.scaleTouchBlock?(self.isMin)
    }
}

// MARK: Private
extension AgoraUserView {
    fileprivate func resizeView() {
        if (self.isMin) {
            self.defaultView.isHidden = true
            self.cupView.isHidden = true
            self.audioBtn.isHidden = true
            self.videoBtn.isHidden = true
            
            self.nameView.backgroundColor = UIColor.clear
            self.nameView.layer.cornerRadius = 0
    
            self.backgroundColor = UIColor(red: 117/255.0, green: 192/255.0, blue: 255/255.0, alpha: 1)
            self.layer.cornerRadius = 15

        } else {
            // check defaultView & cupView & videoBtn
            self.defaultView.isHidden = false
            self.cupView.isHidden = false
            self.audioBtn.isHidden = false
            self.videoBtn.isHidden = false
            
            let bgColor = UIColor(red: 78/255.0, green: 78/255.0, blue: 78/255.0, alpha: 0.5)
            self.nameView.backgroundColor = bgColor
            self.nameView.layer.cornerRadius = 15
            
            self.backgroundColor = UIColor.clear
            self.layer.cornerRadius = 20
        }
    }
    
    fileprivate func initView() {
        
        self.backgroundColor = UIColor.clear
        self.clipsToBounds = true
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor(red: 117/255.0, green: 192/255.0, blue: 255/255.0, alpha: 1).cgColor
        self.layer.cornerRadius = 20
        
        self.addSubview(self.defaultView)
        self.addSubview(self.cupView)
        self.addSubview(self.nameView)
        self.addSubview(self.audioBtn)
        self.addSubview(self.videoBtn)
        self.addSubview(self.scaleBtn)
    }
    fileprivate func initLayout() {
        
        self.defaultView.move(0, 0)
        self.defaultView.right = 0
        self.defaultView.bottom = 0
        
        self.cupView.x = 6
        self.cupView.y = 8
        self.cupView.height = 29

        self.nameView.x = 6
        self.nameView.bottom = 8
        self.nameView.height = 29
        
        self.audioBtn.right = 10
        self.audioBtn.bottom = 10
        let _ = self.audioBtn.resize(29, 29)
            
        self.videoBtn.right = 49
        self.videoBtn.bottom = 10
        let _ = self.videoBtn.resize(29, 29)
        
        self.scaleBtn.y = 10
        self.scaleBtn.right = 10
        let _ = self.scaleBtn.resize(25, 25)
    }
    
    fileprivate func roundView(bgColor: UIColor, imgName: String, text: String, textColor: UIColor, textSize: CGFloat) -> AgoraBaseView {
        
        let bg = AgoraBaseView()
        bg.backgroundColor = bgColor
        bg.clipsToBounds = true
        
        var labelX: CGFloat = 0

        let img = AgoraImageWithName(imgName, self.classForCoder)
        if (img != nil) {
            let tag = AgoraBaseImageView(image: img)
            bg.addSubview(tag)
            tag.x = 7
            tag.centerY = 0
            let size = tag.frame.size
            let _ = tag.resize(size.width, size.height)
            labelX = tag.width + 10

        } else {
            labelX = 7
        }

        let label = AgoraBaseLabel()
        label.text = text
        label.textColor = textColor
        label.tag = RoundLabelTag
        label.font = UIFont.systemFont(ofSize: textSize)
        bg.addSubview(label)
        
        label.sizeToFit()
        let size = label.frame.size
        
        label.x = labelX
        label.centerY = 0
        label.right = 7
        let _ = label.resize(size.width + 1, size.height + 1)
    
        return bg
    }
}
