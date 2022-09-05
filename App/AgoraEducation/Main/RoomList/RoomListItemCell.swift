//
//  RoomListItemCell.swift
//  AgoraEducation
//
//  Created by Jonathan on 2022/9/2.
//  Copyright © 2022 Agora. All rights reserved.
//

import UIKit

class RoomListItemCell: UITableViewCell {
    
    let cardView = UIView()
    
    let stateLabel = UILabel()
    
    let idLabel = UILabel()
    
    let nameLabel = UILabel()
    
    let timeLabel = UILabel()
    
    let typeLabel = UILabel()
    
    let enterButton = UIButton()
    
    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(style: style,
                   reuseIdentifier: reuseIdentifier)
        
        createViews()
        createConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Creations
private extension RoomListItemCell {
    func createViews() {
        cardView.backgroundColor = UIColor(hex: 0x5765FF)
        cardView.layer.cornerRadius = 16
        cardView.clipsToBounds = true
        contentView.addSubview(cardView)
    }
    
    func createConstrains() {
        cardView.mas_makeConstraints { make in
            make?.edges.equalTo()(UIEdgeInsets(top: 6,
                                               left: 14,
                                               bottom: 6,
                                               right: 14))
        }
    }
}
