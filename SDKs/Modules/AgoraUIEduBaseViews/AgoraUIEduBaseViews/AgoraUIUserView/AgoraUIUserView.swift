//
//  AgoraUIUserView.swift
//  AgoraUIEduBaseViews
//
//  Created by SRS on 2021/3/11.
//

import AgoraUIBaseViews
import AudioToolbox
import UIKit

public class AgoraUIVideoCanvas: AgoraBaseUIView {
    public var renderingStreamUuid: String?
}

public protocol AgoraUIUserViewDelegate: NSObjectProtocol {
    func userView(_ userView: AgoraUIUserView,
                  didPressAudioButton button: AgoraBaseUIButton,
                  indexOfUserList index: Int)
}

public class AgoraUIUserView: AgoraBaseUIView {
    public enum DeviceState {
        case available, invalid, close
    }
    
    public private(set) lazy var videoCanvas: AgoraUIVideoCanvas =  {
        let view = AgoraUIVideoCanvas()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    public var hiddenRewardView: Bool = false {
        didSet {
            cupView.isHidden = hiddenRewardView
        }
    }
    
    public weak var delegate: AgoraUIUserViewDelegate?
    
    public var index: Int = 0
    public var userUuid: String?
    
    public private(set) lazy var audioBtn: AgoraBaseUIButton = {
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
    
    public private(set) lazy var whiteBoardImageView: AgoraBaseUIImageView =  {
        let image = AgoraKitImage("icon_whiteBoard")
        let view = AgoraBaseUIImageView(image: image)
        view.isHidden = true
        return view
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
}

// MARK: - Update views
public extension AgoraUIUserView {
    // 摄像头状态
    func updateCameraState(_ state: DeviceState,
                           hasStream: Bool) {
        // default_baddevice 摄像头不可用
        // default_close 摄像头关闭
        // default_offline 用户不在线
        // default_novideo 设备打开了，没有视频流
        
        switch state {
        // 摄像头正常
        case .available:
            // 是否有流
            if hasStream {
                defaultView.isHidden = true
            } else {
                defaultView.isHidden = false
                defaultImageView?.image = AgoraKitImage("default_novideo")
            }
        // 摄像头不可用
        case .invalid:
            defaultView.isHidden = false
            defaultImageView?.image = AgoraKitImage("default_baddevice")
        // 摄像头关闭
        case .close:
            defaultView.isHidden = false
            defaultImageView?.image = AgoraKitImage("default_close")
        }
    }
    
    func updateDefaultDeviceState() {
        defaultView.isHidden = false
        defaultImageView?.image = AgoraKitImage("default_offline")
        
        audioBtn.setImage(AgoraKitImage("micro_disable_off"),
                          for: .normal)
        audioEffectView.isHidden = true
    }
    
    func updateMicState(_ state: DeviceState,
                        hasStream: Bool,
                        isLocal: Bool) {
        // micro_disable_off  // 灰色
        // micro_disable_on   // 灰色
        
        // micro_enable_off   // 红色
        // micro_enable_on    // 蓝色
        
        audioBtn.isUserInteractionEnabled = isLocal
        
        switch state {
        // 麦克风正常
        case .available:
            var imageName: String
            
            // 是否有流
            if hasStream {
                // 是否是自己
                imageName = "micro_enable_on"
            } else {
                // 是否是自己
                imageName = "micro_enable_off"
            }
            
            audioBtn.setImage(AgoraKitImage(imageName),
                              for: .normal)
            audioEffectView.isHidden = !hasStream
            
        // 麦克风不可用
        case .invalid, .close:
            let imageName = "micro_disable_off"
            audioBtn.setImage(AgoraKitImage(imageName),
                              for: .normal)
            audioEffectView.isHidden = true
        }
    }
    
    func updateDefaultMicState(isLocal: Bool) {
        // micro_disable_off  // 灰色
        // micro_disable_on   // 灰色
        
        // micro_enable_off   // 红色
        // micro_enable_on    // 蓝色
        
        let imageName = "micro_disable_off"
        audioBtn.setImage(AgoraKitImage(imageName),
                          for: .normal)
        
        audioBtn.isUserInteractionEnabled = isLocal
    }
    
    func updateUserName(name: String) {
        nameLabel.isHidden = true
        
        if name.count > 0 {
            nameLabel.isHidden = false
        }

        self.nameLabel.text = name

        nameLabel.agora_x = audioBtn.agora_x + audioBtn.agora_width + 2
        
        let nameAgoraRight: CGFloat = whiteBoardImageView.isHidden ? 0 : 20

        let maxWidth: CGFloat = 75
        let nameWidth = frame.size.width - nameLabel.agora_x - nameAgoraRight
        nameLabel.agora_width = maxWidth > nameWidth ? nameWidth : maxWidth
    }
    
    func updateAudio(effect: Int) {
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
    
    func updateUserReward(count: Int) {
        let label = self.cupView.viewWithTag(RoundLabelTag) as! AgoraBaseUILabel
        label.text = "x\(count)"
        hiddenRewardView = (count == 0)
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
        
        self.nameLabel.agora_x = self.audioBtn.agora_x + self.audioBtn.agora_width + 2
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
