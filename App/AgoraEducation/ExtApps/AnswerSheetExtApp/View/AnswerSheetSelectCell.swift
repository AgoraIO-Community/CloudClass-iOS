//
//  AnswerSheetSelectCell.swift
//  AgoraExtApp
//
//  Created by Jonathan on 2021/10/27.
//

import UIKit
import SwifterSwift

class AnswerSheetSelectCell: UICollectionViewCell {
    
    var titleLabel: UILabel!
    
    var aSeleted: Bool = false {
        didSet {
            if aSeleted {
                titleLabel.layer.borderColor = UIColor.clear.cgColor
                titleLabel.backgroundColor = UIColor(hex: 0x357BF6)
                titleLabel.textColor = .white
            } else {
                titleLabel.layer.borderColor = UIColor(hex: 0xEEEEF7)?.cgColor
                titleLabel.backgroundColor = .white
                titleLabel.textColor = UIColor(hex: 0xBDBDCA)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor(hex: 0xBDBDCA)
        titleLabel.backgroundColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        titleLabel.layer.borderWidth = 1
        titleLabel.layer.borderColor = UIColor(hex: 0xEEEEF7)?.cgColor
        titleLabel.layer.cornerRadius = 12
        titleLabel.clipsToBounds = true
        contentView.addSubview(titleLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.frame = bounds
    }
}
