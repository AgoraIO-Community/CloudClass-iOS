//
//  FcrLanguageViewController.swift
//  AgoraEducation
//
//  Created by Jonathan on 2022/6/30.
//  Copyright © 2022 Agora. All rights reserved.
//

import UIKit

class FcrLanguageViewController: FcrOutsideClassBaseController {
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    private let dataSource: [FcrSurpportLanguage] = [.zh_cn,
                                                     .en]
    
    private lazy var selectedLanguage: FcrSurpportLanguage? = FcrLocalization.shared.language

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "fcr_settings_label_language".ag_localized()
        createViews()
        createConstrains()
    }
    
    func reloadRootViews() {
        let navi = FcrNavigationController(rootViewController: LoginViewController())
        var viewControllers = navi.viewControllers
        viewControllers.append(FcrSettingsViewController())
        viewControllers.append(FcrGeneralSettingsViewController())
        viewControllers.append(FcrLanguageViewController())
        navi.resetViewControllers(viewControllers: viewControllers)
        UIApplication.shared.keyWindow?.rootViewController = navi
    }
}
// MARK: - Creations
extension FcrLanguageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: FcrCheckBoxCell.self)
        let type = dataSource[indexPath.row]
        cell.infoLabel.text = type.description()
        cell.aSelected = (selectedLanguage == type)
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath,
                              animated: false)
        let type = dataSource[indexPath.row]
        selectedLanguage = type
        FcrLocalization.shared.setupNewLanguage(type)
        reloadRootViews()
    }
}
// MARK: - Creations
private extension FcrLanguageViewController {
    func createViews() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.bounces = false
        let footer = UIView.init(frame: CGRect(x: 0, y: 0, width: 1, height: 0.5))
        footer.backgroundColor = UIColor(hexString: "#EEEEF7")
        tableView.tableFooterView = footer
        tableView.rowHeight = 52
        tableView.separatorInset = .zero
        tableView.separatorColor = UIColor(hexString: "#EEEEF7")
        tableView.register(cellWithClass: FcrCheckBoxCell.self)
        view.addSubview(tableView)
    }
    
    func createConstrains() {
        tableView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
    }
}

private extension FcrSurpportLanguage {
    
    func description() -> String {
        switch self {
        case .zh_cn:
            return "fcr_settings_option_general_language_simplified".ag_localized()
        case .en:
            return "fcr_settings_option_general_language_english".ag_localized()
        case .zh_tw:
            return "fcr_settings_option_general_language_traditional".ag_localized()
        }
    }
}

