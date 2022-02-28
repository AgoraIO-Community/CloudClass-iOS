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

extension AgoraRenderMemberModel {
    static func model(with context: AgoraEduContextPool,
                      uuid: String,
                      name: String) -> AgoraRenderMemberModel {
        var model = AgoraRenderMemberModel()
        model.uuid = uuid
        model.name = name
        let reward = context.user.getUserRewardCount(userUuid: uuid)
        model.rewardCount = reward
        let stream = context.stream.getStreamList(userUuid: uuid)?.first
        model.updateStream(stream)
        return model
    }
    
    func updateStream(_ stream: AgoraEduContextStreamInfo?) {
        if let `stream` = stream {
            self.streamID = stream.streamUuid
            // audio
            if stream.streamType.hasAudio,
               stream.audioSourceState == .open {
                self.audioState = .on
            } else if stream.streamType.hasAudio,
                      stream.audioSourceState == .close {
                self.audioState = .off
            } else if stream.streamType.hasAudio == false,
                      stream.audioSourceState == .open {
                self.audioState = .forbidden
            } else {
                self.audioState = .off
            }
            // video
            if stream.streamType.hasVideo,
               stream.videoSourceState == .open {
                self.videoState = .on
            } else if stream.streamType.hasVideo,
                      stream.videoSourceState == .close {
                self.videoState = .off
            } else if stream.streamType.hasVideo == false,
                      stream.videoSourceState == .open {
                self.videoState = .forbidden
            } else {
                self.videoState = .off
            }
        } else {
            self.streamID = nil
            self.audioState = .off
            self.videoState = .off
        }
    }
}
