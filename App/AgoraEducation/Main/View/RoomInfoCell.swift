//
//  RoomInfoCell.swift
//  AgoraEducation
//
//  Created by HeZhengQing on 2021/9/9.
//  Copyright © 2021 Agora. All rights reserved.
//

import AgoraUIBaseViews
import Foundation
import UIKit

protocol RoomInfoCellDelegate: AnyObject {
    /** 开始编辑cell上的文字*/
    func infoCellDidBeginEditing(cell: RoomInfoCell);
    /** 结束编辑cell上的文字*/
    func infoCellInputTextDidChange(cell: RoomInfoCell);
    /** 结束编辑cell上的文字*/
    func infoCellDidEndEditing(cell: RoomInfoCell);
    /** 结束时间选择*/
    func timePickerDidEndChoosing(timeInterval: Int64);
}

enum RoomInfoCellMode {
    case none
    case input
    case option
    case unable
    case timePick
}

class RoomInfoCell: UITableViewCell {
    
    var indexPath = IndexPath.init(row: 0, section: 0)
    
    weak var delegate: RoomInfoCellDelegate?
    
    var titleLabel: UILabel!
    
    var textField: UITextField!
    
    var lineView: UIView!
    
    let maxInputLength = 50
    
    private var indicatorView: UIImageView!
    
    private var timePickerView: UIDatePicker!
    
    lazy var roomWarningLabel: UILabel = {
        return createWarningLabel(type: .roomName)
    }()
    
    lazy var userWarningLabel: UILabel = {
        return createWarningLabel(type: .nickName)
    }()
    
    private var aFocused: Bool = false
    
    var mode: RoomInfoCellMode = .none {
        didSet {
            switch mode {
            case .input:
                textField.isUserInteractionEnabled = true
                indicatorView.isHidden = true
                timePickerView.isHidden = true
            case .option:
                textField.isUserInteractionEnabled = false
                indicatorView.isHidden = false
                timePickerView.isHidden = true
            case .unable:
                textField.isUserInteractionEnabled = false
                indicatorView.isHidden = true
                timePickerView.isHidden = true
            case .timePick:
                textField.isUserInteractionEnabled = false
                indicatorView.isHidden = true
                timePickerView.isHidden = false
            default: break
            }
        }
    }
    
    var isRoomWarning: Bool = false {
        didSet {
            if isRoomWarning {
                lineView.backgroundColor = UIColor(hexString: "#F04C36")
                roomWarningLabel.isHidden = false
            } else {
                lineView.backgroundColor = UIColor(hexString: "#E3E3EC")
                roomWarningLabel.isHidden = true
            }
        }
    }
    
    var isUserWarning: Bool = false {
        didSet {
            if isUserWarning {
                lineView.backgroundColor = UIColor(hexString: "#F04C36")
                userWarningLabel.isHidden = false
            } else {
                lineView.backgroundColor = UIColor(hexString: "#E3E3EC")
                userWarningLabel.isHidden = true
            }
        }
    }
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        createViews()
        createConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setFocused(_ focused: Bool) {
        if (mode == .option) { // 多项选中状态
            if aFocused != focused {
                aFocused = focused
                indicatorView.transform = indicatorView.transform.rotated(by: CGFloat(Double.pi))
            }
        }
    }
    
    @objc func onTextDidChange(_ sender: UITextField) {
        delegate?.infoCellInputTextDidChange(cell: self)
    }
    
    @objc func timeChanged(_ datePicker : UIDatePicker){
        let timeInterval = Int64(datePicker.date.timeIntervalSince1970 * 1000)
        delegate?.timePickerDidEndChoosing(timeInterval: timeInterval)
    }
}

// MARK: - UITextFieldDelegate
extension RoomInfoCell: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.infoCellDidBeginEditing(cell: self)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.infoCellDidEndEditing(cell: self)
    }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard let text = textField.text else {
            return false
        }
        let strLength = text.count - range.length + string.count
        return strLength <= maxInputLength
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return mode == .input
    }
}

// MARK: - Creations
extension RoomInfoCell {
    func createViews() {
        titleLabel = UILabel()
        titleLabel.textColor = UIColor(hexString: "8A8A9A")
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        contentView.addSubview(titleLabel)
        
        textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.keyboardType = .emailAddress
        textField.delegate = self
        textField.addTarget(self, action: #selector(onTextDidChange(_:)), for: .editingChanged)
        contentView.addSubview(textField)
        
        lineView = UIView()
        lineView.backgroundColor = UIColor(hexString: "#E3E3EC")
        contentView.addSubview(lineView)
        
        indicatorView = UIImageView(image: UIImage(named: "show_types"))
        contentView.addSubview(indicatorView)
        
        timePickerView = UIDatePicker(frame: .zero)
        timePickerView.locale = Locale.current
        timePickerView.datePickerMode = .time
        timePickerView.minimumDate = Date()
        timePickerView.addTarget(self,
                                 action: #selector(timeChanged(_:)),
                             for: .valueChanged)
        contentView.addSubview(timePickerView)
    }
    
    func createConstraint() {
        titleLabel.mas_makeConstraints { make in
            make?.top.left().equalTo()(0)
            make?.height.equalTo()(40)
            make?.width.equalTo()(58)
        }
        textField.mas_makeConstraints { make in
            make?.top.right().equalTo()(0)
            make?.left.equalTo()(titleLabel.mas_right)
            make?.height.equalTo()(40)
        }
        indicatorView.mas_makeConstraints { make in
            make?.right.equalTo()(0)
            make?.centerY.equalTo()(titleLabel)
        }
        lineView.mas_makeConstraints { make in
            make?.top.equalTo()(textField.mas_bottom)
            make?.left.right().equalTo()(0)
            make?.height.equalTo()(1)
        }
        timePickerView.mas_makeConstraints { make in
            make?.top.equalTo()(0)
            make?.height.equalTo()(40)
            make?.left.equalTo()(titleLabel.mas_right)
            make?.right.equalTo()(0)
        }
    }
    
    func createWarningLabel(type: RoomInfoItemType) -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = UIColor(hexString: "#F04C36")
        label.textAlignment = .center
        label.isHidden = true
        contentView.addSubview(label)
        label.mas_makeConstraints { make in
            make?.left.right().equalTo()(0)
            make?.top.equalTo()(lineView.mas_bottom)
        }

        switch type {
        case .roomName:
            label.text = "Login_room_warn".ag_localized()
        case .nickName:
            label.text = "Login_user_warn".ag_localized()
        default:
            break
        }
        return label
    }
}
