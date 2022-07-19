//
//  FcrUIGroup.swift
//  AgoraEduUI
//
//  Created by Cavan on 2022/7/7.
//

import UIKit

struct FcrUIColorGroup {
    // MARK: - UI Config
    // 背景色
    static var systemBackgroundColor: UIColor {
        switch UIMode {
        case .agoraLight: return UIColor(hex: 0xF9F9FC)!
        case .agoraDark:  return UIColor(hex: 0x262626)!
        }
    }
    
    // 前景色
    static var systemForegroundColor: UIColor {
        switch UIMode {
        case .agoraLight:  return UIColor(hex: 0xFFFFFF)!
        case .agoraDark:   return UIColor(hex: 0x1D1D1D)!
        }
    }
    
    // 组件背景色
    static var systemComponentColor: UIColor {
        switch UIMode {
        case .agoraLight:   return UIColor(hex: 0xFFFFFF)!
        case .agoraDark:    return UIColor(hex: 0x2F2F2F)!
        }
    }
    
    // 边框/分割线色
    static var systemDividerColor: UIColor {
        switch UIMode {
        case .agoraLight:   return UIColor(hex: 0xEEEEF7)!
        case .agoraDark:    return UIColor(hex: 0x373737)!
        }
    }

    // 警告色
    static var systemErrorColor: UIColor {
        switch UIMode {
        case .agoraLight:   return UIColor(hex: 0xF5655C)!
        case .agoraDark:    return UIColor(hex: 0xF5655C)!
        }
    }
    
    // 警示色
    static var systemWarningColor: UIColor {
        switch UIMode {
        case .agoraLight:   return UIColor(hex: 0xFFB554)!
        case .agoraDark:    return UIColor(hex: 0xFFB554)!
        }
    }
    
    // 安全色
    static var systemSafeColor: UIColor {
        switch UIMode {
        case .agoraLight:   return UIColor(hex: 0x64BB5C)!
        case .agoraDark:    return UIColor(hex: 0x69C42E)!
        }
    }
    
    // 图标被选背景色
    static var iconSelectedBackgroundColor: UIColor {
        switch UIMode {
        case .agoraLight:   return UIColor(hex: 0xF8F9FC)!
        case .agoraDark:    return UIColor(hex: 0x323232)!
        }
    }
    
    // 图标色
    static var iconNormalBackgroundColor: UIColor {
        switch UIMode {
        case .agoraLight:   return UIColor(hex: 0x7B88A0)!
        case .agoraDark:    return UIColor(hex: 0x8E8E8E)!
        }
    }
    
    // 填充按钮色
    static var iconFillColor: UIColor {
        switch UIMode {
        case .agoraLight:   return UIColor(hex: 0x357BF6)!
        case .agoraDark:    return UIColor(hex: 0x317AF7)!
        }
    }
    
    // 线框按钮色
    static var iconLineColor: UIColor {
        switch UIMode {
        case .agoraLight:   return UIColor(hex: 0xEEEEF7)!
        case .agoraDark:    return UIColor(hex: 0x373737)!
        }
    }
    
    // 一级文本色
    static var textLevel1Color: UIColor {
        switch UIMode {
        case .agoraLight:   return UIColor(hex: 0x191919)!
        case .agoraDark:    return UIColor(hex: 0xFFFFFF)!.withAlphaComponent(0.80)
        }
    }
    
    // 二级文本色
    static var textLevel2Color: UIColor {
        switch UIMode {
        case .agoraLight:   return UIColor(hex: 0x586376)!
        case .agoraDark:    return UIColor(hex: 0xFFFFFF)!.withAlphaComponent(0.60)
        }
    }
    
    // 三级文本色
    static var textLevel3Color: UIColor {
        switch UIMode {
        case .agoraLight:   return UIColor(hex: 0x7B88A0)!
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
    static var textContrastColor: UIColor {
        switch UIMode {
        case .agoraLight:   return UIColor(hex: 0xFFFFFF)!
        case .agoraDark:    return UIColor(hex: 0xFFFFFF)!
        }
    }
     
    // MARK: - UI Standard
    static var borderColor: UIColor {
        switch UIMode {
        case .agoraLight:  return UIColor(hex: 0xEEEEF7)!
        case .agoraDark:   return UIColor(hex: 0x373737)!
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
