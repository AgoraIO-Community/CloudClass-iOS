//
//  FcrSettingsViewController.swift
//  AgoraEducation
//
//  Created by Jonathan on 2022/6/30.
//  Copyright © 2022 Agora. All rights reserved.
//

import UIKit
import AgoraEduUI

class FcrSettingsViewController: FcrOutsideClassBaseController {
    
    private enum FcrSettingsOption: Int {
        case generalSetting = 0
        case aboutUs = 1
    }
    
    private let tableView = UITableView(frame: .zero,
                                        style: .plain)
    
    private let logoutButton = UIButton(type: .system)
    
    private let dataSource: [FcrSettingsOption] = [.generalSetting,
                                                   .aboutUs]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "settings_setting".ag_localized()
        createViews()
        createConstrains()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false,
                                                     animated: true)
    }
}
// MARK: - Actions
private extension FcrSettingsViewController {
    func onClickGeneralSettings() {
        let vc = FcrGeneralSettingsViewController()
        navigationController?.pushViewController(vc,
                                                 animated: true)
    }
    
    func onClickAbout() {
        let vc = FcrAboutViewController()
        navigationController?.pushViewController(vc,
                                                 animated: true)
    }
    // 退出登录按钮
    @objc func onClickLogout() {
        let alertController = UIAlertController(title: "fcr_alert_title".ag_localized(),
                                                message: "settings_logout_alert".ag_localized(),
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
}
// MARK: - Creations
extension FcrSettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: FcrNavigatorCell.self)
        let type = dataSource[indexPath.row]
        switch type {
        case .generalSetting:
            cell.infoLabel.text = "fcr_settings_option_general".ag_localized()
        case .aboutUs:
            cell.infoLabel.text = "fcr_settings_option_about_us".ag_localized()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let type = dataSource[indexPath.row]
        switch type {
        case .generalSetting:
            onClickGeneralSettings()
        case .aboutUs:
            onClickAbout()
        }
    }
}
// MARK: - Creations
private extension FcrSettingsViewController {
    func createViews() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.bounces = false
        let footer = UIView(frame: CGRect(x: 0,
                                          y: 0,
                                          width: 1,
                                          height: 0.5))
        footer.backgroundColor = UIColor(hexString: "#EEEEF7")
        tableView.tableFooterView = footer
        tableView.rowHeight = 52
        tableView.separatorInset = .zero
        tableView.separatorColor = UIColor(hexString: "#EEEEF7")
        tableView.register(cellWithClass: FcrNavigatorCell.self)
        view.addSubview(tableView)
        
        logoutButton.layer.borderWidth = 1
        logoutButton.layer.borderColor = UIColor(hex: 0xD2D2E2)?.cgColor
        logoutButton.layer.cornerRadius = 6
        logoutButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        logoutButton.setTitleColor(UIColor(hex: 0x357BF6),
                                   for: .normal)
        logoutButton.setTitle("settings_logout".ag_localized(),
                              for: .normal)
        logoutButton.addTarget(self,
                               action: #selector(onClickLogout),
                               for: .touchUpInside)
        view.addSubview(logoutButton)
    }
    
    func createConstrains() {
        tableView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
        logoutButton.mas_makeConstraints { make in
            make?.centerX.equalTo()(0)
            make?.height.equalTo()(44)
            make?.width.equalTo()(300)
            make?.bottom.equalTo()(-60)
        }
    }
}
