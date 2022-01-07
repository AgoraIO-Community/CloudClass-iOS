//
//  KickOutAlertController.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2021/11/3.
//

import UIKit
import Masonry

class AgoraKickOutAlertController: UIViewController {
    
    private var contentView: UIView!
    
    private var titleLable: UILabel!
    
    private var cancelButton: UIButton!
    
    private var submitButton: UIButton!
    
    private var hLine: UIView!
    
    private var vLine: UIView!
    
    private var firstButton: UIButton!
    
    private var firstLabel: UILabel!
    
    private var seconedButton: UIButton!
    
    private var seconedLabel: UILabel!
    
    private var onComplete: ((_ forever: Bool) -> Void)?
    
    private var onCancel: (() -> Void)?
    
    private var kickForever: Bool = false {
        didSet {
            if kickForever {
                firstButton.isSelected = false
                firstLabel.textColor = UIColor(hex: 0x586376)
                seconedButton.isSelected = true
                seconedLabel.textColor = UIColor(hex: 0x191919)
            } else {
                firstButton.isSelected = true
                firstLabel.textColor = UIColor(hex: 0x191919)
                seconedButton.isSelected = false
                seconedLabel.textColor = UIColor(hex: 0x586376)
            }
        }
    }
    
    public class func present(by viewController: UIViewController, onComplete: ((_ forever: Bool) -> Void)?, onCancel: (() -> Void)?) {
        let vc = AgoraKickOutAlertController()
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        vc.onComplete = onComplete
        vc.onCancel = onCancel
        viewController.present(vc, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        createViews()
        createConstrains()
    }
}
// MARK: - Actions
private extension AgoraKickOutAlertController {
    @objc func onClickSubmit(_ sender: UIButton) {
        onComplete?(self.kickForever)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func onClickCancel(_ sender: UIButton) {
        onCancel?()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func onClickFirstButton(_ sender: UIButton) {
        self.kickForever = false
    }
    
    @objc func onClickSecondButton(_ sender: UIButton) {
        self.kickForever = true
    }
}
// MARK: - Creation
extension AgoraKickOutAlertController {
    func createViews() {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        
        contentView = UIView()
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 12
        contentView.layer.shadowOpacity = 1
        contentView.layer.shadowRadius = 6
        contentView.layer.shadowColor = UIColor(hex: 0x2F4192,
                                                transparency: 0.15)?.cgColor
        contentView.layer.shadowOffset = CGSize(width: 0,
                                                height: 2)
        self.view.addSubview(contentView)
        
        titleLable = UILabel()
        titleLable.textColor = UIColor(hex: 0x030303)
        titleLable.textAlignment = .center
        titleLable.text = "kick_out_student".agedu_localized()
        titleLable.font = UIFont.systemFont(ofSize: 17)
        contentView.addSubview(titleLable)
        
        firstButton = UIButton(type: .custom)
        firstButton.isSelected = true
        firstButton.addTarget(self,
                              action: #selector(onClickFirstButton(_:)),
                              for: .touchUpInside)
        firstButton.setImage(UIImage.agedu_named("ic_nameroll_ckeck_box_off"),
                             for: .normal)
        firstButton.setImage(UIImage.agedu_named("ic_nameroll_ckeck_box_on"),
                             for: .selected)
        contentView.addSubview(firstButton)
        
        firstLabel = UILabel()
        firstLabel.textColor = UIColor(hex: 0x191919)
        firstLabel.text = "kick_out_once".agedu_localized()
        firstLabel.font = UIFont.systemFont(ofSize: 13)
        contentView.addSubview(firstLabel)
        
        seconedButton = UIButton(type: .custom)
        seconedButton.isSelected = false
        seconedButton.addTarget(self,
                                action: #selector(onClickSecondButton(_:)),
                                for: .touchUpInside)
        seconedButton.setImage(UIImage.agedu_named("ic_nameroll_ckeck_box_off"),
                               for: .normal)
        seconedButton.setImage(UIImage.agedu_named("ic_nameroll_ckeck_box_on"),
                               for: .selected)
        contentView.addSubview(seconedButton)
        
        seconedLabel = UILabel()
        seconedLabel.textColor = UIColor(hex: 0x586376)
        seconedLabel.text = "kick_out_forever".agedu_localized()
        seconedLabel.font = UIFont.systemFont(ofSize: 13)
        contentView.addSubview(seconedLabel)
        
        vLine = UIView()
        vLine.backgroundColor = UIColor(hex: 0xEEEEF7)
        contentView.addSubview(vLine)
        
        hLine = UIView()
        hLine.backgroundColor = UIColor(hex: 0xEEEEF7)
        contentView.addSubview(hLine)
        
        submitButton = UIButton(type: .system)
        submitButton.addTarget(self,
                               action: #selector(onClickSubmit(_:)),
                               for: .touchUpInside)
        submitButton.setTitle("kick_out_submit".agedu_localized(),
                              for: .normal)
        contentView.addSubview(submitButton)
        
        cancelButton = UIButton(type: .system)
        cancelButton.addTarget(self,
                               action: #selector(onClickCancel(_:)),
                               for: .touchUpInside)
        cancelButton.setTitle("kick_out_cancel".agedu_localized(),
                              for: .normal)
        contentView.addSubview(cancelButton)
    }
    
    func createConstrains() {
        contentView.mas_makeConstraints { make in
            make?.center.equalTo()(0)
            make?.width.equalTo()(270)
            make?.height.equalTo()(179)
        }
        titleLable.mas_makeConstraints { make in
            make?.top.equalTo()(20)
            make?.left.right().equalTo()(0)
        }
        firstButton.mas_makeConstraints { make in
            make?.width.height().equalTo()(34)
            make?.top.equalTo()(titleLable.mas_bottom)?.offset()(8)
            make?.left.equalTo()(16)
        }
        firstLabel.mas_makeConstraints { make in
            make?.left.equalTo()(firstButton.mas_right)?.offset()(4)
            make?.centerY.equalTo()(firstButton)
        }
        seconedButton.mas_makeConstraints { make in
            make?.width.height().equalTo()(34)
            make?.top.equalTo()(firstButton.mas_bottom)
            make?.left.equalTo()(16)
        }
        seconedLabel.mas_makeConstraints { make in
            make?.left.equalTo()(seconedButton.mas_right)?.offset()(4)
            make?.centerY.equalTo()(seconedButton)
        }
        vLine.mas_makeConstraints { make in
            make?.bottom.centerX().equalTo()(0)
            make?.height.equalTo()(45)
            make?.width.equalTo()(1)
        }
        hLine.mas_makeConstraints { make in
            make?.left.right().equalTo()(0)
            make?.height.equalTo()(1)
            make?.bottom.equalTo()(vLine.mas_top)
        }
        submitButton.mas_makeConstraints { make in
            make?.right.bottom().equalTo()(0)
            make?.top.equalTo()(hLine.mas_bottom)
            make?.left.equalTo()(vLine.mas_right)
        }
        cancelButton.mas_makeConstraints { make in
            make?.left.bottom().equalTo()(0)
            make?.top.equalTo()(hLine.mas_bottom)
            make?.right.equalTo()(vLine.mas_left)
        }
    }
}
