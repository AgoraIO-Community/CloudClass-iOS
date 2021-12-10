//
//  AgoraRenderSpreadVM.swift
//  AgoraWidgets
//
//  Created by LYY on 2021/10/11.
//

import AgoraEduContext

struct AgoraSpreadRenderUserInfo {
    // userInfo
    var userId: String
    var userName: String
    var streamId: String
    var role: AgoraSpreadUserRole
    var isOnline: Bool = true
    
    // streamInfo
    var cameraState: AgoraSpreadDeviceState = .available
    var microState: AgoraSpreadDeviceState = .available
    var enableVideo: Bool = true
    var enableAudio: Bool = true
}

struct AgoraSpreadRenderViewInfo {
    var userName = ""
    var isOnline = true
    var cameraState: AgoraSpreadDeviceState = .available
    var microState: AgoraSpreadDeviceState = .available
    var hasVideo = true
    var hasAudio = true
}

extension AgoraSpreadRenderUserInfo {
    func toViewInfo() -> AgoraSpreadRenderViewInfo {
        return AgoraSpreadRenderViewInfo(userName: self.userName,
                                         isOnline: self.isOnline,
                                         cameraState: self.cameraState,
                                         microState: self.microState,
                                         hasVideo: self.enableVideo,
                                         hasAudio: self.enableAudio)
        
    }
}

// MARK: - model
struct AgoraSpreadRoomMessageModel: Decodable {
    var position: AgoraSpreadPositionModel
    var size: AgoraSpreadSizeModel
    var extra: AgoraSpreadExtraModel
}

struct AgoraSpreadPositionModel: Decodable {
    var xaxis: Double
    var yaxis: Double
}

struct AgoraSpreadSizeModel: Decodable {
    var width: Double
    var height: Double
}

struct AgoraSpreadExtraModel: Decodable {
    var initial: Bool
    var userId: String
    var streamId: String
    var operatorId: String
}

struct AgoraSpreadVCMessageModel: Decodable {
    var action: AgoraSpreadAction
    var userId: String
    var streamId: String
}

// MARK: - enum
enum AgoraSpreadDeviceState {
    case available, invalid, close
}

enum AgoraSpreadUserRole {
    case invalid, teacher, student
}

enum AgoraSpreadAction: Int,Decodable {
    case start = 0, move, change, close
}

extension AgoraEduContextVideoSourceType {
    func toSpread() -> AgoraSpreadDeviceState {
        switch self {
        case .none:   return .close
        case .camera: return .available
        case .screen: return .available
        default:      return .invalid
        }
    }
}

extension AgoraEduContextAudioSourceType {
    func toSpread() -> AgoraSpreadDeviceState {
        switch self {
        case .none: return .close
        case .mic:  return .available
        default:    return .invalid
        }
    }
}

extension AgoraEduContextUserRole {
    func toSpread() -> AgoraSpreadUserRole {
        switch self {
        case .teacher: return .teacher
        case .student: return .student
        default:       return .invalid
        }
    }
}
