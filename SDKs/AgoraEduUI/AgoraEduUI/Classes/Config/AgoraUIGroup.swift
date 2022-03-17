//
//  AgoraColorGroup.swift
//  AgoraClassroomSDK_iOS
//
//  Created by Cavan on 2022/3/17.
//

import AgoraUIBaseViews
import UIKit

fileprivate enum AgoraUIMode {
    case  agoraLight, akasuo
}

fileprivate let Mode: AgoraUIMode = .akasuo

class AgoraUIGroup {
    private(set) lazy var color = AgoraColorGroup()
    private(set) lazy var frame = AgoraFrameGroup()
}

class AgoraColorGroup {
    init() {
            self.mode = Mode
        }
    
    fileprivate var mode: AgoraUIMode = .agoraLight
    
    // Common
    var common_base_tint_color: UIColor {
        switch mode {
        case .agoraLight:   return UIColor(hex: 0x357BF6)!
        case .akasuo:       return UIColor(hex: 0xDDB332)!
        }
    }
    
    // board
    var board_bg_color: UIColor {
        switch mode {
        case .agoraLight:   return UIColor(hex: 0x357BF6)!
        case .akasuo:       return UIColor(hex: 0x263487)!
        }
    }
    
    // Tool bar
    var tool_bar_button_normal_color: UIColor {
        switch mode {
        case .agoraLight:  return UIColor(hex: 0xECECF1)!
        case .akasuo:      return UIColor(hexString: "#75C0FE")!
        }
    }
    
    // Render
    var render_label_shadow_opacity: Float = 1
    
    var render_label_color: UIColor = .white
    
    var render_label_shadow_color: CGColor = UIColor(hex: 0x0D1D3D,
                                                     transparency: 0.8)!.cgColor
    var render_cell_bg_color: UIColor {
        switch mode {
        case .agoraLight:  return UIColor(hex: 0xF9F9FC)!
        case .akasuo:      return UIColor(hex: 0xF9F9FC)!
        }
    }
    var render_cell_border_color: CGColor {
        switch mode {
        case .agoraLight:  return UIColor(hex: 0xECECF1)!.cgColor
        case .akasuo:      return UIColor(hex: 0x75C0FE)!.cgColor
        }
    }
    
    var render_left_right_button_color: UIColor {
        return .black.withAlphaComponent(0.3)
    }
    
    // Room state bar
    var room_state_bg_color: UIColor {
        switch mode {
        case .agoraLight:  return .white
        case .akasuo:      return UIColor(hex: 0x1D35AD)!
        }
    }
    
    var room_state_border_color: CGColor {
        switch mode {
        case .agoraLight:  return UIColor(hex: 0xECECF1)!.cgColor
        case .akasuo:      return UIColor(hex: 0x1D35AD)!.cgColor
        }
    }
    
    var room_state_label_before_color: UIColor {
        switch mode {
        case .agoraLight:  return UIColor(hex: 0x677386)!
        case .akasuo:      return UIColor(hexString: "#C2D5E5")!
        }
    }
    
    var room_state_line_color : UIColor {
        switch mode {
        case .agoraLight:  return UIColor(hex: 0xECECF1)!
        case .akasuo:      return UIColor(hex: 0xECECF1)!
        }
    }
    
    var room_state_time_color: UIColor {
        switch mode {
        case .agoraLight:  return UIColor(hex: 0x191919)!
        case .akasuo:      return UIColor(hex: 0x191919)!
        }
    }
    
    var room_state_sep_line_color: UIColor {
        switch mode {
        case .agoraLight:  return UIColor(hex: 0xD2D2E2)!
        case .akasuo:      return UIColor(hex: 0xD2D2E2)!
        }
    }
    
    var room_state_label_during_color: UIColor {
        switch mode {
        case .agoraLight:  return UIColor(hex: 0x677386)!
        case .akasuo:      return UIColor(hexString: "#C2D5E5")!
        }
    }
    
    var room_state_label_after_color: UIColor {
        switch mode {
        case .agoraLight:  return .red
        case .akasuo:      return UIColor(hexString: "#C2D5E5")!
        }
    }
    
    var small_room_state_border_color: CGColor {
        switch mode {
        case .agoraLight:  return UIColor(hex: 0xECECF1)!.cgColor
        case .akasuo:      return UIColor(hexString: "#C2D5E5")!.cgColor
        }
    }
    
    var one_room_state_title_color: UIColor {
        switch mode {
        case .agoraLight:  return UIColor(hex: 0x191919)!
        case .akasuo:      return UIColor(hex: 0xC2D5E5)!
        }
    }
    
    var one_room_state_time_color: UIColor {
        switch mode {
        case .agoraLight:  return UIColor(hex: 0x677386)!
        case .akasuo:      return UIColor(hex: 0xC2D5E5)!
        }
    }
    
    var one_room_setting_selected_tint_color: UIColor {
        switch mode {
        case .agoraLight:  return .white
        case .akasuo:      return .white
        }
    }
    
    var one_room_setting_selected_bg_color: UIColor {
        switch mode {
        case .agoraLight:  return UIColor(hex: 0x357BF6)!
        case .akasuo:      return UIColor(hex: 0xDDB332)!
        }
    }
    
    var one_room_setting_unselected_tint_color: UIColor {
        switch mode {
        case .agoraLight:  return UIColor(hex: 0x7B88A0)!
        case .akasuo:      return UIColor(hex: 0x7B88A0)!
        }
    }
    
    var one_room_setting_unselected_bg_color: UIColor {
        switch mode {
        case .agoraLight:  return .white
        case .akasuo:      return .clear
        }
    }
}

struct AgoraFrameGroup {
    init() {
        self.mode = Mode
    }
    
    fileprivate var mode: AgoraUIMode = .agoraLight
    
    // Render
    var render_label_shadow_radius: CGFloat = 2
    
    var render_cell_border_width: CGFloat {
        switch mode {
        case .agoraLight:  return 1
        case .akasuo:      return 2
        }
    }
    
    var one_one_to_render_cell_corner_radius: CGFloat {
        switch mode {
        case .agoraLight:  return 1
        case .akasuo:      return 6
        }
    }
    
    var small_render_cell_corner_radius: CGFloat {
        switch mode {
        case .agoraLight:  return 2
        case .akasuo:      return 2
        }
    }
    
    
    var render_left_right_button_radius: CGFloat {
        return 2
    }
    
    // Board
    var board_border_width: CGFloat {
        switch mode {
        case .agoraLight:  return 1
        case .akasuo:      return 2
        }
    }
    
    var board_corner_radius: CGFloat {
        switch mode {
        case .agoraLight:  return 1
        case .akasuo:      return 2
        }
    }
    
    // Room state bar
    var room_state_radius: CGFloat {
        switch mode {
        case .agoraLight:  return 2
        case .akasuo:      return 2
        }
    }
    
    var room_state_corner_radius: CGFloat {
        switch mode {
        case .agoraLight:  return 2
        case .akasuo:      return 2
        }
    }
    
    var room_state_border_width: CGFloat = 1
    
    // class state
    var class_state_button_corner_radius: CGFloat {
        return 20
    }
}
