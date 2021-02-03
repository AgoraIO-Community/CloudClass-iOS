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
        let view = self.roundView(bgColor: bgColor, imgName: "cup", imgSize: AgoraDeviceAssistant.OS.isPad ? CGSize(width: 22, height: 15) : CGSize(width: 13, height: 9), text: "x0", textColor: textColor, textSize: AgoraDeviceAssistant.OS.isPad ? 12 : 9)
        view.layer.cornerRadius = AgoraDeviceAssistant.OS.isPad ? 15 : 8
        view.isHidden = true
        return view
    }()
    fileprivate lazy var nameView: AgoraBaseView = {
        let bgColor = UIColor(red: 78/255.0, green: 78/255.0, blue: 78/255.0, alpha: 0.5)
        let textColor = UIColor(red: 254/255.0, green: 254/255.0, blue: 254/255.0, alpha: 1)
        let view = self.roundView(bgColor: bgColor, imgName: "role-icon", imgSize: AgoraDeviceAssistant.OS.isPad ? CGSize(width: 13, height: 14) : CGSize(width: 7, height: 8), text: "", textColor: textColor, textSize: AgoraDeviceAssistant.OS.isPad ? 14 : 9)
        view.layer.cornerRadius = AgoraDeviceAssistant.OS.isPad ? 15 : 10
        return view
    }()
    fileprivate lazy var audioBtn: AgoraBaseUIButton = {
        let btn = AgoraBaseUIButton(type: .custom)
        btn.addTarget(self, action: #selector(onAudioTouchEvent), for: .touchUpInside)
        btn.setImage(AgoraImageWithName("audio", self.classForCoder), for: .normal)
        btn.setImage(AgoraImageWithName("audio_mute", self.classForCoder), for: .selected)
        return btn
    }()
    fileprivate lazy var videoBtn: AgoraBaseUIButton = {
        let btn = AgoraBaseUIButton(type: .custom)
        btn.addTarget(self, action: #selector(onVideoTouchEvent), for: .touchUpInside)
        btn.setImage(AgoraImageWithName("video", self.classForCoder), for: .normal)
        btn.setImage(AgoraImageWithName("video_mute", self.classForCoder), for: .selected)
        btn.isHidden = true
        return btn
    }()
    fileprivate lazy var scaleBtn: AgoraBaseUIButton = {
        let btn = AgoraBaseUIButton(type: .custom)
        btn.addTarget(self, action: #selector(onScaleTouchEvent), for: .touchUpInside)
        btn.setImage(AgoraImageWithName("scale", self.classForCoder), for: .normal)
        return btn
    }()
    fileprivate lazy var audioEffectView: AgoraBaseView = {
    
        let view = AgoraBaseView()
        view.isHidden = true
        
        for index in 0...3 {
            
            var imgName = "audio_tag_0"

            let imgView = AgoraBaseUIImageView(image:AgoraImageWithName(imgName, self.classForCoder))
            imgView.tag = index + AudioEffectImageTagStart
            view.addSubview(imgView)
        }
        
        return view
    }()
    
    fileprivate weak var defaultLabel: AgoraBaseUILabel?
    fileprivate weak var defaultImageView: AgoraBaseUIImageView?
    fileprivate lazy var defaultView: AgoraBaseView = {
        let view = AgoraBaseView()
        view.backgroundColor = UIColor(red: 222/255.0, green: 244/255.0, blue: 255/255.0, alpha: 1)
        
        let imgView = AgoraBaseUIImageView(image: nil)
        view.addSubview(imgView)
        if AgoraDeviceAssistant.OS.isPad {
            imgView.agora_resize(70, 70)
            imgView.agora_center_x = 0
            imgView.agora_center_y = -23
        } else {
            imgView.agora_resize(40, 40)
            imgView.agora_center_x = 0
            imgView.agora_center_y = -13
        }
        self.defaultImageView = imgView
        
        let label = AgoraBaseUILabel()
        label.text = ""
        label.textAlignment = .center
        label.textColor = UIColor(red: 0/255.0, green: 37/255.0, blue: 145/255.0, alpha: 1)
        view.addSubview(label)
        
        if AgoraDeviceAssistant.OS.isPad {
            label.agora_x = 0
            label.agora_right = 0
            label.agora_height = 12
            label.agora_center_y = 38
            label.font = UIFont.systemFont(ofSize: 17)
        } else {
            label.agora_x = 0
            label.agora_right = 0
            label.agora_height = 10
            label.agora_center_y = 15
            label.font = UIFont.systemFont(ofSize: 10)
        }
        
        self.defaultLabel = label

        return view
    }()
    
    fileprivate let RoundLabelTag: Int = 99
    fileprivate let AudioEffectImageTagStart: Int = 100

    fileprivate var stream: AgoraRTEStream?

    public var userName: String? {
        didSet {
            self.updateUserName(name: userName)
        }
    }
    public var isMin: Bool = false {
        didSet {
            self.resizeView()
        }
    }
    public lazy var videoCanvas: AgoraBaseView = {
        let view = AgoraBaseView()
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initView()
        initLayout()
    }
    
    public func updateView(stream: AgoraRTEStream, cupNum: Int) {
        
        self.stream = stream
        
        if !stream.hasVideo {
            self.defaultView.isHidden = false
            self.defaultLabel?.text = "已关闭摄像头"
            //等待外教进入教室…
            //已关闭摄像头
            //外教已离开教室
            //没有检测到摄像头
            self.defaultImageView?.image = AgoraImageWithName("camera_close", self.classForCoder)
        } else {
            self.defaultView.isHidden = true
        }
        
        self.videoBtn.isSelected = !stream.hasVideo
        self.audioBtn.isSelected = !stream.hasAudio

        let role = stream.userInfo.role
        if (role == .student) {
            self.cupView.isHidden = false
            let cupLabel = self.cupView.viewWithTag(RoundLabelTag) as! AgoraBaseUILabel
            cupLabel.text = cupNum > 99 ? "x99+" : ("x" + String(cupNum))
            cupLabel.sizeToFit()
            let cupSize = cupLabel.frame.size
            let _ = cupLabel.agora_resize(cupSize.width + 1, cupSize.height + 1)

            self.audioBtn.isUserInteractionEnabled = true
            self.videoBtn.isHidden = false
            self.videoBtn.isUserInteractionEnabled = true
            
        } else if (role == .teacher) {
            self.cupView.isHidden = true
            
            self.audioBtn.isUserInteractionEnabled = true
            self.videoBtn.isHidden = true
        }
        
        self.updateUserName(name: stream.userInfo.userName)
    }
    
    fileprivate func updateUserName(name: String?) {
        
        let nameLabel = self.nameView.viewWithTag(RoundLabelTag) as! AgoraBaseUILabel
        nameLabel.text = name
        
        nameLabel.sizeToFit()
        let nameSize = nameLabel.frame.size
        let _ = nameLabel.agora_resize(nameSize.width + 1, nameSize.height + 1)
    }
    
    public func updateAudio(effect: Int) {
        self.audioEffectView.isHidden = false
        
        let totleCount = effect / 4

        for index in 0...3 {
            
            var imgName = "audio_tag_0"
            if (index <= totleCount) {
                imgName = "audio_tag_1"
            }
            
            let imgView = self.audioEffectView.viewWithTag(index + AudioEffectImageTagStart) as! AgoraBaseUIImageView
            imgView.image = AgoraImageWithName(imgName, self.classForCoder)
        
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: UIButton Event
extension AgoraUserView {
 
    @objc fileprivate func onAudioTouchEvent() {
        if self.audioTouchBlock != nil {
            self.audioBtn.isSelected = !self.audioBtn.isSelected
            self.audioTouchBlock?(self.audioBtn.isSelected)
        }
    }
    
    @objc fileprivate func onVideoTouchEvent() {
        if self.videoTouchBlock != nil {
            self.videoBtn.isSelected = !self.videoBtn.isSelected
            self.videoTouchBlock?(self.videoBtn.isSelected)
        }
    }
    
    @objc fileprivate func onScaleTouchEvent() {
        if self.scaleTouchBlock != nil {
            self.isMin = !isMin
            self.scaleTouchBlock?(self.isMin)
        }
    }
}

// MARK: Private
extension AgoraUserView {
    fileprivate func resizeView() {
        if (self.isMin) {
            self.defaultView.isHidden = true
            self.videoCanvas.isHidden = true
            self.cupView.isHidden = true
            self.audioBtn.isHidden = true
            self.videoBtn.isHidden = true
            
            self.audioEffectView.isHidden = true
            
            self.scaleBtn.setImage(AgoraImageWithName("scale_min", self.classForCoder), for: .normal)
            
            self.nameView.backgroundColor = UIColor.clear
            self.nameView.layer.cornerRadius = 0
    
            self.backgroundColor = UIColor(red: 117/255.0, green: 192/255.0, blue: 255/255.0, alpha: 1)
            self.layer.borderColor = UIColor(red: 73/255.0, green: 146/255.0, blue: 207/255.0, alpha: 1).cgColor
            self.layer.cornerRadius = AgoraDeviceAssistant.OS.isPad ? 10 : 5

        } else {
            // check defaultView & cupView & videoBtn
            self.videoCanvas.isHidden = false
            self.defaultView.isHidden = self.stream?.hasVideo ?? false
            self.cupView.isHidden = false
            self.audioBtn.isHidden = !(self.stream?.hasAudio ?? false)
            self.videoBtn.isHidden = !(self.stream?.hasVideo ?? false)
            
            self.scaleBtn.setImage(AgoraImageWithName("scale", self.classForCoder), for: .normal)
            
            let bgColor = UIColor(red: 78/255.0, green: 78/255.0, blue: 78/255.0, alpha: 0.5)
            self.nameView.backgroundColor = bgColor
            self.nameView.layer.cornerRadius = AgoraDeviceAssistant.OS.isPad ? 15 : 10

            self.backgroundColor = UIColor.clear
            self.layer.borderColor = UIColor(red: 117/255.0, green: 192/255.0, blue: 255/255.0, alpha: 1).cgColor
            self.layer.cornerRadius = AgoraDeviceAssistant.OS.isPad ? 20 : 10
        }
    }
    
    fileprivate func initView() {
        
        self.backgroundColor = UIColor.clear
        self.clipsToBounds = true
        self.layer.borderWidth = AgoraDeviceAssistant.OS.isPad ? 4 : 2
        self.layer.borderColor = UIColor(red: 117/255.0, green: 192/255.0, blue: 255/255.0, alpha: 1).cgColor
        self.layer.cornerRadius = AgoraDeviceAssistant.OS.isPad ? 20 : 10
        
        self.addSubview(self.videoCanvas)
        self.addSubview(self.defaultView)
        self.addSubview(self.cupView)
        self.addSubview(self.nameView)
        self.addSubview(self.audioBtn)
        self.addSubview(self.videoBtn)
        self.addSubview(self.scaleBtn)
        self.addSubview(self.audioEffectView)
    }
    fileprivate func initLayout() {
        self.defaultView.agora_move(0, 0)
        self.defaultView.agora_right = 0
        self.defaultView.agora_bottom = 0
        
        self.videoCanvas.agora_move(0, 0)
        self.videoCanvas.agora_right = 0
        self.videoCanvas.agora_bottom = 0
        
        if AgoraDeviceAssistant.OS.isPad {
            self.cupView.agora_x = 10
            self.cupView.agora_y = self.cupView.agora_x
            self.cupView.agora_height = 35

            self.nameView.agora_x = self.cupView.agora_x
            self.nameView.agora_bottom = self.nameView.agora_x
            self.nameView.agora_height = 33
            
            self.audioBtn.agora_right = self.nameView.agora_x
            self.audioBtn.agora_bottom = self.nameView.agora_x
            self.audioBtn.agora_resize(33, 33)
                
            self.videoBtn.agora_right = self.audioBtn.agora_right + self.audioBtn.agora_width + 15
            self.videoBtn.agora_bottom = self.nameView.agora_bottom
            self.videoBtn.agora_resize(self.audioBtn.agora_width, self.audioBtn.agora_height)
            
            self.scaleBtn.agora_y = self.cupView.agora_x
            self.scaleBtn.agora_right = self.cupView.agora_x
            self.scaleBtn.agora_resize(self.cupView.agora_height, self.cupView.agora_height)
            
        } else {
            self.cupView.agora_x = 13
            self.cupView.agora_y = self.cupView.agora_x
            self.cupView.agora_height = 25

            self.nameView.agora_x = self.cupView.agora_x
            self.nameView.agora_bottom = 7
            self.nameView.agora_height = 21
            
            self.audioBtn.agora_right = self.cupView.agora_x
            self.audioBtn.agora_bottom = self.nameView.agora_bottom
            self.audioBtn.agora_resize(25, 25)
                
            self.videoBtn.agora_right = self.audioBtn.agora_right + self.audioBtn.agora_width + 6
            self.videoBtn.agora_bottom = self.nameView.agora_bottom
            self.videoBtn.agora_resize(self.audioBtn.agora_width, self.audioBtn.agora_height)
            
            self.scaleBtn.agora_y = self.cupView.agora_x
            self.scaleBtn.agora_right = self.cupView.agora_x
            self.scaleBtn.agora_resize(self.cupView.agora_height, self.cupView.agora_height)
        }
        
        let audioEffectViewWidth = self.audioBtn.agora_width * 0.6
        let audioEffectImgHeight: CGFloat = AgoraDeviceAssistant.OS.isPad ? 3 : 2
        let audioEffectImgGap: CGFloat = AgoraDeviceAssistant.OS.isPad ? 3 : 2
        for index in 0...3 {
            let imgView = self.audioEffectView.viewWithTag(index + AudioEffectImageTagStart) as! AgoraBaseUIImageView
            
            imgView.agora_resize(audioEffectViewWidth, audioEffectImgHeight)
            imgView.agora_x = 0
            imgView.agora_right = 0
            imgView.agora_bottom = audioEffectImgGap + CGFloat(index * (Int(imgView.agora_height + audioEffectImgGap)))
            if(index == 3) {
                imgView.agora_y = 0
                self.audioEffectView.agora_bottom = self.audioBtn.agora_bottom + self.audioBtn.agora_height + audioEffectImgGap
                self.audioEffectView.agora_right = self.audioBtn.agora_right + (self.audioBtn.agora_width - imgView.agora_width) * 0.5
            }
        }
    }
    
    fileprivate func roundView(bgColor: UIColor, imgName: String, imgSize:CGSize, text: String, textColor: UIColor, textSize: CGFloat) -> AgoraBaseView {
        
        let bg = AgoraBaseView()
        bg.backgroundColor = bgColor
        bg.clipsToBounds = true
        
        var labelX: CGFloat = 0

        let img = AgoraImageWithName(imgName, self.classForCoder)
        if (img != nil) {
            let tag = AgoraBaseUIImageView(image: img)
            bg.addSubview(tag)
            tag.agora_x = 7
            tag.agora_center_y = 0
            let _ = tag.agora_resize(imgSize.width, imgSize.height)
            labelX = imgSize.width + 10

        } else {
            labelX = 7
        }

        let label = AgoraBaseUILabel()
        label.text = text
        label.textColor = textColor
        label.tag = RoundLabelTag
        label.font = UIFont.systemFont(ofSize: textSize)
        bg.addSubview(label)
        
        label.sizeToFit()
        let size = label.frame.size
        
        label.agora_x = labelX
        label.agora_center_y = 0
        label.agora_right = 7
        let _ = label.agora_resize(size.width + 1, size.height + 1)
    
        return bg
    }
}
