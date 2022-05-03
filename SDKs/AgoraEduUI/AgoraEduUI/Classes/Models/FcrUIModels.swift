//
//  FcrUIModels.swift
//  AgoraClassroomSDK_iOS
//
//  Created by Cavan on 2022/4/26.
//

import AgoraUIBaseViews
import AgoraEduContext

// MARK: - Render
struct AgoraRenderMemberViewModel {
    var userId: String
    var userName: String
    var streamId: String?
    var userState: AgoraRenderUserState
    var videoState: AgoraRenderMediaState
    var audioState: AgoraRenderMediaState
    
    private var curWindow: Bool = false
    
    static func defaultNilValue(curWindow: Bool = false) -> AgoraRenderMemberViewModel {
        return AgoraRenderMemberViewModel(userId: "",
                                          userName: "",
                                          streamId: nil,
                                          userState: .none,
                                          videoState: .deviceOff,
                                          audioState: .deviceOff,
                                          curWindow: curWindow)
    }
    
    static func model(user: AgoraEduContextUserInfo,
                      stream: AgoraEduContextStreamInfo?,
                      windowFlag: Bool = false,
                      curWindow: Bool = false) -> AgoraRenderMemberViewModel {
        var model = AgoraRenderMemberViewModel.defaultNilValue()
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
                      windowFlag: Bool = false,
                      curWindow: Bool = false) -> AgoraRenderMemberViewModel {
        var model = AgoraRenderMemberViewModel.defaultNilValue()
        /// user
        model.userId = oldValue.userId
        model.userName = oldValue.userName
        model.userState = windowFlag ? .window : .normal
        model.curWindow = curWindow
        
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

    func videoImage() -> UIImage? {
        if let image = userState.image {
            return image
        } else {
            var imageName = ""
            switch videoState {
            case .deviceOff:        imageName = "ic_member_device_off"
            case .streamForbidden:  imageName = "ic_member_device_forbidden"
            default:                break
            }
            return UIImage.agedu_named(imageName)
        }
    }
    
    func audioImage() -> UIImage? {
        guard userState == .normal else {
            return nil
        }
        var imageName = ""
        switch audioState {
        case .normal:           imageName = "ic_mic_status_on"
        case .deviceOff:        imageName = "ic_mic_status_off"
        case .streamForbidden:  imageName = "ic_mic_status_forbidden"
        }
        return UIImage.agedu_named(imageName)
    }
    
    func setRenderMemberView(view: AgoraRenderMemberView) {
        // TODO: 判断hide，更新文档
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
        view.videoMaskView.image = self.videoImage()
        
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
