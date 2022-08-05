//
//  DebugOptionsView.swift
//  AgoraEducation
//
//  Created by LYY on 2022/8/5.
//  Copyright © 2022 Agora. All rights reserved.
//

import AgoraUIBaseViews

protocol DebugOptionsViewDelegate: NSObjectProtocol {
    func didSelect(at index: Int, value: String)
}

typealias OptionSelectedAction = (() -> Void)

class DebugOptionsView: UIView {
    weak var delegate: DebugOptionsViewDelegate?
    private lazy var listView = UITableView(frame: .zero,
                                            style: .plain)
    private var data = [(String, OptionSelectedAction)]()
    private var selectedIndex = -1
    
    func updateData(data: [(String, OptionSelectedAction)],
                    selectedIndex: Int) {
        self.data = data
        self.selectedIndex = selectedIndex
        listView.reloadData()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initViews()
        initViewFrame()
        updateViewProperties()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - table view
extension DebugOptionsView: UITableViewDataSource,
                            UITableViewDelegate {
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        <#code#>
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
    
    
}
    
// MARK: - AgoraUIContentContainer
extension DebugOptionsView: AgoraUIContentContainer {
    func initViews() {
        listView.tableFooterView = UIView.init(frame: CGRect(x: 0,
                                                    y: 0,
                                                    width: 1,
                                                             height: 0.01))
        listView.rowHeight = 44
        listView.separatorInset = UIEdgeInsets(top: 0,
                                               left: 15,
                                               bottom: 0,
                                               right: 15)
        listView.delegate = self
        listView.dataSource = self
        listView.register(DebugOptionCell.self,
                          forCellReuseIdentifier: DebugOptionCell.id)
        addSubview(listView)
    }
    
    func initViewFrame() {
        listView.mas_makeConstraints { make in
            make?.left.right().equalTo()(0)
            make?.top.equalTo()(11)
            make?.bottom.equalTo()(-11)
        }
    }
    
    func updateViewProperties() {
        backgroundColor = UIColor.white
        layer.cornerRadius = 8
        layer.shadowColor = UIColor(hex: 0x2F4192, transparency: 0.15)?.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 1
        layer.shadowRadius = 6
        
        listView.separatorColor = UIColor(hex: 0xEEEEF7)
    }
}

class DebugOptionCell: UITableViewCell {
    static let id = "DebugOptionCell"
    var infoLabel = UILabel()

    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(style: style,
                   reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        infoLabel.font = UIFont.systemFont(ofSize: 14)
        infoLabel.textColor = UIColor(hexString: "#191919")
        infoLabel.textAlignment = .center
        contentView.addSubview(infoLabel)
        
        infoLabel.mas_makeConstraints { make in
            make?.center.equalTo()(contentView)
            make?.left.equalTo()(15)
            make?.right.equalTo()(-15)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
