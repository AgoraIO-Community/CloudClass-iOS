//
//  RoomInfoOptionsView.swift
//  AgoraEducation
//
//  Created by HeZhengQing on 2021/9/9.
//  Copyright © 2021 Agora. All rights reserved.
//

import UIKit
import Masonry
import AgoraUIBaseViews
import SwifterSwift

class RoomInfoOptionsView: UIView, UITableViewDelegate, UITableViewDataSource {
        
    var tableView: UITableView!
    
    var dataSource: [String] = []
    
    var selectedIndex = 0
    
    var onSelected: ((Int) -> Void)?
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        createViews()
        createConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // 在某个视图的下方展示
    public func show(beside: UIView,
                     options: [String],
                     index: Int,
                     onSelected:@escaping (_ index: Int)->()) {
        hide()
        superview?.bringSubviewToFront(self)
        self.onSelected = onSelected
        dataSource = options
        selectedIndex = index
        tableView.reloadData()
        // 计算本次显示位置
        let itemHeight: CGFloat = 44.0, insert: CGFloat = 11.0
        var contentHeight: CGFloat = 0
        if (options.count > 4) {
            contentHeight = itemHeight * 4 + insert * 2
        } else {
            contentHeight = itemHeight * CGFloat(options.count) + insert * 2
        }
        self.mas_remakeConstraints { make in
            make?.top.equalTo()(beside.mas_bottom)?.offset()(-26)
            make?.left.right().equalTo()(beside)
            make?.height.equalTo()(0)
        }
        self.superview?.layoutIfNeeded()
        self.mas_updateConstraints { make in
            make?.height.equalTo()(contentHeight)
        }
        self.alpha = 0.2
        isHidden = false
        UIView.animate(withDuration: 0.1) {
            self.superview?.layoutIfNeeded()
            self.alpha = 1
        } completion: { finish in
            
        }
    }
    // 主动隐藏
    public func hide() {
        isHidden = true
        onSelected = nil
    }
    
    @objc func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    @objc func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(RoomInfoOptionCell.self)) as? RoomInfoOptionCell
        cell?.infoLabel.text = dataSource[indexPath.row]
        let color = (selectedIndex == indexPath.row) ? UIColor(hexString: "#357BF6") : UIColor(hexString: "#191919")
        cell?.infoLabel.textColor = color
        return cell!
    }
    
    @objc func tableView(_ tableView: UITableView,
                          didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath,
                              animated: false)
        onSelected?(indexPath.row)
    }
}

// MARK: - Creations
extension RoomInfoOptionsView {
    func createViews() {
        backgroundColor = UIColor.white
        layer.cornerRadius = 8
        layer.shadowColor = UIColor(hex: 0x2F4192, transparency: 0.15)?.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 1
        layer.shadowRadius = 6
        
        tableView = AgoraBaseUITableView.init(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView.init(frame: CGRect(x: 0, y: 0, width: 1, height: 0.01))
        tableView.rowHeight = 44
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        tableView.separatorColor = UIColor(hexString: "#EEEEF7")
        tableView.register(RoomInfoOptionCell.self, forCellReuseIdentifier: NSStringFromClass(RoomInfoOptionCell.self))
        addSubview(tableView)
    }

    func createConstraint() {
        tableView.mas_makeConstraints { make in
            make?.left.right().equalTo()(0)
            make?.top.equalTo()(11)
            make?.bottom.equalTo()(-11)
        }
    }
}


