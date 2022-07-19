//
//  FcrCheckBoxCell.swift
//  AgoraEducation
//
//  Created by Jonathan on 2022/6/30.
//  Copyright © 2022 Agora. All rights reserved.
//

import UIKit

class FcrDetailInfoCell: UITableViewCell {

    public var infoLabel: UILabel = UILabel()
    
    public var detailLabel: UILabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(style: style,
                   reuseIdentifier: reuseIdentifier)
        
        separatorInset = .zero
        createViews()
        createConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Creations
private extension FcrDetailInfoCell {
    func createViews() {
        infoLabel.font = UIFont.systemFont(ofSize: 14)
        infoLabel.textColor = UIColor(hex: 0x191919)
        infoLabel.textAlignment = .left
        addSubview(infoLabel)
        
        detailLabel.font = UIFont.systemFont(ofSize: 14)
        detailLabel.textColor = UIColor(hex: 0x191919)
        detailLabel.textAlignment = .right
        addSubview(detailLabel)
    }
    
    func createConstrains() {
        infoLabel.mas_makeConstraints { make in
            make?.left.equalTo()(16)
            make?.centerY.equalTo()(0)
        }
        detailLabel.mas_makeConstraints { make in
            make?.right.equalTo()(-16)
            make?.centerY.equalTo()(0)
        }
    }
}
