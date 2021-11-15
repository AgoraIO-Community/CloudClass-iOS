//
//  ExtAppTitleView.swift
//  AgoraExtApp
//
//  Created by Jonathan on 2021/10/27.
//

import UIKit
import AgoraUIBaseViews
import SwifterSwift

class ExtAppTitleView: UIView {
    
    var titleLabel: UILabel!
    
    var timeLabel: UILabel!
    
    var closeButton: UIButton!
    
    private var line: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        createViews()
        createConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Creations
private extension ExtAppTitleView {
    func createViews() {
        backgroundColor = UIColor(hex: 0xF9F9FC)
        
        titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 13)
        titleLabel.textColor = UIColor(hex: 0x191919)
        addSubview(titleLabel)
        
        timeLabel = UILabel()
        timeLabel.font = UIFont.systemFont(ofSize: 13)
        timeLabel.textColor = UIColor(hex: 0x677386)
        addSubview(timeLabel)
        
        closeButton = UIButton.init(type: .custom)
        addSubview(closeButton)
        
        line = UIView()
        line.backgroundColor = UIColor(hex: 0xEEEEF7)
        addSubview(line)
    }
    
    func createConstrains() {
        titleLabel.mas_makeConstraints { make in
            make?.centerY.equalTo()(self)
            make?.left.equalTo()(11)
        }
        timeLabel.mas_makeConstraints { make in
            make?.centerY.equalTo()(self)
            make?.left.equalTo()(titleLabel.mas_right)?.offset()(2)
        }
        closeButton.mas_makeConstraints { make in
            make?.top.bottom().equalTo()(self)
            make?.width.equalTo()(44)
            make?.right.equalTo()(0)
        }
        line.mas_makeConstraints { make in
            make?.height.equalTo()(1)
            make?.left.right().bottom().equalTo()(self)
        }
    }
}
