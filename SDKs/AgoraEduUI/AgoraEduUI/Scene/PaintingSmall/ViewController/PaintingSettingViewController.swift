//
//  PaintingSettingViewController.swift
//  AgoraEduUI
//
//  Created by HeZhengQing on 2021/9/25.
//

import UIKit
import SwifterSwift
import AgoraEduContext
import AgoraUIEduBaseViews

class PaintingSettingViewController: UIViewController {
    
    var contentView: UIView!
    
    var cameraLabel: UILabel!
    
    var cameraSwitch: UISwitch!
    
    var directionLabel: UILabel!
    
    var frontCamButton: UIButton!
    
    var backCamButton: UIButton!
    
    var sepLine: UIView!
    
    var micLabel: UILabel!
    
    var micSwitch: UISwitch!
    
    var audioLabel: UILabel!
    
    var audioSwitch: UISwitch!
    
    var uploadLogButton: UIButton!
    
    var exitButton: UIButton!
    /** SDK环境*/
    var contextPool: AgoraEduContextPool!
    
    deinit {
        print("\(#function): \(self.classForCoder)")
    }
    
    init(context: AgoraEduContextPool) {
        super.init(nibName: nil, bundle: nil)
        contextPool = context
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createViews()
        createConstrains()
    }
}
// MARK: - Actions
private extension PaintingSettingViewController {
    @objc func onClickCameraSwitch(_ sender: UISwitch) {
        print("sender: \(sender.isOn)")
    }
    
    @objc func onClickMicSwitch(_ sender: UISwitch) {
        print("sender: \(sender.isOn)")
    }
    
    @objc func onClickAudioSwitch(_ sender: UISwitch) {
        print("sender: \(sender.isOn)")
    }
    
    @objc func onClickUploadLog(_ sender: UIButton) {
        
    }
    
    @objc func onClickExit(_ sender: UIButton) {
        
    }
    
    @objc func onClickFrontCamera(_ sender: UIButton) {
        sender.isSelected = true
        backCamButton.isSelected = false
    }
    
    @objc func onClickBackCamera(_ sender: UIButton) {
        sender.isSelected = true
        frontCamButton.isSelected = false
    }
}

// MARK: - Creations
private extension PaintingSettingViewController {
    func createViews() {
        view.layer.shadowColor = UIColor(rgb: 0x2F4192,
                                         alpha: 0.15).cgColor
        view.layer.shadowOffset = CGSize(width: 0,
                                         height: 2)
        view.layer.shadowOpacity = 1
        view.layer.shadowRadius = 6
        
        contentView = UIView()
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 10.0
        contentView.clipsToBounds = true
        view.addSubview(contentView)
        
        cameraLabel = UILabel(frame: .zero)
        cameraLabel.text = AgoraKitLocalizedString("CameraText")
        cameraLabel.font = UIFont.systemFont(ofSize: 12)
        cameraLabel.textColor = UIColor(rgb: 0x191919)
        view.addSubview(cameraLabel)
        
        cameraSwitch = UISwitch()
        cameraSwitch.onTintColor = UIColor(rgb: 0x357BF6)
        cameraSwitch.transform = CGAffineTransform(scaleX: 0.75,
                                                   y: 0.75)
        cameraSwitch.addTarget(self,
                               action: #selector(onClickCameraSwitch(_:)),
                               for: .touchUpInside)
        view.addSubview(cameraSwitch)
        
        directionLabel = UILabel(frame: .zero)
        directionLabel.text = AgoraKitLocalizedString("DirectionText")
        directionLabel.font = UIFont.systemFont(ofSize: 12)
        directionLabel.textColor = UIColor(rgb: 0x677386)
        view.addSubview(directionLabel)
        
        frontCamButton = UIButton(type: .custom)
        frontCamButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        frontCamButton.setTitleColor(.white,
                                     for: .selected)
        frontCamButton.setTitleColor(UIColor(rgb: 0xB5B5C9),
                                     for: .normal)
        frontCamButton.setTitle(AgoraKitLocalizedString("FrontText"),
                                for: .normal)
        frontCamButton.setBackgroundImage(UIImage(color: UIColor(rgb: 0xF4F4F8),
                                                  size: CGSize(width: 1,
                                                               height: 1)),
                                          for: .normal)
        frontCamButton.setBackgroundImage(UIImage(color: UIColor(rgb: 0x7B88A0),
                                                  size: CGSize(width: 1,
                                                               height: 1)),
                                          for: .selected)
        frontCamButton.addTarget(self,
                                 action: #selector(onClickFrontCamera(_:)),
                                 for: .touchUpInside)
        frontCamButton.layer.cornerRadius = 4
        frontCamButton.clipsToBounds = true
        view.addSubview(frontCamButton)
        
        backCamButton = UIButton(type: .custom)
        backCamButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        backCamButton.setTitleColor(.white,
                                    for: .selected)
        backCamButton.setTitleColor(UIColor(rgb: 0xB5B5C9),
                                    for: .normal)
        backCamButton.setBackgroundImage(UIImage(color: UIColor(rgb: 0xF4F4F8),
                                                 size: CGSize(width: 1,
                                                              height: 1)),
                                         for: .normal)
        backCamButton.setBackgroundImage(UIImage(color: UIColor(rgb: 0x7B88A0),
                                                 size: CGSize(width: 1,
                                                              height: 1)),
                                         for: .selected)
        backCamButton.setTitle(AgoraKitLocalizedString("BackText"),
                               for: .normal)
        backCamButton.addTarget(self,
                                action: #selector(onClickBackCamera(_:)),
                                for: .touchUpInside)
        backCamButton.layer.cornerRadius = 4
        backCamButton.clipsToBounds = true
        view.addSubview(backCamButton)
        
        sepLine = UIView(frame: .zero)
        sepLine.backgroundColor = UIColor(rgb: 0xECECF1)
        view.addSubview(sepLine)
        
        micLabel = UILabel(frame: .zero)
        micLabel.text = AgoraKitLocalizedString("MicrophoneText")
        micLabel.font = UIFont.systemFont(ofSize: 12)
        micLabel.textColor = UIColor(rgb: 0x191919)
        view.addSubview(micLabel)
        
        micSwitch = UISwitch()
        micSwitch.onTintColor = UIColor(rgb: 0x357BF6)
        micSwitch.transform = CGAffineTransform(scaleX: 0.75,
                                                y: 0.75)
        micSwitch.addTarget(self,
                            action: #selector(onClickCameraSwitch(_:)),
                            for: .touchUpInside)
        view.addSubview(micSwitch)
        
        audioLabel = UILabel(frame: .zero)
        audioLabel.text = AgoraKitLocalizedString("SpeakerText")
        audioLabel.font = UIFont.systemFont(ofSize: 12)
        audioLabel.textColor = UIColor(rgb: 0x191919)
        view.addSubview(audioLabel)
        
        audioSwitch = UISwitch()
        audioSwitch.onTintColor = UIColor(rgb: 0x357BF6)
        audioSwitch.transform = CGAffineTransform(scaleX: 0.75,
                                                  y: 0.75)
        audioSwitch.addTarget(self,
                              action: #selector(onClickCameraSwitch(_:)),
                              for: .touchUpInside)
        view.addSubview(audioSwitch)
        
        let attrs = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize:12.0),
            NSAttributedString.Key.foregroundColor: UIColor(rgb: 0x191919),
            NSAttributedString.Key.underlineStyle: 1] as [NSAttributedString.Key : Any]
        let str = NSMutableAttributedString(string: AgoraKitLocalizedString("upload_log"),
                                            attributes: attrs)
        uploadLogButton = UIButton(type: .custom)
        uploadLogButton.setAttributedTitle(str,
                                           for: .normal)
        uploadLogButton.addTarget(self,
                                  action: #selector(onClickUploadLog(_:)),
                                  for: .touchUpInside)
        view.addSubview(uploadLogButton)
        
        exitButton = UIButton(type: .custom)
        exitButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        exitButton.setTitleColor(.white,
                                 for: .normal)
        exitButton.setTitle(AgoraKitLocalizedString("LeaveText"),
                            for: .normal)
        exitButton.addTarget(self,
                             action: #selector(onClickExit(_:)),
                             for: .touchUpInside)
        exitButton.backgroundColor = UIColor(rgb: 0x191919)
        exitButton.layer.cornerRadius = 6
        exitButton.clipsToBounds = true
        view.addSubview(exitButton)
    }
    
    func createConstrains() {
        contentView.snp.makeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()
        }
        cameraLabel.snp.makeConstraints { make in
            make.top.left.equalTo(16)
        }
        cameraSwitch.snp.makeConstraints { make in
            make.right.equalTo(-16)
            make.width.equalTo(40)
            make.height.equalTo(20)
            make.centerY.equalTo(cameraLabel).offset(-5)
        }
        directionLabel.snp.makeConstraints { make in
            make.left.equalTo(cameraLabel)
            make.top.equalTo(cameraLabel.snp.bottom).offset(20)
        }
        frontCamButton.snp.makeConstraints { make in
            make.width.equalTo(40)
            make.height.equalTo(22)
            make.right.equalTo(cameraSwitch)
            make.centerY.equalTo(directionLabel)
        }
        backCamButton.snp.makeConstraints { make in
            make.width.equalTo(40)
            make.height.equalTo(22)
            make.right.equalTo(frontCamButton.snp.left).offset(-5)
            make.centerY.equalTo(frontCamButton)
        }
        sepLine.snp.makeConstraints { make in
            make.top.equalTo(directionLabel.snp.bottom).offset(17)
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.height.equalTo(1)
        }
        micLabel.snp.makeConstraints { make in
            make.left.equalTo(cameraLabel)
            make.top.equalTo(sepLine.snp.bottom).offset(16)
        }
        micSwitch.snp.makeConstraints { make in
            make.right.equalTo(-16)
            make.width.equalTo(40)
            make.height.equalTo(20)
            make.centerY.equalTo(micLabel).offset(-5)
        }
        audioLabel.snp.makeConstraints { make in
            make.left.equalTo(cameraLabel)
            make.top.equalTo(micLabel.snp.bottom).offset(18)
        }
        audioSwitch.snp.makeConstraints { make in
            make.right.equalTo(-16)
            make.width.equalTo(40)
            make.height.equalTo(20)
            make.centerY.equalTo(audioLabel).offset(-5)
        }
        exitButton.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.height.equalTo(30)
            make.bottom.equalTo(-16)
        }
        uploadLogButton.snp.makeConstraints { make in
            make.right.equalTo(cameraSwitch)
            make.height.equalTo(20)
            make.bottom.equalTo(exitButton.snp.top).offset(-30)
        }
    }
}
