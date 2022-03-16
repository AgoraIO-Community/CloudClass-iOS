//
//  PaintingSmallToolsView.swift
//  AgoraEduUI
//
//  Created by HeZhengQing on 2021/9/22.
//

import AgoraUIBaseViews
import Masonry

// MARK: - Protocol
protocol AgoraRoomToolsViewDelegate: NSObject {
    /** 工具被选取*/
    func toolsViewDidSelectTool(_ tool: AgoraRoomToolstView.AgoraRoomToolType)
    /** 工具被取消选取*/
    func toolsViewDidDeselectTool(_ tool: AgoraRoomToolstView.AgoraRoomToolType)
}
// MARK: - AgoraToolListView
private let kButtonSize: CGFloat = 36.0
private let kGap: CGFloat = 12.0
private let kDefaultTag: Int = 3389

class AgoraRoomToolstView: UIView {
    
    weak var delegate: AgoraRoomToolsViewDelegate?
    
    public enum AgoraRoomToolType: Int {
        case setting = 0, toolBox, nameRoll, message
    }
    
    private var contentView: UIStackView!
    /** 设置按钮*/
    private lazy var settingButton: AgoraZoomButton = {
        let v = AgoraZoomButton(frame: .zero)
        v.tag = kDefaultTag + AgoraRoomToolType.setting.rawValue
        v.setImage(UIImage.agedu_named("ic_func_setting"))
        v.addTarget(self, action: #selector(onClickToolButton(_:)),
                    for: .touchUpInside)
        return v
    }()

    /** 花名册按钮*/
    private lazy var nameRollButton: AgoraZoomButton = {
        let v = AgoraZoomButton(frame: .zero)
        v.tag = kDefaultTag + AgoraRoomToolType.nameRoll.rawValue
        v.setImage(UIImage.agedu_named("ic_func_name_roll"))
        v.addTarget(self, action: #selector(onClickToolButton(_:)),
                    for: .touchUpInside)
        return v
    }()
    /** 消息按钮*/
    private lazy var messageButton: AgoraZoomButton = {
        let v = AgoraZoomButton(frame: .zero)
        v.tag = kDefaultTag + AgoraRoomToolType.message.rawValue
        v.setImage(UIImage.agedu_named("ic_func_message"))
        v.addTarget(self, action: #selector(onClickToolButton(_:)),
                    for: .touchUpInside)
        return v
    }()
    private lazy var messageRedDot: UIView = {
        let v = UIView()
        v.isHidden = true
        v.isUserInteractionEnabled = false
        v.backgroundColor = UIColor(hex: 0xF04C36)
        v.layer.cornerRadius = 2
        v.clipsToBounds = true
        self.addSubview(v)
        messageButton.addSubview(v)
        v.mas_makeConstraints { make in
            make?.width.height().equalTo()(4)
            make?.top.equalTo()(messageButton)?.offset()(5)
            make?.right.equalTo()(messageButton)?.offset()(-5)
        }
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
        createConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func deselectAll() {
        if selectedTool != nil {
            selectedTool = nil
        }
    }
    
    public func updateChatRedDot(isShow: Bool) {
        messageRedDot.isHidden = !isShow
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
            case .nameRoll:
                tempAry.append(self.nameRollButton)
            case .message:
                tempAry.append(self.messageButton)
            default:
                break
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
    
    func createConstraint() {
        contentView.mas_remakeConstraints { make in
            make?.left.right().top().bottom().equalTo()(self)
            make?.width.equalTo()(kButtonSize)
            make?.height.equalTo()((kButtonSize + kGap) * 5 - kGap)
        }
    }
}
