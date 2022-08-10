//
//  FcrLogoffViewController.swift
//  AgoraEducation
//
//  Created by Jonathan on 2022/7/11.
//  Copyright © 2022 Agora. All rights reserved.
//

import UIKit
import AgoraEduUI

class FcrLogoffViewController: FcrOutsideClassBaseController {

    private let textLabel = UILabel()
    
    private let checkBox = UIButton(type: .custom)
    
    private let logoffButton = UIButton(type: .custom)
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(hex: 0xF9F9FC)
        title = "settings_close_account".ag_localized()
        createViews()
        createConstrains()
    }
}
// MARK: - Actions
private extension FcrLogoffViewController {
    // 注销账号
    @objc func onClickLogoff() {
        let alertController = UIAlertController(title: "fcr_alert_title".ag_localized(),
                                                message: "settings_logoff_alert".ag_localized(),
                                                preferredStyle: .alert)
        let submit = UIAlertAction(title: "fcr_alert_submit".ag_localized(),
                                   style: .default) { action in
            FcrUserInfoPresenter.shared.logout {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
        let cancel = UIAlertAction(title: "fcr_alert_cancel".ag_localized(),
                                   style: .default)
        alertController.addAction(submit)
        alertController.addAction(cancel)
        present(alertController, animated: true)
    }
    // 协议勾选
    @objc func onClickCheckBox(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        logoffButton.isEnabled = sender.isSelected
    }
    
}
// MARK: - Creations
private extension FcrLogoffViewController {
    func createViews() {
        textLabel.numberOfLines = 0
        let attrString = NSMutableAttributedString(string: "settings_logoff_detail".ag_localized())
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.paragraphSpacing = 21
        let attr: [NSAttributedString.Key : Any] = [.font: UIFont.systemFont(ofSize: 18),
                                                    .foregroundColor: UIColor(hex: 0x191919) as Any,
                                                    .paragraphStyle: paraStyle]
        let range = NSRange(location: 0,
                            length: attrString.length)
        attrString.addAttributes(attr,
                                 range: range)
        textLabel.attributedText = attrString
        view.addSubview(textLabel)
        
        checkBox.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        checkBox.setTitleColor(UIColor(hex: 0x191919), for: .normal)
        checkBox.setTitle("settings_logoff_agreenment".ag_localized(),
                          for: .normal)
        checkBox.setImage(UIImage(named: "checkBox_unchecked"),
                          for: .normal)
        checkBox.setImage(UIImage(named: "checkBox_checked"),
                          for: .selected)
        checkBox.addTarget(self,
                           action: #selector(onClickCheckBox(_:)),
                           for: .touchUpInside)
        checkBox.titleLabel?.adjustsFontSizeToFitWidth = true
        checkBox.titleEdgeInsets = UIEdgeInsets(top: 0,
                                                left: 10,
                                                bottom: 0,
                                                right: 0)
        view.addSubview(checkBox)
        
        logoffButton.layer.borderWidth = 1
        logoffButton.layer.borderColor = UIColor(hex: 0xD2D2E2)?.cgColor
        logoffButton.layer.cornerRadius = 6
        logoffButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        logoffButton.setTitleColor(UIColor(hex: 0x677386),
                                   for: .disabled)
        logoffButton.setTitleColor(UIColor(hex: 0x357BF6),
                                   for: .normal)
        logoffButton.isEnabled = false
        logoffButton.setTitle("settings_logoff_submit".ag_localized(),
                              for: .normal)
        logoffButton.addTarget(self,
                               action: #selector(onClickLogoff),
                               for: .touchUpInside)
        view.addSubview(logoffButton)
    }
    
    func createConstrains() {
        textLabel.mas_makeConstraints { make in
            make?.left.equalTo()(20)
            make?.right.equalTo()(-20)
            make?.top.equalTo()(10)
        }
        checkBox.mas_makeConstraints { make in
            make?.left.equalTo()(textLabel)
            make?.top.equalTo()(textLabel.mas_bottom)?.offset()(30)
            make?.height.equalTo()(30)
        }
        logoffButton.mas_makeConstraints { make in
            make?.centerX.equalTo()(0)
            make?.height.equalTo()(44)
            make?.width.equalTo()(300)
            make?.bottom.equalTo()(-60)
        }
    }
}
