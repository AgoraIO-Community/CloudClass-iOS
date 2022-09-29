//
//  RoomListItemCell.swift
//  AgoraEducation
//
//  Created by Jonathan on 2022/9/2.
//  Copyright © 2022 Agora. All rights reserved.
//

import UIKit
import AgoraEduCore

protocol RoomListItemCellDelegate: NSObjectProtocol {
    func onClickShare(at indexPath: IndexPath)
    func onClickEnter(at indexPath: IndexPath)
    func onClickCopy(at indexPath: IndexPath)
}
class RoomListItemCell: UITableViewCell {
    
    public weak var delegate: RoomListItemCellDelegate?
    
    public var model: RoomItemModel? {
        didSet {
            updateModel()
        }
    }
    
    public var indexPath: IndexPath?
    
    private enum RoomListItemCellType {
        case unknow, upcoming, living, closed
    }
    
    private var cellType: RoomListItemCellType = .unknow {
        didSet {
            guard cellType != oldValue else {
                return
            }
            updateCellType()
        }
    }
    
    let cardView = UIView()
    
    let stateIcon = UIImageView(image: UIImage(named: "fcr_room_list_state_live"))
    
    let stateLabel = UILabel()
    
    let verticalLine = UIView()
    
    let idTitleLabel = UILabel()
    
    let idLabel = UILabel()
    
    let copyButton = UIButton(type: .custom)
    
    let nameLabel = UILabel()
    
    let timeIcon = UIImageView(image: UIImage(named: "fcr_room_list_state_live"))
    
    let timeLabel = UILabel()
    
    let typeIcon = UIImageView(image: UIImage(named: "fcr_room_list_state_live"))
        
    let typeLabel = UILabel()
    
    let enterButton = UIButton(type: .custom)
    
    let shareButton = UIButton(type: .custom)
    
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
// MARK: - Actions
private extension RoomListItemCell {
    
    @objc func onClickShare(_ sender: UIButton) {
        guard let i = indexPath else {
            return
        }
        delegate?.onClickShare(at: i)
    }
    
    @objc func onClickEnter(_ sender: UIButton) {
        guard let i = indexPath else {
            return
        }
        delegate?.onClickEnter(at: i)
    }
    
    @objc func onClickCopy(_ sender: UIButton) {
        guard let i = indexPath else {
            return
        }
        delegate?.onClickCopy(at: i)
    }
}
// MARK: - Creations
private extension RoomListItemCell {
    func updateModel() {
        guard let item = model else {
            return
        }
        nameLabel.text = item.roomName
        idLabel.text = item.roomId
        updateDate()
        let type = AgoraEduCoreRoomType(rawValue: Int(item.roomType))
        switch type {
        case .oneToOne:
            typeLabel.text = "fcr_create_onetoone_title".ag_localized()
        case .lecture:
            typeLabel.text = "fcr_create_lecture_title".ag_localized()
        case .small:
            typeLabel.text = "fcr_create_small_title".ag_localized()
        case .none:
            typeLabel.text = ""
        case .some(_):
            typeLabel.text = ""
        }
    }
    
    func updateCellType() {
        switch cellType {
        case .upcoming:
            cardView.alpha = 1
            stateLabel.text = "fcr_room_list_upcoming".ag_localized()
            stateIcon.isHidden = true
            cardView.backgroundColor = UIColor(hex: 0xE4E6FF)
            shareButton.isHidden = false
            enterButton.isHidden = false
            enterButton.backgroundColor = UIColor(hex: 0x357BF6)
            enterButton.setTitleColor(.white,
                                      for: .normal)
            copyButton.isHidden = false
            shareButton.setImage(UIImage(named: "fcr_room_list_share_black"),
                                 for: .normal)
            copyButton.setImage(UIImage(named: "fcr_room_list_copy_black"),
                                for: .normal)
            timeIcon.image = UIImage(named: "fcr_room_list_clock_black")
            typeIcon.image = UIImage(named: "fcr_room_list_label_black")
            verticalLine.backgroundColor = .black
            // text color
            stateLabel.textColor = .black
            idTitleLabel.textColor = .black
            idLabel.textColor = .black
            nameLabel.textColor = .black
            timeLabel.textColor = .black
            typeLabel.textColor = .black
            stateLabel.mas_updateConstraints { make in
                make?.left.equalTo()(17)
            }
        case .living:
            cardView.alpha = 1
            stateLabel.text = "fcr_room_list_live_now".ag_localized()
            stateIcon.isHidden = false
            cardView.backgroundColor = UIColor(hex: 0x5765FF)
            shareButton.isHidden = false
            enterButton.isHidden = false
            enterButton.backgroundColor = .black
            shareButton.setImage(UIImage(named: "fcr_room_list_share_white"),
                                 for: .normal)
            copyButton.isHidden = false
            copyButton.setImage(UIImage(named: "fcr_room_list_copy_white"),
                                for: .normal)
            timeIcon.image = UIImage(named: "fcr_room_list_clock_white")
            typeIcon.image = UIImage(named: "fcr_room_list_label_white")
            verticalLine.backgroundColor = .white
            // text color
            stateLabel.textColor = .white
            idTitleLabel.textColor = .white
            idLabel.textColor = .white
            nameLabel.textColor = .white
            timeLabel.textColor = .white
            typeLabel.textColor = .white
            stateLabel.mas_updateConstraints { make in
                make?.left.equalTo()(35)
            }
        case .closed:
            cardView.alpha = 0.5
            stateLabel.text = "fcr_room_list_closed".ag_localized()
            stateIcon.isHidden = true
            cardView.backgroundColor = UIColor(hex: 0xF0F0F7)
            shareButton.isHidden = true
            enterButton.isHidden = true
            copyButton.isHidden = true
            timeIcon.image = UIImage(named: "fcr_room_list_clock_black")
            typeIcon.image = UIImage(named: "fcr_room_list_label_black")
            verticalLine.backgroundColor = .black
            // text color
            stateLabel.textColor = .black
            idTitleLabel.textColor = .black
            idLabel.textColor = .black
            nameLabel.textColor = .black
            timeLabel.textColor = .black
            typeLabel.textColor = .black
            stateLabel.mas_updateConstraints { make in
                make?.left.equalTo()(17)
            }
        default:
            break
        }
    }
    
    func updateDate() {
        guard let item = model else {
            return
        }
        let startDate = Date(timeIntervalSince1970: Double(item.startTime) * 0.001)
        let endDate = Date(timeIntervalSince1970: Double(item.endTime) * 0.001)
        let day = startDate.string(withFormat: "yyyy-MM-dd")
        let startTime = startDate.string(withFormat: "HH:mm")
        let endTime = endDate.string(withFormat: "HH:mm")
        timeLabel.text = "\(day)，\(startTime)-\(endTime)"
        let now = Date()
        if now.compare(startDate) == .orderedAscending {
            cellType = .upcoming
        } else if now.compare(endDate) == .orderedDescending {
            cellType = .closed
        } else {
            cellType = .living
        }
    }
    
    func createViews() {
        cardView.backgroundColor = UIColor(hex: 0x5765FF)
        cardView.layer.cornerRadius = 16
        cardView.clipsToBounds = true
        contentView.addSubview(cardView)
        
        cardView.addSubview(stateIcon)
        
        stateLabel.font = UIFont.boldSystemFont(ofSize: 12)
        stateLabel.text = "   "
        cardView.addSubview(stateLabel)
        
        cardView.addSubview(verticalLine)
        
        idTitleLabel.text = "ID"
        idTitleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        cardView.addSubview(idTitleLabel)
        
        idLabel.font = UIFont.systemFont(ofSize: 10)
        cardView.addSubview(idLabel)
        
        copyButton.setImage(UIImage(named: "fcr_room_list_copy_black"),
                            for: .normal)
        copyButton.addTarget(self,
                             action: #selector(onClickCopy(_:)),
                             for: .touchUpInside)
        cardView.addSubview(copyButton)
        
        nameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        cardView.addSubview(nameLabel)
        
        cardView.addSubview(timeIcon)
        
        timeLabel.font = UIFont.systemFont(ofSize: 10)
        cardView.addSubview(timeLabel)
                
        cardView.addSubview(typeIcon)
        
        typeLabel.font = UIFont.systemFont(ofSize: 10)
        cardView.addSubview(typeLabel)
        
        enterButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        enterButton.layer.cornerRadius = 18
        enterButton.clipsToBounds = true
        enterButton.setTitle("fcr_room_list_enter".ag_localized(),
                             for: .normal)
        enterButton.addTarget(self,
                              action: #selector(onClickEnter(_:)),
                              for: .touchUpInside)
        cardView.addSubview(enterButton)
        
        shareButton.setImage(UIImage(named: "fcr_room_list_share_black"),
                             for: .normal)
        shareButton.addTarget(self,
                              action: #selector(onClickShare(_:)),
                              for: .touchUpInside)
        cardView.addSubview(shareButton)
    }
    
    func createConstrains() {
        cardView.mas_makeConstraints { make in
            make?.edges.equalTo()(UIEdgeInsets(top: 6,
                                               left: 14,
                                               bottom: 6,
                                               right: 14))
        }
        stateIcon.mas_makeConstraints { make in
            make?.left.top().equalTo()(14)
        }
        stateLabel.mas_makeConstraints { make in
            make?.left.equalTo()(17)
            make?.centerY.equalTo()(stateIcon)
        }
        verticalLine.mas_makeConstraints { make in
            make?.left.equalTo()(stateLabel.mas_right)?.offset()(8)
            make?.centerY.equalTo()(stateLabel)
            make?.width.equalTo()(1)
            make?.height.equalTo()(8)
        }
        idTitleLabel.mas_makeConstraints { make in
            make?.left.equalTo()(verticalLine.mas_right)?.offset()(12)
            make?.centerY.equalTo()(stateLabel)
        }
        idLabel.mas_makeConstraints { make in
            make?.left.equalTo()(idTitleLabel.mas_right)?.offset()(4)
            make?.centerY.equalTo()(stateLabel)
        }
        copyButton.mas_makeConstraints { make in
            make?.left.equalTo()(idLabel.mas_right)
            make?.centerY.equalTo()(stateLabel)
        }
        shareButton.mas_makeConstraints { make in
            make?.top.equalTo()(14)
            make?.right.equalTo()(-12)
        }
        nameLabel.mas_makeConstraints { make in
            make?.left.equalTo()(17)
            make?.top.equalTo()(stateLabel.mas_bottom)?.offset()(12)
        }
        timeIcon.mas_makeConstraints { make in
            make?.top.equalTo()(nameLabel.mas_bottom)?.offset()(17)
            make?.left.equalTo()(nameLabel)
        }
        timeLabel.mas_makeConstraints { make in
            make?.centerY.equalTo()(timeIcon)
            make?.left.equalTo()(timeIcon.mas_right)?.offset()(8)
        }
        typeIcon.mas_makeConstraints { make in
            make?.top.equalTo()(timeLabel.mas_bottom)?.offset()(7)
            make?.left.equalTo()(nameLabel)
        }
        typeLabel.mas_makeConstraints { make in
            make?.centerY.equalTo()(typeIcon)
            make?.left.equalTo()(typeIcon.mas_right)?.offset()(8)
        }
        enterButton.mas_makeConstraints { make in
            make?.right.offset()(-14)
            make?.bottom.offset()(-19)
            make?.width.equalTo()(100)
            make?.height.equalTo()(36)
        }
    }
}
//
class RoomListTitleCell: UITableViewCell {
    
    let label = UILabel()
    
    let leftFillCorner = UIView()
    let rightFillCorner = UIView()
    
    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(style: style,
                   reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .white
        self.contentView.cornerRadius = 33
        self.contentView.clipsToBounds = true
        
        leftFillCorner.backgroundColor = .white
        addSubview(leftFillCorner)
        leftFillCorner.mas_makeConstraints { make in
            make?.left.bottom().equalTo()(0)
            make?.width.height().equalTo()(33)
        }
        rightFillCorner.backgroundColor = .white
        addSubview(rightFillCorner)
        rightFillCorner.mas_makeConstraints { make in
            make?.top.bottom().right().equalTo()(0)
            make?.width.equalTo()(33)
        }
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.text = "fcr_room_list_rooms".ag_localized()
        addSubview(label)
        label.mas_makeConstraints { make in
            make?.left.equalTo()(21)
            make?.centerY.equalTo()(0)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
//
class RoomListNotiCell: UITableViewCell {
    
    let cardView = UIView()
    
    let label = UILabel()
    
    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(style: style,
                   reuseIdentifier: reuseIdentifier)
        
        cardView.backgroundColor = UIColor(hex: 0x357BF6)
        cardView.layer.cornerRadius = 20
        cardView.clipsToBounds = true
        contentView.addSubview(cardView)
        
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.text = "fcr_room_list_room_created".ag_localized()
        contentView.addSubview(label)
        
        label.mas_makeConstraints { make in
            make?.center.equalTo()(0)
            make?.height.greaterThanOrEqualTo()(20)
            make?.width.greaterThanOrEqualTo()(126)
        }
        cardView.mas_makeConstraints { make in
            make?.center.equalTo()(label)
            make?.width.equalTo()(label)?.offset()(44)
            make?.height.equalTo()(label)?.offset()(20)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
//
class RoomListEmptyCell: UITableViewCell {
    
    let emptyImageView = UIImageView(image: UIImage(named: "fcr_room_list_empty"))
    
    let label = UILabel()
    
    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(style: style,
                   reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(emptyImageView)
        emptyImageView.mas_makeConstraints { make in
            make?.top.equalTo()(89)
            make?.centerX.equalTo()(0)
        }
        label.text = "fcr_room_list_empty".ag_localized()
        label.textColor = UIColor(hex: 0xACABB0)
        label.font = UIFont.systemFont(ofSize: 12)
        contentView.addSubview(label)
        label.mas_makeConstraints { make in
            make?.top.equalTo()(emptyImageView.mas_bottom)?.offset()(10)
            make?.centerX.equalTo()(0)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
