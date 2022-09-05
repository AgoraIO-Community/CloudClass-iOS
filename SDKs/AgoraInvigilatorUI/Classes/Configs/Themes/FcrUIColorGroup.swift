//
//  FcrUIGroup.swift
//  AgoraEduUI
//
//  Created by Cavan on 2022/7/7.
//

import UIKit

struct FcrUIColorGroup {
    // MARK: - UI Config
    // 图标色
    static var fcr_dark_icon_background1: UIColor {
        switch UIMode {
        case .agoraLight:   return UIColor(hex: 0x8A8A8A)!.withAlphaComponent(0.1)
        case .agoraDark:    return UIColor(hex: 0x343434)!.withAlphaComponent(0.9)
        }
    }
    
    // 一级文本色
    static var textLevel1Color: UIColor {
        switch UIMode {
        case .agoraLight:   return UIColor(hex: 0x000000)!
        case .agoraDark:    return UIColor(hex: 0xFFFFFF)!.withAlphaComponent(0.80)
        }
    }

    // 不可用文本色
    static var textDisabledColor: UIColor {
        switch UIMode {
        case .agoraLight:   return UIColor(hex: 0xBDBDCA)!
        case .agoraDark:    return UIColor(hex: 0xFFFFFF)!.withAlphaComponent(0.38)
        }
    }
    
    // 可点击/链接色
    static var textEnabledColor: UIColor {
        switch UIMode {
        case .agoraLight:   return UIColor(hex: 0x357BF6)!
        case .agoraDark:    return UIColor(hex: 0x317AF7)!
        }
    }
    
    // 主按钮文本色
    static var textContrastColor: UIColor {
        switch UIMode {
        case .agoraLight:   return UIColor(hex: 0xFFFFFF)!
        case .agoraDark:    return UIColor(hex: 0xFFFFFF)!
        }
    }
     
    // shadow
    static var textShadowColor: UIColor {
        switch UIMode {
        case .agoraLight:  return UIColor(hex: 0x0D1D3D,
                                          transparency: 0.8)!
        case .agoraDark:   return UIColor(hex: 0x0D1D3D,
                                          transparency: 0.8)!
        }
    }
    
    static var containerShadowColor: UIColor {
        switch UIMode {
        case .agoraLight:   return UIColor(hex: 0x2F4192,
                                           transparency: 0.15)!
        case .agoraDark:    return UIColor(hex: 0x000000,
                                           transparency: 0.12)!
        }
    }
    
    static var labelShadowRadius: CGFloat = 2
    static var labelShadowOffset: CGSize = CGSize(width: 0,
                                                        height: 1)
    static var shadowOpacity: Float = 1
    static var containerShadowRadius: CGFloat = 8
    static var containerShadowOffset: CGSize = CGSize(width: 0,
                                                       height: 2)
}
