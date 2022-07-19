//
//  FcrLanguageViewController.swift
//  AgoraEducation
//
//  Created by Jonathan on 2022/6/30.
//  Copyright © 2022 Agora. All rights reserved.
//

import UIKit

class FcrLanguageViewController: UIViewController {
    
    private enum FcrLanguageOption: String {
        case zh_cn = "zh-Hans"
        case en = "en"
        case zh_tw = "zh-tw"
        
        func description() -> String {
            switch self {
            case .zh_cn:
                return NSLocalizedString("fcr_settings_option_general_language_simplified",
                                         comment: "")
            case .en:
                return NSLocalizedString("fcr_settings_option_general_language_english",
                                         comment: "")
            case .zh_tw:
                return NSLocalizedString("fcr_settings_option_general_language_traditional",
                                         comment: "")
            }
        }
    }
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    private let dataSource: [FcrLanguageOption] = [.zh_cn,
                                                   .en]
    
    private lazy var selectedLanguage: FcrLanguageOption = {
        let language = FcrLanguageOption(rawValue: FcrUserInfoPresenter.shared.language) ?? .zh_cn
        return language
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("fcr_settings_label_language",
                                  comment: "")
        createViews()
        createConstrains()
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
        FcrUserInfoPresenter.shared.language = type.rawValue
        tableView.reloadData()
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

