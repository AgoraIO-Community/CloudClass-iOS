//
//  FcrThemeViewController.swift
//  AgoraEducation
//
//  Created by Jonathan on 2022/6/30.
//  Copyright © 2022 Agora. All rights reserved.
//

import UIKit

class FcrThemeViewController: FcrOutsideClassBaseController {
    
    private enum FcrThemeOption: Int {
        case light = 0
        case dark = 1
        
        func description() -> String {
            switch self {
            case .light:
                return "settings_theme_light".ag_localized()
            case .dark:
                return "settings_theme_dark".ag_localized()
            }
        }
    }
    
    private let tableView = UITableView(frame: .zero,
                                        style: .plain)
    
    private let dataSource: [FcrThemeOption] = [.light,
                                                .dark]
    
    private lazy var selectedTheme: FcrThemeOption = {
        let theme = FcrThemeOption(rawValue: FcrUserInfoPresenter.shared.theme) ?? .light
        return theme
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "settings_theme".ag_localized()
        createViews()
        createConstrains()
    }
}
// MARK: - Creations
extension FcrThemeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: FcrCheckBoxCell.self)
        let type = dataSource[indexPath.row]
        cell.infoLabel.text = type.description()
        cell.aSelected = (selectedTheme == type)
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let type = dataSource[indexPath.row]
        selectedTheme = type
        FcrUserInfoPresenter.shared.theme = type.rawValue
        tableView.reloadData()
    }
}
// MARK: - Creations
private extension FcrThemeViewController {
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

