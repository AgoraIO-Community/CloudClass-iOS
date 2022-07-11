//
//  FcrUIGroup.swift
//  AgoraEduUI
//
//  Created by Cavan on 2022/7/7.
//

import UIKit

struct FcrUIColorGroup {
    // standard
    static var fcr_system_background_color: UIColor {
        switch UIMode {
        case .agoraLight: return UIColor(hex: 0xF9F9FC)!
        case .agoraDark:  return UIColor(hex: 0x121212)!
        }
    }
    
    static var fcr_system_foreground_color: UIColor {
        switch UIMode {
        case .agoraLight:  return UIColor(hex: 0xFFFFFF)!
        case .agoraDark:   return UIColor(hex: 0x1D1D1D)!
        }
    }
    
    static var fcr_system_component_color: UIColor {
        switch UIMode {
        case .agoraLight:   return UIColor(hex: 0xFFFFFF)!
        case .agoraDark:    return UIColor(hex: 0x2A2A2A)!
        }
    }
    
    static var fcr_system_divider_color: UIColor {
        switch UIMode {
        case .agoraLight:   return UIColor(hex: 0xEEEEF7)!
        case .agoraDark:    return UIColor(hex: 0x373737)!
        }
    }
    
    static var fcr_system_highlight_color: UIColor {
        switch UIMode {
        case .agoraLight:   return UIColor(hex: 0x357BF6)!
        case .agoraDark:    return UIColor(hex: 0x317AF7)!
        }
    }

    static var fcr_system_error_color: UIColor {
        switch UIMode {
        case .agoraLight:   return UIColor(hex: 0xF04C36)!
        case .agoraDark:    return UIColor(hex: 0xD94838)!
        }
    }
    
    static var fcr_system_warning_color: UIColor {
        switch UIMode {
        case .agoraLight:   return UIColor(hex: 0xFFA229)!
        case .agoraDark:    return UIColor(hex: 0xF8A01D)!
        }
    }
    
    static var fcr_system_safe_color: UIColor {
        switch UIMode {
        case .agoraLight:   return UIColor(hex: 0x64BB5C)!
        case .agoraDark:    return UIColor(hex: 0x69C42E)!
        }
    }
    
    // icon
    static var fcr_icon_normal_color: UIColor {
        switch UIMode {
        case .agoraLight:   return UIColor(hex: 0x7B88A0)!
        case .agoraDark:    return UIColor(hex: 0x8E8E8E)!
        }
    }
    
    static var fcr_icon_fill_color: UIColor {
        switch UIMode {
        case .agoraLight:   return UIColor(hex: 0x357BF6)!
        case .agoraDark:    return UIColor(hex: 0x317AF7)!
        }
    }
    
    static var fcr_icon_line_color: UIColor {
        switch UIMode {
        case .agoraLight:   return UIColor(hex: 0xEEEEF7)!
        case .agoraDark:    return UIColor(hex: 0x373737)!
        }
    }
    
    // Text
    static var fcr_text_level1_color: UIColor {
        switch UIMode {
        case .agoraLight:   return UIColor(hex: 0x191919)!
        case .agoraDark:    return UIColor(hex: 0xFFFFFF)!.withAlphaComponent(0.87)
        }
    }
    
    static var fcr_text_level2_color: UIColor {
        switch UIMode {
        case .agoraLight:   return UIColor(hex: 0x586376)!
        case .agoraDark:    return UIColor(hex: 0xFFFFFF)!.withAlphaComponent(0.60)
        }
    }
    
    static var fcr_text_level3_color: UIColor {
        switch UIMode {
        case .agoraLight:   return UIColor(hex: 0x7B88A0)!
        case .agoraDark:    return UIColor(hex: 0xFFFFFF)!.withAlphaComponent(0.60)
        }
    }
    
    static var fcr_text_disabled_color: UIColor {
        switch UIMode {
        case .agoraLight:   return UIColor(hex: 0xBDBDCA)!
        case .agoraDark:    return UIColor(hex: 0xFFFFFF)!.withAlphaComponent(0.38)
        }
    }
    
    static var fcr_text_enabled_color: UIColor {
        switch UIMode {
        case .agoraLight:   return UIColor(hex: 0x357BF6)!
        case .agoraDark:    return UIColor(hex: 0x317AF7)!
        }
    }
    
    static var fcr_text_contrast_color: UIColor {
        switch UIMode {
        case .agoraLight:   return .white
        case .agoraDark:    return .white
        }
    }
    
    // border
    static var fcr_border_color: CGColor {
        switch UIMode {
        case .agoraLight:  return UIColor(hex: 0xEEEEF7)!.cgColor
        case .agoraDark:   return UIColor(hex: 0x373737)!.cgColor
        }
    }
    
    // shadow
    static var fcr_text_shadow_color: CGColor {
        switch UIMode {
        case .agoraLight:  return UIColor(hex: 0x0D1D3D,
                                          transparency: 0.8)!.cgColor
        case .agoraDark:   return UIColor(hex: 0x0D1D3D,
                                          transparency: 0.8)!.cgColor
        }
    }
    
    static var fcr_container_shadow_color: CGColor {
        switch UIMode {
        case .agoraLight:   return UIColor(hex: 0x2F4192,
                                           transparency: 0.15)!.cgColor
        case .agoraDark:    return UIColor(hex: 0x000000,
                                           transparency: 0.12)!.cgColor
        }
    }
    
    static var fcr_label_shadow_radius: CGFloat = 2
    static var fcr_label_shadow_offset: CGSize = CGSize(width: 0,
                                                        height: 1)
    static var fcr_shadow_opacity: Float = 1
    static var fcr_shadow_radius: CGFloat = 8
    static var fcr_view_shadow_offset: CGSize = CGSize(width: 0,
                                                       height: 2)
    
    static func borderSet(layer: CALayer) {
        layer.shadowColor = fcr_container_shadow_color
        layer.shadowOffset = fcr_view_shadow_offset
        layer.shadowOpacity = fcr_shadow_opacity
        layer.shadowRadius = fcr_shadow_radius
    }
}
