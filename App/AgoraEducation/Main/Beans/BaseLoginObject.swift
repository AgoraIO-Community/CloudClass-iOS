//
//  BaseLoginObject.swift
//  AgoraEducation
//
//  Created by LYY on 2021/4/19.
//  Copyright © 2021 Agora. All rights reserved.
//

#if canImport(AgoraClassroomSDK_iOS)
import AgoraClassroomSDK_iOS
#else
import AgoraClassroomSDK
#endif
import Foundation
import UIKit

enum Device: String {
    case iPhone_Big
    case iPhone_Small
    case iPad
}

enum FIELD_TYPE: String {
    case `default`
    case room
    case user
    case duration
    case encryptKey
    case encryptMode
    
    var moveDistance: CGFloat {
        switch self {
        case .room:
            return 0
        case .user:
            return LoginConfig.device == .iPad ? 50 : 0
        case .duration:
            return LoginConfig.device == .iPad ? 230 : 50
        case .encryptKey:
            return LoginConfig.device == .iPad ? 300 : 90
        case .encryptMode:
            return LoginConfig.device == .iPad ? 350 : 130
        default:
            return 0
        }
    }
}

class LoginConfig {
    
    static let version_time: String = {
        return "2022.08.05"
    }()
    
    static let sdk_version: String = AgoraClassroomSDK.version()
    static let class_version: String = Bundle.main.version
    
    static var device: Device {
        if UIDevice.current.model == "iPhone" {
            if UIScreen.main.bounds.size.height < 700 {
                return .iPhone_Small
            }
            return .iPhone_Big
        }
        return .iPad
    }
    
    static var login_icon_y: CGFloat {
        switch device {
        case .iPhone_Big: return 115
        case .iPhone_Small: return 98
        case .iPad: return 88
        }
    }
    
    static var login_about_y: CGFloat {
        switch device {
        case .iPhone_Big: return 46
        case .iPhone_Small: return 98
        case .iPad: return 32
        }
    }
    
    static var login_first_group_y: CGFloat {
        switch device {
        case .iPhone_Big: return 225
        case .iPhone_Small: return 163
        case .iPad: return 270
        }
    }
    static var login_about_right: CGFloat {
        switch device {
        case .iPhone_Big: fallthrough
        case .iPhone_Small: return 15
        case .iPad: return 17
        }
    }
    
    static let login_choose_cell_height: CGFloat = 44
    static let login_class_types_width: CGFloat = 310
    static var login_class_types_y: CGFloat {
        switch device {
        case .iPhone_Big: return 382
        case .iPhone_Small: return 343
        case .iPad: return 430
        }
    }
    
    static var login_regions_types_y: CGFloat {
        switch device {
        case .iPhone_Big: return 445
        case .iPhone_Small: return 403
        case .iPad: return 491
        }
    }
    
    static let login_group_title_width : CGFloat = 58
    static let login_group_width : CGFloat = (device == .iPhone_Small) ? 260 : 280
    static var login_bottom_bottom : CGFloat {
        switch device {
        case .iPhone_Big: return 64
        case .iPhone_Small: return 14
        case .iPad: return 30
        }
    }
    
    static var about_enter_right: CGFloat = (device == .iPad) ? 21 : 15
    static var about_title_height : CGFloat {
        switch device {
        case .iPhone_Big: return 89
        case .iPhone_Small: return 69
        case .iPad: return 44
        }
    }
    static var about_title_font: UIFont = (device == .iPad) ? UIFont.systemFont(ofSize: 16) : UIFont.systemFont(ofSize: 17)
    static var about_title_sep: CGFloat = (device == .iPad) ? 0 : 10
    static var about_cell_title_x: CGFloat = (device == .iPad) ? 20 : 15
    static var about_cell_height: CGFloat = (device == .iPad) ? 44 : 48
    static var about_cell_info_right: CGFloat = (device == .iPad) ? 21 : 15
    static var about_bottom_line_x: CGFloat = (device == .iPad) ? 20 : 10
    static var about_line_length: CGFloat = (device == .iPad) ? 380 : UIScreen.main.bounds.width
    static var about_label_font: UIFont = (device == .iPad) ? UIFont.systemFont(ofSize: 14) : UIFont.systemFont(ofSize: 16)
    
    static var dis_title_height : CGFloat {
        switch device {
        case .iPhone_Big: return 89
        case .iPhone_Small: return 69
        case .iPad: return 44
        }
    }
    static var dis_line_x: CGFloat = (device == .iPad) ? 10 : 0
    static var dis_back_x: CGFloat = (device == .iPad) ? 10 : 15
    static var dis_back_bottom: CGFloat = (device == .iPad) ? 0 : 1
    static var dis_label_x: CGFloat = (device == .iPad) ? 20 : 15
    
    static var dis_title_sep: CGFloat = (device == .iPad) ? 10 : 15
    
    
    static let class_cell_id: String = "ClassTypeCell"
    static let region_cell_id: String = "RegionCell"
    static let About_cell_id: String = "AboutCell"
    static let encryption_cell_id: String = "EncryptionCell"
}

