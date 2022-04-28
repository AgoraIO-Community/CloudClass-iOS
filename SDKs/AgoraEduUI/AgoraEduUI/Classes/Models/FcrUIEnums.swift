//
//  FcrUIEnums.swift
//  AgoraClassroomSDK_iOS
//
//  Created by Cavan on 2022/4/26.
//

import AgoraUIBaseViews

enum AgoraRenderUserState {
    case normal, none, window
    
    var image: UIImage? {
        switch self {
        case .normal: return nil
        case .none:   return UIImage.agedu_named("ic_member_no_user")
        case .window: return UIImage.agedu_named("ic_member_empty")
        }
    }
}

enum AgoraRenderMediaState {
    case normal, deviceOff, streamForbidden
    
    enum AgoraRenderMediaType {
        case video, audio
    }
    
    func image(_ type: AgoraRenderMediaType) -> UIImage? {
        var imageName = ""
        switch type {
        case .video:
            switch self {
            case .deviceOff:        imageName = "ic_member_device_off"
            case .streamForbidden:  imageName = "ic_member_device_forbidden"
            default:                break
            }
        case .audio:
            switch self {
            case .normal:           imageName = "ic_mic_status_on"
            case .deviceOff:        imageName = "ic_mic_status_off"
            case .streamForbidden:  imageName = "ic_mic_status_forbidden"
            }
        }
        return UIImage.agedu_named(imageName)
    }
}
