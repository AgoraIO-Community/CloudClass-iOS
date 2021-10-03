//
//  PaintingSmallToolsView.swift
//  AgoraEduUI
//
//  Created by HeZhengQing on 2021/9/22.
//

import AgoraUIBaseViews
import SnapKit

class ToolsZoomButton: AgoraBaseUIButton {
    
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        super.touchesEnded(touches,
                           with: event)
        UIView.animate(withDuration: 0.1,
                       delay: 0,
                       options: .curveLinear) {
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
}

// MARK: - Protocol
protocol PaintingSmallToolsViewDelegate: NSObject {
    /** 工具被选取*/
    func toolsViewDidSelectTool(_ tool: PaintingSmallToolsView.PaintingSmallTool)
    /** 工具被取消选取*/
    func toolsViewDidDeselectTool(_ tool: PaintingSmallToolsView.PaintingSmallTool)
}
// MARK: - PaintingSmallToolsView
private let kButtonSize: CGFloat = 46.0
private let kDefaultTag: Int = 3389
class PaintingSmallToolsView: UIView {
    
    weak var delegate: PaintingSmallToolsViewDelegate?
    
    public enum PaintingSmallTool: Int {
        case setting = 0, toolBox, nameRoll, message, handsup
    }
    
    private var contentView: UIStackView!
    
    private var settingButton: ToolsZoomButton!
    
    private var toolBoxButton: ToolsZoomButton!
    
    private var nameRollButton: ToolsZoomButton!
    
    private var messageButton: ToolsZoomButton!
    
    private var handsupButton: ToolsZoomButton!
    /** 已被选中的工具*/
    private var selectedTool: PaintingSmallTool? {
        didSet {
            if let oldTool = oldValue,
               let oldButton = self.viewWithTag(kDefaultTag + oldTool.rawValue) as? UIButton{
                oldButton.isSelected = false
                self.delegate?.toolsViewDidDeselectTool(oldTool)
            }
            if let tool = selectedTool {
                self.delegate?.toolsViewDidSelectTool(tool)
            }
        }
    }
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        createViews()
        createConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func deselectAll() {
        if selectedTool != nil {
            selectedTool = nil
        }
    }
}

// MARK: - Actions
extension PaintingSmallToolsView {
    
    @objc func onClickToolButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected,
           let curTool = PaintingSmallTool(rawValue: sender.tag - kDefaultTag) {
            selectedTool = curTool
        } else {
            selectedTool = nil
        }
    }
    
    @objc func onClickHandsup(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
}

// MARK: - Creations
private extension PaintingSmallToolsView {
    func createViews() {
        contentView = UIStackView(frame: CGRect(x: 0, y: 0, width: 46, height: 230))
        contentView.backgroundColor = .clear
        contentView.axis = .vertical
        contentView.spacing = 0
        contentView.distribution = .fillEqually
        contentView.alignment = .trailing
        addSubview(contentView)
        
        settingButton = ToolsZoomButton(type: .custom)
        settingButton.tag = kDefaultTag + PaintingSmallTool.setting.rawValue
        settingButton.frame = CGRect(x: 0, y: 0, width: kButtonSize, height: kButtonSize)
        settingButton.setImage(AgoraUIImage(object: self, name: "ic_func_setting"),
                               for: .normal)
        settingButton.setImage(AgoraUIImage(object: self, name: "ic_func_setting_sel"),
                               for: .selected)
        settingButton.setImage(AgoraUIImage(object: self, name: "ic_func_setting_sel"),
                               for: .highlighted)
        settingButton.adjustsImageWhenHighlighted = false
        settingButton.showsTouchWhenHighlighted = false
        settingButton.addTarget(self, action: #selector(onClickToolButton(_:)), for: .touchUpInside)
        contentView.addArrangedSubview(settingButton)
        
        toolBoxButton = ToolsZoomButton(type: .custom)
        toolBoxButton.tag = kDefaultTag + PaintingSmallTool.toolBox.rawValue
        toolBoxButton.frame = CGRect(x: 0, y: 0, width: kButtonSize, height: kButtonSize)
        toolBoxButton.setImage(AgoraUIImage(object: self, name: "ic_func_toolbox"),
                               for: .normal)
        toolBoxButton.setImage(AgoraUIImage(object: self, name: "ic_func_toolbox_sel"),
                               for: .selected)
        toolBoxButton.setImage(AgoraUIImage(object: self, name: "ic_func_toolbox_sel"),
                               for: .highlighted)
        toolBoxButton.addTarget(self, action: #selector(onClickToolButton(_:)),
                                for: .touchUpInside)
        contentView.addArrangedSubview(toolBoxButton)
        
        nameRollButton = ToolsZoomButton(type: .custom)
        nameRollButton.tag = kDefaultTag + PaintingSmallTool.nameRoll.rawValue
        nameRollButton.frame = CGRect(x: 0, y: 0, width: kButtonSize, height: kButtonSize)
        nameRollButton.setImage(AgoraUIImage(object: self, name: "ic_func_name_roll"),
                                for: .normal)
        nameRollButton.setImage(AgoraUIImage(object: self, name: "ic_func_name_roll_sel"),
                               for: .selected)
        nameRollButton.setImage(AgoraUIImage(object: self, name: "ic_func_name_roll_sel"),
                                for: .highlighted)
        nameRollButton.addTarget(self, action: #selector(onClickToolButton(_:)),
                                 for: .touchUpInside)
        contentView.addArrangedSubview(nameRollButton)
        
        messageButton = ToolsZoomButton(type: .custom)
        messageButton.tag = kDefaultTag + PaintingSmallTool.message.rawValue
        messageButton.frame = CGRect(x: 0, y: 0, width: kButtonSize, height: kButtonSize)
        messageButton.setImage(AgoraUIImage(object: self, name: "ic_func_message"),
                               for: .normal)
        messageButton.setImage(AgoraUIImage(object: self, name: "ic_func_message_sel"),
                               for: .selected)
        messageButton.setImage(AgoraUIImage(object: self, name: "ic_func_message_sel"),
                               for: .highlighted)
        messageButton.addTarget(self, action: #selector(onClickToolButton(_:)),
                                for: .touchUpInside)
        contentView.addArrangedSubview(messageButton)
        
        handsupButton = ToolsZoomButton(type: .custom)
        handsupButton.tag = kDefaultTag + PaintingSmallTool.handsup.rawValue
        handsupButton.frame = CGRect(x: 0, y: 0, width: kButtonSize, height: kButtonSize)
        handsupButton.setImage(AgoraUIImage(object: self, name: "ic_func_hands_up"),
                               for: .normal)
        handsupButton.setImage(AgoraUIImage(object: self, name: "ic_func_hands_up_sel"),
                               for: .selected)
        handsupButton.setImage(AgoraUIImage(object: self, name: "ic_func_hands_up_sel"),
                               for: .highlighted)
        handsupButton.addTarget(self, action: #selector(onClickHandsup(_:)),
                                for: .touchUpInside)
        contentView.addArrangedSubview(handsupButton)
    }
    
    func createConstrains() {
        contentView.snp.makeConstraints { make in
            make.left.right.top.bottom.equalTo(self)
            make.width.equalTo(46)
            make.height.equalTo(46 * 5)
        }
    }
}
