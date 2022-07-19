//
//  FcrGeneralSettingsViewController.swift
//  AgoraEducation
//
//  Created by Jonathan on 2022/6/30.
//  Copyright © 2022 Agora. All rights reserved.
//

import UIKit

class FcrGeneralSettingsViewController: UIViewController {
    
    private enum FcrSettingsOption: Int {
        case nickName = 0
        case language = 1
        case area = 2
        case theme = 3
        case logoff = 4
    }
    
    private let tableView = UITableView(frame: .zero,
                                        style: .plain)
    
    private let dataSource: [FcrSettingsOption] = [.nickName,
                                                   .language,
                                                   .area,
                                                   .theme,
                                                   .logoff]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("fcr_settings_option_general",
                                  comment: "")
        createViews()
        createConstrains()
    }
}
// MARK: - Actions
private extension FcrGeneralSettingsViewController {
    func onClickNickName() {
        let vc = FcrNickNameViewController()
        navigationController?.pushViewController(vc,
                                                 animated: true)
    }
    
    func onClickLanguage() {
        let vc = FcrLanguageViewController()
        navigationController?.pushViewController(vc,
                                                 animated: true)
    }
    
    func onClickArea() {
        let vc = FcrRegionViewController()
        navigationController?.pushViewController(vc,
                                                 animated: true)
    }
    
    func onClickTheme() {
        let vc = FcrThemeViewController()
        navigationController?.pushViewController(vc,
                                                 animated: true)
    }
    
    func onClickLogoff() {
        let vc = FcrLogoffViewController()
        navigationController?.pushViewController(vc,
                                                 animated: true)
    }
}
// MARK: - Creations
extension FcrGeneralSettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: FcrNavigatorCell.self)
        let type = dataSource[indexPath.row]
        switch type {
        case .nickName:
            cell.infoLabel.text = NSLocalizedString("settings_nickname",
                                                    comment: "")
        case .language:
            cell.infoLabel.text = NSLocalizedString("fcr_settings_label_language",
                                                    comment: "")
        case .area:
            cell.infoLabel.text = NSLocalizedString("fcr_settings_label_region",
                                                    comment: "")
        case .theme:
            cell.infoLabel.text = NSLocalizedString("settings_theme",
                                                    comment: "")
        case .logoff:
            cell.infoLabel.text = NSLocalizedString("settings_close_account",
                                                    comment: "")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath,
                              animated: false)
        let type = dataSource[indexPath.row]
        switch type {
        case .nickName:
            onClickNickName()
        case .language:
            onClickLanguage()
        case .area:
            onClickArea()
        case .theme:
            onClickTheme()
        case .logoff:
            onClickLogoff()
        }
    }
}
// MARK: - Creations
private extension FcrGeneralSettingsViewController {
    func createViews() {
        tableView.delegate = self
        tableView.dataSource = self
        let footer = UIView.init(frame: CGRect(x: 0, y: 0, width: 1, height: 0.5))
        footer.backgroundColor = UIColor(hexString: "#EEEEF7")
        tableView.tableFooterView = footer
        tableView.rowHeight = 52
        tableView.separatorInset = .zero
        tableView.separatorColor = UIColor(hexString: "#EEEEF7")
        tableView.register(cellWithClass: FcrNavigatorCell.self)
        view.addSubview(tableView)
    }
    
    func createConstrains() {
        tableView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
    }
}
