//
//  RoomCreateTableCells.swift
//  AgoraEducation
//
//  Created by Jonathan on 2022/9/5.
//  Copyright © 2022 Agora. All rights reserved.
//

import UIKit

protocol RoomBaseInfoCellDelegate: NSObjectProtocol {
    
    func onRoomNameChanged(text: String)
}
// 房间基本信息：名称及班型
class RoomBaseInfoCell: UITableViewCell, UITextFieldDelegate {
    
    public weak var delegate: RoomBaseInfoCellDelegate?
    
    public var optionsView: UIView? {
        didSet {
            if optionsView != oldValue {
                if let view = oldValue {
                    view.removeFromSuperview()
                }
                if let view = optionsView {
                    cardView.addSubview(view)
                    view.mas_makeConstraints { make in
                        make?.top.equalTo()(lineView.mas_bottom)
                        make?.left.right().equalTo()(0)
                        make?.bottom.equalTo()(-20)
                    }
                }
            }
        }
    }
    
    public var inputText: String? {
        didSet {
            guard inputText != oldValue else {
                return
            }
            textFeild.text = inputText
            textFieldDidEndEditing(textFeild)
        }
    }
    
    private let cardView = UIView()
    
    private let textFeild = UITextField(frame: .zero)
    
    private let editIcon = UIImageView(image: UIImage(named: "fcr_room_create_edit"))
    private let editInfoLabel = UILabel()
    
    private let lineView = UIView()
    
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        editIcon.isHidden = true
        editInfoLabel.isHidden = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        editIcon.isHidden = !textField.isEmpty
        editInfoLabel.isHidden = !textField.isEmpty
        delegate?.onRoomNameChanged(text: textField.text ?? "")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard let text = textField.text else {
            return true
        }
        if text.count > 50 && string.count != 0 {
            return false
        }
        return true
    }
    
    private func createViews() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        cardView.backgroundColor = UIColor.white
        cardView.layer.cornerRadius = 16
        cardView.clipsToBounds = true
        contentView.addSubview(cardView)
        
        cardView.addSubview(editIcon)
        
        editInfoLabel.textColor = UIColor(hex: 0xBDBEC6)
        editInfoLabel.font = UIFont.systemFont(ofSize: 15)
        editInfoLabel.text = "fcr_create_input_name".localized()
        cardView.addSubview(editInfoLabel)
        
        textFeild.font = UIFont.boldSystemFont(ofSize: 15)
        textFeild.textAlignment = .center
        textFeild.returnKeyType = .done
        textFeild.delegate = self
        cardView.addSubview(textFeild)
        
        lineView.backgroundColor = UIColor(hex: 0xEFEFEF)
        cardView.addSubview(lineView)
    }
    
    private func createConstrains() {
        cardView.mas_makeConstraints { make in
            make?.top.bottom().equalTo()(0)
            make?.left.equalTo()(15)
            make?.right.equalTo()(-15)
        }
        editInfoLabel.mas_makeConstraints { make in
            make?.top.equalTo()(36)
            make?.centerX.equalTo()(0)?.offset()(20)
            make?.height.equalTo()(44)
        }
        editIcon.mas_makeConstraints { make in
            make?.centerY.equalTo()(editInfoLabel)
            make?.right.equalTo()(editInfoLabel.mas_left)
        }
        textFeild.mas_makeConstraints { make in
            make?.left.equalTo()(16)
            make?.right.equalTo()(-16)
            make?.top.height().equalTo()(editInfoLabel)
        }
        lineView.mas_makeConstraints { make in
            make?.left.equalTo()(12)
            make?.right.equalTo()(-12)
            make?.height.equalTo()(1)
            make?.bottom.equalTo()(editInfoLabel)
        }
    }
}
// 班型选项
class RoomTypeInfoCell: UICollectionViewCell {
    
    public let imageView = UIImageView()
    
    public let titleLabel = UILabel()
    
    public let subTitleLabel = UILabel()
    
    public let selectedView = UIImageView(image: UIImage(named: "fcr_room_create_sel"))
    
    public var aSelected = false {
        didSet {
            guard aSelected != oldValue else {
                return
            }
            selectedView.isHidden = !aSelected
        }
    }
    
    private let selectIcon = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
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
        titleLabel.font = UIFont.boldSystemFont(ofSize: 14)
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        
        subTitleLabel.textColor = UIColor.white
        subTitleLabel.font = UIFont.systemFont(ofSize: 12)
        subTitleLabel.textAlignment = .center
        contentView.addSubview(subTitleLabel)
        
        selectedView.isHidden = true
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
            make?.left.right().equalTo()(0)
        }
        selectedView.mas_makeConstraints { make in
            make?.width.height().equalTo()(30)
            make?.top.equalTo()(imageView)?.offset()(-8)
            make?.right.equalTo()(imageView)?.offset()(8)
        }
    }
}
// 房间subType选项信息
class RoomSubTypeInfoCell: UITableViewCell {
    
    public let iconView = UIImageView()
    
    public let titleLabel = UILabel()
    
    public let subTitleLabel = UILabel()
    
    private let cardView = UIView()
    
    private let selectedView = UIImageView(image: UIImage(named: "fcr_room_create_unsel"))
    
    private let lineView = UIView()
    
    public var aSelected = false {
        didSet {
            guard aSelected != oldValue else {
                return
            }
            selectedView.image = aSelected ? UIImage(named: "fcr_room_create_sel") : UIImage(named: "fcr_room_create_unsel")
        }
    }
    
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
        
        cardView.backgroundColor = UIColor(red: 254, green: 254, blue: 255)
        contentView.addSubview(cardView)
        
        cardView.addSubview(iconView)
        
        titleLabel.textColor = .black
        titleLabel.font = UIFont.systemFont(ofSize: 13)
        cardView.addSubview(titleLabel)
        
        subTitleLabel.textColor = UIColor(hex: 0x757575)
        subTitleLabel.font = UIFont.systemFont(ofSize: 8)
        cardView.addSubview(subTitleLabel)
        
        cardView.addSubview(selectedView)
        
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
            make?.left.equalTo()(16)
            make?.centerY.equalTo()(0)
            make?.width.height().equalTo()(22)
        }
        titleLabel.mas_makeConstraints { make in
            make?.centerY.equalTo()(-10)
            make?.left.equalTo()(iconView.mas_right)?.offset()(8)
        }
        subTitleLabel.mas_makeConstraints { make in
            make?.centerY.equalTo()(10)
            make?.left.equalTo()(titleLabel)
        }
        selectedView.mas_makeConstraints { make in
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
    
    private let arrowIcon = UIImageView(image: UIImage(named: "fcr_room_create_time_arrow"))
    
    private let endTimeLabel = UILabel()
    
    private let endInfoLabel = UILabel()
    
    public var startDate: Date? {
        didSet {
            if let date = startDate {
                startTimeLabel.text = date.string(withFormat: "fcr_create_table_time_format".ag_localized())
                let endDate = date.addingTimeInterval(30*60)
                endTimeLabel.text = endDate.string(withFormat: "HH:mm")
            } else {
                startTimeLabel.text = "fcr_create_current_time".ag_localized()
                endTimeLabel.text = ""
            }
        }
    }
    
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
        cardView.layer.cornerRadius = 16
        cardView.clipsToBounds = true
        contentView.addSubview(cardView)
        
        startTitleLabel.text = "fcr_create_start_time".localized()
        startTitleLabel.font = UIFont.systemFont(ofSize: 13)
        startTitleLabel.textColor = UIColor(hex: 0x757575)
        cardView.addSubview(startTitleLabel)
        
        endTitleLabel.text = "fcr_create_end_time".localized()
        endTitleLabel.font = UIFont.systemFont(ofSize: 13)
        endTitleLabel.textColor = UIColor(hex: 0x757575)
        cardView.addSubview(endTitleLabel)
        
        startTimeLabel.text = "Start Time"
        startTimeLabel.font = UIFont.boldSystemFont(ofSize: 14)
        startTimeLabel.textColor = UIColor.black
        cardView.addSubview(startTimeLabel)
        
        cardView.addSubview(arrowIcon)
        
        endTimeLabel.text = "fcr_create_end_time".localized()
        endTimeLabel.font = UIFont.boldSystemFont(ofSize: 14)
        endTimeLabel.textColor = UIColor(hex: 0x757575)
        cardView.addSubview(endTimeLabel)
        
        endInfoLabel.text = "fcr_create_end_time_info".localized()
        endInfoLabel.font = UIFont.systemFont(ofSize: 10)
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
            make?.top.equalTo()(cardView)?.offset()(16)
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
        arrowIcon.mas_makeConstraints { make in
            make?.left.equalTo()(startTimeLabel.mas_right)?.offset()(5)
            make?.centerY.equalTo()(startTimeLabel)
        }
        endTimeLabel.mas_makeConstraints { make in
            make?.left.equalTo()(endTitleLabel)
            make?.centerY.equalTo()(startTimeLabel)
            make?.height.greaterThanOrEqualTo()(10)
        }
        endInfoLabel.mas_makeConstraints { make in
            make?.left.equalTo()(endTimeLabel.mas_right)?.offset()(8)
            make?.bottom.equalTo()(endTimeLabel)
        }
    }
}
