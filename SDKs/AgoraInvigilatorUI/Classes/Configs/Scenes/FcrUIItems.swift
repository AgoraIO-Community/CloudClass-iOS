//
//  FcrUIItems.swift
//  AgoraEduUI
//
//  Created by Cavan on 2022/7/7.
//

import UIKit

protocol FcrUIItemProtocol {
    var visible: Bool { get }
    var enable: Bool { get }
}

// Device
struct FcrUIItemDeviceExitButton: FcrUIItemProtocol {
    var visible: Bool    = true
    var enable: Bool     = true
    
    let backgroundColor: UIColor = FcrUIColorGroup.iconBackgroundColor
    let image = UIImage.fcr_named("exit")
    let cornerRadius = FcrUIFrameGroup.systemCornerRadius
}

struct FcrUIItemDeviceGreetLabel: FcrUIItemProtocol {
    var visible: Bool    = true
    var enable: Bool     = true
    
    let font:  UIFont = FcrUIFontGroup.font24
    let color: UIColor = FcrUIColorGroup.textLevel1Color
}

struct FcrUIItemDeviceStateLabel: FcrUIItemProtocol {
    var visible: Bool    = true
    var enable: Bool     = true
    
    let font:  UIFont = FcrUIFontGroup.font12
    let color: UIColor = FcrUIColorGroup.textLevel1Color
}

struct FcrUIItemDeviceTitleLabel: FcrUIItemProtocol {
    var visible: Bool    = true
    var enable: Bool     = true
    
    let font:  UIFont = FcrUIFontGroup.font14
    let color: UIColor = FcrUIColorGroup.textLevel1Color
}

struct FcrUIItemDeviceAvatar: FcrUIItemProtocol {
    var visible: Bool    = true
    var enable: Bool     = true
    
    let backgroundColor: UIColor = .clear
    let borderWidth: CGFloat     = FcrUIFrameGroup.highlightBorderWidth
    let titleFont:  UIFont       = FcrUIFontGroup.font30
    let titleColor: UIColor      = FcrUIColorGroup.textContrastColor
}

struct FcrUIItemDeviceEnterButton: FcrUIItemProtocol {
    var visible: Bool    = true
    var enable: Bool     = true
    
    let backgroundColor: UIColor = FcrUIColorGroup.systemBrandColor
    let cornerRadius             = FcrUIFrameGroup.buttonCornerRadius
    let titleFont:  UIFont       = FcrUIFontGroup.font16
    let titleColor: UIColor      = FcrUIColorGroup.textContrastColor
}

struct FcrUIItemDeviceNoAccess: FcrUIItemProtocol {
    var visible: Bool    = true
    var enable: Bool     = true
    
    // TODO: color
    let backgroundColor: UIColor = FcrUIColorGroup.systemForegroundColor.withAlphaComponent(0.1)
    let cornerRadius             = FcrUIFrameGroup.cardCornerRadius
    let titleFont:  UIFont       = FcrUIFontGroup.font20
    let titleColor: UIColor      = FcrUIColorGroup.textLevel2Color
    let contentFont:  UIFont     = FcrUIFontGroup.font14
    let contentColor: UIColor    = FcrUIColorGroup.textLevel2Color
}

// Test
struct FcrUIItemTestTitle: FcrUIItemProtocol {
    var visible: Bool    = true
    var enable: Bool     = true
    
    let font:  UIFont = FcrUIFontGroup.font14
    let color: UIColor = FcrUIColorGroup.textLevel1Color
}
