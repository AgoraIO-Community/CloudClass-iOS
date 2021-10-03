//
//  RoomInfoOptionsView.swift
//  AgoraEducation
//
//  Created by HeZhengQing on 2021/9/9.
//  Copyright © 2021 Agora. All rights reserved.
//

import UIKit

class RoomInfoOptionsView: AgoraBaseUIView {
        
    var tableView: UITableView!
    
    var dataSource: [String] = []
    
    var selectedIndex = 0
    
    var onSelected: ((Int) -> Void)?
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        createViews()
        createConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // 在某个视图的下方展示
    public func show(beside: UIView, options: [String], index: Int, onSelected:@escaping (_ index: Int)->()) {
        hide()
        superview?.bringSubviewToFront(self)
        self.onSelected = onSelected
        dataSource = options
        selectedIndex = index
        tableView.reloadData()
        // 计算本次显示位置
        let itemHeight: Float = 44.0, insert: Float = 11.0
        var contentHeight: Float = 0
        if (options.count > 4) {
            contentHeight = itemHeight * 4 + insert * 2
        } else {
            contentHeight = itemHeight * Float(options.count) + insert * 2
        }
        let rect = beside.convert(beside.bounds, to: superview)
        agora_y = rect.maxY - 18
        agora_center_x = 0
        agora_width = rect.width
        agora_height = CGFloat(contentHeight)
        isHidden = false
    }
    // 主动隐藏
    public func hide() {
        isHidden = true
        onSelected = nil
    }
}

extension RoomInfoOptionsView: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(RoomInfoOptionCell.self)) as? RoomInfoOptionCell
        cell?.infoLabel.text = dataSource[indexPath.row]
        let color = (selectedIndex == indexPath.row) ? UIColor(hexString: "#357BF6") : UIColor(hexString: "#191919")
        cell?.infoLabel.textColor = color
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        onSelected?(indexPath.row)
    }
}

// MARK: - Creations
extension RoomInfoOptionsView {
    func createViews() {
        backgroundColor = UIColor.white
        layer.cornerRadius = 8
        layer.shadowColor = UIColor(hexString: "#2F4192", alpha: 0.15).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 1
        layer.shadowRadius = 6
        
        tableView = AgoraBaseUITableView.init(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView.init(frame: CGRect(x: 0, y: 0, width: 1, height: 0.01))
        tableView.rowHeight = 44
        tableView.separatorColor = UIColor(hexString: "#E3E3EC")
        tableView.separatorInset = .zero
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        tableView.separatorColor = UIColor(hexString: "#EEEEF7")
        tableView.register(RoomInfoOptionCell.self, forCellReuseIdentifier: NSStringFromClass(RoomInfoOptionCell.self))
        addSubview(tableView)
    }

    func createConstrains() {
        tableView.agora_x = agora_x
        tableView.agora_right = agora_right
        tableView.agora_y = 11
        tableView.agora_bottom = 11
    }
}


