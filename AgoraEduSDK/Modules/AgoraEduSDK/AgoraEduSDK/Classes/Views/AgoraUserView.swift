//
//  AgoraUserView.swift
//  AgoraEduSDK
//
//  Created by SRS on 2021/1/27.
//

import UIKit
import EduSDK

@objcMembers public class AgoraUserView: AgoraBaseView {
    
    fileprivate lazy var cupView: AgoraBaseView = {
        let bgColor = UIColor(red: 78/255.0, green: 78/255.0, blue: 78/255.0, alpha: 1)
        let textColor = UIColor(red: 255/255.0, green: 217/255.0, blue: 25/255.0, alpha: 1)
        let view = self.roundView(bgColor: bgColor, imgName: "cup", text: "x0", textColor: textColor, textSize: 10)
        view.layer.cornerRadius = 10
        view.isHidden = true
        return view
    }()
    fileprivate lazy var nameView: AgoraBaseView = {
        let bgColor = UIColor(red: 78/255.0, green: 78/255.0, blue: 78/255.0, alpha: 1)
        let textColor = UIColor(red: 254/255.0, green: 254/255.0, blue: 254/255.0, alpha: 1)
        let view = self.roundView(bgColor: bgColor, imgName: "role-icon", text: "", textColor: textColor, textSize: 10)
        view.layer.cornerRadius = 10
        return view
    }()
    fileprivate lazy var audioBtn: AgoraBaseButton = {
        let btn = AgoraBaseButton(type: .custom)
        btn.addTarget(self, action: #selector(onAudioTouchEvent), for: .touchUpInside)
        btn.setImage(AgoraImageWithName("audio", self.classForCoder), for: .normal)
        return btn
    }()
    fileprivate lazy var videoBtn: AgoraBaseButton = {
        let btn = AgoraBaseButton(type: .custom)
        btn.addTarget(self, action: #selector(onVideoTouchEvent), for: .touchUpInside)
        btn.setImage(AgoraImageWithName("video", self.classForCoder), for: .normal)
        return btn
    }()
    fileprivate lazy var scaleBtn: AgoraBaseButton = {
        let btn = AgoraBaseButton(type: .custom)
        btn.addTarget(self, action: #selector(onScaleTouchEvent), for: .touchUpInside)
        btn.setImage(AgoraImageWithName("scale", self.classForCoder), for: .normal)
        return btn
    }()
    fileprivate var audioEffectView: AgoraBaseView?

    //stu
    fileprivate let RoundLabelTag: Int = 99
//    fileprivate var role: EduRoleType = .student {
//        didSet {
//
//        }
//    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initView()
        initLayout()
    }
    
    func updateView() {
        
        let role = EduRoleType.student
        
        if (role == .student) {
            self.cupView.isHidden = false
            let cupLabel = self.cupView.viewWithTag(RoundLabelTag) as! UILabel
            cupLabel.text = "x99+"
            
            self.audioBtn.isUserInteractionEnabled = true
            self.videoBtn.isHidden = false
            self.videoBtn.isUserInteractionEnabled = true
            
        } else if (role == .teacher) {
            self.cupView.isHidden = true
            
            self.audioBtn.isUserInteractionEnabled = true
            self.videoBtn.isHidden = true
        }
        
        let nameLabel = self.nameView.viewWithTag(RoundLabelTag) as! UILabel
        nameLabel.text = "名字"
        
//        self.audioImgView.image = UIImage(named: "")
//        self.videoImgView.image = UIImage(named: "")
    }
    
    func updateAudioEffect(effect: Int) {
        self.audioEffectView?.removeFromSuperview()
        
        let totleCount = effect / 4
        
        self.audioEffectView = AgoraBaseView()
        self.addSubview(self.audioEffectView!)
        NSLayoutConstraint.activate([
            self.audioEffectView!.bottomAnchor.constraint(equalTo: self.audioBtn.topAnchor),
            self.audioEffectView!.centerXAnchor.constraint(equalTo: self.audioBtn.centerXAnchor),
            self.audioEffectView!.widthAnchor.constraint(equalToConstant: 16),
            self.audioEffectView!.heightAnchor.constraint(equalToConstant: 3 + 4 * 6)
        ])
        
        for index in 0...3 {
            
            var imgName = "audio_tag_0"
            if (index <= totleCount) {
                imgName = "audio_tag_1"
            }
            
            let imgView = UIImageView(image:AgoraImageWithName(imgName, self.classForCoder))
            self.audioEffectView?.addSubview(imgView)
            imgView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                imgView.widthAnchor.constraint(equalToConstant: 16),
                imgView.heightAnchor.constraint(equalToConstant: 3),
                imgView.leftAnchor.constraint(equalTo: self.audioEffectView!.leftAnchor),
                imgView.bottomAnchor.constraint(equalTo: self.audioBtn.topAnchor, constant: CGFloat(3 + index * 6)),
            ])
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: UIButton Event
extension AgoraUserView {
 
    @objc fileprivate func onAudioTouchEvent() {
        
    }
    
    @objc fileprivate func onVideoTouchEvent() {
        
    }
    
    @objc fileprivate func onScaleTouchEvent() {
        
    }
    
}

// MARK: Private
extension AgoraUserView {
    fileprivate func initView() {
        self.addSubview(self.cupView)
        self.addSubview(self.nameView)
        self.addSubview(self.audioBtn)
        self.addSubview(self.videoBtn)
        self.addSubview(self.scaleBtn)
    }
    fileprivate func initLayout() {
        
        self.cupView.x = 6
        self.cupView.y = 8
        self.cupView.height = 29

        self.nameView.x = 6
        self.nameView.bottom = 8
        self.nameView.height = 29

        self.audioBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.audioBtn.widthAnchor.constraint(equalToConstant: 29),
            self.audioBtn.heightAnchor.constraint(equalToConstant: 29),
            self.audioBtn.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10),
            self.audioBtn.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10),
        ])

        self.videoBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.videoBtn.widthAnchor.constraint(equalToConstant: 29),
            self.videoBtn.heightAnchor.constraint(equalToConstant: 29),
            self.videoBtn.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -49),
            self.videoBtn.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10),
        ])
    }
    
    fileprivate func roundView(bgColor: UIColor, imgName: String, text: String, textColor: UIColor, textSize: CGFloat) -> AgoraBaseView {
        
        let bg = AgoraBaseView()
        bg.backgroundColor = bgColor
        bg.clipsToBounds = true
        
        var leftView: UIView

        let img = AgoraImageWithName(imgName, self.classForCoder)
        if (img != nil) {
            let tag = UIImageView(image: img)
            bg.addSubview(tag)
            tag.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                tag.centerYAnchor.constraint(equalTo: bg.centerYAnchor),
                tag.leftAnchor.constraint(equalTo: bg.leftAnchor, constant: 5)
            ])
            leftView = tag

        } else {
            leftView = bg
        }

        let label = UILabel()
        label.text = text
        label.textColor = textColor
        label.tag = RoundLabelTag
        label.font = UIFont.systemFont(ofSize: textSize)
        bg.addSubview(label)
        label.sizeToFit()

        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: bg.centerYAnchor),
            label.leftAnchor.constraint(equalTo: leftView.leftAnchor, constant: 5),
            label.widthAnchor.constraint(equalToConstant: label.frame.width + 1),
            label.heightAnchor.constraint(equalToConstant: label.frame.height + 1),
            label.rightAnchor.constraint(equalTo: bg.rightAnchor, constant: -5),
        ])
        
        return bg
    }
}
