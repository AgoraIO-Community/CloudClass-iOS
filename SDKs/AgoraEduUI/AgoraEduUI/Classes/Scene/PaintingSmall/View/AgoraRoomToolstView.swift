//
//  PaintingSmallToolsView.swift
//  AgoraEduUI
//
//  Created by HeZhengQing on 2021/9/22.
//

import AgoraUIBaseViews
import Masonry

// MARK: - AgoraRoomToolZoomButton
class AgoraRoomToolZoomButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.white
        imageView?.tintColor = UIColor(rgb: 0x7B88A0)
        
        layer.cornerRadius = 8
        layer.shadowColor = UIColor(rgb:0x2F4192).withAlphaComponent(0.15).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 1
        layer.shadowRadius = 6
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = bounds.height * 0.5
    }
    
    override var isSelected: Bool {
        willSet {
            if isSelected != newValue {
                backgroundColor = newValue ? UIColor(rgb: 0x357BF6) : .white
                imageView?.tintColor = newValue ? .white : UIColor(rgb: 0x7B88A0)
            }
        }
    }
    
    func setImage(_ image: UIImage?) {
        guard let v = image else {
            return
        }
        setImageForAllStates(v.withRenderingMode(.alwaysTemplate))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        UIView.animate(withDuration: 0.1,
                       delay: 0,
                       options: .curveLinear) {
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
        } completion: { finish in
        }
    }
}

// MARK: - Protocol
protocol AgoraRoomToolsViewDelegate: NSObject {
    /** 工具被选取*/
    func toolsViewDidSelectTool(_ tool: AgoraRoomToolstView.AgoraRoomToolType)
    /** 工具被取消选取*/
    func toolsViewDidDeselectTool(_ tool: AgoraRoomToolstView.AgoraRoomToolType)
}
// MARK: - AgoraToolListView
private let kButtonSize: CGFloat = AgoraFit.scale(46.0)
private let kGap: CGFloat = 12.0
private let kDefaultTag: Int = 3389

class AgoraRoomToolstView: UIView {
    
    weak var delegate: AgoraRoomToolsViewDelegate?
    
    public enum AgoraRoomToolType: Int {
        case setting = 0, toolBox, nameRoll, message
    }
    
    private var contentView: UIStackView!
    /** 设置按钮*/
    private lazy var settingButton: AgoraRoomToolZoomButton = {
        let v = AgoraRoomToolZoomButton(frame: .zero)
        v.tag = kDefaultTag + AgoraRoomToolType.setting.rawValue
        v.setImage(AgoraUIImage(object: self, name: "ic_func_setting"))
        v.addTarget(self, action: #selector(onClickToolButton(_:)),
                    for: .touchUpInside)
        return v
    }()
    /** 工具箱按钮*/
    private lazy var toolBoxButton: AgoraRoomToolZoomButton = {
        let v = AgoraRoomToolZoomButton(frame: .zero)
        v.tag = kDefaultTag + AgoraRoomToolType.toolBox.rawValue
        v.setImage(AgoraUIImage(object: self, name: "ic_func_toolbox"))
        v.addTarget(self, action: #selector(onClickToolButton(_:)),
                    for: .touchUpInside)
        return v
    }()
    /** 花名册按钮*/
    private lazy var nameRollButton: AgoraRoomToolZoomButton = {
        let v = AgoraRoomToolZoomButton(frame: .zero)
        v.tag = kDefaultTag + AgoraRoomToolType.nameRoll.rawValue
        v.setImage(AgoraUIImage(object: self, name: "ic_func_name_roll"))
        v.addTarget(self, action: #selector(onClickToolButton(_:)),
                    for: .touchUpInside)
        return v
    }()
    /** 消息按钮*/
    private lazy var messageButton: AgoraRoomToolZoomButton = {
        let v = AgoraRoomToolZoomButton(frame: .zero)
        v.tag = kDefaultTag + AgoraRoomToolType.message.rawValue
        v.setImage(AgoraUIImage(object: self, name: "ic_func_message"))
        v.addTarget(self, action: #selector(onClickToolButton(_:)),
                    for: .touchUpInside)
        return v
    }()
    /** 展示的工具*/
    public var tools: [AgoraRoomToolType] = [AgoraRoomToolType]() {
        didSet {
            if tools != oldValue {
                updateToolsView()
            }
        }
    }
    /** 已被选中的工具*/
    private var selectedTool: AgoraRoomToolType? {
        didSet {
            if let oldTool = oldValue,
               let oldButton = self.viewWithTag(kDefaultTag + oldTool.rawValue) as? UIButton {
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
// MARK: - Private
private extension AgoraRoomToolstView {
    func updateToolsView() {
        var tempAry = [UIView]()
        for tool in tools {
            switch tool {
            case .setting:
                tempAry.append(self.settingButton)
            case .toolBox:
                tempAry.append(self.toolBoxButton)
            case .nameRoll:
                tempAry.append(self.nameRollButton)
            case .message:
                tempAry.append(self.messageButton)
            default: break
            }
        }
        contentView.removeArrangedSubviews()
        let count = CGFloat(tools.count)
        contentView.mas_remakeConstraints { make in
            make?.left.right().top().bottom().equalTo()(self)
            make?.width.equalTo()(kButtonSize)
            make?.height.equalTo()((kButtonSize + kGap) * count - kGap)
        }
        contentView.addArrangedSubviews(tempAry)
    }
}

// MARK: - Actions
extension AgoraRoomToolstView {
    
    @objc func onClickToolButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected,
           let curTool = AgoraRoomToolType(rawValue: sender.tag - kDefaultTag) {
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
private extension AgoraRoomToolstView {
    func createViews() {
        contentView = UIStackView(frame: .zero)
        contentView.backgroundColor = .clear
        contentView.axis = .vertical
        contentView.spacing = kGap
        contentView.distribution = .fillEqually
        contentView.alignment = .fill
        addSubview(contentView)
    }
    
    func createConstrains() {
        contentView.mas_remakeConstraints { make in
            make?.left.right().top().bottom().equalTo()(self)
            make?.width.equalTo()(kButtonSize)
            make?.height.equalTo()((kButtonSize + kGap) * 5 - kGap)
        }
    }
}