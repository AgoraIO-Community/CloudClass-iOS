//
//  BaseLoginObject.swift
//  AgoraEducation
//
//  Created by LYY on 2021/4/19.
//  Copyright © 2021 Agora. All rights reserved.
//

import Foundation
import AgoraEduSDK

enum Device_type: String {
    case iPhone
    case iPad
}

enum FIELD_TYPE: String {
    case `default`
    case room
    case user
    case duration
    
    var moveDistance: CGFloat {
        switch self {
        case .room:
            return 0
        case .user:
            return LoginConfig.device == .iPad ? 50 : 0
        case .duration:
            return LoginConfig.device == .iPad ? 230 : 50
        default:
            return 0
        }
    }
}

enum Region_Type: String,CaseIterable {
    case CN
    case NA
    case EU
    case AP
    
    var regionStr: String {
        switch self {
        case .CN:
            return "cn-hz"
        case .NA:
            return "us-sv"
        case .EU:
            return "gb-lon"
        case .AP:
            return "sg"
        }
    }
    
    static func allTypes() -> Array<String> {
        var arr: Array<String> = []
        Region_Type.allCases.forEach{arr.append($0.rawValue)}
        return arr
    }
}

class LoginConfig {
    static let ClassTypes: Array<(AgoraEduRoomType,String)> = [(AgoraEduRoomType.type1V1, NSLocalizedString("Login_onetoone", comment: "")),
                                                               (AgoraEduRoomType.typeSmall, NSLocalizedString("Login_small", comment: "")),
                                                               (AgoraEduRoomType.typeLecture, NSLocalizedString("Login_lecture", comment: ""))]
    
    static let AboutInfoList: Array<(String,Any?)> =
        [(NSLocalizedString("About_privacy", comment: ""), URL(string: NSLocalizedString("Privacy_url", comment: ""))),
         (NSLocalizedString("About_disclaimer", comment: ""),  DisclaimerView(frame: .zero)),
         (NSLocalizedString("About_register", comment: ""), URL(string: NSLocalizedString("Signup_url", comment: ""))),
         (NSLocalizedString("About_version_time", comment: ""),  version_time),
         (NSLocalizedString("About_sdk_version", comment: ""),  sdk_version),
         (NSLocalizedString("About_class_version", comment: ""), class_version)]
    
    static let version_time: String = KeyCenter.publishDate()
    static let RegionList: Array<String> = Region_Type.allTypes()
    
    static let sdk_version: String = KeyCenter.rtcVersion()
    static let class_version: String = "Ver \(AgoraEduSDK.version())"
    
    static let device: Device_type = Device_type.init(rawValue: UIDevice.current.model) ?? .iPhone
    
    static let login_icon_y: CGFloat = (device == .iPhone) ? 115 : 88
    static let login_about_y: CGFloat = (device == .iPhone) ? 46 : 32
    static let login_first_group_y: CGFloat = (device == .iPhone) ? 225 : 270
    static let login_about_right: CGFloat = (device == .iPhone) ? 15 : 17
    static let login_choose_cell_height: CGFloat = 44
    static let login_class_types_width: CGFloat = 310
    static let login_class_types_y: CGFloat = (device == .iPhone) ? 382 : 430
    static let login_regions_types_y: CGFloat = (device == .iPhone) ? 445 : 491
    static let login_group_title_width : CGFloat = 58
    static let login_group_width : CGFloat = 280
    static let login_group_height : CGFloat = 40
    static let login_bottom_bottom : CGFloat = (device == .iPhone) ? 64 : 30
    
    static let about_enter_right: CGFloat = (device == .iPhone) ? 15 : 21
    static let about_title_height: CGFloat = (device == .iPhone) ? 89 : 44
    static let about_title_font: UIFont = (device == .iPhone) ? UIFont.systemFont(ofSize: 17) : UIFont.systemFont(ofSize: 16)
    static let about_title_sep: CGFloat = (device == .iPhone) ? 10 : 0
    static let about_cell_title_x: CGFloat = (device == .iPhone) ? 15 : 20
    static let about_cell_height: CGFloat = (device == .iPhone) ? 48 : 44
    static let about_cell_info_right: CGFloat = (device == .iPhone) ? 15 : 21
    static let about_bottom_line_x: CGFloat = (device == .iPhone) ? 10 : 20
    static let about_line_length: CGFloat = (device == .iPhone) ? UIScreen.main.bounds.width : 380
    static let about_label_font: UIFont = (device == .iPhone) ? UIFont.systemFont(ofSize: 16) : UIFont.systemFont(ofSize: 14)
    
    static let dis_title_height: CGFloat = (device == .iPhone) ? 89 : 44
    static let dis_line_x: CGFloat = (device == .iPhone) ? 0 : 10
    static let dis_back_x: CGFloat = (device == .iPhone) ? 15 : 10
    static let dis_back_bottom: CGFloat = (device == .iPhone) ? 1 : 0
    static let dis_label_width: CGFloat = (device == .iPhone) ? 345 : 380
    
    static let dis_title_sep: CGFloat = (device == .iPhone) ? 15 : 10
    
    
    static let class_cell_id: String = "ClassTypeCell"
    static let region_cell_id: String = "RegionCell"
    static let About_cell_id: String = "AboutCell"
    
    // Data
    static let USER_DEFAULT_EYE_CARE = "USER_DEFAULT_EYE_CARE"
    
}
