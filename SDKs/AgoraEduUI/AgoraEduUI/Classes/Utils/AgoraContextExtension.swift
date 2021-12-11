//
//  AgoraContextExtension.swift
//  AgoraEduUI
//
//  Created by Cavan on 2021/10/16.
//

import AgoraUIEduBaseViews
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
                      name: String,
                      role: AgoraEduContextUserRole) -> AgoraRenderMemberModel {
        var model = AgoraRenderMemberModel()
        model.uuid = uuid
        model.name = name
        model.role = role == .teacher ? .teacher : .student
        let stream = context.stream.getStreamList(userUuid: uuid)?.first
        model.updateStream(stream)
        context.user.getUserRewardCount(userUuid: uuid)
        return model
    }
    
    func updateStream(_ stream: AgoraEduContextStreamInfo?) {
        if let `stream` = stream {
            self.streamID = stream.streamUuid
            // audio
            if stream.streamType == .both ||
                stream.streamType == .audio {
                switch stream.audioSourceState {
                case .error:
                    self.audioState = .broken
                case .close:
                    self.audioState = .off
                case .open:
                    self.audioState = .on
                }
            } else {
                switch stream.audioSourceState {
                case .error:
                    self.audioState = .broken
                case .close:
                    self.audioState = .forbidden
                case .open:
                    self.audioState = .off
                }
            }
            // video
            if stream.streamType == .both ||
                stream.streamType == .video {
                switch stream.videoSourceState {
                case .error:
                    self.videoState = .broken
                case .close:
                    self.videoState = .off
                case .open:
                    self.videoState = .on
                }
            } else {
                switch stream.videoSourceState {
                case .error:
                    self.videoState = .broken
                case .close:
                    self.videoState = .forbidden
                case .open:
                    self.videoState = .off
                }
            }
        } else {
            self.streamID = nil
            self.audioState = .off
            self.videoState = .off
        }
    }
}
