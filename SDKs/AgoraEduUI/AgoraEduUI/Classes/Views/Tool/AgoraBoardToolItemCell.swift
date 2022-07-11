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
    
    var widgetShape: FcrBoardWidgetShapeType {
        switch self {
        case .pencil:       return .curve
        case .line:         return .straight
        case .rect:         return .rectangle
        case .circle:       return .ellipse
        case .pentagram:    return .pentagram
        case .rhombus:      return .rhombus
        case .arrow:        return .arrow
        case .triangle:     return .triangle
        }
    }
    
    var unselectedImage: UIImage? {
        var imageName = ""
        switch self {
        case .pencil:       imageName = "toolcollection_unselecetd_pencil"
        case .line:         imageName = "toolcollection_unselecetd_line"
        case .rect:         imageName = "toolcollection_unselecetd_rect"
        case .circle:       imageName = "toolcollection_unselecetd_circle"
        case .pentagram:    imageName = "toolcollection_unselecetd_pentagram"
        case .rhombus:      imageName = "toolcollection_unselecetd_rhombus"
        case .arrow:        imageName = "toolcollection_unselecetd_arrow"
        case .triangle:     imageName = "toolcollection_unselecetd_triangle"
        }
        return UIImage.agedu_named(imageName)
    }
    
    var selectedImage: UIImage? {
        var imageName = ""
        switch self {
        case .pencil:       imageName = "toolcollection_selected_pencil"
        case .line:         imageName = "toolcollection_selected_line"
        case .rect:         imageName = "toolcollection_selected_rect"
        case .circle:       imageName = "toolcollection_selected_circle"
        case .pentagram:    imageName = "toolcollection_selected_pentagram"
        case .rhombus:      imageName = "toolcollection_selected_rhombus"
        case .arrow:        imageName = "toolcollection_selected_arrow"
        case .triangle:     imageName = "toolcollection_selected_triangle"
        }
        return UIImage.agedu_named(imageName)
    }
}

enum AgoraBoardToolMainType: Int, CaseIterable {
    case clicker, area, paint, text, rubber, clear, pre, next
    
    var unselectedImage: UIImage? {
        var imageName = ""
        switch self {
        case .clicker:  imageName = "toolcollection_unselecetd_clicker"
        case .area:     imageName = "toolcollection_unselecetd_area"
        case .paint:    imageName = "toolcollection_unselecetd_paint"
        case .text:     imageName = "toolcollection_unselecetd_text"
        case .rubber:   imageName = "toolcollection_unselecetd_rubber"
        case .clear:    imageName = "toolcollection_unselecetd_clear"
        case .pre:      imageName = "toolcollection_enabled_pre"
        case .next:     imageName = "toolcollection_enabled_next"
        }
        return UIImage.agedu_named(imageName)
    }
    
    var selectedImage: UIImage? {
        var imageName = ""
        switch self {
        case .clicker:  imageName = "toolcollection_selected_clicker"
        case .area:     imageName = "toolcollection_selected_area"
        case .paint:    imageName = "toolcollection_selected_paint"
        case .text:     imageName = "toolcollection_selecetd_text"
        case .rubber:   imageName = "toolcollection_selected_rubber"
        case .clear:    imageName = "toolcollection_enabled_clear"
        case .pre:      imageName = "toolcollection_enabled_pre"
        case .next:     imageName = "toolcollection_enabled_next"
        }
        return UIImage.agedu_named(imageName)
    }
    
    var disabledImage: UIImage? {
        var imageName = ""
        switch self {
        case .pre:      imageName = "toolcollection_disabled_pre"
        case .next:     imageName = "toolcollection_disabled_next"
        default:        break
        }
        return UIImage.agedu_named(imageName)
    }
    
    var widgetType: FcrBoardWidgetToolType? {
        switch self {
        case .clicker:  return .clicker
        case .area:     return .area
        case .rubber:   return .eraser
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

// MARK: - AgoraToolCollectionToolCell
class AgoraToolCollectionToolCell: UICollectionViewCell, AgoraUIContentContainer {
    private lazy var imageView = UIImageView(frame: .zero)
    private var selectedColor: UIColor?
    
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
        
        initViews()
        initViewFrame()
        updateViewProperties()
    }
    
    public func setEnable(_ enable: Bool) {
        guard let i = imageView.image else {
            return
        }
        if enable {
            imageView.tintColor = nil
        } else {
            imageView.tintColor = FcrColorGroup.fcr_icon_normal_color
            imageView.image = i.withRenderingMode(.alwaysTemplate)
        }
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
    
    // MARK: AgoraUIContentContainer
    func initViews() {
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
    }
    
    func initViewFrame() {
        imageView.mas_makeConstraints { make in
            make?.center.equalTo()(self)
            make?.width.height().equalTo()(UIDevice.current.agora_is_pad ? 34 : 30)
        }
    }
    
    func updateViewProperties() {
        let ui = AgoraUIGroup()
        imageView.tintColor = FcrColorGroup.fcr_icon_normal_color
    }
}

// MARK: - AgoraBoardTextSizeItemCell
class AgoraBoardTextSizeItemCell: UICollectionViewCell {
    public var level: Int = -1 {
        willSet {
            if level != newValue {
                let scale: CGFloat = (10 + 2 * CGFloat(newValue)) / 16
                sizeView.transform = CGAffineTransform(scaleX: scale,
                                                       y: scale)
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
        
        let image = UIImage.agedu_named("toolcollection_text")
        sizeView = UIImageView(image: image)
        sizeView.contentMode = .scaleAspectFill
        addSubview(sizeView)
        sizeView.mas_makeConstraints { make in
            make?.center.equalTo()(sizeView.superview)
            make?.width.height().equalTo()(sizeView.superview)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - BrushSizeItemCell
class AgoraBoardLineWidthCell: UICollectionViewCell, AgoraUIContentContainer {
    private var unselectedColor: UIColor!
    
    private var scales: [CGFloat] = [1, 4/3, 2, 7/3, 3]
    
    public var level: Int = -1 {
        willSet {
            if level != newValue {
                sizeView.transform = CGAffineTransform(scaleX: scales[newValue],
                                                       y: scales[newValue])
                let baseBorderWidth = AgoraUIGroup().frame.fcr_border_width
                sizeView.borderWidth = baseBorderWidth / scales[newValue]
            }
        }
    }
    
    public var color: UIColor!
    /** 需要先设置颜色才能正常刷出来*/
    public var aSelected: Bool = false {
        didSet {
            updateColor()
        }
    }
    
    private lazy var sizeView = UIView(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initViews()
        initViewFrame()
        updateViewProperties()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initViews() {
        // set to make a circle
        sizeView.cornerRadius = 3
        addSubview(sizeView)
    }
    
    func initViewFrame() {
        sizeView.mas_makeConstraints { make in
            make?.center.equalTo()(sizeView.superview)
            make?.width.height().equalTo()(6)
        }
    }
    
    func updateViewProperties() {
        let ui = AgoraUIGroup()
        unselectedColor = FcrColorGroup.fcr_icon_normal_color
        
        color = unselectedColor

        sizeView.borderWidth = ui.frame.fcr_border_width
        sizeView.borderColor = unselectedColor
        
        if aSelected {
            sizeView.backgroundColor = color
        } else {
            sizeView.backgroundColor = unselectedColor
        }
    }
    
    func updateColor() {
        // TODO: update color
        guard aSelected else {
            sizeView.borderColor = .clear
            sizeView.backgroundColor = unselectedColor
            return
        }
        
        sizeView.backgroundColor = color
        
        if color == UIColor(hex: 0xFFFFFF)! {
            sizeView.borderColor = unselectedColor
        } else {
            sizeView.borderColor = .clear
        }
    }
}

// MARK: - BrushColorItemCell
class AgoraBoardColorItemCell: UICollectionViewCell, AgoraUIContentContainer {
    lazy var frontView = UIView(frame: .zero)
    
    lazy var backView = UIView(frame: .zero)
    
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
        
        initViews()
        initViewFrame()
        updateViewProperties()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: AgoraUIContentContainer
    func initViews() {
        addSubview(backView)
        addSubview(frontView)
    }
    
    func initViewFrame() {
        backView.mas_makeConstraints { make in
            make?.center.equalTo()(backView.superview)
            make?.width.height().equalTo()(24)
        }
        
        frontView.mas_makeConstraints { make in
            make?.center.equalTo()(frontView.superview)
            make?.width.height().equalTo()(20)
        }
    }
    
    func updateViewProperties() {
        let ui = AgoraUIGroup()
        backView.layer.borderWidth = ui.frame.fcr_border_width
        backView.layer.cornerRadius = ui.frame.fcr_toast_corner_radius
        backView.backgroundColor = FcrColorGroup.fcr_system_component_color
        
        frontView.layer.borderWidth = ui.frame.fcr_border_width
        frontView.layer.cornerRadius = ui.frame.fcr_toast_corner_radius
        frontView.clipsToBounds = true
    }
}
