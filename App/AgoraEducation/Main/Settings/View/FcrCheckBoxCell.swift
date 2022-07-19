//
//  FcrCheckBoxCell.swift
//  AgoraEducation
//
//  Created by Jonathan on 2022/6/30.
//  Copyright © 2022 Agora. All rights reserved.
//

import UIKit

class FcrCheckBoxCell: UITableViewCell {

    public var infoLabel: UILabel = UILabel()
    
    public var aSelected = false {
        didSet {
            guard aSelected != oldValue else {
                return
            }
            if aSelected {
                checkBox.image = UIImage(named: "ic_round_check_box_sel")
            } else {
                checkBox.image = UIImage(named: "ic_round_check_box_unsel")
            }
        }
    }
    
    private var checkBox = UIImageView(image: UIImage(named: "ic_round_check_box_unsel"))
    
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
private extension FcrCheckBoxCell {
    func createViews() {
        infoLabel.font = UIFont.systemFont(ofSize: 14)
        infoLabel.textColor = UIColor(hex: 0x191919)
        infoLabel.textAlignment = .left
        addSubview(infoLabel)
        
        addSubview(checkBox)
    }
    
    func createConstrains() {
        infoLabel.mas_makeConstraints { make in
            make?.left.equalTo()(16)
            make?.centerY.equalTo()(0)
        }
        checkBox.mas_makeConstraints { make in
            make?.right.equalTo()(-20)
            make?.centerY.equalTo()(0)
        }
    }
}
