//
//  AgoraCloudContentView.swift
//  AgoraWidgets
//
//  Created by ZYP on 2021/10/21.
//

import AgoraUIBaseViews
import AgoraUIEduBaseViews
import Masonry

protocol AgoraCloudListViewDelegate: NSObjectProtocol {
    func agoraCloudListViewDidSelectedIndex(index: Int)
}

class AgoraCloudListView: AgoraBaseUIView, UITableViewDataSource, UITableViewDelegate {
    typealias Info = AgoraCloudCell.Info
    private let tableView = AgoraBaseUITableView()
    private let headerView = AgoraCloudHeaderView(frame: .zero)
    private var infos = [Info]()
    weak var delegate: AgoraCloudListViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        initLayout()
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        tableView.contentInset = .zero
        tableView.backgroundColor = .white
        tableView.tableFooterView = AgoraBaseUIView()
        tableView.separatorInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        addSubview(tableView)
    }
    
    private func commonInit() {
        tableView.register(AgoraCloudCell.self,
                           forCellReuseIdentifier: "AgoraCloudCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
    }
    
    private func initLayout() {
        tableView.mas_makeConstraints { make in
            make?.left.and().right().and().top().and().bottom().equalTo()(self)
        }
    }
    
    func update(infos: [Info]) {
        self.infos = infos
        tableView.reloadData()
    }
    
    @objc func tableView(_ tableView: UITableView,
                         numberOfRowsInSection section: Int) -> Int {
        return infos.count
    }
    
    @objc func tableView(_ tableView: UITableView,
                         cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AgoraCloudCell",
                                                 for: indexPath) as! AgoraCloudCell
        let info = infos[indexPath.row]
        cell.set(info: info)
        return cell
    }
    
    @objc func tableView(_ tableView: UITableView,
                         didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath,
                              animated: true)
        delegate?.agoraCloudListViewDidSelectedIndex(index: indexPath.row)
    }
}


