//
//  AgoraUIUserView.swift
//  AgoraUIEduBaseViews
//
//  Created by SRS on 2021/3/11.
//

import AgoraUIBaseViews
import AudioToolbox
import AgoraEduContext

public class AgoraUIVideoCanvas: AgoraBaseUIView {
    public var renderingStreamUuid: String?
}

public protocol AgoraUIUserViewDelegate: NSObjectProtocol {
    func userView(_ userView: AgoraUIUserView,
                  didPressAudioButton button: AgoraBaseUIButton,
                  indexOfUserList index: Int)
    
    func userView(_ userView: AgoraUIUserView,
                  didPressVideoButton button: AgoraBaseUIButton,
                  indexOfUserList index: Int)
}

@objcMembers public class AgoraUIUserView: AgoraBaseUIView {
    public private(set) lazy var videoCanvas: AgoraUIVideoCanvas =  {
        let view = AgoraUIVideoCanvas()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    public var hiddenRewardView: Bool = false {
        didSet {
            self.cupView.isHidden = hiddenRewardView
        }
    }
    
    public weak var delegate: AgoraUIUserViewDelegate?
    
    public var index: Int = 0
    
    private(set) lazy var audioBtn: AgoraBaseUIButton = {
        let btn = AgoraBaseUIButton(type: .custom)
        btn.touchRange = 20
        btn.addTarget(self,
                      action: #selector(onAudioTouchEvent(_:)),
                      for: .touchUpInside)
        btn.setImage(AgoraKitImage("micro_disable_off"),
                     for: .normal)
        btn.isUserInteractionEnabled = false
        return btn
    }()
    
    private(set) lazy var videoBtn: AgoraBaseUIButton = {
        let btn = AgoraBaseUIButton()
        btn.touchRange = 20
        btn.addTarget(self,
                      action: #selector(onVideoTouchEvent(_:)),
                      for: .touchUpInside)
        btn.setImage(AgoraKitImage("camera_disable_off"),
                     for: .normal)
        btn.isHidden = true
        return btn
    }()
    
    private lazy var cupView: AgoraBaseUIView = {
        let bg = AgoraBaseUIView()
        bg.isHidden = true
        
        let label = AgoraBaseUILabel()
        label.text = "x0"
        label.textColor = UIColor.white
        label.tag = RoundLabelTag
        label.font = UIFont.systemFont(ofSize: 11)
        label.layer.shadowColor = UIColor(rgb: 0x0D1D3D, alpha: 0.8).cgColor
        label.layer.shadowOffset = CGSize(width: 0, height: 1)
        label.layer.shadowOpacity = 1
        label.layer.shadowRadius = 2
        label.textAlignment = .right
        bg.addSubview(label)
        
        label.agora_right = 3
        label.agora_center_y = 0
        label.agora_width = 20
        label.agora_height = 15
        
        let img = AgoraKitImage("star")
        let tag = AgoraBaseUIImageView(image: img)
        bg.addSubview(tag)
        let imgSize = AgoraKitDeviceAssistant.OS.isPad ? CGSize(width: 22, height: 22) : CGSize(width: 13, height: 13)
        tag.agora_right = label.agora_right + 15 + 3
        tag.agora_center_y = 0
        tag.agora_resize(imgSize.width, imgSize.height)
        tag.agora_x = 0
        
        return bg
    }()
    
    private lazy var nameLabel: AgoraBaseUILabel =  {
        let label = AgoraBaseUILabel()
        label.text = ""
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 12)
        label.layer.shadowColor = UIColor(rgb: 0x0D1D3D, alpha: 0.8).cgColor
        label.layer.shadowOffset = CGSize(width: 0, height: 1)
        label.layer.shadowOpacity = 1
        label.layer.shadowRadius = 2
        return label
    }()
    
    private lazy var audioEffectView: AgoraBaseUIView =  {
        let view = AgoraBaseUIView()
        view.isHidden = true
        for index in 0...7 {
            let v = AgoraBaseUIView()
            v.backgroundColor = UIColor(rgb: 0x357BF6)
            v.tag = index + AudioEffectTagStart
            view.addSubview(v)
        }
        return view
    }()
    
    private lazy var whiteBoardImageView: AgoraBaseUIImageView =  {
        let image = AgoraKitImage("icon_whiteBoard")
        let view = AgoraBaseUIImageView(image: image)
        view.isHidden = true
        return view
    }()

    private lazy var defaultView: AgoraBaseUIView =  {
        let view = AgoraBaseUIView()
        view.backgroundColor = UIColor(rgb: 0xF9F9FC)
        
        let imgView = AgoraBaseUIImageView(image: AgoraKitImage("default_offline"))
        view.addSubview(imgView)
        if AgoraKitDeviceAssistant.OS.isPad {
            imgView.agora_resize(70, 70)
            imgView.agora_center_x = 0
            imgView.agora_center_y = 0
        } else {
            imgView.agora_resize(45, 45)
            imgView.agora_center_x = 0
            imgView.agora_center_y = 0
        }
        self.defaultImageView = imgView
    
        return view
    }()
    
    private weak var defaultImageView: AgoraBaseUIImageView?
    private let RoundLabelTag: Int = 99
    private let AudioEffectTagStart: Int = 100
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
        initLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var isVideoButtonHidden = false
    
    func setVideoButtonHidden(hidden: Bool) {
        isVideoButtonHidden = hidden
    }
    
    // MARK: touch event
    @objc  func onAudioTouchEvent(_ button: AgoraBaseUIButton) {
        delegate?.userView(self,
                           didPressAudioButton: button,
                           indexOfUserList: index)
    }
    
    @objc func onVideoTouchEvent(_ button: AgoraBaseUIButton) {
        delegate?.userView(self,
                           didPressVideoButton: button,
                           indexOfUserList: index)
    }
}

// MARK: - Private
private extension AgoraUIUserView {
     func initView() {
        backgroundColor = UIColor.clear
        clipsToBounds = true
        layer.borderWidth = AgoraKitDeviceAssistant.OS.isPad ? 2 : 1
        layer.borderColor = UIColor(rgb: 0xECECF1).cgColor
        layer.cornerRadius = AgoraKitDeviceAssistant.OS.isPad ? 10 : 4
        
        addSubview(videoCanvas)
        addSubview(defaultView)
        addSubview(cupView)
        addSubview(audioBtn)
        addSubview(videoBtn)
        addSubview(nameLabel)
        addSubview(audioEffectView)
        addSubview(whiteBoardImageView)
    }
    
    func initLayout() {
        self.defaultView.agora_move(0, 0)
        self.defaultView.agora_right = 0
        self.defaultView.agora_bottom = 0
        
        self.videoCanvas.agora_move(0, 0)
        self.videoCanvas.agora_right = 0
        self.videoCanvas.agora_bottom = 0
        
        self.cupView.agora_right = 5
        self.cupView.agora_y = 5
        self.cupView.agora_height = 15

        self.audioBtn.agora_x = 5
        self.audioBtn.agora_bottom = 5
        self.audioBtn.agora_resize(18, 18)
        
        self.videoBtn.agora_x = self.audioBtn.agora_x + self.audioBtn.agora_width + 2
        self.videoBtn.agora_bottom = 5
        self.videoBtn.agora_resize(18, 18)
        
        self.nameLabel.agora_x = self.videoBtn.agora_x + self.videoBtn.agora_width + 2
        self.nameLabel.agora_width = 75
        self.nameLabel.agora_bottom = self.audioBtn.agora_bottom
        self.nameLabel.agora_height = 18
        
        whiteBoardImageView.agora_right = 5
        whiteBoardImageView.agora_bottom = 5
        whiteBoardImageView.agora_resize(18, 18)
        
        let audioEffectViewWidth = self.audioBtn.agora_width * 0.8
        let audioEffectHeight: CGFloat = AgoraKitDeviceAssistant.OS.isPad ? 3 : 2
        let audioEffectGap: CGFloat = AgoraKitDeviceAssistant.OS.isPad ? 3 : 2
        for index in 0...7 {
            let v = self.audioEffectView.viewWithTag(index + AudioEffectTagStart) as! AgoraBaseUIView
            
            v.agora_resize(audioEffectViewWidth, audioEffectHeight)
            v.agora_x = 0
            v.agora_right = 0
            v.agora_bottom = audioEffectGap + CGFloat(index * (Int(v.agora_height + audioEffectGap)))
            
            guard index == 7 else {
                continue
            }
            
            v.agora_y = 0
            self.audioEffectView.agora_bottom = self.audioBtn.agora_bottom + self.audioBtn.agora_height + audioEffectGap
            self.audioEffectView.agora_x = self.audioBtn.agora_x + (self.audioBtn.agora_width - v.agora_width) * 0.5
        }
    }
}

// MARK: - Update views
private extension AgoraUIUserView {
    func updateUserName(userInfo: AgoraEduContextUserDetailInfo?) {
        self.nameLabel.isHidden = true
        
        guard let info = userInfo else {
            return
        }
        
        let name = info.user.userName
        
        if name.count > 0 {
            self.nameLabel.isHidden = false
        }

        self.nameLabel.text = name

        if isVideoButtonHidden {
            self.nameLabel.agora_x = self.audioBtn.agora_x + self.audioBtn.agora_width + 2
        } else {
            self.nameLabel.agora_x = self.videoBtn.agora_x + self.videoBtn.agora_width + 2
        }

        let nameAgoraRight: CGFloat = info.boardGranted ? 20 : 0

        let maxWidth: CGFloat = 75
        let nameWidth = self.frame.size.width - self.nameLabel.agora_x - nameAgoraRight
        self.nameLabel.agora_width = maxWidth > nameWidth ? nameWidth : maxWidth
    }
    
    func updateDefaultView(userInfo: AgoraEduContextUserDetailInfo?) {
        self.audioBtn.setImage(AgoraKitImage("micro_disable_off"),
                               for: .normal)
        self.videoBtn.setImage(AgoraKitImage("camera_disable_off"),
                               for: .normal)
        self.audioBtn.isUserInteractionEnabled = false
        self.videoBtn.isUserInteractionEnabled = false
        self.audioBtn.isHidden = false
        self.videoBtn.isHidden = true
        self.isVideoButtonHidden = true
        
        self.audioEffectView.isHidden = true
        self.defaultView.isHidden = true
        
        // offline
        guard let info = userInfo else {
            self.defaultView.isHidden = false
            self.defaultImageView?.image = AgoraKitImage("default_offline")
            return
        }
        
        let user = info.user
        
        // 学生才显示视频按钮
        if user.role == .student {
            self.videoBtn.isHidden = false
            self.isVideoButtonHidden = false
        }
        
        // 不在线
        if !info.onLine {
            self.defaultView.isHidden = false
            self.defaultImageView?.image = AgoraKitImage("default_offline")
            return
        }
        
        // 摄像头状态
        if info.cameraState == .close {
            self.defaultView.isHidden = false
            self.defaultImageView?.image = AgoraKitImage("default_close")
            
        } else if info.cameraState == .notAvailable {
            self.defaultView.isHidden = false
            self.defaultImageView?.image = AgoraKitImage("default_baddevice")
            
        } else if info.enableVideo { // 摄像头好的 & 开流了
            self.videoBtn.isUserInteractionEnabled = true
            let imgName = "camera_enable_on"
            self.videoBtn.setImage(AgoraKitImage(imgName),
                                   for: .normal)
            
        } else { // // 摄像头好的 & 没有开流
            
            self.defaultView.isHidden = false
            self.defaultImageView?.image = AgoraKitImage("default_novideo")
            
            self.videoBtn.isUserInteractionEnabled = true
            let imgName = "camera_enable_off"
            self.videoBtn.setImage(AgoraKitImage(imgName),
                                   for: .normal)
        }
        
        // 麦克风状态
        if info.microState == .available {
            self.audioBtn.isUserInteractionEnabled = true
            let imgName = info.enableAudio ? "micro_enable_on" : "micro_enable_off"
            self.audioBtn.setImage(AgoraKitImage(imgName),
                                   for: .normal)
        }
    }
    
    func updateBoardView(userInfo: AgoraEduContextUserDetailInfo?) {
        whiteBoardImageView.isHidden = true
        
        guard let info = userInfo else {
            return
        }
        let user = info.user
        if user.role == AgoraEduContextUserRole.student {
            whiteBoardImageView.isHidden = !info.boardGranted
        }
    }
}

extension AgoraUIUserView {
    public func update(with info: AgoraEduContextUserDetailInfo?) {
        self.updateDefaultView(userInfo: info)
        self.updateUserName(userInfo: info)
        self.updateUserReward(userInfo: info)
        self.updateBoardView(userInfo: info)
    }
    
    fileprivate func updateUserReward(userInfo: AgoraEduContextUserDetailInfo?) {
        let label = self.cupView.viewWithTag(RoundLabelTag) as! AgoraBaseUILabel
        label.text = "x0"

        guard let info = userInfo else {
            return
        }
        label.text = "x\(info.rewardCount)"
        hiddenRewardView = (info.rewardCount == 0)
    }
    
    public func updateAudio(effect: Int) {
        self.audioEffectView.isHidden = false

        let totleCount = effect / 30 + (effect % 30 > 0 ? 1 : 0)

        for index in 0...7 {
            let v = self.audioEffectView.viewWithTag(index + AudioEffectTagStart) as! AgoraBaseUIView
            v.isHidden = true

            if (index <= totleCount) {
                v.isHidden = false
            }
        }
    }
}
