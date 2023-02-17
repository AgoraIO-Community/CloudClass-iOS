//
//  VocationalUIModels.swift
//  AgoraEduUI
//
//  Created by Cavan on 2023/1/13.
//

import AgoraEduCore
import AgoraWidget
import Foundation

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

enum AgoraRenderMediaState {
    case normal, deviceOff, streamForbidden
}

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

// MARK: - Render
struct AgoraRenderMemberViewModel {
    var userId: String
    var userName: String
    var userRole: AgoraRenderUserRole
    var streamId: String?
    var cdnURL: String?
    var userState: AgoraRenderUserState
    var videoState: AgoraRenderMediaState
    var audioState: AgoraRenderMediaState
    
    private var curWindow: Bool = false
    
    static func defaultNilValue(role: AgoraRenderUserRole) -> AgoraRenderMemberViewModel {
        return AgoraRenderMemberViewModel(userId: "",
                                          userName: "",
                                          userRole: role,
                                          streamId: nil,
                                          userState: .none,
                                          videoState: .deviceOff,
                                          audioState: .deviceOff,
                                          curWindow: false)
    }
    
    static func model(user: AgoraEduContextUserInfo,
                      stream: AgoraEduContextStreamInfo?,
                      windowFlag: Bool = false,
                      curWindow: Bool = false) -> AgoraRenderMemberViewModel {
        var model = AgoraRenderMemberViewModel.defaultNilValue(role: user.userRole.toRender)
        /// user
        model.userId = user.userUuid
        model.userName = user.userName
        model.userState = windowFlag ? .window : .normal
        model.curWindow = curWindow
        
        model.updateStream(stream: stream)
        
        return model
    }
    
    static func model(oldValue: AgoraRenderMemberViewModel,
                      stream: AgoraEduContextStreamInfo?,
                      windowFlag: Bool = false) -> AgoraRenderMemberViewModel {
        var model = AgoraRenderMemberViewModel.defaultNilValue(role: oldValue.userRole)
        /// user
        model.userId = oldValue.userId
        model.userName = oldValue.userName
        model.userState = windowFlag ? .window : .normal
        model.curWindow = oldValue.curWindow
        
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
        // 优先使用RTMP
        if let cdnURL = stream.streamRtmpUrl {
            self.cdnURL = cdnURL
        } else if let cdnURL = stream.streamHlsUrl {
            self.cdnURL = cdnURL
        } else if let cdnURL = stream.streamFlvUrl {
            self.cdnURL = cdnURL
        }
        
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

    func videoImage() -> UIImage? {
        switch userState {
        case .normal:
            guard !curWindow else {
                return userState.image
            }
        case .none:
            return userState.image
        case .window:
            guard curWindow else {
                return userState.image
            }
        }
        
        let config = UIConfig.studentVideo.mask
        switch videoState {
            case .deviceOff:       return config.cameraOffImage
            case .streamForbidden: return config.cameraForbiddenImage
            default:               return nil
        }
    }
    
    func audioImage() -> UIImage? {
        let config = UIConfig.studentVideo.mask
        switch audioState {
        case .normal:           return config.micOnImage
        case .deviceOff:        return config.micOffImage
        case .streamForbidden:  return config.micForbiddenImage
        }
    }
    
    func setRenderMemberView(view: AgoraRenderMemberView) {
        // user
        var hideNameAudioFlag = true
        if (curWindow && userState == .window) ||
            (!curWindow && userState == .normal) {
            hideNameAudioFlag = false
        }
        view.nameLabel.isHidden = hideNameAudioFlag
        view.nameLabel.text = self.userName
        // video
        view.videoView.isHidden = (hideNameAudioFlag || videoState != .normal)
        view.videoMaskView.isHidden = (!curWindow && userState == .window)
        view.videoMaskView.imageView.image = self.videoImage()
        
        // audio
        view.micView.isHidden = hideNameAudioFlag
        view.micView.imageView.image = self.audioImage()
        view.micView.animaView.isHidden = (self.audioState != .normal)
    }
}


// MARK: - StreamWindow
struct AgoraStreamWindowCameraInfo {
    var renderModel: AgoraRenderMemberViewModel
    var renderView: AgoraRenderMemberView
}

struct AgoraStreamWindowSharingInfo {
    var userUuid: String
    var streamUuid: String
}

struct FcrWindowWidgetItem {
    var widgetObjectId: String
    var owner: String
    var streamId: String
    var videoSourceType: AgoraEduContextVideoSourceType
    var object: AgoraBaseWidget
    var zIndex: Int
}
