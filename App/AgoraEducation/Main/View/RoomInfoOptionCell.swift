//
//  RoomInfoOptionCell.swift
//  AgoraEducation
//
//  Created by HeZhengQing on 2021/9/10.
//  Copyright © 2021 Agora. All rights reserved.
//

import UIKit
import AgoraUIBaseViews

class RoomInfoOptionCell: AgoraBaseUITableViewCell {
    var infoLabel: AgoraBaseUILabel!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        infoLabel = AgoraBaseUILabel()
        infoLabel.font = UIFont.systemFont(ofSize: 14)
        infoLabel.textColor = UIColor(hexString: "#191919")
        infoLabel.textAlignment = .center
        contentView.addSubview(infoLabel)
        
        infoLabel.agora_center_y = 0
        infoLabel.agora_center_x = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
