//
//  RoomListViewController.swift
//  AgoraEducation
//
//  Created by Jonathan on 2022/9/2.
//  Copyright © 2022 Agora. All rights reserved.
//

import UIKit

class RoomListViewController: UIViewController {
    
    let tableView = UITableView(frame: .zero, style: .plain)
    
    let titleView = RoomListTitleView(frame: .zero)
    
    let settingButton = UIButton(type: .custom)
    
    private let kTitleMax: CGFloat = 198
    
    private let kTitleMin: CGFloat = 110

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        createViews()
        createConstrains()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true,
                                                     animated: true)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard FcrUserInfoPresenter.shared.qaMode == false else {
            let debugVC = DebugViewController()
            debugVC.modalPresentationStyle = .fullScreen
            self.present(debugVC,
                         animated: true,
                         completion: nil)
            return
        }
        
        #if !DEBUG
        // 检查协议，检查登录
        FcrPrivacyTermsViewController.checkPrivacyTerms {
            LoginWebViewController.showLoginIfNot(complete: nil)
        }
        #endif
    }
    
    @objc func onClickSetting(_ sender: UIButton) {
        let vc = FcrSettingsViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
// MARK: -
extension RoomListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: RoomListItemCell.self)
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var height = kTitleMax - scrollView.contentOffset.y
        height = height < kTitleMin ? kTitleMin : height
        titleView.setSoildPercent(scrollView.contentOffset.y/(kTitleMax - kTitleMin))
        titleView.mas_updateConstraints { make in
            make?.height.equalTo()(height)
        }
    }
    
}
// MARK: - RoomListTitleViewDelegate
extension RoomListViewController: RoomListTitleViewDelegate {
    
    func onClickJoin() {
        
    }
    
    func onClickCreate() {
        RoomCreateViewController.showCreateRoom {
            
        }
    }
}
// MARK: - Creations
private extension RoomListViewController {
    
    func createViews() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.register(cellWithClass: RoomListItemCell.self)
        let headerFrame = CGRect(x: 0,
                                 y: 0,
                                 width: 200,
                                 height: kTitleMax)
        let headerView = UIView(frame: headerFrame)
        headerView.backgroundColor = .orange
        tableView.tableHeaderView = headerView
        tableView.rowHeight = 152
        view.addSubview(tableView)
        
        titleView.delegate = self
        titleView.clipsToBounds = true
        view.addSubview(titleView)
        
        settingButton.setImage(UIImage(named: "fcr_roomlist_setting"),
                               for: .normal)
        settingButton.addTarget(self,
                                action: #selector(onClickSetting(_:)),
                                for: .touchUpInside)
        view.addSubview(settingButton)
    }
    
    func createConstrains() {
        tableView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
        titleView.mas_makeConstraints { make in
            make?.left.top().right().equalTo()(0)
            make?.height.equalTo()(kTitleMax)
        }
        settingButton.mas_makeConstraints { make in
            make?.top.equalTo()(68)
            make?.right.equalTo()(-14)
        }
    }
}
