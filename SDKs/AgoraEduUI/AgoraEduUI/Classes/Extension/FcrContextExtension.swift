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

// MARK: - AgoraRenderMemberViewModel
extension AgoraRenderMemberViewModel {
    static func model(user: AgoraEduContextUserInfo,
                      stream: AgoraEduContextStreamInfo?,
                      windowFlag: Bool = false) -> AgoraRenderMemberViewModel {
        var model = AgoraRenderMemberViewModel.defaultNilValue()
        /// user
        model.userId = user.userUuid
        model.userName = user.userName
        model.userState = windowFlag ? .window : .normal
        
        model.updateStream(stream: stream)
        
        return model
    }
    
    static func model(oldValue: AgoraRenderMemberViewModel,
                      stream: AgoraEduContextStreamInfo?,
                      windowFlag: Bool = false) -> AgoraRenderMemberViewModel {
        var model = AgoraRenderMemberViewModel.defaultNilValue()
        /// user
        model.userId = oldValue.userId
        model.userName = oldValue.userName
        model.userState = windowFlag ? .window : .normal
        
        model.updateStream(stream: stream)
        
        return model
    }
    
    private mutating func updateStream(stream: AgoraEduContextStreamInfo?) {
        /// stream
        guard let `stream` = stream else {
            self.streamId = nil
            self.audioState = .deviceOff
            self.videoState = .deviceOff
            return
        }
        
        self.streamId = stream.streamUuid
        // audio
        if stream.streamType.hasAudio,
           stream.audioSourceState == .open {
            self.audioState = .normal
        } else if stream.streamType.hasAudio,
                  stream.audioSourceState == .close {
            self.audioState = .deviceOff
        } else if stream.streamType.hasAudio == false,
                  stream.audioSourceState == .open {
            self.audioState = .streamForbidden
        } else {
            self.audioState = .deviceOff
        }
        // video
        if stream.streamType.hasVideo,
           stream.videoSourceState == .open {
            self.videoState = .normal
        } else if stream.streamType.hasVideo,
                  stream.videoSourceState == .close {
            self.videoState = .deviceOff
        } else if stream.streamType.hasVideo == false,
                  stream.videoSourceState == .open {
            self.videoState = .streamForbidden
        } else {
            self.videoState = .deviceOff
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
