//
//  AgoraCourseTipsView.swift
//  AFNetworking
//
//  Created by ZYP on 2021/2/3.
//

import UIKit

@objcMembers public class AgoraCourseTipsView: AgoraBaseView {
    
    public typealias StyleType = Int
    /// style for no alert icon
    public static let styleNromal: StyleType = 0
    /// style for alert
    public static let styleAlert: StyleType = 1
    
    let imageView = UIImageView()
    let textLabel = UILabel()
    let bgView = UIView()
    var style: StyleType = -1
    var bgViewLeadingConstraint: NSLayoutConstraint?
    var textLabelLeadingConstraint: NSLayoutConstraint?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setup() {
        
        let allHeight = AgoraCourseTipsView.allHeight()
        let bgViewHeight = AgoraCourseTipsView.bgViewHeight()
        
        backgroundColor = .clear
        imageView.image = Bundle.agoraEduBundle.image(name: "时钟")
        imageView.isHidden = style == AgoraCourseTipsView.styleNromal
        bgView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        bgView.layer.cornerRadius = bgViewHeight/2
        bgView.layer.masksToBounds = true
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        bgView.translatesAutoresizingMaskIntoConstraints = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        bgView.addSubview(textLabel)
        addSubview(bgView)
        addSubview(imageView)
        
        textLabelLeadingConstraint = textLabel.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: textLabelLeadingConstraintConstant())
        textLabelLeadingConstraint?.isActive = true
        textLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        textLabel.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -10).isActive = true
        
        bgViewLeadingConstraint = bgView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: bgViewLeadingConstraintConstant())
        bgViewLeadingConstraint?.isActive = true
        bgView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        bgView.heightAnchor.constraint(equalToConstant: bgViewHeight).isActive = true
        bgView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        imageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -2).isActive = true
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            imageView.widthAnchor.constraint(equalToConstant: 52.2525).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: 60.0025).isActive = true
        }
    }
    
    /// set text and decide to set by red color in redAttrRange
    /// - Parameters:
    ///   - text: text eg: “距离教室关闭还有1分钟”
    ///   - usingRedAttribe: using Red Attribe or not
    ///   - redAttrRange: text will be set by red color in `redAttrRange`, default is `NSRange(location: 8, length: 1)`
    /// - see also `setAttributedText` method
    public func setText(text: String,
                        usingRedAttribe: Bool = true,
                        redAttrRange: NSRange = NSRange(location: 8, length: 1)) {
        let normalColor = UIColor(red: 1, green: 1, blue: 1,alpha:1)
        let alertColor = UIColor(red: 1, green: 0.19, blue: 0.25,alpha:1)
        
        /** if no using attribe */
        let attrString = NSMutableAttributedString(string: text)
        if !usingRedAttribe {
            let strSubAttr1: [NSMutableAttributedString.Key: Any] = [.font: nromalFont(),.
                                                                        foregroundColor: normalColor]
            attrString.addAttributes(strSubAttr1, range: NSRange(location: 0, length: text.count))
            setAttributedText(attributedText: attrString)
            return
        }
        
        guard text.count > redAttrRange.location + redAttrRange.length else {
            return
        }
        
        /** if using attribe */
        let location = redAttrRange.location
        let strSubAttr1: [NSMutableAttributedString.Key: Any] = [.font: nromalFont(),
                                                                 .foregroundColor: normalColor]
        attrString.addAttributes(strSubAttr1, range: NSRange(location: 0, length: location))
        let strSubAttr2: [NSMutableAttributedString.Key: Any] = [.font: alertFont(),
                                                                 .foregroundColor: alertColor]
        attrString.addAttributes(strSubAttr2, range: NSRange(location: location, length: 1))
        let strSubAttr3: [NSMutableAttributedString.Key: Any] = [.font: nromalFont(),
                                                                 .foregroundColor: normalColor]
        attrString.addAttributes(strSubAttr3, range: NSRange(location: location+1, length: text.count - location - 1))
        setAttributedText(attributedText: attrString)
    }
    
    /// set text by coustomed attributedText
    public func setAttributedText(attributedText: NSMutableAttributedString) {
        textLabel.attributedText = attributedText
    }
    
    
    /// config stype
    /// - Parameter style: StyleType: `AgoraCourseTipsView.styleNromal` or `AgoraCourseTipsView.styleAlert`
    public func setStyle(style: StyleType) {
        if self.style == -1 {
            self.style = style
            setup()
            return
        }
        
        self.style = style
        bgViewLeadingConstraint?.constant = bgViewLeadingConstraintConstant()
        textLabelLeadingConstraint?.constant = textLabelLeadingConstraintConstant()
        layoutIfNeeded()
    }
    
    /// Height of AgoraCourseTipsView instance should be set `allHeight` value
    public static func allHeight() -> CGFloat {
        return UIDevice.current.userInterfaceIdiom == .pad ? 82.5 : 70
    }
    
    static func bgViewHeight() -> CGFloat {
        return allHeight() - 25
    }
    
    func textLabelLeadingConstraintConstant() -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad  {
            return style == AgoraCourseTipsView.styleNromal ? 22 : 65
        }
        else {
            return style == AgoraCourseTipsView.styleNromal ? 20 : 45
        }
    }
    
    func bgViewLeadingConstraintConstant() -> CGFloat {
        return style == AgoraCourseTipsView.styleNromal ? 0 : 33/2
    }
    
    func nromalFont() -> UIFont {
        let size: CGFloat =  UIDevice.current.userInterfaceIdiom == .pad ? 14 : 12
        return UIFont.systemFont(ofSize: size)
    }
    
    func alertFont() -> UIFont {
        let size: CGFloat =  UIDevice.current.userInterfaceIdiom == .pad ? 20 : 18
        return UIFont.systemFont(ofSize: size)
    }
}


