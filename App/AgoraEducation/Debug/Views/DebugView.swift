//
//  DebugView.swift
//  AgoraEducation
//
//  Created by LYY on 2022/8/5.
//  Copyright © 2022 Agora. All rights reserved.
//

import AgoraUIBaseViews

protocol DebugViewDelagate: NSObjectProtocol {
    func didClickClose()
    func didClickEnter()
}

class DebugView: UIView {
    /**data**/
    weak var delegate: DebugViewDelagate?
    
    var dataSource = [DebugInfoCellModel]()
    /**views**/
    // title
    private lazy var titleLabel = UILabel()
    // only ipad
    private lazy var subTitleLabel = UILabel()
    // only iphone
    private lazy var topImageView = UIImageView(frame: .zero)
    // logo
    private lazy var logoImageView = UIImageView(frame: .zero)
    // close debug view
    private lazy var closeButton = UIButton(frame: .zero)
    // enter classroom
    private lazy var enterButton = UIButton(frame: .zero)
    // bottom info
    private(set) lazy var bottomLabel = UILabel(frame: .zero)
    // info list
    private(set) lazy var tableView = UITableView(frame: .zero,
                                                  style: .plain)
    private(set) lazy var optionsView = DebugOptionsView(frame: .zero)
    
    func reloadList(_ indexList: [Int]? = nil) {
        guard let list = indexList else {
            tableView.reloadData()
        }
        let indexPathList = list.map({return IndexPath(row: $0,
                                                       section: 0)})
        tableView.reloadRows(at: indexPathList,
                             with: .none)
    }
}

// MARK: - private
private extension DebugView {
    @objc func didClickClose() {
        delegate?.didClickClose()
    }
    
    @objc func didClickEnter() {
        delegate?.didClickEnter()
    }
}

extension DebugView: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DebugInfoCell.id) as! DebugInfoCell
        
        let model = dataSource[indexPath.row]
        cell.model = model
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? DebugInfoCell else {
            return
        }
        
        let model = dataSource[indexPath.row]
        guard case DebugInfoCellType.option(let options, _, _, let selectedIndex) = model.type else {
            return
        }
        cell.showOptions(options: options,
                         selectedIndex: selectedIndex)
    }
}

// MARK: - AgoraUIContentContainer
extension DebugView: AgoraUIContentContainer {
    func initViews() {
        if !UIDevice.current.agora_is_pad {
            addSubview(topImageView)
        } else {
            addSubview(subTitleLabel)
        }
        
        addSubview(titleLabel)
        
        addSubview(logoImageView)
        
        closeButton.addTarget(self,
                              action: #selector(didClickClose),
                              for: .touchUpInside)
        addSubview(closeButton)
        
        
        enterButton.addTarget(self,
                              action: #selector(didClickEnter),
                              for: .touchUpInside)
        addSubview(enterButton)

        addSubview(bottomLabel)
                
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 68
        tableView.estimatedRowHeight = 68
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.separatorInset = .zero
        tableView.separatorStyle = .none
        tableView.allowsMultipleSelection = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(DebugInfoCell.self,
                           forCellReuseIdentifier:DebugInfoCell.id)
        addSubview(tableView)
        
        addSubview(optionsView)
        optionsView.agora_visible = false
    }
    
    func initViewFrame() {
        if !UIDevice.current.agora_is_pad {
            topImageView.mas_makeConstraints { make in
                make?.left.top().right().equalTo()(0)
                make?.height.equalTo()(150)
            }
            
            titleLabel.mas_makeConstraints { make in
                make?.centerX.equalTo()(0)
                make?.centerY.equalTo()(topImageView.mas_centerY)?.offset()(-2)
            }
        } else {
            titleLabel.mas_makeConstraints { make in
                make?.centerX.equalTo()(0)
                make?.top.equalTo()(logoImageView.mas_bottom)?.offset()(17)
            }
            
            subTitleLabel.mas_makeConstraints { make in
                make?.centerX.equalTo()(0)
                make?.top.equalTo()(titleLabel.mas_bottom)?.offset()(2)
            }
        }
        logoImageView.mas_makeConstraints { make in
            make?.centerX.equalTo()(0)
            make?.top.equalTo()(LoginConfig.login_icon_y)
        }
        
        closeButton.mas_makeConstraints { make in
            make?.top.equalTo()(46)
            make?.right.equalTo()(-15)
        }
        
        tableView.mas_makeConstraints { make in
            make?.centerX.equalTo()(0)
            make?.width.equalTo()(LoginConfig.login_group_width)
            make?.height.equalTo()(68 * 5)
            make?.top.equalTo()(LoginConfig.login_first_group_y)
        }
        
        let enter_gap: CGFloat = LoginConfig.device == .iPhone_Small ? 30 : 40
        enterButton.mas_makeConstraints { make in
            make?.centerX.equalTo()(0)
            make?.height.equalTo()(44)
            make?.width.equalTo()(280)
            make?.top.equalTo()(tableView.mas_bottom)?.offset()(enter_gap)
        }

        bottomLabel.mas_makeConstraints { make in
            make?.centerX.equalTo()(0)
            make?.bottom.equalTo()(-LoginConfig.login_bottom_bottom)
        }
    }
    
    func updateViewProperties() {
        let isPad = UIDevice.current.agora_is_pad
        if !isPad {
            let image = UIImage(named: LoginConfig.device == .iPhone_Small ? "title_bg_small" : "title_bg")
            topImageView.image = image
            
            titleLabel.textColor = .white
        } else {
            subTitleLabel.text = "About_url".ag_localized()
            subTitleLabel.textColor = UIColor(hex: 0x677386)
            subTitleLabel.font = UIFont.systemFont(ofSize: 14)
            
            titleLabel.textColor = UIColor(hex: 0x191919)
        }

        titleLabel.font = .systemFont(ofSize: isPad ? 24 : 20)
        titleLabel.text = "Login_title".ag_localized()
        
        let iconName = (LoginConfig.device == .iPhone_Small) ? "icon_small" : "icon_big"
        logoImageView.image = UIImage(named: iconName)
        
        closeButton.setTitle("Close",
                             for: .normal)
        
        enterButton.setTitle("Login_enter".ag_localized(),
                             for: .normal)
        enterButton.setTitleColor(.white,
                                  for: .normal)
        enterButton.backgroundColor = UIColor(hexString: "C0D6FF")
        enterButton.isUserInteractionEnabled = false
        enterButton.layer.cornerRadius = 22
        
        bottomLabel.textColor = UIColor(hexString: "7D8798")
        bottomLabel.font = UIFont.systemFont(ofSize: 12)
    }
}
