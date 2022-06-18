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

extension AgoraEduContextVideoStreamConfig {
    static func small(isMirror: Bool = false) -> AgoraEduContextVideoStreamConfig {
        return AgoraEduContextVideoStreamConfig(dimensionWidth: 320,
                                                dimensionHeight: 240,
                                                frameRate: 15,
                                                bitRate: 200,
                                                isMirror: isMirror)
    }
    
    static func large(isMirror: Bool = false) -> AgoraEduContextVideoStreamConfig {
        return AgoraEduContextVideoStreamConfig(dimensionWidth: 640,
                                                dimensionHeight: 480,
                                                frameRate: 15,
                                                bitRate: 1000,
                                                isMirror: isMirror)
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
    
    var toWindowRenderData: FcrWindowRenderViewData {
        let videoState = createVideoViewState()
        let audioState = createAudioViewState()

        let data = FcrWindowRenderViewData(userId: owner.userUuid,
                                           userName: owner.userName,
                                           streamId: streamUuid,
                                           videoState: videoState,
                                           audioState: audioState)
        
        return data
    }
        
    private func createVideoViewState() -> FcrWindowRenderMediaViewState {
        let sourceOffImage = UIImage.agedu_named("ic_member_device_off")!
        
        var videoState = FcrWindowRenderMediaViewState.none(sourceOffImage)
        
        var videoMaskCode = 0
        
        if streamType.hasVideo {
            videoMaskCode += 1
        }
        
        if videoSourceState == .open {
            videoMaskCode += 2
        }
        
        switch videoMaskCode {
        // hasStreamPublishPrivilege
        case 1:
            videoState = FcrWindowRenderMediaViewState.hasStreamPublishPrivilege(sourceOffImage)
        // mediaSourceOpen
        case 2:
            let noPrivilegeImage = UIImage.agedu_named("ic_member_device_forbidden")!
            videoState = FcrWindowRenderMediaViewState.mediaSourceOpen(noPrivilegeImage)
        // both
        case 3:
            videoState = FcrWindowRenderMediaViewState.both(nil)
        default:
            break
        }
        
        return videoState
    }
    
    private func createAudioViewState() -> FcrWindowRenderMediaViewState {
        let sourceOffImage = UIImage.agedu_named("ic_mic_status_off")!
        
        var audioState = FcrWindowRenderMediaViewState.none(sourceOffImage)
        
        var audioMaskCode = 0
        
        if streamType.hasAudio {
            audioMaskCode += 1
        }
        
        if audioSourceState == .open {
            audioMaskCode += 2
        }
        
        switch audioMaskCode {
        // hasStreamPublishPrivilege
        case 1:
            audioState = FcrWindowRenderMediaViewState.hasStreamPublishPrivilege(sourceOffImage)
        // mediaSourceOpen
        case 2:
            let noPrivilegeImage = UIImage.agedu_named("ic_mic_status_forbidden")!
            audioState = FcrWindowRenderMediaViewState.mediaSourceOpen(noPrivilegeImage)
        // both
        case 3:
            let image = UIImage.agedu_named("ic_mic_status_on")!
            audioState = FcrWindowRenderMediaViewState.both(image)
        default:
            break
        }
        
        return audioState
    }
    
    var hasAudio: Bool {
        guard streamType.hasAudio else {
            return false
        }
        
        return (audioSourceType == .mic)
    }
}

extension AgoraEduWidgetContext {
    func streamWindowWidgetIsActive(of stream: AgoraEduContextStreamInfo) -> Bool {
        let list = getAllWidgetActivity()
        
        for (widgetId, activity) in list {
            guard widgetId.hasPrefix(WindowWidgetId) else {
                continue
            }
            
            guard widgetId.contains(stream.streamUuid) else {
                continue
            }
            
            return activity.boolValue
        }
        
        return false
    }
    
    func getActiveWidgetList(widgetId: String) -> [String]? {
        let list = getAllWidgetActivity()
        
        guard list.count > 0 else {
            return nil
        }
        
        var activeList = [String]()
        
        for (widget, activity) in list {
            guard widget.contains(widgetId) else {
                continue
            }
            
            guard activity.boolValue else {
                continue
            }
            
            activeList.append(widget)
        }
        
        if activeList.count > 0 {
            return activeList
        } else {
            return nil
        }
    }
}

extension AgoraEduStreamContext {
    func firstCameraStream(of user: AgoraEduContextUserInfo) -> AgoraEduContextStreamInfo? {
        guard let streamList = getStreamList(userUuid: user.userUuid) else {
            return nil
        }
        
        return streamList.first(where: {$0.videoSourceType == .camera})
    }
}
