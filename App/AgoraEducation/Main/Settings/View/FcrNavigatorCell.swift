//
//  FcrNavigatorCell.swift
//  AgoraEducation
//
//  Created by Jonathan on 2022/6/30.
//  Copyright © 2022 Agora. All rights reserved.
//

import UIKit

class FcrNavigatorCell: UITableViewCell {
    
    public var infoLabel: UILabel = UILabel()
    
    private var arrow = UIImageView(image: UIImage(named: "ic_right_arrow"))
    
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
private extension FcrNavigatorCell {
    func createViews() {
        infoLabel.font = UIFont.systemFont(ofSize: 14)
        infoLabel.textColor = UIColor(hex: 0x191919)
        infoLabel.textAlignment = .left
        addSubview(infoLabel)
        
        addSubview(arrow)
    }
    
    func createConstrains() {
        infoLabel.mas_makeConstraints { make in
            make?.left.equalTo()(16)
            make?.centerY.equalTo()(0)
        }
        arrow.mas_makeConstraints { make in
            make?.right.equalTo()(-16)
            make?.centerY.equalTo()(0)
        }
    }
}
