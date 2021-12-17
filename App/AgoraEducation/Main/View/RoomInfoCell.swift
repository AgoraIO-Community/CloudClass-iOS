//
//  RoomInfoCell.swift
//  AgoraEducation
//
//  Created by HeZhengQing on 2021/9/9.
//  Copyright © 2021 Agora. All rights reserved.
//

import Foundation

protocol RoomInfoCellDelegate: AnyObject {
    /** 开始编辑cell上的文字*/
    func infoCellDidBeginEditing(cell: RoomInfoCell);
    /** 结束编辑cell上的文字*/
    func infoCellInputTextDidChange(cell: RoomInfoCell);
    /** 结束编辑cell上的文字*/
    func infoCellDidEndEditing(cell: RoomInfoCell);
}

enum RoomInfoCellMode {
    case none
    case input
    case option
    case unable
}

class RoomInfoCell: AgoraBaseUITableViewCell {
    
    var indexPath = IndexPath.init(row: 0, section: 0)
    
    weak var delegate: RoomInfoCellDelegate?
    
    var titleLabel: AgoraBaseUILabel!
    
    var textField: AgoraBaseUITextField!
    
    var lineView: AgoraBaseUIView!
    
    let maxInputLength = 50
    
    private var indicatorView: AgoraBaseUIImageView!
    
    lazy var warningLabel: AgoraBaseUILabel = {
        let label = AgoraBaseUILabel()
        label.text = NSLocalizedString("Login_warn", comment: "")
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = UIColor(hexString: "#F04C36")
        label.isHidden = true
        contentView.addSubview(label)
        
        label.agora_x = 0
        label.agora_y = textField.agora_height + lineView.agora_height
        return label
    }()
    
    private var aFocused: Bool = false
    
    var mode: RoomInfoCellMode = .none {
        didSet {
            switch mode {
            case .input:
                textField.isUserInteractionEnabled = true
                indicatorView.isHidden = true
            case .option:
                textField.isUserInteractionEnabled = false
                indicatorView.isHidden = false
            case .unable:
                textField.isUserInteractionEnabled = false
                indicatorView.isHidden = true
            default: break
            }
        }
    }
    
    var isTextWaring: Bool = false {
        didSet {
            if isTextWaring {
                lineView.backgroundColor = UIColor(hexString: "#F04C36")
                warningLabel.isHidden = false
            } else {
                lineView.backgroundColor = UIColor(hexString: "#E3E3EC")
                warningLabel.isHidden = true
            }
            
        }
    }
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        createViews()
        createConstrains()
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
    
    func onTextDidChange(_ sender: UITextField) {
        delegate?.infoCellInputTextDidChange(cell: self)
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
        titleLabel = AgoraBaseUILabel()
        titleLabel.textColor = UIColor(hexString: "8A8A9A")
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        contentView.addSubview(titleLabel)
        
        textField = AgoraBaseUITextField()
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.keyboardType = .emailAddress
        textField.delegate = self
        textField.addTarget(self, action: #selector(onTextDidChange(_:)), for: .editingChanged)
        contentView.addSubview(textField)
        
        lineView = AgoraBaseUIView()
        lineView.backgroundColor = UIColor(hexString: "#E3E3EC")
        contentView.addSubview(lineView)
        
        indicatorView = AgoraBaseUIImageView(image: UIImage(named: "show_types"))
        contentView.addSubview(indicatorView)
    }
    
    func createConstrains() {
        titleLabel.agora_x = 0
        titleLabel.agora_y = 0
        titleLabel.agora_height = 40
        titleLabel.agora_width = 58
        
        textField.agora_x = titleLabel.agora_width
        textField.agora_right = 0
        textField.agora_y = 0
        textField.agora_height = 40
        
        indicatorView.agora_right = 0
        indicatorView.agora_equal_to(view: titleLabel, attribute: .centerY)
        
        lineView.agora_x = 0
        lineView.agora_right = 0
        lineView.agora_height = 1
        lineView.agora_y = textField.agora_height
    }
}
