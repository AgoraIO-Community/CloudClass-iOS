//
//  BrushToolsViewController.swift
//  AgoraEduUI
//
//  Created by HeZhengQing on 2021/9/23.
//

import AgoraUIEduBaseViews
import AgoraEduContext
import SwifterSwift
import AgoraWidget
import UIKit

@objc public enum AgoraBoardToolsLineWidth: Int, CaseIterable {
    case width1 = 0, width2, width3, width4, width5
    
    public var value: Int {
        switch self {
        case .width1: return 4
        case .width2: return 8
        case .width3: return 12
        case .width4: return 18
        case .width5: return 22
        }
    }
    
    public static func fromValue(_ value: Int?) -> AgoraBoardToolsLineWidth {
        guard let v = value else {
            return .width1
        }
        switch v {
        case 4: return .width1
        case 8: return .width2
        case 12: return .width3
        case 18: return .width4
        case 22: return .width5
        default:
            return .width1
        }
    }
}

@objc public enum AgoraBoardToolsFont: Int, CaseIterable {
    case font22 = 0, font24, font26, font30, font36, font42
    
    public var value: Int {
        switch self {
        case .font22: return 22
        case .font24: return 24
        case .font26: return 26
        case .font30: return 30
        case .font36: return 36
        case .font42: return 42
        }
    }
    
    public static func fromValue(_ value: Int?) -> AgoraBoardToolsFont {
        guard let v = value else {
            return .font22
        }
        switch v {
        case 22: return .font22
        case 24: return .font24
        case 26: return .font26
        case 30: return .font30
        case 36: return .font36
        case 42: return .font42
        default:
            return .font22
        }
    }
}

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
        return [Int(red * 255),Int(green * 255),Int(blue * 255)]
    }
}

fileprivate extension AgoraBoardWidgetMemberState {
    func toItem() -> AgoraBoardToolItem? {
        guard let toolType = self.activeApplianceType else {
            return nil
        }
        
        let lineConfig = AgoraBoardToolItemLineConfig(size: AgoraBoardToolsLineWidth.fromValue(self.strokeWidth))
        let textConfig = AgoraBoardToolItemTextConfig(size: AgoraBoardToolsFont.fromValue(self.textSize))
        switch toolType {
        case .Clicker:
            return .clicker
        case .Selector:
            return .area
        case .Text:
            return .text(textConfig)
        case .Rectangle:
            return .rect(lineConfig)
        case .Ellipse:
            return .cycle(lineConfig)
        case .Eraser:
            return .rubber
        case .Pencil:
            return .pencil(lineConfig)
        case .Straight:
            return .line(lineConfig)
        case .Pointer:
            return .laser
        default:
            return nil
        }
        return nil
    }
    
    func toColor() -> Int {
        guard let colorArr = self.strokeColor else {
            return 0x0073FF
        }
        let r = colorArr[0] ?? 0x00
        let g = colorArr[1] ?? 0x73
        let b = colorArr[2] ?? 0xFF
        
        let color = (r << 16) | (g << 8) | b
        return color
    }
}

struct AgoraBoardToolItemTextConfig {
    var size: AgoraBoardToolsFont = .font22
}

struct AgoraBoardToolItemLineConfig {
    var size: AgoraBoardToolsLineWidth = .width1
}

enum AgoraBoardToolItem: CaseIterable {
    case clicker, area, rubber, laser
    case text(AgoraBoardToolItemTextConfig), pencil(AgoraBoardToolItemLineConfig), line(AgoraBoardToolItemLineConfig)
    case rect(AgoraBoardToolItemLineConfig), cycle(AgoraBoardToolItemLineConfig)
    
    static var allCases: [AgoraBoardToolItem] = [.clicker,
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
        case .clicker:  return 1
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
    
    func image() -> UIImage? {
        let bundleName = "AgoraEduUI"
        switch self {
        case .clicker:
            return UIImage.ag_imageNamed("ic_brush_arrow",
                                         in: bundleName)
        case .area:
            return UIImage.ag_imageNamed("ic_brush_area",
                                         in: bundleName)
        case .text:
            return UIImage.ag_imageNamed("ic_brush_text",
                                         in: bundleName)
        case .rubber:
            return UIImage.ag_imageNamed("ic_brush_rubber",
                                         in: bundleName)
        case .laser:
            return UIImage.ag_imageNamed("ic_brush_laser",
                                         in: bundleName)
        case .pencil:
            return UIImage.ag_imageNamed("ic_brush_pencil",
                                         in: bundleName)
        case .line:
            return UIImage.ag_imageNamed("ic_brush_line",
                                         in: bundleName)
        case .rect:
            return UIImage.ag_imageNamed("ic_brush_rect",
                                         in: bundleName)
        case .cycle:
            return UIImage.ag_imageNamed("ic_brush_cycle",
                                         in: bundleName)
        default:
            return UIImage.ag_imageNamed("ic_brush_arrow",
                                         in: bundleName)
        }
    }
}

fileprivate extension AgoraBoardToolItem {
    func toWidgetMemberState(color: UIColor,
                             lineConfig: AgoraBoardToolItemLineConfig,
                             textConfig: AgoraBoardToolItemTextConfig) -> AgoraBoardWidgetMemberState? {
        let colorArr = color.getRGBAArr()
        
        switch self {
        case .clicker:
            return AgoraBoardWidgetMemberState(activeApplianceType: .Clicker)
        case .area:
            return AgoraBoardWidgetMemberState(activeApplianceType: .Selector,
                                               strokeColor: colorArr)
        case .rubber:
            return AgoraBoardWidgetMemberState(activeApplianceType: .Eraser,
                                               strokeColor: colorArr)
        case .laser:
            return AgoraBoardWidgetMemberState(activeApplianceType: .Pointer)
        case .text(let _):
            return AgoraBoardWidgetMemberState(activeApplianceType: .Text,
                                               strokeColor: colorArr,
                                               textSize: textConfig.size.fontSize())
        case .pencil(let _):
            return AgoraBoardWidgetMemberState(activeApplianceType: .Pencil,
                                               strokeColor: colorArr,
                                               strokeWidth: lineConfig.size.value)
        case .line(let _):
            return AgoraBoardWidgetMemberState(activeApplianceType: .Straight,
                                               strokeColor: colorArr,
                                               strokeWidth: lineConfig.size.value)
        case .rect(let _):
            return AgoraBoardWidgetMemberState(activeApplianceType: .Rectangle,
                                               strokeColor: colorArr,
                                               strokeWidth: lineConfig.size.value)
        case .cycle(let _):
            return AgoraBoardWidgetMemberState(activeApplianceType: .Ellipse,
                                               strokeColor: colorArr,
                                               strokeWidth: lineConfig.size.value)

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

fileprivate class AgoraBrushToolButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.white
        imageView?.tintColor = UIColor(hex: 0x7B88A0)
        
        layer.cornerRadius = 8
        layer.shadowColor = UIColor(hex: 0x2F4192,
                                    transparency: 0.15)?.cgColor
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

protocol AgoraBoardToolsUIControllerDelegate: class {
    /** 展示或隐藏画笔工具*/
    func onShowBrushTools(isShow: Bool)
}

private let kBrushSizeCount: Int = 5
private let kTextSizeCount: Int = 4
class AgoraBoardToolsUIController: UIViewController {
    
    public var button: UIButton {
        return brushButton
    }
    
    private lazy var brushButton: AgoraBrushToolButton = {
        let v = AgoraBrushToolButton(frame: CGRect(x: 0,
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
    
    public weak var delegate: AgoraBoardToolsUIControllerDelegate?
    
    private var contentView: UIView!
    
    private var toolsCollectionView: UICollectionView!
    
    private var topLine: UIView!
        
    private var sizeCollectionView: UICollectionView!
    
    private var bottomLine: UIView!
    
    private var colorCollectionView: UICollectionView!
    /** SDK环境*/
    private var contextPool: AgoraEduContextPool!
    
    private let hexColors: [Int] = [
        0xFFFFFF, 0x9B9B9B, 0x4A4A4A, 0x000000, 0xD0021B, 0xF5A623,
        0xF8E71C, 0x7ED321, 0x9013FE, 0x50E3C2, 0x0073FF, 0xFFC8E2
    ]
        
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
    
    var lineConfig = AgoraBoardToolItemLineConfig(size: .width1)
    var brushLevel = 0 {
        didSet {
            lineConfig = AgoraBoardToolItemLineConfig(size: AgoraBoardToolsLineWidth(rawValue: brushLevel) ?? .width1)
            callbackItemUpdated()
        }
    }
    
    var textConfig = AgoraBoardToolItemTextConfig(size: .font22)
    var textLevel = 0 {
        didSet {
            textConfig = AgoraBoardToolItemTextConfig(size: AgoraBoardToolsFont(rawValue: textLevel) ?? .font22)
            callbackItemUpdated()
        }
    }
    
    var selectedTool: AgoraBoardToolItem = .clicker {
        didSet {
            self.brushButton.setImage(selectedTool.image())
            callbackItemUpdated()
        }
    }
    
    var selectColor: Int = 0xFFFFFF {
        didSet {
            if selectColor == 0xFFFFFF {
                self.brushButton.imageView?.tintColor = UIColor(hex: 0xE1E1EA)
            } else {
                self.brushButton.imageView?.tintColor = UIColor(hex: selectColor)
            }
            callbackItemUpdated()
        }
    }
        
    deinit {
        print("\(#function): \(self.classForCoder)")
    }
    
    init(context: AgoraEduContextPool) {
        super.init(nibName: nil, bundle: nil)
        contextPool = context

        contextPool.widget.add(self,
                               widgetId: "netlessBoard")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        createViews()
        createConstrains()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        isSpread = (selectedTool.expandBarType() != nil)
    }
    
    private func callbackItemUpdated() {
        let color = UIColor(hex: selectColor) ?? .white
        
        if let memberState = selectedTool.toWidgetMemberState(color: color,
                                                              lineConfig: lineConfig,
                                                              textConfig: textConfig) {
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
            return hexColors.count
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
            cell.setImage(tool.image())
            cell.aSelected = (tool == selectedTool)
            return cell
        } else if collectionView == sizeCollectionView {
            if selectedTool.expandBarType() == .text {
                let cell = collectionView.dequeueReusableCell(withClass: AgoraBoardTextSizeItemCell.self,
                                                              for: indexPath)
                cell.level = indexPath.row
                cell.color = (selectColor == 0xFFFFFF ? nil : UIColor(hex: selectColor))
                cell.aSelected = (indexPath.row == textLevel)
                return cell
            } else if selectedTool.expandBarType() == .brush {
                let cell = collectionView.dequeueReusableCell(withClass: AgoraBoardSizeItemCell.self,
                                                              for: indexPath)
                cell.level = indexPath.row
                cell.color = (selectColor == 0xFFFFFF ? nil : UIColor(hex: selectColor))
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
            let color = hexColors[indexPath.row]
            cell.color = (color == 0xFFFFFF ? nil : UIColor(hex: color))
            cell.aSelected = (selectColor == color)
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
            if selectColor != hexColors[indexPath.row] {
                selectColor = hexColors[indexPath.row]
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
        view.layer.shadowColor = UIColor(hex: 0x2F4192,
                                         transparency: 0.15)?.cgColor
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
        topLine.backgroundColor = UIColor(hex: 0xECECF1)
        contentView.addSubview(topLine)
        
        bottomLine = UIView(frame: .zero)
        bottomLine.backgroundColor = UIColor(hex: 0xECECF1)
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
            if let item = state.toItem() {
                selectedTool = item
            }
            
            self.selectColor = state.toColor()
        case .BoardGrantDataChanged(let list):
            if let users = list,
               users.contains(contextPool.user.getLocalUserInfo().userUuid) {
                self.button.isHidden = false
            } else {
                self.button.isHidden = true
            }
        default:
            break
        }
    }
}
