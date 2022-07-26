//
//  FcrAreaViewController.swift
//  AgoraEducation
//
//  Created by Jonathan on 2022/6/30.
//  Copyright © 2022 Agora. All rights reserved.
//

import UIKit

class FcrRegionViewController: FcrOutsideClassBaseController {
    
    private let tableView = UITableView(frame: .zero,
                                        style: .plain)
        
    private let dataSource: [FcrEnvironment.Region] = [.NA,
                                                       .AP,
                                                       .CN,
                                                       .EU]
    
    private var selectedRegion: FcrEnvironment.Region = FcrEnvironment.shared.region

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "fcr_settings_label_region".ag_localized()
        
        createViews()
        createConstrains()
    }
}
// MARK: - Creations
extension FcrRegionViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: FcrCheckBoxCell.self)
        let type = dataSource[indexPath.row]
        cell.infoLabel.text = type.rawValue
        cell.aSelected = (selectedRegion == type)
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath,
                              animated: false)
        let type = dataSource[indexPath.row]
        selectedRegion = type
        FcrEnvironment.shared.region = type
        tableView.reloadData()
    }
}
// MARK: - Creations
private extension FcrRegionViewController {
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
