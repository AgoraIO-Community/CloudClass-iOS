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
    
    private lazy var optionsView: DebugOptionsView = {
        let optionsView = DebugOptionsView(frame: .zero)
        contentView.addSubview(optionsView)
        return optionsView
    }()
    
    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(style: style,
                   reuseIdentifier: reuseIdentifier)
        
        initViews()
        initViewFrame()
        updateViewProperties()
    }
    
    func showOptions(options: [(String, OptionSelectedAction)],
                      selectedIndex: Int) {
        _showOptions(options: options,
                     selectedIndex: selectedIndex)
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
        switch model?.type {
        case .text(_ , _, let action):
            action(textField.text)
        default:
            return
        }
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
              case DebugInfoCellType.time(let action) = type else {
            return
        }
        let timeInterval = Int64(datePicker.date.timeIntervalSince1970 * 1000)
        action(timeInterval)
    }
    
    func _showOptions(options: [(String, OptionSelectedAction)],
                     selectedIndex: Int) {
        optionsView.updateData(data: options,
                               selectedIndex: selectedIndex)
        optionsView.agora_visible = true
        
        let itemHeight: CGFloat = 44.0
        let insert: CGFloat = 11.0
        
        var contentHeight: CGFloat = 0
        if (options.count > 4) {
            contentHeight = itemHeight * 4 + insert * 2
        } else {
            contentHeight = itemHeight * CGFloat(options.count) + insert * 2
        }
        
        optionsView.mas_remakeConstraints { make in
            make?.top.equalTo()(contentView.mas_bottom)?.offset()(-26)
            make?.left.right().equalTo()(contentView)
            make?.height.equalTo()(0)
        }
        
        layoutIfNeeded()
        optionsView.mas_updateConstraints { make in
            make?.height.equalTo()(contentHeight)
        }
        optionsView.alpha = 0.2
        
        UIView.animate(withDuration: 0.1) {
            self.layoutIfNeeded()
            self.optionsView.alpha = 1
        } completion: { finish in
            
        }
    }
    
    func updateWithModel() {
        guard let `model` = model else {
            return
        }
        titleLabel.text = model.title
        
        switch model.type {
        case .text(let placeholder, let text, _):
            textField.text = text
            textField.placeholder = placeholder
            indicatorView.agora_visible = false
            timePickerView.agora_visible = false
        case .option(_ , let placeholder,let text, _):
            textField.text = text
            textField.placeholder = placeholder
            textField.isUserInteractionEnabled = false
            indicatorView.agora_visible = true
            timePickerView.agora_visible = false
        case .time:
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
        
        contentView.addSubviews([titleLabel,
                                 textField,
                                 indicatorView,
                                 timePickerView])
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
    }
    
    func updateViewProperties() {
        titleLabel.textColor = UIColor(hexString: "8A8A9A")
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        
        textField.font = UIFont.systemFont(ofSize: 14)
        
        indicatorView.image = .init(named: "show_types")
        lineLayer.backgroundColor = UIColor(hex: 0xE3E3EC)!.cgColor
    }
}

