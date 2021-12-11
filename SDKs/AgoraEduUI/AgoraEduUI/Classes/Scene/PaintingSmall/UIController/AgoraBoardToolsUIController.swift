//
//  BrushToolsViewController.swift
//  AgoraEduUI
//
//  Created by HeZhengQing on 2021/9/23.
//

import AgoraUIEduBaseViews
import AgoraEduContext
import AgoraWidget
import UIKit

fileprivate extension AgoraBoardToolsFont {
    func fontSize() -> Int {
        switch self {
        case .font22:  return 22
        case .font24:  return 24
        case .font26:  return 26
        case .font30:  return 30
        case .font36:  return 36
        case .font42:  return 42
        default:
            return 22
        }
    }
}

fileprivate extension UIColor {
    func getRGBAArr() -> Array<Int> {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        self.getRed(&red,
                    green: &green,
                    blue: &blue,
                    alpha: &alpha)
        return [Int(red),Int(green),Int(blue),Int(alpha)]
    }
}

struct AgoraBoardToolItemTextConfig {
    var size: AgoraBoardToolsFont = .font22
}

struct AgoraBoardToolItemLineConfig {
    var size: AgoraBoardToolsLineWidth = .width1
}

enum AgoraBoardToolItem: CaseIterable {
    case arrow, area, rubber, laser
    case text(AgoraBoardToolItemTextConfig), pencil(AgoraBoardToolItemLineConfig), line(AgoraBoardToolItemLineConfig)
    case rect(AgoraBoardToolItemLineConfig), cycle(AgoraBoardToolItemLineConfig)
    
    static var allCases: [AgoraBoardToolItem] = [.arrow,
                                                 .area,
                                                 .text(AgoraBoardToolItemTextConfig()),
                                                 .rubber,
                                                 //                                            .laser,
                                                 .pencil(AgoraBoardToolItemLineConfig()),
                                                 .line(AgoraBoardToolItemLineConfig()),
                                                 .rect(AgoraBoardToolItemLineConfig()),
                                                 .cycle(AgoraBoardToolItemLineConfig())]
    
    var rawValue: Int {
        switch self {
        case .arrow:  return 1
        case .area:   return 2
        case .text:   return 3
        case .rubber: return 4
        case .laser:  return 5
        case .pencil: return 6
        case .line:   return 7
        case .rect:   return 8
        case .cycle:  return 9
        }
    }
    
    static func initShape(rawValue: Int,
                          config: AgoraBoardToolItemLineConfig) -> AgoraBoardToolItem {
        switch rawValue {
        case 6:  return AgoraBoardToolItem.pencil(config)
        case 7:  return AgoraBoardToolItem.line(config)
        case 8:  return AgoraBoardToolItem.rect(config)
        case 9:  return AgoraBoardToolItem.cycle(config)
        default: fatalError()
        }
    }
    
    static func fromWidget(_ state: AgoraBoardWidgetMemberState) -> AgoraBoardToolItem? {
        guard let toolType = state.activeApplianceType else {
            return nil
        }
        
        let config = AgoraBoardToolItemLineConfig(size: AgoraBoardToolsLineWidth.fromValue(state.strokeWidth))
        
        switch toolType {
        case .Pencil:
            return AgoraBoardToolItem.pencil(config)
        case .Straight:
            return AgoraBoardToolItem.line(config)
        case .Rectangle:
            return AgoraBoardToolItem.rect(config)
        case .Ellipse:
            return AgoraBoardToolItem.cycle(config)
        default:
            return nil
        }
    }
    
    var isShape: Bool {
        switch self {
        case .pencil, .line, .rect, .cycle: return true
        default:                            return false
        }
    }
    
    static func !=(left: AgoraBoardToolItem,
                   right: AgoraBoardToolItem) -> Bool {
        return (left.rawValue != right.rawValue)
    }
    
    static func ==(left: AgoraBoardToolItem,
                   right: AgoraBoardToolItem) -> Bool {
        return (left.rawValue == right.rawValue)
    }
    
    func image(_ obj: NSObject) -> UIImage? {
        switch self {
        case .arrow:
            return AgoraUIImage(object: obj,
                                name: "ic_brush_arrow")
        case .area:
            return AgoraUIImage(object: obj,
                                name: "ic_brush_area")
        case .text:
            return AgoraUIImage(object: obj,
                                name: "ic_brush_text")
        case .rubber:
            return AgoraUIImage(object: obj,
                                name: "ic_brush_rubber")
        case .laser:
            return AgoraUIImage(object: obj,
                                name: "ic_brush_laser")
        case .pencil:
            return AgoraUIImage(object: obj,
                                name: "ic_brush_pencil")
        case .line:
            return AgoraUIImage(object: obj,
                                name: "ic_brush_line")
        case .rect:
            return AgoraUIImage(object: obj,
                                name: "ic_brush_rect")
        case .cycle:
            return AgoraUIImage(object: obj,
                                name: "ic_brush_cycle")
        default:
            return AgoraUIImage(object: obj,
                                name: "ic_brush_arrow")
        }
    }
}

fileprivate extension AgoraBoardToolItem {
    func toWidgetMemberState(color: UIColor) -> AgoraBoardWidgetMemberState? {
        let colorArr = color.getRGBAArr()
        
        switch self {
        case .arrow:
            return AgoraBoardWidgetMemberState(activeApplianceType: .Arrow,
                                               strokeColor: colorArr)
        case .area:
            return AgoraBoardWidgetMemberState(activeApplianceType: .Selector,
                                               strokeColor: colorArr)
        case .rubber:
            return AgoraBoardWidgetMemberState(activeApplianceType: .Eraser,
                                               strokeColor: colorArr)
        case .laser:
            return AgoraBoardWidgetMemberState(activeApplianceType: .Pointer)
        case .text(let textConfig):
            return AgoraBoardWidgetMemberState(activeApplianceType: .Text,
                                               strokeColor: colorArr,
                                               textSize: textConfig.size.fontSize())
        case .pencil(let lineConfig):
            return AgoraBoardWidgetMemberState(activeApplianceType: .Pencil,
                                               strokeColor: colorArr,
                                               strokeWidth: lineConfig.size.rawValue)
        case .line(let lineConfig):
            return AgoraBoardWidgetMemberState(activeApplianceType: .Straight,
                                               strokeColor: colorArr,
                                               strokeWidth: lineConfig.size.rawValue)
        case .rect(let lineConfig):
            return AgoraBoardWidgetMemberState(activeApplianceType: .Rectangle,
                                               strokeColor: colorArr,
                                               strokeWidth: lineConfig.size.rawValue)
        case .cycle(let lineConfig):
            return AgoraBoardWidgetMemberState(activeApplianceType: .Ellipse,
                                               strokeColor: colorArr,
                                               strokeWidth: lineConfig.size.rawValue)

        default:
            return nil
        }
    }
}

private extension AgoraBoardToolItem {
    enum ExpandBarType {
        case text, brush
    }
    /** 扩展属性栏样式*/
    func expandBarType() -> ExpandBarType? {
        switch self {
        case .text:
            return .text
        case .pencil, .line, .rect, .cycle:
            return .brush
        default:
            return nil
        }
    }
}

private enum AgoraBoardToolsViewState {
    case toolsOnly
    case sizeExtension
    case colorExtension
}

protocol AgoraBoardToolsUIControllerDelegate: class {
    /** 展示或隐藏画笔工具*/
    func onShowBrushTools(isShow: Bool)
}

private let kBrushSizeCount: Int = 5
private let kTextSizeCount: Int = 4
class AgoraBoardToolsUIController: UIViewController {
    
    public lazy var button: AgoraRoomToolZoomButton = {
        let v = AgoraRoomToolZoomButton(frame: CGRect(x: 0,
                                                      y: 0,
                                                      width: 44,
                                                      height: 44))
        v.isHidden = true
        v.setImage(AgoraUIImage(object: self,
                                name: "ic_brush_pencil"))
        v.addTarget(self,
                    action: #selector(onClickBrushTools(_:)),
                    for: .touchUpInside)
        return v
    }()
    
    weak var delegate: AgoraBoardToolsUIControllerDelegate?
    
    var contentView: UIView!
    
    var toolsCollectionView: UICollectionView!
    
    var topLine: UIView!
        
    var sizeCollectionView: UICollectionView!
    
    var bottomLine: UIView!
    
    var colorCollectionView: UICollectionView!
    /** SDK环境*/
    var contextPool: AgoraEduContextPool!
    
    let colors = AgoraBoardToolsColor.allCases
    
    let tools = AgoraBoardToolItem.allCases
    
    private var isSpread = false {
        didSet {
            guard isSpread != oldValue else {
                return
            }
            
            if isSpread {
                contentView.mas_remakeConstraints { make in
                    make?.width.equalTo()(280)
                    make?.height.equalTo()(310)
                    make?.top.bottom().left().right().equalTo()(contentView.superview)
                }
            } else {
                contentView.mas_remakeConstraints { make in
                    make?.width.equalTo()(280)
                    make?.height.equalTo()(136)
                    make?.top.bottom().left().right().equalTo()(contentView.superview)
                }
            }
        }
    }
    
    var brushLevel = 0 {
        didSet {
            callbackItemUpdated()
        }
    }
    
    var textLevel = 0 {
        didSet {
            callbackItemUpdated()
        }
    }
    
    var selectedTool: AgoraBoardToolItem = .arrow {
        didSet {
            callbackItemUpdated()
        }
    }
    
    var colorIndex: IndexPath = IndexPath(row: 0, section: 0) {
        didSet {
            callbackItemUpdated()
        }
    }
        
    deinit {
        print("\(#function): \(self.classForCoder)")
    }
    
    init(context: AgoraEduContextPool) {
        super.init(nibName: nil, bundle: nil)
        contextPool = context
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        createViews()
        createConstrains()
        contextPool.widget.add(self,
                               widgetId: "netlessBoard")
    }
    
    private func callbackItemUpdated() {
        let color = AgoraBoardToolsColor.allCases[colorIndex.row].value
        
        if let memberState = selectedTool.toWidgetMemberState(color: color) {
            sendMessage(signal: .MemberStateChanged(memberState))
        }
    }
    
    func sendMessage(signal: AgoraBoardWidgetSignal) {
        guard let text = signal.toMessageString() else {
            return
        }
        contextPool.widget.sendMessage(toWidget: "netlessBoard",
                                       message: text)
    }
}

private extension AgoraBoardToolsUIController {
    @objc func onClickBrushTools(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.delegate?.onShowBrushTools(isShow: sender.isSelected)
    }
}

// MARK: - UICollectionViewDelegate
extension AgoraBoardToolsUIController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if collectionView == toolsCollectionView {
            return tools.count
        } else if collectionView == sizeCollectionView {
            if selectedTool.expandBarType() == .text {
                return kTextSizeCount
            } else if selectedTool.expandBarType() == .brush {
                return kBrushSizeCount
            } else {
                return 0
            }
        } else if collectionView == colorCollectionView {
            return colors.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == toolsCollectionView {
            let cell = collectionView.dequeueReusableCell(withClass: AgoraBoardToolItemCell.self,
                                                          for: indexPath)
            let tool = tools[indexPath.row]
            cell.setImage(tool.image(self))
            cell.aSelected = (tool == selectedTool)
            return cell
        } else if collectionView == sizeCollectionView {
            if selectedTool.expandBarType() == .text {
                let cell = collectionView.dequeueReusableCell(withClass: AgoraBoardTextSizeItemCell.self,
                                                              for: indexPath)
                let color = colors[colorIndex.row]
                cell.level = indexPath.row
                cell.color = (color == .white ? nil : color.value)
                cell.aSelected = (indexPath.row == textLevel)
                return cell
            } else if selectedTool.expandBarType() == .brush {
                let cell = collectionView.dequeueReusableCell(withClass: AgoraBoardSizeItemCell.self,
                                                              for: indexPath)
                let color = colors[colorIndex.row]
                cell.level = indexPath.row
                cell.color = (color == .white ? nil : color.value)
                cell.aSelected = (indexPath.row == brushLevel)
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withClass: AgoraBoardTextSizeItemCell.self,
                                                              for: indexPath)
                return cell
            }
        } else if collectionView == colorCollectionView {
            let cell = collectionView.dequeueReusableCell(withClass: AgoraBoardColorItemCell.self,
                                                          for: indexPath)
            let color = colors[indexPath.row]
            cell.color = (color == .white ? nil : color.value)
            cell.aSelected = (indexPath == colorIndex)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(AgoraBoardColorItemCell.self),
                                                          for: indexPath)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath,
                                    animated: false)
        
        if collectionView == toolsCollectionView {
            let tool = tools[indexPath.row]
            if selectedTool != tool {
                selectedTool = tool
                collectionView.reloadData()
                
                isSpread = (selectedTool.expandBarType() != nil)
                colorCollectionView.reloadData()
                sizeCollectionView.reloadData()
            }
        } else if collectionView == sizeCollectionView {
            if selectedTool.expandBarType() == .text {
                textLevel = indexPath.row
            } else if selectedTool.expandBarType() == .brush {
                brushLevel = indexPath.row
            }
            collectionView.reloadData()
        } else if collectionView == colorCollectionView {
            if colorIndex != indexPath {
                colorIndex = indexPath
                collectionView.reloadData()
                sizeCollectionView.reloadData()
            }
        } else {
            // Do Noting
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == toolsCollectionView {
            return CGSize(width: 52, height: 58)
        } else if collectionView == sizeCollectionView {
            let height = collectionView.bounds.height
            if selectedTool.expandBarType() == .text {
                let width = (collectionView.bounds.width - 32) / CGFloat(kTextSizeCount)
                return CGSize(width: width, height: height)
            } else if selectedTool.expandBarType() == .brush {
                let width = (collectionView.bounds.width - 32) / CGFloat(kBrushSizeCount)
                return CGSize(width: width, height: height)
            } else {
                return .zero
            }
        } else if collectionView == colorCollectionView {
            return CGSize(width: 42, height: 42)
        } else {
            return CGSize(width: 0, height: 0)
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == toolsCollectionView {
            return UIEdgeInsets(top: 10, left: 6, bottom: 0, right: 6)
        } else if collectionView == sizeCollectionView {
            return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        } else if collectionView == colorCollectionView {
            return UIEdgeInsets(top: 12, left: 10, bottom: 0, right: 10)
        } else {
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
// MARK: - Creations
private extension AgoraBoardToolsUIController {
    func createViews() {
        view.layer.shadowColor = UIColor(rgb: 0x2F4192, alpha: 0.15).cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowOpacity = 1
        view.layer.shadowRadius = 6
        
        contentView = UIView(frame: .zero)
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 10.0
        contentView.clipsToBounds = true
        view.addSubview(contentView)
        
        let toolsLayout = UICollectionViewFlowLayout()
        toolsLayout.scrollDirection = .vertical
        toolsCollectionView = UICollectionView(frame: .zero,
                                               collectionViewLayout: toolsLayout)
        toolsCollectionView.showsHorizontalScrollIndicator = false
        toolsCollectionView.backgroundColor = .white
        toolsCollectionView.bounces = false
        toolsCollectionView.delegate = self
        toolsCollectionView.dataSource = self
        toolsCollectionView.register(cellWithClass: AgoraBoardToolItemCell.self)
        contentView.addSubview(toolsCollectionView)
        
        let sizeLayout = UICollectionViewFlowLayout()
        sizeLayout.scrollDirection = .horizontal
        sizeCollectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: sizeLayout)
        sizeCollectionView.showsHorizontalScrollIndicator = false
        sizeCollectionView.backgroundColor = .white
        sizeCollectionView.bounces = false
        sizeCollectionView.delegate = self
        sizeCollectionView.dataSource = self
        sizeCollectionView.register(cellWithClass: AgoraBoardTextSizeItemCell.self)
        sizeCollectionView.register(cellWithClass: AgoraBoardSizeItemCell.self)
        contentView.addSubview(sizeCollectionView)
        
        let colorlayout = UICollectionViewFlowLayout()
        colorlayout.scrollDirection = .vertical
        colorCollectionView = UICollectionView(frame: .zero,
                                               collectionViewLayout: colorlayout)
        colorCollectionView.showsHorizontalScrollIndicator = false
        colorCollectionView.backgroundColor = .white
        colorCollectionView.bounces = false
        colorCollectionView.delegate = self
        colorCollectionView.dataSource = self
        colorCollectionView.register(cellWithClass: AgoraBoardColorItemCell.self)
        contentView.addSubview(colorCollectionView)
        
        topLine = UIView(frame: .zero)
        topLine.backgroundColor = UIColor(rgb: 0xECECF1)
        contentView.addSubview(topLine)
        
        bottomLine = UIView(frame: .zero)
        bottomLine.backgroundColor = UIColor(rgb: 0xECECF1)
        contentView.addSubview(bottomLine)
    }
    
    func createConstrains() {
        contentView.mas_makeConstraints { make in
            make?.width.equalTo()(280)
            make?.height.equalTo()(136)
            make?.top.bottom().left().right().equalTo()(contentView.superview)
        }
        toolsCollectionView.mas_makeConstraints { make in
            make?.left.right().top().equalTo()(toolsCollectionView.superview)
            make?.height.equalTo()(136)
        }
        topLine.mas_makeConstraints { make in
            make?.left.equalTo()(16)
            make?.right.equalTo()(-16)
            make?.height.equalTo()(1)
            make?.top.equalTo()(toolsCollectionView.mas_bottom)
        }
        sizeCollectionView.mas_makeConstraints { make in
            make?.left.right().equalTo()(sizeCollectionView.superview)
            make?.top.equalTo()(topLine)
            make?.height.equalTo()(60)
        }
        bottomLine.mas_makeConstraints { make in
            make?.left.equalTo()(16)
            make?.right.equalTo()(-16)
            make?.height.equalTo()(1)
            make?.top.equalTo()(sizeCollectionView.mas_bottom)
        }
        colorCollectionView.mas_makeConstraints { make in
            make?.left.right().equalTo()(colorCollectionView.superview)
            make?.top.equalTo()(bottomLine)
            make?.height.equalTo()(112)
        }
    }
}

extension AgoraBoardToolsUIController: AgoraWidgetMessageObserver {
    func onMessageReceived(_ message: String,
                           widgetId: String) {
        guard widgetId == "netlessBoard",
              let signal = message.toSignal() else {
            return
        }
        switch signal {
        case .MemberStateChanged(let state):
            if let item = AgoraBoardToolItem.fromWidget(state) {
                selectedTool = item
            }
        case .BoardGrantDataChanged(let list):
            if let users = list,
               users.contains(contextPool.user.getLocalUserInfo().userUuid){
                self.button.isHidden = false
            }
        default:
            break
        }
    }
}
