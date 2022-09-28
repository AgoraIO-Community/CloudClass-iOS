//
//  PtUIGroup.swift
//  AgoraEduUI
//
//  Created by Cavan on 2022/7/7.
//

import UIKit

struct PtUIColorGroup {
    // MARK: - UI Config
    static var systemBackgroundColor: UIColor {
        switch UIMode {
        case .agoraLight: return UIColor(hex: 0x000000)!
        case .agoraDark: return UIColor(hex: 0x000000)!
        }
    }
    
    static var systemForegroundColor: UIColor {
        switch UIMode {
        case .agoraLight: return UIColor(hex: 0x2D2F3C)!
        case .agoraDark: return UIColor(hex: 0x2D2F3C)!
        }
    }
    
    static var systemBrandColor: UIColor {
        switch UIMode {
        case .agoraLight: return UIColor(hex: 0x357BF6)!
        case .agoraDark: return UIColor(hex: 0x357BF6)!
        }
    }
    
    static var buttonNormalColor: UIColor {
        switch UIMode {
        case .agoraLight: return UIColor(hex: 0xF8F8F8)!
        case .agoraDark: return UIColor(hex: 0xF8F8F8)!
        }
    }
    
    static var componentBackgroundColor: UIColor {
        switch UIMode {
        case .agoraLight: return UIColor(hex: 0xFFFFFF)!
        case .agoraDark: return UIColor(hex: 0xFFFFFF)!
        }
    }
    
    static var cardBackgroundColor: UIColor {
        switch UIMode {
        case .agoraLight: return UIColor(hex: 0xD9D9D9)!.withAlphaComponent(0.9)
        case .agoraDark: return UIColor(hex: 0xD9D9D9)!.withAlphaComponent(0.9)
        }
    }
    
    // 警告色
    static var systemErrorColor: UIColor {
        switch UIMode {
        case .agoraLight:   return UIColor(hex: 0xF5655C)!
        case .agoraDark:    return UIColor(hex: 0xF5655C)!
        }
    }
    
    // 组件背景色
    static var systemComponentColor: UIColor {
        switch UIMode {
        case .agoraLight:   return UIColor(hex: 0xFFFFFF)!
        case .agoraDark:    return UIColor(hex: 0x2F2F2F)!
        }
    }
    
    
    // 图标色
    static var iconBackgroundColor: UIColor {
        switch UIMode {
        case .agoraLight:   return UIColor(hex: 0x8A8A8A)!.withAlphaComponent(0.1)
        case .agoraDark:    return UIColor(hex: 0x343434)!.withAlphaComponent(0.9)
        }
    }
    
    static var iconAlphaBackgroundColor: UIColor {
        switch UIMode {
        case .agoraLight:   return UIColor(hex: 0x8A8A8A)!.withAlphaComponent(0.1)
        case .agoraDark:    return UIColor(hex: 0x8A8A8A)!.withAlphaComponent(0.1)
        }
    }
    
    // border
    static var componentBorderColor: UIColor {
        switch UIMode {
        case .agoraLight:   return UIColor(hex: 0x4A4C5F)!
        case .agoraDark:    return UIColor(hex: 0xEFEFEF)!
        }
    }
    
    // 文本色
    static var textLevel1Color: UIColor {
        switch UIMode {
        case .agoraLight:   return UIColor(hex: 0x000000)!
        case .agoraDark:    return UIColor(hex: 0xFFFFFF)!
        }
    }
    
    static var textLevel2Color: UIColor {
        switch UIMode {
        case .agoraLight:   return UIColor(hex: 0x586376)!
        case .agoraDark:    return UIColor(hex: 0xFFFFFF)!.withAlphaComponent(0.60)
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
    static var textDarkContrastColor: UIColor {
        switch UIMode {
        case .agoraLight:   return UIColor(hex: 0xFFFFFF)!
        case .agoraDark:    return UIColor(hex: 0xFFFFFF)!
        }
    }
    
    static var textLightContrastColor: UIColor {
        switch UIMode {
        case .agoraLight:   return UIColor(hex: 0x000000)!
        case .agoraDark:    return UIColor(hex: 0x000000)!
        }
    }
    
    // 边框/分割线色
    static var systemDividerColor: UIColor {
        switch UIMode {
        case .agoraLight:   return UIColor(hex: 0xEEEEF7)!
        case .agoraDark:    return UIColor(hex: 0x373737)!
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
