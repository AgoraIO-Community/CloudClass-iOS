//
//  BrushToolItemCell.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2021/9/29.
//

import Masonry
import UIKit

enum AgoraBoardToolPaintType: Int, CaseIterable {
    case pencil, line, rect, circle, pentagram, rhombus, arrow, triangle
    
    static var allCases: [AgoraBoardToolPaintType] = [.pencil, .line, .rect, .circle, .pentagram, .rhombus, .arrow, .triangle]
    
    var boardWidgetToolType: AgoraBoardWidgetToolType? {
        switch self {
        case .pencil:       return .Pencil
        case .line:         return .Straight
        case .rect:         return .Rectangle
        case .circle:       return .Ellipse
        case .arrow:        return .Arrow
        default:            return nil
        }
    }
    
    var boardWidgetShapeType: AgoraBoardWidgetShapeType? {
        switch self {
        case .pentagram:    return .Pentagram
        case .rhombus:      return .Rhombus
        case .triangle:     return .Triangle
        default:            return nil
        }
    }
    
    var image: UIImage? {
        switch self {
        case .pencil:       return UIImage.agedu_named("ic_brush_pencil")
        case .line:         return UIImage.agedu_named("ic_brush_line")
        case .rect:         return UIImage.agedu_named("ic_brush_rect")
        case .circle:       return UIImage.agedu_named("ic_brush_circle")
        case .pentagram:    return UIImage.agedu_named("ic_brush_pentagram")
        case .rhombus:      return UIImage.agedu_named("ic_brush_rhombus")
        case .arrow:        return UIImage.agedu_named("ic_brush_arrow")
        case .triangle:     return UIImage.agedu_named("ic_brush_triangle")
        }
    }
    
    var selectedImage: UIImage? {
        switch self {
        case .pencil:       return UIImage.agedu_named("ic_brush_pencil")
        case .line:         return UIImage.agedu_named("ic_brush_line")
        case .rect:         return UIImage.agedu_named("ic_brush_rect_selected")
        case .circle:       return UIImage.agedu_named("ic_brush_circle_selected")
        case .pentagram:    return UIImage.agedu_named("ic_brush_pentagram_selected")
        case .rhombus:      return UIImage.agedu_named("ic_brush_rhombus_selected")
        case .arrow:        return UIImage.agedu_named("ic_brush_arrow")
        case .triangle:     return UIImage.agedu_named("ic_brush_triangle_selected")
        }
    }
}

enum AgoraBoardToolMainType: Int, CaseIterable {
    case clicker, area, paint, text, rubber, clear, pre, next
    
    var image: UIImage? {
        switch self {
        case .clicker:  return UIImage.agedu_named("ic_brush_clicker")
        case .area:     return UIImage.agedu_named("ic_brush_area")
        case .paint:    return UIImage.agedu_named("ic_brush_paint")
        case .text:     return UIImage.agedu_named("ic_brush_text")
        case .rubber:   return UIImage.agedu_named("ic_brush_rubber")
        case .clear:    return UIImage.agedu_named("ic_brush_clear")
        case .pre:      return UIImage.agedu_named("ic_brush_pre")
        case .next:     return UIImage.agedu_named("ic_brush_next")
        }
    }
    
    var selectedImage: UIImage? {
        switch self {
        case .clicker:  return UIImage.agedu_named("ic_brush_clicker_selected")
        case .area:     return UIImage.agedu_named("ic_brush_area_selected")
        case .paint:    return UIImage.agedu_named("ic_brush_paint_selected")
        case .text:     return UIImage.agedu_named("ic_brush_text")
        case .rubber:   return UIImage.agedu_named("ic_brush_rubber_selected")
        case .clear:    return UIImage.agedu_named("ic_brush_clear")
        case .pre:      return UIImage.agedu_named("ic_brush_pre")
        case .next:     return UIImage.agedu_named("ic_brush_next")
        }
    }
    
    var associatedType: Any.Type? {
        switch self {
        case .paint:
            return AgoraBoardToolPaintType.self
        default:
            return nil
        }
    }
    
    var boardWidgetToolType: AgoraBoardWidgetToolType? {
        switch self {
        case .clicker:  return .Clicker
        case .area:     return .Rectangle
        case .text:     return .Text
        case .rubber:   return .Eraser
        default:
            return nil
        }
    }
    
    var needUpdateCell: Bool {
        switch self {
        case .clicker, .area, .paint, .text, .rubber:  return true
        case .clear, .pre ,.next:                      return false
        }
    }
}

enum AgoraBoardToolItemType: Int, CaseIterable {
    case clicker, area, rubber, laser, text, pencil, line, rect, cycle
}

// MARK: - AgoraBoardToolItemCell
class AgoraBoardToolItemCell: UICollectionViewCell {
    private var imageView: UIImageView!
    
    private var colorView: UIView!
    
    var aSelected: Bool = false {
        willSet {
            if newValue {
                imageView.tintColor = .white
                colorView.backgroundColor = UIColor(hex: 0x0073FF)
            } else {
                imageView.tintColor = UIColor(hex: 0x7B88A0)
                colorView.backgroundColor = .white
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        colorView = UIView(frame: .zero)
        colorView.layer.cornerRadius = 5
        colorView.clipsToBounds = true
        addSubview(colorView)
        colorView.mas_makeConstraints { make in
            make?.width.height().equalTo()(38)
            make?.center.equalTo()(self)
        }
        
        imageView = UIImageView(frame: .zero)
        addSubview(imageView)
        imageView.mas_makeConstraints { make in
            make?.center.equalTo()(self)
        }
    }
    
    public func setImage(_ image: UIImage?) {
        guard let v = image else {
            return
        }
        imageView.image = v.withRenderingMode(.alwaysTemplate)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - AgoraToolCollectionToolCell
class AgoraToolCollectionToolCell: UICollectionViewCell {
    private var imageView: UIImageView!
    private var selectedColor: UIColor?
    
    // for pre/next
    private var enable: Bool = true {
        didSet {
            guard let i = imageView.image else {
                return
            }
            if enable {
                imageView.tintColor = nil
            } else {
                imageView.tintColor = UIColor(hex: 0xE2E2EE)
                imageView.image = i.withRenderingMode(.alwaysTemplate)
            }
        }
    }
    
    var aSelected: Bool = false {
        willSet {
            if newValue,
               let i = imageView.image {
                imageView.image = i.withRenderingMode(.alwaysTemplate)
                imageView.tintColor = selectedColor
            } else {
                imageView.tintColor = nil
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        
        imageView.mas_makeConstraints { make in
            make?.center.equalTo()(self)
        }
    }
    
    public func setEnable(_ enable: Bool) {
        self.enable = enable
    }
    
    public func setImage(image: UIImage?,
                         color: UIColor?) {
        if let c = color {
            selectedColor = color
        }
        imageView.image = image
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - AgoraBoardTextSizeItemCell
class AgoraBoardTextSizeItemCell: UICollectionViewCell {
    public var level: Int = 0 {
        willSet {
            if level != newValue {
                let scale = CGFloat(truncating: pow(1.4, newValue) as NSNumber)
                sizeView.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
        }
    }
    
    public var color: UIColor?
    /** 需要先设置颜色才能正常刷出来*/
    public var aSelected: Bool = false {
        willSet {
            guard let i = sizeView.image else {
                return
            }
            if newValue == true,
               let c = color {
                sizeView.image = i.withRenderingMode(.alwaysTemplate)
                sizeView.tintColor = c
            } else {
                sizeView.image = i.withRenderingMode(.alwaysOriginal)
            }
        }
    }
    
    private var sizeView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let image = UIImage.agedu_named("ic_brush_text")
        sizeView = UIImageView(image: image)
        sizeView.contentMode = .scaleAspectFit
        addSubview(sizeView)
        sizeView.mas_makeConstraints { make in
            make?.center.equalTo()(sizeView.superview)
            make?.width.height().equalTo()(12)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - BrushSizeItemCell
class AgoraBoardLineWidthCell: UICollectionViewCell {
    private var unselectedColor = AgoraColorGroup().tool_unselected_color
    public var level: Int = 0 {
        willSet {
            if level != newValue {
                let scale = CGFloat(truncating: pow(1.4, newValue) as NSNumber)
                sizeView.transform = CGAffineTransform(scaleX: scale,
                                                       y: scale)
            }
        }
    }
    
    public var color: UIColor?
    /** 需要先设置颜色才能正常刷出来*/
    public var aSelected: Bool = false {
        willSet {
            if newValue == true {
                if let c = color {
                    sizeView.backgroundColor = c
                    if c == UIColor(hex: 0xFFFFFF)! {
                        sizeView.borderWidth = 1
                        sizeView.borderColor = unselectedColor
                    } else {
                        sizeView.borderWidth = 0
                        sizeView.borderColor = nil
                    }
                } else {
                    sizeView.backgroundColor = unselectedColor
                }
            } else {
                sizeView.backgroundColor = unselectedColor
            }
        }
    }
    
    private var sizeView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        sizeView = UIView(frame: .zero)
        sizeView.backgroundColor = unselectedColor
        sizeView.cornerRadius = 3
        addSubview(sizeView)
        sizeView.mas_makeConstraints { make in
            make?.center.equalTo()(sizeView.superview)
            make?.width.height().equalTo()(6)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - BrushColorItemCell
class AgoraBoardColorItemCell: UICollectionViewCell {
    var frontView: UIView!
    
    var backView: UIView!
    
    var color: UIColor? {
        didSet {
            if let c = color {
                frontView.backgroundColor = c
                frontView.layer.borderColor = UIColor.clear.cgColor
                backView.layer.borderColor = c.cgColor
            } else {
                frontView.backgroundColor = .white
                frontView.layer.borderColor = UIColor(hex: 0xE1E1EA)?.cgColor
                backView.layer.borderColor = UIColor(hex: 0xE1E1EA)?.cgColor
            }
        }
    }
    
    var aSelected: Bool = false {
        willSet {
            backView.isHidden = !newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backView = UIView(frame: .zero)
        backView.layer.borderWidth = 1
        backView.layer.cornerRadius = 4
        backView.backgroundColor = .white
        addSubview(backView)
        backView.mas_makeConstraints { make in
            make?.center.equalTo()(backView.superview)
            make?.width.height().equalTo()(24)
        }
        
        frontView = UIView(frame: .zero)
        frontView.layer.borderWidth = 1
        frontView.layer.cornerRadius = 4
        frontView.clipsToBounds = true
        addSubview(frontView)
        frontView.mas_makeConstraints { make in
            make?.center.equalTo()(frontView.superview)
            make?.width.height().equalTo()(20)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
