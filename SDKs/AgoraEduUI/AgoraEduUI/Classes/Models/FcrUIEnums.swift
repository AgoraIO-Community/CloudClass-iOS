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
        case .none:   return UIConfig.studentVideo.mask.noUserImage
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
            let image = UIConfig.studentVideo.mask.boardAuthWindowImage!
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
        let config = UIConfig.toolBox
        switch self {
        case .cloudStorage:     return config.cloudStorageImage
        case .saveBoard:        return UIConfig.netlessBoard.save.image
        case .record:           return config.recordImage
        case .vote:             return config.voteImage
        case .countDown:        return config.countDownImage
        case .answerSheet:      return config.answerSheetImage
        default:                return nil
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
    case setting, roster, message, waveHands, handsList, help
    
    var selectedImage: UIImage? {
        let config = UIConfig.toolBar
        switch self {
        case .setting:          return config.setting.selectedImage
        case .roster:           return UIConfig.roster.selectedImage
        case .message:          return config.message.selectedImage
        case .handsList:        return config.handsList.selectedImage
        default:                return nil
        }
    }
    
    var unselectedImage: UIImage? {
        let config = UIConfig.toolBar
        switch self {
        case .setting:          return config.setting.normalImage
        case .roster:           return UIConfig.roster.normalImage
        case .message:          return config.message.normalImage
        case .waveHands:        return UIConfig.raiseHand.normalImage
        case .handsList:        return config.handsList.normalImage
        case .help:             return UIConfig.breakoutRoom.help.enabledImage
        default:                return nil
        }
    }
    
    var disabledImage: UIImage? {
        let config = UIConfig.toolBar
        switch self {
        case .help:             return UIConfig.breakoutRoom.help.disabledImage
        default:                return nil
        }
    }
    
    var isOnceKind: Bool {
        switch self {
        case .help:     return true
        default:        return false
        }
    }
}

// MARK: - ToolCollection
enum AgoraBoardToolPaintType: Int, CaseIterable {
    case pencil, line, rect, circle, pentagram, rhombus, arrow, triangle
    
    static var allCases: [AgoraBoardToolPaintType] = [.pencil, .line, .rect, .circle, .pentagram, .rhombus, .arrow, .triangle]
    
    var widgetShape: FcrBoardWidgetShapeType {
        switch self {
        case .pencil:       return .curve
        case .line:         return .straight
        case .rect:         return .rectangle
        case .circle:       return .ellipse
        case .pentagram:    return .pentagram
        case .rhombus:      return .rhombus
        case .arrow:        return .arrow
        case .triangle:     return .triangle
        }
    }
    
    var image: UIImage? {
        let config = UIConfig.netlessBoard
        switch self {
        case .pencil:       return config.pencil.image
        case .line:         return config.line.image
        case .rect:         return config.rect.image
        case .circle:       return config.circle.image
        case .pentagram:    return config.pentagram.image
        case .rhombus:      return config.rhombus.image
        case .arrow:        return config.arrow.image
        case .triangle:     return config.triangle.image
        }
    }
}

enum AgoraBoardToolMainType: Int, CaseIterable {
    case clicker, area, paint, text, rubber, clear, pre, next
    
    var unselectedImage: UIImage? {
        let config = UIConfig.netlessBoard
        switch self {
        case .clicker:  return config.mouse.unselectedImage
        case .area:     return config.selector.unselectedImage
        case .paint:    return config.paint.unselectedImage
        case .text:     return config.text.image
        case .rubber:   return config.eraser.unselectedImage
        case .clear:    return config.clear.enabledImage
        case .pre:      return config.prev.enabledImage
        case .next:     return config.next.enabledImage
        default:        return nil
        }
    }
    
    var selectedImage: UIImage? {
        let config = UIConfig.netlessBoard
        switch self {
        case .clicker:  return config.mouse.selectedImage
        case .area:     return config.selector.selectedImage
        case .paint:    return config.paint.selectedImage
        case .text:     return config.text.image
        case .rubber:   return config.eraser.selectedImage
        default:        return nil
        }
    }
    
    var disabledImage: UIImage? {
        let config = UIConfig.netlessBoard
        switch self {
        case .pre:      return config.prev.disabledImage
        case .next:     return config.next.disabledImage
        default:        return nil
        }
    }
    
    var widgetType: FcrBoardWidgetToolType? {
        switch self {
        case .clicker:  return .clicker
        case .area:     return .area
        case .rubber:   return .eraser
        default:
            return nil
        }
    }
    
    var needUpdateCell: Bool {
        switch self {
        case .clicker, .area, .paint, .text, .rubber:  return true
        case .clear, .pre ,.next:                      return false
        }
    }
}
