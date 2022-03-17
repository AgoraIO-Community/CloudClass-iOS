//
//  AgoraColorGroup.swift
//  AgoraClassroomSDK_iOS
//
//  Created by Cavan on 2022/3/17.
//

import AgoraUIBaseViews
import UIKit

fileprivate enum AgoraUIMode {
    case agoraWhite, akasuo
}

fileprivate let mode: AgoraUIMode = .agoraWhite

struct AgoraUIGroup {
    private(set) lazy var color = AgoraColorGroup(mode: mode)
    private(set) lazy var frame = AgoraFrameGroup(mode: mode)
}

struct AgoraColorGroup {
    fileprivate var mode: AgoraUIMode = .agoraWhite
    
    // Tool bar
    var tool_bar_button_normal_color: UIColor {
        switch mode {
        case .agoraWhite:  return UIColor(hex: 0xECECF1)!
        case .akasuo:      return UIColor(hexString: "#75C0FE")!
        }
    }
    
    // Render
    var render_cell_border_color: UIColor {
        switch mode {
        case .agoraWhite:  return UIColor(hex: 0xECECF1)!
        case .akasuo:      return UIColor(hexString: "#75C0FE")!
        }
    }
    
    // Room state bar
    var room_state_label_color: UIColor {
        switch mode {
        case .agoraWhite:  return UIColor.white
        case .akasuo:      return UIColor(hexString: "#C2D5E5")!
        }
    }
}

struct AgoraFrameGroup {
    fileprivate var mode: AgoraUIMode = .agoraWhite
    
    // Render
    var render_cell_border_width: CGFloat {
        switch mode {
        case .agoraWhite:  return 1
        case .akasuo:      return 2
        }
    }
    
    var one_one_to_render_cell_corner_radius: CGFloat {
        switch mode {
        case .agoraWhite:  return 1
        case .akasuo:      return 6
        }
    }
    
    var small_render_cell_corner_radius: CGFloat {
        switch mode {
        case .agoraWhite:  return 2
        case .akasuo:      return 2
        }
    }
    
    // Board
    var board_border_width: CGFloat {
        switch mode {
        case .agoraWhite:  return 1
        case .akasuo:      return 2
        }
    }
    
    var board_corner_radius: CGFloat {
        switch mode {
        case .agoraWhite:  return 1
        case .akasuo:      return 2
        }
    }
    
    // Room state bar
    var room_state_radius: CGFloat {
        switch mode {
        case .agoraWhite:  return 2
        case .akasuo:      return 2
        }
    }
    
    var room_state_label_color: CGFloat {
        switch mode {
        case .agoraWhite:  return 2
        case .akasuo:      return 2
        }
    }
}
