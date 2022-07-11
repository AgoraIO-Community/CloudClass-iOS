//
//  KickOutAlertController.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2021/11/3.
//

import Masonry
import UIKit

class AgoraKickOutAlertController: UIViewController {
    
    private lazy var contentView = UIView()
    
    private lazy var titleLable = UILabel()
    
    private lazy var cancelButton = UIButton(type: .system)
    
    private lazy var submitButton = UIButton(type: .system)
    
    private lazy var hLine = UIView()
    
    private lazy var vLine = UIView()
    
    private lazy var firstButton = UIButton(type: .custom)
    
    private lazy var firstLabel = UILabel()
    
    private lazy var seconedButton = UIButton(type: .custom)
    
    private lazy var seconedLabel = UILabel()
    
    private var onComplete: ((_ forever: Bool) -> Void)?
    
    private var onCancel: (() -> Void)?
    
    private var kickForever: Bool = false {
        didSet {
            let color_one = FcrColorGroup.fcr_text_level1_color
            let color_two = FcrColorGroup.fcr_text_level2_color
            if kickForever {
                firstButton.isSelected = false
                firstLabel.textColor = color_two
                seconedButton.isSelected = true
                seconedLabel.textColor = color_one
            } else {
                firstButton.isSelected = true
                firstLabel.textColor = color_one
                seconedButton.isSelected = false
                seconedLabel.textColor = color_two
            }
        }
    }
    
    public class func present(by viewController: UIViewController,
                              onComplete: ((_ forever: Bool) -> Void)?,
                              onCancel: (() -> Void)?) {
        let vc = AgoraKickOutAlertController()
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        vc.onComplete = onComplete
        vc.onCancel = onCancel
        viewController.present(vc, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initViews()
        initViewFrame()
        updateViewProperties()
    }
}
// MARK: - Actions
private extension AgoraKickOutAlertController {
    @objc func onClickSubmit(_ sender: UIButton) {
        onComplete?(kickForever)
        dismiss(animated: true,
                completion: nil)
    }
    
    @objc func onClickCancel(_ sender: UIButton) {
        onCancel?()
        dismiss(animated: true,
                completion: nil)
    }
    
    @objc func onClickFirstButton(_ sender: UIButton) {
        kickForever = false
    }
    
    @objc func onClickSecondButton(_ sender: UIButton) {
        kickForever = true
    }
}
// MARK: - AgoraUIContentContainer
extension AgoraKickOutAlertController: AgoraUIContentContainer {
    func initViews() {
        view.addSubview(contentView)

        titleLable.textAlignment = .center
        titleLable.text = "fcr_user_kick_out".agedu_localized()
        
        contentView.addSubview(titleLable)
        
        firstButton.isSelected = true
        firstButton.addTarget(self,
                              action: #selector(onClickFirstButton(_:)),
                              for: .touchUpInside)
        firstButton.setImage(UIImage.agedu_named("ic_nameroll_ckeck_box_off"),
                             for: .normal)
        firstButton.setImage(UIImage.agedu_named("ic_nameroll_ckeck_box_on"),
                             for: .selected)
        contentView.addSubview(firstButton)
        
        firstLabel.text = "fcr_user_kick_out_once".agedu_localized()
        contentView.addSubview(firstLabel)
        
        seconedButton.isSelected = false
        seconedButton.addTarget(self,
                                action: #selector(onClickSecondButton(_:)),
                                for: .touchUpInside)
        seconedButton.setImage(UIImage.agedu_named("ic_nameroll_ckeck_box_off"),
                               for: .normal)
        seconedButton.setImage(UIImage.agedu_named("ic_nameroll_ckeck_box_on"),
                               for: .selected)
        contentView.addSubview(seconedButton)
        
        seconedLabel.text = "fcr_user_kick_out_forever".agedu_localized()
        contentView.addSubview(seconedLabel)
        
        contentView.addSubview(vLine)
        
        contentView.addSubview(hLine)
        
        submitButton.addTarget(self,
                               action: #selector(onClickSubmit(_:)),
                               for: .touchUpInside)
        submitButton.setTitle("fcr_user_kick_out_submit".agedu_localized(),
                              for: .normal)
        contentView.addSubview(submitButton)
        
        cancelButton.addTarget(self,
                               action: #selector(onClickCancel(_:)),
                               for: .touchUpInside)
        cancelButton.setTitle("fcr_user_kick_out_cancel".agedu_localized(),
                              for: .normal)
        contentView.addSubview(cancelButton)
    }
    
    func initViewFrame() {
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
            make?.right.equalTo()(-30)
            make?.centerY.equalTo()(firstButton)
        }
        seconedButton.mas_makeConstraints { make in
            make?.width.height().equalTo()(34)
            make?.top.equalTo()(firstButton.mas_bottom)
            make?.left.equalTo()(16)
        }
        seconedLabel.mas_makeConstraints { make in
            make?.left.equalTo()(seconedButton.mas_right)?.offset()(4)
            make?.right.equalTo()(-30)
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
    
    func updateViewProperties() {
        let ui = AgoraUIGroup()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        FcrColorGroup.borderSet(layer: contentView.layer)
        titleLable.font = ui.font.fcr_font17
        firstLabel.textColor = FcrColorGroup.fcr_text_level1_color
        firstLabel.font = ui.font.fcr_font13
        vLine.backgroundColor = FcrColorGroup.fcr_system_divider_color
        hLine.backgroundColor = FcrColorGroup.fcr_system_divider_color
        contentView.backgroundColor = FcrColorGroup.fcr_system_component_color
        contentView.layer.cornerRadius = ui.frame.fcr_alert_corner_radius
        titleLable.textColor = UIColor(hex: 0x030303)
        seconedLabel.textColor = UIColor(hex: 0x586376)
        seconedLabel.font = ui.font.fcr_font13
    }
}
