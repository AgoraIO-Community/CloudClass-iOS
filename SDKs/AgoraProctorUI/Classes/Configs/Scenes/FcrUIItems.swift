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
    let borderColor: UIColor     = FcrUIColorGroup.componentBorderColor
    let titleFont:  UIFont       = FcrUIFontGroup.font30
    let titleColor: UIColor      = FcrUIColorGroup.textDarkContrastColor
}

struct FcrUIItemDeviceEnterButton: FcrUIItemProtocol {
    var visible: Bool    = true
    var enable: Bool     = true
    
    let backgroundColor: UIColor = FcrUIColorGroup.systemBrandColor
    let cornerRadius             = FcrUIFrameGroup.buttonCornerRadius
    let titleFont:  UIFont       = FcrUIFontGroup.font16
    let titleColor: UIColor      = FcrUIColorGroup.textDarkContrastColor
}

struct FcrUIItemDeviceNoAccess: FcrUIItemProtocol {
    var visible: Bool    = true
    var enable: Bool     = true
    
    let backgroundColor: UIColor        = .clear
    let cardBackgroundColor: UIColor    = FcrUIColorGroup.componentBackgroundColor
    let cornerRadius                    = FcrUIFrameGroup.cardCornerRadius
    let titleFont:  UIFont              = FcrUIFontGroup.font20
    let titleColor: UIColor             = FcrUIColorGroup.textLightContrastColor
    let contentFont:  UIFont            = FcrUIFontGroup.font14
    let contentColor: UIColor           = FcrUIColorGroup.textLightContrastColor
    
    let image: UIImage?          = UIImage.fcr_named("fcr_invigilate_camera")
}

// Test
struct FcrUIItemTestTitle: FcrUIItemProtocol {
    var visible: Bool    = true
    var enable: Bool     = true
    
    let font:  UIFont = FcrUIFontGroup.font14
    let color: UIColor = FcrUIColorGroup.textLevel1Color
}

// Alert
struct FcrUIItemAlertTitle: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let color: UIColor  = FcrUIColorGroup.textLevel1Color
    let font: UIFont    = FcrUIFontGroup.font17
}

struct FcrUIItemAlertMessage: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let normalColor: UIColor  = FcrUIColorGroup.textLevel2Color
    let selectedColor: UIColor  = FcrUIColorGroup.textLevel1Color
    let font: UIFont    = FcrUIFontGroup.font13
    
    let checkedImage: UIImage?   = .fcr_named("ic_alert_checked")
    let uncheckedImage: UIImage? = .fcr_named("ic_alert_unchecked")
}

struct FcrUIItemAlertButton: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let normalTitleColor: UIColor = FcrUIColorGroup.textEnabledColor
    let font: UIFont              = FcrUIFontGroup.font17
}

// MARK: - common
struct FcrUIItemSepLine: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let backgroundColor: UIColor = FcrUIColorGroup.systemDividerColor
}

struct FcrUIItemShadow: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let color: CGColor  = FcrUIColorGroup.containerShadowColor.cgColor
    let offset: CGSize  = FcrUIColorGroup.containerShadowOffset
    let opacity: Float  = FcrUIColorGroup.shadowOpacity
    let radius: CGFloat = FcrUIColorGroup.containerShadowRadius
}
