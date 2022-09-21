//
//  RoomCreateMoreInfoCells.swift
//  AgoraEducation
//
//  Created by Jonathan on 2022/9/17.
//  Copyright © 2022 Agora. All rights reserved.
//

import UIKit

// 房间更多信息
class RoomMoreTitleCell: UITableViewCell {
    
    public var spred = false {
        didSet {
            guard spred != oldValue else {
                return
            }
            if spred {
                arrow.isHidden = true
                titleLabel.mas_remakeConstraints { make in
                    make?.left.equalTo()(cardView)?.offset()(18)
                    make?.centerY.equalTo()(cardView)
                }
            } else {
                arrow.isHidden = false
                titleLabel.mas_remakeConstraints { make in
                    make?.center.equalTo()(cardView)
                }
            }
        }
    }
    
    private let titleLabel = UILabel()
    
    private let arrow = UIImageView(image: UIImage(named: "fcr_room_create_arrow_down"))
    
    private let cardView = UIView()
        
    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(style: style,
                   reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        createViews()
        createConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createViews() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        cardView.backgroundColor = UIColor.white
        contentView.addSubview(cardView)
        
        titleLabel.textColor = UIColor.black
        titleLabel.font = UIFont.boldSystemFont(ofSize: 13)
        titleLabel.text = "fcr_create_more_setting".ag_localized()
        contentView.addSubview(titleLabel)
        
        contentView.addSubview(arrow)
    }
    
    private func createConstrains() {
        cardView.mas_makeConstraints { make in
            make?.top.equalTo()(10)
            make?.left.equalTo()(15)
            make?.right.equalTo()(-15)
            make?.bottom.equalTo()(0)
        }
        titleLabel.mas_makeConstraints { make in
            make?.center.equalTo()(cardView)
        }
        arrow.mas_makeConstraints { make in
            make?.centerY.equalTo()((titleLabel))
            make?.left.equalTo()(titleLabel.mas_right)
            make?.width.height().equalTo()(20)
        }
    }
}
// 直播安全
class RoomSecurityInfoCell: UITableViewCell {
    
    public let switchButton = UIButton(type: .custom)
    
    private let cardView = UIView()
    
    private let lineView = UIView()
    
    private let iconView = UIImageView(image: UIImage(named: "fcr_room_create_security"))
    
    private let titleLabel = UILabel()
    
    private let detailLabel = UILabel()
        
    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(style: style,
                   reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        createViews()
        createConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createViews() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        cardView.backgroundColor = UIColor.white
        contentView.addSubview(cardView)
        
        lineView.backgroundColor = UIColor(hex: 0xEFEFEF)
        contentView.addSubview(lineView)
        
        contentView.addSubview(iconView)
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 13)
        titleLabel.text = "fcr_create_more_security".ag_localized() + "·"
        titleLabel.textColor = UIColor.black
        contentView.addSubview(titleLabel)
        
        detailLabel.font = UIFont.boldSystemFont(ofSize: 13)
        detailLabel.text = "fcr_create_more_security_detail".ag_localized()
        detailLabel.textColor = UIColor(hex: 0x757575)
        contentView.addSubview(detailLabel)
        
        switchButton.setImage(UIImage(named: "fcr_room_create_off"),
                              for: .normal)
        switchButton.setImage(UIImage(named: "fcr_room_create_on"),
                              for: .selected)
        contentView.addSubview(switchButton)
    }
    
    private func createConstrains() {
        cardView.mas_makeConstraints { make in
            make?.top.bottom().equalTo()(0)
            make?.left.equalTo()(15)
            make?.right.equalTo()(-15)
        }
        lineView.mas_makeConstraints { make in
            make?.left.equalTo()(cardView)?.offset()(15)
            make?.right.bottom().equalTo()(0)
            make?.height.equalTo()(1)
        }
        iconView.mas_makeConstraints { make in
            make?.left.equalTo()(cardView)?.offset()(16)
            make?.centerY.equalTo()(0)
            make?.width.height().equalTo()(18)
        }
        titleLabel.mas_makeConstraints { make in
            make?.left.equalTo()(iconView.mas_right)?.offset()(8)
            make?.centerY.equalTo()(iconView)
        }
        detailLabel.mas_makeConstraints { make in
            make?.left.equalTo()(titleLabel.mas_right)?.offset()(12)
            make?.centerY.equalTo()(iconView)
        }
        switchButton.mas_makeConstraints { make in
            make?.right.equalTo()(cardView)?.offset()(-16)
            make?.centerY.equalTo()(0)
        }
    }
}
// 伪直播开关
class RoomPlayBackInfoCell: UITableViewCell {
    
    public let switchButton = UIButton(type: .custom)
    
    private let cardView = UIView()
    
    private let lineView = UIView()
    
    private let iconView = UIImageView(image: UIImage(named: "fcr_room_create_playback"))
    
    private let titleLabel = UILabel()
        
    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(style: style,
                   reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        createViews()
        createConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createViews() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        cardView.backgroundColor = UIColor.white
        contentView.addSubview(cardView)
        
        lineView.backgroundColor = UIColor(hex: 0xEFEFEF)
        contentView.addSubview(lineView)
        
        contentView.addSubview(iconView)
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 13)
        titleLabel.text = "fcr_create_more_playback".ag_localized()
        titleLabel.textColor = UIColor.black
        contentView.addSubview(titleLabel)
        
        switchButton.setImage(UIImage(named: "fcr_room_create_off"),
                              for: .normal)
        switchButton.setImage(UIImage(named: "fcr_room_create_on"),
                              for: .selected)
        contentView.addSubview(switchButton)
    }
    
    private func createConstrains() {
        cardView.mas_makeConstraints { make in
            make?.top.bottom().equalTo()(0)
            make?.left.equalTo()(15)
            make?.right.equalTo()(-15)
        }
        lineView.mas_makeConstraints { make in
            make?.left.equalTo()(cardView)?.offset()(15)
            make?.right.bottom().equalTo()(0)
            make?.height.equalTo()(1)
        }
        iconView.mas_makeConstraints { make in
            make?.left.equalTo()(cardView)?.offset()(16)
            make?.centerY.equalTo()(0)
            make?.width.height().equalTo()(18)
        }
        titleLabel.mas_makeConstraints { make in
            make?.left.equalTo()(iconView.mas_right)?.offset()(8)
            make?.centerY.equalTo()(iconView)
        }
        switchButton.mas_makeConstraints { make in
            make?.right.equalTo()(cardView)?.offset()(-16)
            make?.centerY.equalTo()(0)
        }
    }
}
// 伪直播输入框
class RoomPlayBackInputCell: UITableViewCell {
            
    public let label = UILabel()
    
    private let cardView = UIView()
    
    private let lineView = UIView()
    
    private let arrow = UIImageView(image: UIImage(named: "fcr_room_create_right_arrow"))
        
    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(style: style,
                   reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        createViews()
        createConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createViews() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        cardView.backgroundColor = UIColor.white
        contentView.addSubview(cardView)
        
        lineView.backgroundColor = UIColor(hex: 0xEFEFEF)
        contentView.addSubview(lineView)
        
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.black
        contentView.addSubview(label)
        
        contentView.addSubview(arrow)
    }
    
    private func createConstrains() {
        cardView.mas_makeConstraints { make in
            make?.top.bottom().equalTo()(0)
            make?.left.equalTo()(15)
            make?.right.equalTo()(-15)
        }
        lineView.mas_makeConstraints { make in
            make?.left.equalTo()(cardView)?.offset()(15)
            make?.right.bottom().equalTo()(0)
            make?.height.equalTo()(1)
        }
        arrow.mas_makeConstraints { make in
            make?.centerY.equalTo()(0)
            make?.right.equalTo()(cardView)?.offset()(-12)
            make?.width.height().equalTo()(30)
        }
        label.mas_makeConstraints { make in
            make?.left.equalTo()(cardView)?.offset()(46)
            make?.top.bottom().equalTo()(0)
            make?.right.equalTo()(arrow.mas_left)
        }
    }
}
