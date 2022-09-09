//
//  RoomCreateTableCells.swift
//  AgoraEducation
//
//  Created by Jonathan on 2022/9/5.
//  Copyright © 2022 Agora. All rights reserved.
//

import UIKit

protocol RoomBaseInfoCellDelegate: NSObjectProtocol {
    
    func onClickInputRoomTitle()
}
// 房间基本信息：名称及班型
class RoomBaseInfoCell: UITableViewCell {
    
    public var delegate: RoomBaseInfoCellDelegate?
    
    public var optionsView: UIView? {
        didSet {
            if optionsView != oldValue {
                if let view = oldValue {
                    view.removeFromSuperview()
                }
                if let view = optionsView {
                    cardView.addSubview(view)
                    view.mas_makeConstraints { make in
                        make?.top.equalTo()(lineView.mas_bottom)?.offset()(20)
                        make?.left.right().equalTo()(0)
                        make?.bottom.equalTo()(-20)
                    }
                }
            }
        }
    }
    
    public var dataSource = [String]()
    
    public var roomName: String? {
        didSet {
            if roomName != oldValue {
                updateRoomName()
            }
        }
    }
    
    private let cardView = UIView()
    
    private let inputButton = UIButton(type: .custom)
    
    private let lineView = UIView()
    
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
    
    private func updateRoomName() {
        if let text = roomName {
            inputButton.setTitle(text,
                                 for: .normal)
        } else {
            
        }
    }
    
    private func createViews() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        cardView.backgroundColor = UIColor.white
        cardView.layer.cornerRadius = 16
        cardView.clipsToBounds = true
        contentView.addSubview(cardView)
        
        cardView.addSubview(inputButton)
        
        lineView.backgroundColor = UIColor(hex: 0xEFEFEF)
        cardView.addSubview(lineView)
    }
    
    private func createConstrains() {
        cardView.mas_makeConstraints { make in
            make?.top.bottom().equalTo()(0)
            make?.left.equalTo()(15)
            make?.right.equalTo()(-15)
        }
        inputButton.mas_makeConstraints { make in
            make?.top.equalTo()(36)
            make?.left.right().equalTo()(0)
            make?.height.equalTo()(44)
        }
        lineView.mas_makeConstraints { make in
            make?.left.equalTo()(12)
            make?.right.equalTo()(-12)
            make?.height.equalTo()(1)
            make?.bottom.equalTo()(inputButton)
        }
    }
}
// 班型选项
class RoomTypeInfoCell: UICollectionViewCell {
    
    public let imageView = UIImageView()
    
    public let titleLabel = UILabel()
    
    public let subTitleLabel = UILabel()
    
    public let selectedView = UIImageView()
    
    public var aSelected = false {
        didSet {
            guard aSelected != oldValue else {
                return
            }
            if aSelected {
                
            } else {
                
            }
        }
    }
    
    private let selectIcon = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .orange
        createViews()
        createConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createViews() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        imageView.backgroundColor = UIColor.white
        contentView.addSubview(imageView)
        
        titleLabel.textColor = UIColor.white
        contentView.addSubview(titleLabel)
        
        subTitleLabel.textColor = UIColor.white
        contentView.addSubview(subTitleLabel)
        
        contentView.addSubview(selectedView)
    }
    
    private func createConstrains() {
        imageView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
        titleLabel.mas_makeConstraints { make in
            make?.top.equalTo()(15)
            make?.left.right().equalTo()(0)
        }
        subTitleLabel.mas_makeConstraints { make in
            make?.top.equalTo()(titleLabel.mas_bottom)?.offset()(8)
        }
        selectedView.mas_makeConstraints { make in
            make?.width.height().equalTo()(30)
            make?.top.equalTo()(-15)
            make?.right.equalTo()(15)
        }
    }
}
// 房间subType选项信息
class RoomSubTypeInfoCell: UITableViewCell {
    
    private let cardView = UIView()
    
    private let iconView = UIView()
    
    private let titleLabel = UILabel()
    
    private let infoLabel = UILabel()
    
    private let selectView = UIImageView()
    
    private let lineView = UIView()
    
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
    
    private func createViews() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        cardView.backgroundColor = UIColor.white
        contentView.addSubview(cardView)
        
        iconView.backgroundColor = UIColor(hex: 0xD9D9D9)
        iconView.layer.cornerRadius = 8
        iconView.clipsToBounds = true
        cardView.addSubview(iconView)
        
        cardView.addSubview(titleLabel)
        
        cardView.addSubview(infoLabel)
        
        cardView.addSubview(selectView)
        
        lineView.backgroundColor = UIColor(hex: 0xEFEFEF)
        cardView.addSubview(lineView)
    }
    
    private func createConstrains() {
        cardView.mas_makeConstraints { make in
            make?.top.bottom().equalTo()(0)
            make?.left.equalTo()(15)
            make?.right.equalTo()(-15)
        }
        iconView.mas_makeConstraints { make in
            make?.left.top().equalTo()(16)
            make?.width.height().equalTo()(16)
        }
        titleLabel.mas_makeConstraints { make in
            make?.centerY.equalTo()(iconView)
            make?.left.equalTo()(iconView.mas_right)?.offset()(8)
        }
        infoLabel.mas_makeConstraints { make in
            make?.top.equalTo()(titleLabel.mas_bottom)
            make?.left.equalTo()(titleLabel)
        }
        selectView.mas_makeConstraints { make in
            make?.centerY.equalTo()(0)
            make?.right.equalTo()(-16)
            make?.width.height().equalTo()(30)
        }
        lineView.mas_makeConstraints { make in
            make?.left.equalTo()(titleLabel)
            make?.right.equalTo()(0)
            make?.bottom.equalTo()(0)
            make?.height.equalTo()(1)
        }
    }
}
// 房间时间信息
class RoomTimeInfoCell: UITableViewCell {
    
    private let cardView = UIView()
    
    private let startTitleLabel = UILabel()
    
    private let endTitleLabel = UILabel()
    
    private let startTimeLabel = UILabel()
    
    private let endTimeLabel = UILabel()
    
    private let endInfoLabel = UILabel()
    
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
    
    private func createViews() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        cardView.backgroundColor = UIColor.white
        cardView.layer.cornerRadius = 16
        cardView.clipsToBounds = true
        contentView.addSubview(cardView)
        
        startTitleLabel.text = "Start Time"
        startTitleLabel.textColor = UIColor(hex: 0x757575)
        cardView.addSubview(startTitleLabel)
        
        endTitleLabel.text = "End Time"
        endTitleLabel.textColor = UIColor(hex: 0x757575)
        cardView.addSubview(endTitleLabel)
        
        startTimeLabel.text = "Start Time"
        startTimeLabel.textColor = UIColor.black
        cardView.addSubview(startTimeLabel)
        
        endTimeLabel.text = "End Time"
        endTimeLabel.textColor = UIColor(hex: 0x757575)
        cardView.addSubview(endTimeLabel)
        
        endInfoLabel.text = "End Time"
        endInfoLabel.textColor = UIColor(hex: 0x757575)
        cardView.addSubview(endInfoLabel)
    }
    
    private func createConstrains() {
        cardView.mas_makeConstraints { make in
            make?.top.equalTo()(10)
            make?.left.equalTo()(15)
            make?.right.equalTo()(-15)
            make?.bottom.equalTo()(0)
        }
        startTitleLabel.mas_makeConstraints { make in
            make?.top.equalTo()(13)
            make?.left.equalTo()(21)
        }
        endTitleLabel.mas_makeConstraints { make in
            make?.centerY.equalTo()(startTitleLabel)
            make?.left.equalTo()(contentView.mas_centerX)
        }
        startTimeLabel.mas_makeConstraints { make in
            make?.left.equalTo()(startTitleLabel)
            make?.top.equalTo()(startTitleLabel.mas_bottom)?.offset()(12)
        }
        endTimeLabel.mas_makeConstraints { make in
            make?.left.equalTo()(endTitleLabel)
            make?.centerY.equalTo()(startTimeLabel)
        }
        endInfoLabel.mas_makeConstraints { make in
            make?.left.equalTo()(endTimeLabel.mas_right)
            make?.bottom.equalTo()(endTimeLabel)
        }
    }
}
// 房间时间信息
class RoomMoreInfoCell: UITableViewCell {
    
    public var spred = false {
        didSet {
            
        }
    }
    
    private let cardView = UIView()
    
//    private let cardView = UIView()
//
//    private let cardView = UIView()
    
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
    
    private func createViews() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        cardView.backgroundColor = UIColor.white
        cardView.layer.cornerRadius = 16
        cardView.clipsToBounds = true
        contentView.addSubview(cardView)
    }
    
    private func createConstrains() {
        cardView.mas_makeConstraints { make in
            make?.top.equalTo()(10)
            make?.left.equalTo()(15)
            make?.right.equalTo()(-15)
            make?.bottom.equalTo()(0)
        }
    }
}
