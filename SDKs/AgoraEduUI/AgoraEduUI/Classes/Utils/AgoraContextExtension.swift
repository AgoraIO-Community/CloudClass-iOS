//
//  AgoraContextExtension.swift
//  AgoraEduUI
//
//  Created by Cavan on 2021/10/16.
//

import AgoraUIEduBaseViews
import AgoraEduContext

extension AgoraEduContextUserInfo {
    static func ==(left: AgoraEduContextUserInfo,
                   right: AgoraEduContextUserInfo) -> Bool {
        return left.userUuid == right.userUuid
    }
    
    static func !=(left: AgoraEduContextUserInfo,
                   right: AgoraEduContextUserInfo) -> Bool {
        return left.userUuid != right.userUuid
    }
}

extension AgoraEduContextVideoSourceType {
    var uiType: AgoraUIUserView.DeviceState {
        switch self {
        case .invalid:      return .invalid
        case .none:         return .close
        case .camera:       return .available
        case .screen:       return .available
        }
    }
    
    var isOpen: Bool {
        switch self {
        case .invalid:      return false
        case .none:         return false
        case .camera:       return true
        case .screen:       return true
        }
    }
}

extension AgoraEduContextAudioSourceType {
    var uiType: AgoraUIUserView.DeviceState {
        switch self {
        case .invalid:      return .invalid
        case .none:         return .close
        case .mic:          return .available
        }
    }
    
    var isOpen: Bool {
        switch self {
        case .invalid:      return false
        case .none:         return false
        case .mic:          return true
        }
    }
}

extension AgoraEduContextMediaStreamType {
    var hasAudio: Bool {
        switch self {
        case .none:          return false
        case .audio:         return true
        case .video:         return false
        case .audioAndVideo: return true
        @unknown default:    return false
        }
    }
    
    var hasVideo: Bool {
        switch self {
        case .none:          return false
        case .audio:         return false
        case .video:         return true
        case .audioAndVideo: return true
        @unknown default:    return false
        }
    }
}
