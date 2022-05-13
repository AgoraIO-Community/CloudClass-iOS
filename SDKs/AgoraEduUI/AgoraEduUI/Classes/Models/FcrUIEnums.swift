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

// MARK: - StreamWindow
enum AgoraStreamWindowType: Equatable {
    case video(cameraInfo: AgoraStreamWindowCameraInfo)
    case screen(sharingInfo:AgoraStreamWindowSharingInfo)
    
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
