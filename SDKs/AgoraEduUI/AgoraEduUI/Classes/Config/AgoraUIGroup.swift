//
//  AgoraColorGroup.swift
//  AgoraClassroomSDK_iOS
//
//  Created by Cavan on 2022/3/17.
//

import AgoraUIBaseViews
import UIKit

fileprivate enum AgoraUIMode {
    case agoraLight
}

fileprivate let Mode: AgoraUIMode = .agoraLight

class AgoraUIGroup {
    private(set) lazy var color = AgoraColorGroup()
    private(set) lazy var frame = AgoraFrameGroup()
}

class AgoraColorGroup {
    init() {
        self.mode = Mode
    }
    
    fileprivate var mode: AgoraUIMode
    
    // Common
    var common_base_tint_color: UIColor {
        switch mode {
        case .agoraLight:   return UIColor(hex: 0x357BF6)!
        }
    }
    
    // Tool bar
    var tool_bar_item_selected_color: UIColor {
        switch mode {
        case .agoraLight:  return .white
        }
    }
    
    var tool_bar_item_unselected_color: UIColor {
        switch mode {
        case .agoraLight:  return UIColor(hex: 0x7B88A0)!
        }
    }
    
    var tool_bar_item_highlight_color: UIColor {
        switch mode {
        case .agoraLight:  return UIColor(hex: 0x357BF6)!
        }
    }
    
    var tool_bar_item_background_selected_color: UIColor {
        switch mode {
        case .agoraLight:  return UIColor(hex: 0x357BF6)!
        }
    }
    
    var tool_bar_item_background_unselected_color: UIColor {
        switch mode {
        case .agoraLight:  return .white
        }
    }
    
    var tool_bar_item_background_highlight_color: UIColor {
        switch mode {
        case .agoraLight:  return .white
        }
    }
    
    // Board
    var board_bg_color: UIColor {
        switch mode {
        case .agoraLight:   return .white
        }
    }
    
    var board_border_color: CGColor {
        switch mode {
        case .agoraLight:   return UIColor(hexString: "#ECECF1")!.cgColor
        }
    }
    
    // Tool bar
    var tool_bar_button_normal_color: UIColor {
        switch mode {
        case .agoraLight:  return UIColor(hex: 0xECECF1)!
        }
    }
    
    // Render
    var render_label_shadow_opacity: Float = 1
    
    var render_label_color: UIColor = .white
    
    var render_label_shadow_color: CGColor = UIColor(hex: 0x0D1D3D,
                                                     transparency: 0.8)!.cgColor
    var room_border_color: UIColor {
        switch mode {
        case .agoraLight:   return UIColor(hex: 0xECECF1)!
        }
    }
    
    var room_bg_color: UIColor {
        switch mode {
        case .agoraLight:  return UIColor(hex: 0xF9F9FC)!
        }
    }
    
    var render_cell_bg_color: UIColor {
        switch mode {
        case .agoraLight:  return UIColor(hex: 0xF9F9FC)!
        }
    }
    
    var render_mask_border_color: CGColor {
        switch mode {
        case .agoraLight:  return UIColor(hex: 0xECECF1)!.cgColor
        }
    }
    
    var render_view_border_color: CGColor {
        switch mode {
        case .agoraLight:  return UIColor.clear.cgColor
        }
    }
    
    var render_left_right_button_color: UIColor {
        return UIColor.black.withAlphaComponent(0.3)
    }
    
    // board tool
    var tool_unselected_color: UIColor = UIColor(hex: 0xE1E1EA)!
    var tool_fake_white_color: UIColor = UIColor(hex: 0xE1E1EA)!
    
    // Room state bar
    var room_state_bg_color: UIColor {
        switch mode {
        case .agoraLight:  return .white
        }
    }
    
    var room_state_border_color: CGColor {
        switch mode {
        case .agoraLight:  return UIColor(hex: 0xECECF1)!.cgColor
        }
    }
    
    var room_state_label_before_color: UIColor {
        switch mode {
        case .agoraLight:  return UIColor(hex: 0x677386)!
        }
    }
    
    var room_state_line_color : UIColor {
        switch mode {
        case .agoraLight:  return UIColor(hex: 0xECECF1)!
        }
    }
    
    var room_state_title_color: UIColor {
        switch mode {
        case .agoraLight:  return UIColor(hex: 0x191919)!
        }
    }
    
    var room_state_sep_line_color: UIColor {
        switch mode {
        case .agoraLight:  return UIColor(hex: 0xD2D2E2)!
        }
    }
    
    var room_state_label_during_color: UIColor {
        switch mode {
        case .agoraLight:  return UIColor(hex: 0x677386)!
        }
    }
    
    var room_state_label_after_color: UIColor {
        switch mode {
        case .agoraLight:  return .red
        }
    }
    
    var room_state_bar_recording_text_color: UIColor {
        return UIColor(hexString: "#677386")!
    }
    
    var room_state_bar_recording_state_background_color: UIColor {
        return UIColor(hexString: "#F04C36")!
    }
    
    // class state
    var class_state_shadow_color: CGColor = UIColor(hex: 0x2F4192)!.cgColor
    
    // Setting
    var setting_switch_tint_color: UIColor {
        switch mode {
        case .agoraLight:  return UIColor(hex: 0x357BF6)!
        }
    }
    
    var setting_exit_button_color: UIColor {
        switch mode {
        case .agoraLight:  return UIColor(hex: 0x191919)!
        }
    }
            
    var small_room_state_border_color: CGColor {
        switch mode {
        case .agoraLight:  return UIColor(hex: 0xECECF1)!.cgColor
        }
    }
    
    var one_room_state_title_color: UIColor {
        switch mode {
        case .agoraLight:  return UIColor(hex: 0x191919)!
        }
    }
    
    var one_room_state_time_color: UIColor {
        switch mode {
        case .agoraLight:  return UIColor(hex: 0x677386)!
        }
    }
    
    var one_room_setting_selected_tint_color: UIColor {
        switch mode {
        case .agoraLight:  return .white
        }
    }
    
    var one_right_content_bg_color: UIColor {
        switch mode {
        case .agoraLight: return .white
        }
    }
    
    var one_room_setting_selected_bg_color: UIColor {
        switch mode {
        case .agoraLight:  return UIColor(hex: 0x357BF6)!
        }
    }
    
    var one_room_setting_unselected_tint_color: UIColor {
        switch mode {
        case .agoraLight:  return UIColor(hex: 0x7B88A0)!
        }
    }
    
    var one_room_setting_unselected_bg_color: UIColor {
        switch mode {
        case .agoraLight:  return .white
        }
    }

    func borderSet(layer: CALayer) {
        layer.shadowColor = UIColor(hex: 0x2F4192,
                                         transparency: 0.15)?.cgColor
        layer.shadowOffset = CGSize(width: 0,
                                    height: 2)
        layer.shadowOpacity = 1
        layer.shadowRadius = 6
    }
}

struct AgoraFrameGroup {
    init() {
        self.mode = Mode
    }
    
    fileprivate var mode: AgoraUIMode
    
    // room
    var room_border_width: CGFloat = 1
    
    var one_room_right_corner_radius: CGFloat = 4
    // Render
    var render_label_shadow_radius: CGFloat = 2
    
    var render_cell_border_width: CGFloat {
        switch mode {
        case .agoraLight:  return 1
        }
    }
    
    var one_one_to_render_cell_corner_radius: CGFloat {
        switch mode {
        case .agoraLight:  return 2
        }
    }
    
    var small_render_cell_corner_radius: CGFloat {
        switch mode {
        case .agoraLight:  return 2
        }
    }
    
    var render_left_right_button_radius: CGFloat {
        return 2
    }
    
    // Board
    var board_border_width: CGFloat {
        switch mode {
        case .agoraLight:  return 1
        }
    }
    
    var board_corner_radius: CGFloat {
        switch mode {
        case .agoraLight:  return 1
        }
    }
    
    // Room state bar
    var room_state_radius: CGFloat {
        switch mode {
        case .agoraLight:  return 2
        }
    }
    
    var room_state_corner_radius: CGFloat {
        switch mode {
        case .agoraLight:  return 2
        }
    }
    
    var room_state_bar_font: UIFont {
        return UIFont.systemFont(ofSize: 9)
    }
    
    var room_state_border_width: CGFloat = 1
    
    // class state
    var class_state_button_corner_radius: CGFloat = 17
    
    // subRoom
    var subRoom_option_label_left_space: CGFloat {
        return 37
    }
    
    var subRoom_option_label_right_space: CGFloat {
        return 15
    }
}
