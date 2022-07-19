//
//  AgoraBoardToolConfigView.swift
//  AgoraEduUI
//
//  Created by DoubleCircle on 2022/2/10.
//

import AgoraEduContext
import SwifterSwift
import AgoraWidget
import UIKit

@objc public enum AgoraBoardToolsLineWidth: Int, CaseIterable {
    case width1 = 0, width2, width3, width4, width5
    
    public var value: Int {
        switch self {
        case .width1: return 1
        case .width2: return 2
        case .width3: return 3
        case .width4: return 4
        case .width5: return 5
        }
    }
    
    public static func fromValue(_ value: Int?) -> AgoraBoardToolsLineWidth {
        guard let v = value else {
            return .width1
        }
        switch v {
        case 1:  return .width1
        case 2:  return .width2
        case 3:  return .width3
        case 4:  return .width4
        case 5:  return .width5
        default: return .width2
        }
    }
}

@objc public enum AgoraBoardToolsFont: Int, CaseIterable {
    case font10 = 0, font14, font18, font24
    
    public var value: Int {
        switch self {
        case .font10: return 20
        case .font14: return 28
        case .font18: return 36
        case .font24: return 48
        }
    }
    
    public static func fromValue(_ value: Int?) -> AgoraBoardToolsFont {
        guard let v = value else {
            return .font18
        }
        switch v {
        case 20: return .font10
        case 28: return .font14
        case 36: return .font18
        case 48: return .font24
        default: return .font18
        }
    }
}

extension UIColor {
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

extension Array where Element == Int {
    func toColorHex() -> Int {
        let r = self[0] ?? 0x00
        let g = self[1] ?? 0x73
        let b = self[2] ?? 0xFF
        
        let color = (r << 16) | (g << 8) | b
        return color
    }
}

protocol AgoraBoardToolConfigViewDelegate: class {
    func didSelectColorHex(_ hex: Int)
    func didSelectTextFont(fontSize: Int)
    func didSelectPaintType(_ type: AgoraBoardToolPaintType)
    func didSelectLineWidth(lineWidth: Int)
}

fileprivate let kTextSizeCount: Int = 4

fileprivate let kToolLength: CGFloat = UIDevice.current.agora_is_pad ? 34 : 30
fileprivate let kFontLength: CGFloat = UIDevice.current.agora_is_pad ? 34 : 30
fileprivate let kWidthLength: CGFloat = 28
fileprivate let kColorLength: CGFloat = 22

fileprivate let kGapLength: CGFloat = 12
fileprivate let kToolHGap: CGFloat = 12
fileprivate let kFontHGap: CGFloat = 12
fileprivate let kWidthHGap: CGFloat = UIDevice.current.agora_is_pad ? 8 : 4
fileprivate let kColorHGap: CGFloat = UIDevice.current.agora_is_pad ? 28 : 20
/// only shows when curMainTool is Text or Paint
class AgoraBoardToolConfigView: UIView {
    /** UI*/
    public var suggestSize: CGSize {
        get {
            if isCurrentPaint {
                return CGSize(width: UIDevice.current.agora_is_pad ? 196 : 172,
                              height: toolCollectionHeight + lineCollectionHeight + colorCollectionHeight + AgoraFit.scale(1) * 2)
            } else {
                return CGSize(width: UIDevice.current.agora_is_pad ? 196 : 172,
                              height: textCollectionHeight + colorCollectionHeight + AgoraFit.scale(1))
            }
        }
    }
    
    private lazy var toolCollectionHeight = (kToolLength + kGapLength) * ceil(CGFloat(paintTools.count) / 4) + kGapLength
    var colorCollectionHeight: CGFloat {
        get {
            return (kColorLength + kGapLength) * ceil(CGFloat(hexColors.count) / 4) + kGapLength
        }
    }
    let lineCollectionHeight = kWidthLength + kGapLength * 2
    let textCollectionHeight = kFontLength + kGapLength * 2
    /** 容器*/
    private lazy var contentView = UIView()
    
    private var subPaintCollectionView: UICollectionView!
    private lazy var topLine = UIView(frame: .zero)
    private var lineWidthCollectionView: UICollectionView!
    private var textSizecollectionView: UICollectionView!
    private lazy var bottomLine = UIView(frame: .zero)
    private var colorCollectionView: UICollectionView!
    
    /** Data*/
    private lazy var paintTools = AgoraBoardToolPaintType.allCases.enabledTypes()
    public weak var delegate: AgoraBoardToolConfigViewDelegate?
    private var contextPool: AgoraEduContextPool!
    
    private let hexColors: [Int] = [
        0x9B9B9B, 0x4A4A4A, 0x000000, 0xD0021B, 0xF5A623, 0xF8E71C,
        0x7ED321, 0xEB47A2, 0x9013FE, 0x50E3C2, 0x0073FF, 0xFFC8E2
    ]
    
    var curLineWidth: AgoraBoardToolsLineWidth = .width2 {
        didSet {
            lineWidthCollectionView.reloadData()
        }
    }
    
    var curTextFont: AgoraBoardToolsFont = .font18 {
        didSet {
            textSizecollectionView.reloadData()
        }
    }
    
    private var isCurrentPaint = true {
        didSet {
            updateUIHidden()
            updateConstrains()
        }
    }
    var currentPaintTool: AgoraBoardToolPaintType = .pencil {
        didSet {
            if currentPaintTool != oldValue {
                subPaintCollectionView.reloadData()
            }
        }
    }
    
    var currentColor: Int = 0x0073FF {
        didSet {
            self.delegate?.didSelectColorHex(currentColor)
        }
    }
        
    deinit {
        print("\(#function): \(self.classForCoder)")
    }
    
    init(delegate: AgoraBoardToolConfigViewDelegate) {
        self.delegate = delegate
        super.init(frame: .zero)
        backgroundColor = .clear
        
        initViews()
        initViewFrame()
        updateConstrains()
        updateViewProperties()
    }
    
    func switchType(_ type: AgoraBoardToolMainType) {
        switch type {
        case .paint:
            isCurrentPaint = true
        case .text:
            isCurrentPaint = false
        default:
            break
        }
    }
 
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UICollectionViewDelegate
extension AgoraBoardToolConfigView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if collectionView == subPaintCollectionView {
            return paintTools.count
        } else if collectionView == lineWidthCollectionView {
            return AgoraBoardToolsLineWidth.allCases.count
        } else if collectionView == textSizecollectionView {
            return AgoraBoardToolsFont.allCases.count
        } else if collectionView == colorCollectionView {
            return hexColors.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == subPaintCollectionView {
            let cell = collectionView.dequeueReusableCell(withClass: AgoraToolCollectionToolCell.self,
                                                          for: indexPath)
            let tool = paintTools[indexPath.row]
            cell.setImage(image: tool.image,
                          color: UIColor(hex: currentColor))
            cell.aSelected = (tool == currentPaintTool)
            return cell
        } else if collectionView == lineWidthCollectionView {
            let cell = collectionView.dequeueReusableCell(withClass: AgoraBoardLineWidthCell.self,
                                                          for: indexPath)
            cell.level = indexPath.row
            cell.color = UIColor(hex: currentColor)
            cell.aSelected = (AgoraBoardToolsLineWidth(rawValue: indexPath.row) == curLineWidth)
            return cell
        } else if collectionView == textSizecollectionView {
            let cell = collectionView.dequeueReusableCell(withClass: AgoraBoardTextSizeItemCell.self,
                                                          for: indexPath)
            cell.level = indexPath.row
            cell.color = UIColor(hex: currentColor)
            cell.aSelected = (AgoraBoardToolsFont(rawValue: indexPath.row) == curTextFont)
            return cell
        } else if collectionView == colorCollectionView {
            let cell = collectionView.dequeueReusableCell(withClass: AgoraBoardColorItemCell.self,
                                                          for: indexPath)
            let color = hexColors[indexPath.row]
            cell.color = UIColor(hex: color)!
            cell.aSelected = (currentColor == color)
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
        
        if collectionView == subPaintCollectionView,
           indexPath.row < paintTools.count {
            let tool = paintTools[indexPath.row]
            if currentPaintTool != tool {
                currentPaintTool = tool
                self.delegate?.didSelectPaintType(currentPaintTool)
            }
        } else if collectionView == lineWidthCollectionView,
                  let newValue = AgoraBoardToolsLineWidth(rawValue: indexPath.row),
                  newValue != curLineWidth {
            curLineWidth = newValue
            delegate?.didSelectLineWidth(lineWidth: curLineWidth.value)
        } else if collectionView == textSizecollectionView,
                  let newValue = AgoraBoardToolsFont(rawValue: indexPath.row),
                  newValue != curTextFont {
            curTextFont = newValue
            delegate?.didSelectTextFont(fontSize: curTextFont.value)
        } else if collectionView == colorCollectionView {
            if currentColor != hexColors[indexPath.row] {
                currentColor = hexColors[indexPath.row]
            }
        }
        reloadAllCollectionViews()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == subPaintCollectionView {
            return CGSize(width: kToolLength,
                          height: kToolLength)
        } else if collectionView == lineWidthCollectionView {
            return CGSize(width: kWidthLength,
                          height: kWidthLength)
        } else if collectionView == colorCollectionView {
            return CGSize(width: kColorLength,
                          height: kColorLength)
        } else if collectionView == textSizecollectionView {
            return CGSize(width: kFontLength,
                          height: kFontLength)
        }
        return CGSize(width: 0, height: 0)
    }
}

// MARK: - AgoraUIContentContainer
extension AgoraBoardToolConfigView: AgoraUIContentContainer {
    func initViews() {
        addSubview(contentView)
        
        let toolLeft: CGFloat = UIDevice.current.agora_is_pad ? 12 : 8
        subPaintCollectionView = makeCollectionView(space: kToolHGap,
                                                    sectionInset: UIEdgeInsets(top: kGapLength,
                                                                               left: toolLeft,
                                                                               bottom: kGapLength,
                                                                               right: toolLeft))
        subPaintCollectionView.register(cellWithClass: AgoraToolCollectionToolCell.self)
        contentView.addSubview(subPaintCollectionView)
        
        lineWidthCollectionView = makeCollectionView(space: kWidthHGap,
                                                     sectionInset: UIEdgeInsets(top: kGapLength,
                                                                                left: toolLeft,
                                                                                bottom: kGapLength,
                                                                                right: toolLeft))
        lineWidthCollectionView.register(cellWithClass: AgoraBoardLineWidthCell.self)
        contentView.addSubview(lineWidthCollectionView)
        
        colorCollectionView = makeCollectionView(space: kColorHGap,
                                                 sectionInset: UIEdgeInsets(top: kGapLength,
                                                                            left: kGapLength,
                                                                            bottom: kGapLength,
                                                                            right: kGapLength))
        colorCollectionView.register(cellWithClass: AgoraBoardColorItemCell.self)
        contentView.addSubview(colorCollectionView)
        
        textSizecollectionView = makeCollectionView(space: kFontHGap,
                                                    sectionInset: UIEdgeInsets(top: kGapLength,
                                                                               left: toolLeft,
                                                                               bottom: kGapLength,
                                                                               right: toolLeft))
        textSizecollectionView.register(cellWithClass: AgoraBoardTextSizeItemCell.self)
        contentView.addSubview(textSizecollectionView)
        
        contentView.addSubview(topLine)
        contentView.addSubview(bottomLine)
        
        let config = UIConfig.netlessBoard
        subPaintCollectionView.agora_enable = config.paint.enable
        subPaintCollectionView.agora_visible = config.paint.visible
        
        lineWidthCollectionView.agora_enable = config.lineWidth.enable
        lineWidthCollectionView.agora_visible = config.lineWidth.visible
        
        colorCollectionView.agora_enable = config.colors.enable
        colorCollectionView.agora_visible = config.colors.visible
        
        textSizecollectionView.agora_enable = config.textSize.enable
        textSizecollectionView.agora_visible = config.textSize.visible
    }
    
    func initViewFrame() {
        contentView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(contentView.superview)
        }
        colorCollectionView.mas_makeConstraints { make in
            make?.left.right().bottom().equalTo()(colorCollectionView.superview)
            make?.height.equalTo()(colorCollectionHeight)
        }
        bottomLine.mas_makeConstraints { make in
            make?.left.equalTo()(AgoraFit.scale(10))
            make?.right.equalTo()(AgoraFit.scale(-10))
            make?.height.equalTo()(1)
            make?.bottom.equalTo()(self.colorCollectionView.mas_top)
        }
    }
    
    func updateViewProperties() {
        let config = UIConfig.toolCollection
        
        layer.shadowColor = config.shadow.color
        layer.shadowOffset = config.shadow.offset
        layer.shadowOpacity = config.shadow.opacity
        layer.shadowRadius = config.shadow.radius
        
        contentView.backgroundColor = config.backgroundColor
        contentView.layer.cornerRadius = config.windowCornerRadius
        contentView.clipsToBounds = true
        contentView.borderWidth = config.borderWidth
        contentView.layer.borderColor = config.borderColor
        
        topLine.backgroundColor = config.sepLine.backgroundColor
        bottomLine.backgroundColor = config.sepLine.backgroundColor
    }
    
    
}
// MARK: - Creations
private extension AgoraBoardToolConfigView {
    func updateConstrains() {
        if isCurrentPaint {
            subPaintCollectionView.mas_remakeConstraints { make in
                make?.left.right().top().equalTo()(subPaintCollectionView.superview)
                make?.height.equalTo()(toolCollectionHeight)
            }
            topLine.mas_remakeConstraints { make in
                make?.left.equalTo()(AgoraFit.scale(10))
                make?.right.equalTo()(AgoraFit.scale(-10))
                make?.height.equalTo()(1)
                make?.top.equalTo()(self.subPaintCollectionView.mas_bottom)
            }
            lineWidthCollectionView.mas_remakeConstraints { make in
                make?.left.right().equalTo()(lineWidthCollectionView.superview)
                make?.top.equalTo()(topLine)
                make?.height.equalTo()(lineCollectionHeight)
            }
        } else {
            textSizecollectionView.mas_remakeConstraints { make in
                make?.left.right().top().equalTo()(textSizecollectionView.superview)
                make?.height.equalTo()(textCollectionHeight)
            }
        }
    }
    
    func updateUIHidden() {
        if isCurrentPaint {
            subPaintCollectionView.isHidden = false
            topLine.isHidden = false
            lineWidthCollectionView.isHidden = false
            textSizecollectionView.isHidden = true
        } else {
            subPaintCollectionView.isHidden = true
            topLine.isHidden = true
            lineWidthCollectionView.isHidden = true
            textSizecollectionView.isHidden = false
        }
    }
    
    func reloadAllCollectionViews() {
        subPaintCollectionView.reloadData()
        lineWidthCollectionView.reloadData()
        colorCollectionView.reloadData()
        textSizecollectionView.reloadData()
    }
    
    func makeCollectionView(space: CGFloat,
                            sectionInset: UIEdgeInsets) -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = sectionInset
        layout.minimumInteritemSpacing = space
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.bounces = false
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }
}

fileprivate extension Array where Element == AgoraBoardToolPaintType {
    func enabledTypes() -> [AgoraBoardToolPaintType] {
        let config = UIConfig.netlessBoard
        var list = [AgoraBoardToolPaintType]()
        for item in self {
            switch item {
            case .line:
                if config.line.enable,
                   config.line.visible {
                    list.append(item)
                }
            case .pencil:
                if config.pencil.enable,
                   config.pencil.visible {
                    list.append(item)
                }
            case .rect:
                if config.rect.enable,
                   config.rect.visible {
                    list.append(item)
                }
            case .circle:
                if config.circle.enable,
                   config.circle.visible {
                    list.append(item)
                }
            case .pentagram:
                if config.pentagram.enable,
                   config.pentagram.visible {
                    list.append(item)
                }
            case .rhombus:
                if config.rhombus.enable,
                   config.rhombus.visible {
                    list.append(item)
                }
            case .arrow:
                if config.arrow.enable,
                   config.arrow.visible {
                    list.append(item)
                }
            case .triangle:
                if config.triangle.enable,
                   config.triangle.visible {
                    list.append(item)
                }
            }
        }
        return list
    }
}
