//
//  DebugInfoCell.swift
//  AgoraEducation
//
//  Created by DoubleCircle on 2022/8/6.
//  Copyright © 2022 Agora. All rights reserved.
//

import AgoraUIBaseViews

typealias CellTextEndEditingAction = ((String?) -> Void)
typealias CellTimePickedAction = ((Int64) -> Void)

protocol DebugInfoCellDelegate: AnyObject {
    func infoCellDidBeginEditing()
}

class DebugInfoCell: UITableViewCell {
    static let id = "DebugInfoCell"
    
    weak var delegate: DebugInfoCellDelegate?
    
    var model: DebugInfoCellModel? {
        didSet {
            updateWithModel()
        }
    }
    
    /**views**/
    private let maxInputLength = 50
    
    private lazy var titleLabel = UILabel()
    
    private lazy var textField = UITextField()
    
    private lazy var lineLayer = CALayer()
    
    private lazy var indicatorView = UIImageView()
    
    private lazy var timePickerView = UIDatePicker()
    
    private lazy var textWarningLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(style: style,
                   reuseIdentifier: reuseIdentifier)
        
        initViews()
        initViewFrame()
        updateViewProperties()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        lineLayer.frame = CGRect(x: 0,
                                 y: titleLabel.height,
                                 width: contentView.bounds.width,
                                 height: 1)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - AgoraUIContentContainer
extension DebugInfoCell: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.infoCellDidBeginEditing()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let type = model?.type,
              case .text(_,_,_,let action) = type else {
            return
        }
        action(textField.text)
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
}

// MARK: - private
private extension DebugInfoCell {
    @objc func onTimeChanged(_ datePicker : UIDatePicker) {
        guard let type = model?.type,
              case DebugInfoCellType.time(_ ,let action) = type else {
            return
        }
        let timeInterval = Int64(datePicker.date.timeIntervalSince1970 * 1000)
        action(timeInterval)
    }
    
    func updateWithModel() {
        guard let `model` = model else {
            return
        }
        titleLabel.text = model.title
        
        switch model.type {
        case .text(let placeholder, let text, let warning, _):
            textField.text = text
            textField.placeholder = placeholder
            textField.isUserInteractionEnabled = true
            textWarningLabel.agora_visible = warning
            lineLayer.backgroundColor = warning ? UIColor(hex: 0xF04C36)!.cgColor: UIColor(hex: 0xE3E3EC)!.cgColor
            
            textField.agora_visible = true
            indicatorView.agora_visible = false
            timePickerView.agora_visible = false
        case .option(_ , let placeholder, let text, _):
            textField.text = text
            textField.placeholder = placeholder
            textField.isUserInteractionEnabled = false
            
            lineLayer.backgroundColor = UIColor(hex: 0xE3E3EC)!.cgColor
            textWarningLabel.agora_visible = false
            textField.agora_visible = true
            indicatorView.agora_visible = true
            timePickerView.agora_visible = false
        case .time(let timeInterval, _):
            lineLayer.backgroundColor = UIColor(hex: 0xE3E3EC)!.cgColor
            let date = Date.init(timeIntervalSince1970: timeInterval / 1000)
            timePickerView.setDate(date,
                                   animated: true)
            textWarningLabel.agora_visible = false
            textField.agora_visible = false
            indicatorView.agora_visible = false
            timePickerView.agora_visible = true
        }
    }
}

// MARK: - AgoraUIContentContainer
extension DebugInfoCell: AgoraUIContentContainer {
    func initViews() {
        selectionStyle = .none
        
        textField.delegate = self

        timePickerView.locale = Locale.current
        timePickerView.datePickerMode = .time
        timePickerView.minimumDate = Date()
        timePickerView.addTarget(self,
                                 action: #selector(onTimeChanged(_:)),
                             for: .valueChanged)
        
        textWarningLabel.text = "debug_text_warn".ag_localized()
        
        contentView.addSubviews([titleLabel,
                                 textField,
                                 indicatorView,
                                 timePickerView,
                                 textWarningLabel])
        textWarningLabel.agora_visible = false
        contentView.layer.addSublayer(lineLayer)
    }
    
    func initViewFrame() {
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
        timePickerView.mas_makeConstraints { make in
            make?.top.equalTo()(0)
            make?.height.equalTo()(40)
            make?.left.equalTo()(titleLabel.mas_right)
            make?.right.equalTo()(0)
        }
        textWarningLabel.mas_remakeConstraints { make in
            make?.left.right().equalTo()(0)
            make?.top.equalTo()(titleLabel.mas_bottom)
        }
    }
    
    func updateViewProperties() {
        titleLabel.textColor = UIColor(hexString: "8A8A9A")
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        
        textField.font = UIFont.systemFont(ofSize: 14)
        
        indicatorView.image = .init(named: "show_types")
        lineLayer.backgroundColor = UIColor(hex: 0xE3E3EC)!.cgColor
        
        textWarningLabel.font = UIFont.systemFont(ofSize: 10)
        textWarningLabel.textColor = UIColor(hexString: "#F04C36")
        textWarningLabel.textAlignment = .center
    }
}

class DebugOptionCell: UITableViewCell {
    static let id = "DebugOptionCell"
    
    var infoLabel = UILabel()
    
    var isHighlight: Bool = false {
        willSet {
            if newValue {
                infoLabel.textColor = UIColor(hex: 0x357BF6)
            } else {
                infoLabel.textColor = UIColor(hex: 0x191919)
            }
        }
    }

    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(style: style,
                   reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        infoLabel.font = UIFont.systemFont(ofSize: 14)
        
        infoLabel.textColor = UIColor(hex: 0x191919)
        infoLabel.textAlignment = .center
        contentView.addSubview(infoLabel)
        
        infoLabel.mas_makeConstraints { make in
            make?.center.equalTo()(contentView)
            make?.left.equalTo()(15)
            make?.right.equalTo()(-15)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
