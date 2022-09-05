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
struct FcrUIItemDeviceExit: FcrUIItemProtocol {
    var visible: Bool    = true
    var enable: Bool     = true
    
    let backgroundColor: UIColor = FcrUIColorGroup.fcr_dark_icon_background1
    let image = UIImage.fcr_named("exit")
    let cornerRadius = FcrUIFrameGroup.systemCornerRadius
}

struct FcrUIItemDeviceTitle: FcrUIItemProtocol {
    var visible: Bool    = true
    var enable: Bool     = true
    
    let font:  UIFont = FcrUIFontGroup.font14
    let color: UIColor = FcrUIColorGroup.textLevel1Color
}

// Test
struct FcrUIItemTestTitle: FcrUIItemProtocol {
    var visible: Bool    = true
    var enable: Bool     = true
    
    let font:  UIFont = FcrUIFontGroup.font14
    let color: UIColor = FcrUIColorGroup.textLevel1Color
}
