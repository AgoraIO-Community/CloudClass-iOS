//
//  FcrAboutViewController.swift
//  AgoraEducation
//
//  Created by Jonathan on 2022/6/30.
//  Copyright © 2022 Agora. All rights reserved.
//

import UIKit

class FcrAboutViewController: FcrOutsideClassBaseController {
    
    private enum FcrSettingsOption: Int {
        case privacy = 0
        case terms = 1
        case disclaimer = 2
        case register = 3
        case publish = 4
    }
    
    private let tableView = UITableView(frame: .zero,
                                        style: .plain)
    
    private let dataSource: [FcrSettingsOption] = [.privacy,
                                                   .terms,
                                                   .disclaimer,
                                                   .publish]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "fcr_settings_label_about_us_about_us".ag_localized()
        createViews()
        createConstrains()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false,
                                                     animated: true)
    }
}
// MARK: - Creations
extension FcrAboutViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let type = dataSource[indexPath.row]
        switch type {
        case .privacy:
            let cell = tableView.dequeueReusableCell(withClass: FcrNavigatorCell.self)
            cell.infoLabel.text = "fcr_settings_link_about_us_privacy_policy".ag_localized()
            return cell
        case .terms:
            let cell = tableView.dequeueReusableCell(withClass: FcrNavigatorCell.self)
            cell.infoLabel.text = "fcr_settings_link_about_us_user_agreement".ag_localized()
            return cell
        case .disclaimer:
            let cell = tableView.dequeueReusableCell(withClass: FcrNavigatorCell.self)
            cell.infoLabel.text = "settings_disclaimer".ag_localized()
            return cell
        case .register:
            let cell = tableView.dequeueReusableCell(withClass: FcrNavigatorCell.self)
            cell.infoLabel.text = "settings_register".ag_localized()
            return cell
        case .publish:
            let cell = tableView.dequeueReusableCell(withClass: FcrDetailInfoCell.self)
            cell.infoLabel.text = "settings_publish_time".ag_localized()
            cell.detailLabel.text = LoginConfig.version_time
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath,
                              animated: false)
        let type = dataSource[indexPath.row]
        switch type {
        case .privacy:
            if let url = URL(string: "settings_srivacy_url".ag_localized()) {
                UIApplication.shared.open(url, options: [:]) { (complete) in
                }
            }
        case .terms:
            if let url = URL(string: "settings_terms_url".ag_localized()) {
                UIApplication.shared.open(url, options: [:]) { (complete) in
                }
            }
        case .disclaimer:
            let vc = FcrDisclaimerViewController()
            navigationController?.pushViewController(vc,
                                                     animated: true)
        case .register:
            if let url = URL(string: "settings_signup_url".ag_localized()) {
                UIApplication.shared.open(url, options: [:]) { (complete) in
                }
            }
        case .publish:
            // Do Noting
            break
        }
    }
    
    func tableView(_ tableView: UITableView,
                   shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let type = dataSource[indexPath.row]
        if type == .publish {
            return false
        } else {
            return true
        }
    }
}
// MARK: - Creations
private extension FcrAboutViewController {
    func createViews() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.bounces = false
        let footer = UIView(frame: CGRect(x: 0,
                                          y: 0,
                                          width: 1,
                                          height: 0.5))
        footer.backgroundColor = UIColor(hex: 0xEEEEF7)
        tableView.tableFooterView = footer
        tableView.rowHeight = 52
        tableView.separatorInset = .zero
        tableView.separatorColor = UIColor(hex: 0xEEEEF7)
        tableView.register(cellWithClass: FcrNavigatorCell.self)
        tableView.register(cellWithClass: FcrDetailInfoCell.self)
        view.addSubview(tableView)
    }
    
    func createConstrains() {
        tableView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
    }
}

