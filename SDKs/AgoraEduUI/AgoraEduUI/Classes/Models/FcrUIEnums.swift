//
//  FcrUIEnums.swift
//  AgoraClassroomSDK_iOS
//
//  Created by Cavan on 2022/4/26.
//

import AgoraUIBaseViews

// MARK: - Render
enum AgoraRenderUserRole {
    case teacher, student
}

enum AgoraRenderUserState {
    case normal, none, window
    
    var image: UIImage? {
        switch self {
        case .none:   return UIImage.agedu_named("ic_member_no_user")
        default:      return nil
        }
    }
}

enum AgoraRenderMediaState {
    case normal, deviceOff, streamForbidden
}

enum FcrWindowRenderMediaViewState {
    case none(UIImage)
    case hasStreamPublishPrivilege(UIImage)
    case mediaSourceOpen(UIImage)
    case both(UIImage?)
    
    var isBoth: Bool {
        switch self {
        case .both: return true
        default:    return false
        }
    }
    
    var intValue: Int {
        switch self {
        case .none:                      return 0
        case .hasStreamPublishPrivilege: return 1
        case .mediaSourceOpen:           return 2
        case .both:                      return 3
        }
    }
    
    static func ==(left: FcrWindowRenderMediaViewState,
                   right: FcrWindowRenderMediaViewState) -> Bool {
        return (left.intValue == right.intValue)
    }
    
    static func !=(left: FcrWindowRenderMediaViewState,
                   right: FcrWindowRenderMediaViewState) -> Bool {
        return (left.intValue != right.intValue)
    }
}

enum FcrBoardPrivilegeViewState {
    case none, has(UIImage)
    
    var intValue: Int {
        switch self {
        case .none: return 0
        case .has:  return 1
        }
    }
    
    static func create(_ privilege: Bool) -> FcrBoardPrivilegeViewState {
        if privilege {
            let image = UIImage.agedu_named("ic_board_privilege")!
            return .has(image)
        } else {
            return .none
        }
    }
    
    static func ==(left: FcrBoardPrivilegeViewState,
                   right: FcrBoardPrivilegeViewState) -> Bool {
        return (left.intValue == right.intValue)
    }
    
    static func !=(left: FcrBoardPrivilegeViewState,
                   right: FcrBoardPrivilegeViewState) -> Bool {
        return !(left == right)
    }
}

enum FcrWindowRenderViewState {
    case none, show(FcrWindowRenderViewData), hide(FcrWindowRenderViewData)
    
    var isNone: Bool {
        switch self {
        case .none: return true
        default:    return false
        }
    }
    
    var data: FcrWindowRenderViewData? {
        switch self {
        case .show(let data): return data
        case .hide(let data): return data
        default:              return nil
        }
    }
    
    var isShow: Bool {
        switch self {
        case .show: return true
        default:    return false
        }
    }
    
    var isHide: Bool {
        switch self {
        case .hide: return true
        default:    return false
        }
    }
    
    var intValue: Int {
        switch self {
        case .none: return 0
        case .show: return 1
        case .hide: return 2
        }
    }
    
    static func create(isHide: Bool,
                       data: FcrWindowRenderViewData) -> FcrWindowRenderViewState {
        if isHide {
            return .hide(data)
        } else {
            return .show(data)
        }
    }
    
    static func ==(left: FcrWindowRenderViewState,
                   right: FcrWindowRenderViewState) -> Bool {
        guard left.intValue == right.intValue else {
            return false
        }
        
        guard let leftData = left.data,
              let rightData = right.data else {
            return false
        }
        
        return (leftData == rightData)
    }
    
    static func !=(left: FcrWindowRenderViewState,
                   right: FcrWindowRenderViewState) -> Bool {
        return !(left == right)
    }
}

// MARK: - StreamWindow
enum AgoraStreamWindowType: Equatable {
    case video(cameraInfo: AgoraStreamWindowCameraInfo)
    case screen(sharingInfo: AgoraStreamWindowSharingInfo)
    
    static func == (lhs: Self,
                    rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (let .video(_), let .video(_)):   return true
        case (let .screen(_), let .screen(_)): return true
        default:                               return false
        }
    }
}

// MARK: - RenderMenu
enum AgoraRenderMenuItemType {
    case mic, camera, stage, allOffStage, auth, reward
}

// MARK: - ToolCollection
enum AgoraToolCollectionSelectType: Int {
    case none, main, sub
}

enum AgoraTeachingAidType {
    /** 云盘*/
    case cloudStorage
    /** 保存板书*/
    case saveBoard
    /** 录制*/
    case record
    /** 投票*/
    case vote
    /** 倒计时*/
    case countDown
    /** 答题器*/
    case answerSheet
    
    func cellImage() -> UIImage? {
        switch self {
        case .cloudStorage:     return UIImage.agedu_named("toolcollection_enabled_cloud")
        case .saveBoard:        return UIImage.agedu_named("toolcollection_enabled_save")
        case .record:           return UIImage.agedu_named("ic_toolbox_record")
        case .vote:             return UIImage.agedu_named("ic_toolbox_vote")
        case .countDown:        return UIImage.agedu_named("ic_toolbox_clock")
        case .answerSheet:      return UIImage.agedu_named("ic_toolbox_answer")
        default: return nil
        }
    }
    
    func cellText() -> String? {
        switch self {
        case .cloudStorage:     return "fcr_tool_box_cloud_storage".agedu_localized()
        case .saveBoard:        return "toolbox_save_borad".agedu_localized()
        case .record:           return "fcr_tool_box_record_class".agedu_localized()
        case .vote:             return "fcr_tool_box_poll".agedu_localized()
        case .countDown:        return "fcr_tool_box_count_down".agedu_localized()
        case .answerSheet:      return "fcr_tool_box_popup_quiz".agedu_localized()
        default:                return nil
        }
    }
}


// MARK: - UserList
enum AgoraUserListFunction: Int {
    case stage = 0, auth, camera, mic, reward, kick
    
    func title() -> String {
        switch self {
        case .stage:    return "fcr_user_list_stage".agedu_localized()
        case .auth:     return "fcr_user_list_auth".agedu_localized()
        case .camera:   return "fcr_user_list_video".agedu_localized()
        case .mic:      return "fcr_user_list_audio".agedu_localized()
        case .reward:   return "fcr_user_list_reward".agedu_localized()
        case .kick:     return "fcr_user_list_ban".agedu_localized()
        default:        return ""
        }
    }
}

// MARK: - ToolBar
enum FcrToolBarItemType {
    case setting, nameRoll, message, handsup, handsList, help
    
    var selectedImage: UIImage? {
        var imageName = ""
        switch self {
        case .setting:          imageName = "toolbar_selected_setting"
        case .nameRoll:         imageName = "toolbar_selected_name_roll"
        case .message:          imageName = "toolbar_selected_message"
        case .handsList:        imageName = "toolbar_selected_hands_list"
        default:                break
        }
        return UIImage.agedu_named(imageName)
    }
    
    var unselectedImage: UIImage? {
        var imageName = ""
        switch self {
        case .setting:          imageName = "toolbar_unselected_setting"
        case .nameRoll:         imageName = "toolbar_unselected_name_roll"
        case .message:          imageName = "toolbar_unselected_message"
        case .handsup:          imageName = "toolbar_unselected_wave_hands"
        case .handsList:        imageName = "toolbar_unselected_hands_list"
        case .help:             imageName = "toolbar_enabled_help"
        default:                break
        }
        return UIImage.agedu_named(imageName)
    }
    
    var disabledImage: UIImage? {
        var imageName = ""
        switch self {
        case .help:             imageName = "toolbar_disabled_help"
        default:                break
        }
        return UIImage.agedu_named(imageName)
    }
    
    var isOnceKind: Bool {
        switch self {
        case .help:     return true
        default:        return false
        }
    }
}
