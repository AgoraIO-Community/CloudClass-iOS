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

struct FcrUIItemDeviceEnterButton: FcrUIItemProtocol {
    var visible: Bool    = true
    var enable: Bool     = true
    
    let backgroundColor: UIColor = FcrUIColorGroup.systemBrandColor
    let cornerRadius = FcrUIFrameGroup.buttonCornerRadius
    let titleFont:  UIFont = FcrUIFontGroup.font16
    let titleColor: UIColor = FcrUIColorGroup.textContrastColor
}

// Test
struct FcrUIItemTestTitle: FcrUIItemProtocol {
    var visible: Bool    = true
    var enable: Bool     = true
    
    let font:  UIFont = FcrUIFontGroup.font14
    let color: UIColor = FcrUIColorGroup.textLevel1Color
}
