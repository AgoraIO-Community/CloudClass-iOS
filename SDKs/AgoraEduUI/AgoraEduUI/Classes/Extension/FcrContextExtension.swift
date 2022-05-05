//
//  AgoraContextExtension.swift
//  AgoraEduUI
//
//  Created by Cavan on 2021/10/16.
//

import AgoraEduContext

let kFrontCameraStr = "front"
let kBackCameraStr = "back"
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

extension AgoraEduContextUserRole {
    var toRender: AgoraRenderUserRole {
        switch self {
        case .teacher:  return .teacher
        case .student:  return .student
        default:        return .student
        }
    }
}

extension AgoraEduContextMediaStreamType {
    var hasAudio: Bool {
        switch self {
        case .none:          return false
        case .audio:         return true
        case .video:         return false
        case .both:          return true
        @unknown default:    return false
        }
    }
    
    var hasVideo: Bool {
        switch self {
        case .none:          return false
        case .audio:         return false
        case .video:         return true
        case .both:          return true
        @unknown default:    return false
        }
    }
}

extension AgoraEduContextStreamInfo {
    func toEmptyStream() -> AgoraEduContextStreamInfo {
        let videoSourceType: AgoraEduContextVideoSourceType = (self.videoSourceType == .screen) ? .screen : .none
        let emptyStream = AgoraEduContextStreamInfo(streamUuid: self.streamUuid,
                                                    streamName: self.streamName,
                                                    streamType: .none,
                                                    videoSourceType: videoSourceType,
                                                    audioSourceType: .none,
                                                    videoSourceState: .error,
                                                    audioSourceState: .error,
                                                    owner: self.owner)
        return emptyStream
    }
}
