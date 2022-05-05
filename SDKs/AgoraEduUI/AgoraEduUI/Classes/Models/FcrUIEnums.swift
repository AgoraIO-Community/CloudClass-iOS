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
    case video(AgoraStreamWindowCameraInfo)
    case screen(AgoraStreamWindowSharingInfo)
    
    static func == (lhs: Self,
                    rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (let .video(_), let .video(_)):   return true
        case (let .screen(_), let .screen(_)): return true
        default:                               return false
        }
    }
}
