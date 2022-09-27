//
//  DebugView.swift
//  AgoraEducation
//
//  Created by LYY on 2022/8/5.
//  Copyright © 2022 Agora. All rights reserved.
//

import AgoraUIBaseViews

protocol DebugViewDelagate: NSObjectProtocol {
    func onClickClose()
    func onClickEnter()
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
    private(set) lazy var infoListView = UITableView(frame: .zero,
                                                  style: .plain)
    // options list
    private lazy var optionsView = DebugOptionsView(frame: .zero)
    
    private var currentFocusIndex = -1
    
    func updateCellModel(model: DebugInfoCellModel,
                         at index: Int) {
        guard dataSource.count > index else {
            return
        }
        
        hideOptions()
        hideKeyboard()
        dataSource[index] = model
    }
    
    func updateEnterEnabled(_ enabled: Bool) {
        if enabled {
            enterButton.backgroundColor = UIColor(hexString: "357BF6")
            enterButton.isUserInteractionEnabled = true
        } else {
            enterButton.backgroundColor = UIColor(hexString: "C0D6FF")
            enterButton.isUserInteractionEnabled = true
        }
    }
    
    func reloadList(_ indexList: [Int]? = nil) {
        guard let list = indexList else {
            infoListView.reloadData()
            return
        }
        let indexPathList = list.map({return IndexPath(row: $0,
                                                       section: 0)})
        infoListView.reloadRows(at: indexPathList,
                             with: .none)
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
    
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        super.touchesBegan(touches,
                           with: event)
        
        hideOptions()
        hideKeyboard()
    }
}

// MARK: - private
private extension DebugView {
    @objc func onClickClose() {
        delegate?.onClickClose()
    }
    
    @objc func onClickEnter() {
        delegate?.onClickEnter()
    }
    
    func showOptions(cell: DebugInfoCell,
                     selectedIndex: Int,
                     options: [(String, OptionSelectedAction)]) {
        optionsView.updateData(data: options,
                               selectedIndex: selectedIndex)
        optionsView.agora_visible = true
        bringSubviewToFront(optionsView)
        
        let itemHeight: CGFloat = 44.0
        let insert: CGFloat = 11.0
        
        var contentHeight: CGFloat = 0
        if (options.count > 4) {
            contentHeight = itemHeight * 4 + insert * 2
        } else {
            contentHeight = itemHeight * CGFloat(options.count) + insert * 2
        }
        
        optionsView.mas_remakeConstraints { make in
            make?.top.equalTo()(cell.mas_bottom)?.offset()(-26)
            make?.left.right().equalTo()(cell)
            make?.height.equalTo()(0)
        }
        
        layoutIfNeeded()
        optionsView.mas_updateConstraints { make in
            make?.height.equalTo()(contentHeight)
        }
        optionsView.alpha = 0.2
        
        UIView.animate(withDuration: 0.1) {
            self.layoutIfNeeded()
            self.optionsView.alpha = 1
        } completion: { finish in
            
        }
    }
    
    func hideOptions() {
        currentFocusIndex = -1
        optionsView.agora_visible = false
    }
    
    func hideKeyboard() {
        UIApplication.shared.keyWindow?.endEditing(true)
    }
}

// MARK: - View delegate
extension DebugView: DebugInfoCellDelegate,
                     UITableViewDelegate,
                     UITableViewDataSource {
    // MARK: DebugInfoCellDelegate
    func infoCellDidBeginEditing() {
        hideOptions()
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DebugInfoCell.id) as! DebugInfoCell
        let model = dataSource[indexPath.row]
        cell.model = model
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        guard case DebugInfoCellType.option(let options, _, _, let selectedIndex) = dataSource[indexPath.row].type else {
            return
        }
        
        guard currentFocusIndex != indexPath.row else {
            hideOptions()
            return
        }
        currentFocusIndex = indexPath.row
        
        hideKeyboard()
        
        let cell = tableView.cellForRow(at: indexPath) as! DebugInfoCell
        showOptions(cell: cell,
                    selectedIndex: selectedIndex,
                    options: options)
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
                              action: #selector(onClickClose),
                              for: .touchUpInside)
        addSubview(closeButton)
        
        
        enterButton.addTarget(self,
                              action: #selector(onClickEnter),
                              for: .touchUpInside)
        addSubview(enterButton)

        addSubview(bottomLabel)
                
        infoListView.tableFooterView = UIView()
        infoListView.rowHeight = 68
        infoListView.estimatedRowHeight = 68
        infoListView.estimatedSectionHeaderHeight = 0
        infoListView.estimatedSectionFooterHeight = 0
        infoListView.separatorInset = .zero
        infoListView.separatorStyle = .none
        infoListView.allowsMultipleSelection = false
        infoListView.delegate = self
        infoListView.dataSource = self
        infoListView.register(DebugInfoCell.self,
                           forCellReuseIdentifier:DebugInfoCell.id)
        addSubview(infoListView)
        
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
            make?.height.equalTo()(44)
            make?.width.equalTo()(60)
            make?.right.equalTo()(-15)
        }
        
        infoListView.mas_makeConstraints { make in
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
            make?.top.equalTo()(infoListView.mas_bottom)?.offset()(enter_gap)
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
