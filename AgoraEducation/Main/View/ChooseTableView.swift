//
//  ClassTypeViewController.swift
//  AgoraEducation
//
//  Created by LYY on 2021/4/15.
//  Copyright © 2021 Agora. All rights reserved.
//

import Foundation
import AgoraUIBaseViews
import AgoraEduSDK

@objcMembers public class ChooseTableView: AgoraBaseUIView,
                                           UITableViewDataSource,
                                           UITableViewDelegate{
    private var cellId: String = ""
    private var dataList: Array<String> = []
    
    private lazy var tableView: AgoraBaseUITableView = {
        var tab = AgoraBaseUITableView()
        tab.dataSource = self
        tab.delegate = self
        tab.showsVerticalScrollIndicator = false
        tab.showsHorizontalScrollIndicator = false
        tab.isScrollEnabled = false
        tab.tableFooterView = UIView(frame: .zero)
        tab.register(AgoraBaseUITableViewCell.self, forCellReuseIdentifier: cellId)
        
        return tab
    }()
    

    public func getTotalHeight() -> CGFloat{
        return CGFloat(dataList.count) * LoginConfig.login_choose_cell_height + 20
    }
    
    private var selectTypeBlock: (Int) -> Void?
    
    public convenience init(cell_id: String,
                            list: Array<String>,
                            selectBlock: @escaping (Int)->Void) {
        self.init(frame: .zero, selectBlock: selectBlock)
        cellId = cell_id
        dataList = list
        initView()
        initLayout()
    }
    
    private init(frame: CGRect,selectBlock: @escaping (Int)->Void) {
        selectTypeBlock = selectBlock
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initView() {
        self.layer.cornerRadius = 8
        self.layer.backgroundColor = UIColor.white.cgColor
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(hexString: "ECECF1").cgColor

        self.layer.shadowColor = UIColor(r: 47,
                                         g: 65,
                                         b: 146,
                                         alpha: 0.15).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 6
        
        self.clipsToBounds = false
        
        addSubview(tableView)
    }
    
    private func initLayout() {
        tableView.agora_center_x = 0
        tableView.agora_y = 11
        tableView.agora_bottom = 11
        tableView.agora_width = 280
    }
    
    // MARK: UITableViewDataSource & UITableViewDelegate
    @objc public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    @objc public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    @objc public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! AgoraBaseUITableViewCell
        cell.backgroundColor = .white
        cell.selectionStyle = .none
        cell.separatorInset = UIEdgeInsets(top: LoginConfig.login_choose_cell_height,
                                           left: 15,
                                           bottom: 0,
                                           right: 15)
        
        if let text = cell.contentView.viewWithTag(100) as? AgoraBaseUILabel {
            text.text = dataList[indexPath.row]
        } else {
            let text = AgoraBaseUILabel()
            text.text = dataList[indexPath.row]
            text.tag = 100
            text.font = UIFont.systemFont(ofSize: 14)
            text.textColor = UIColor(hexString: "191919")
            text.textAlignment = .center
            
            cell.contentView.addSubview(text)
            
            text.agora_x = 0
            text.agora_right = 0
            text.agora_y = 0
            text.agora_bottom = 0
        }

        return cell
    }
    
    @objc public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return LoginConfig.login_choose_cell_height
    }
    
    @objc public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectTypeBlock(indexPath.row)
    }
    
}
