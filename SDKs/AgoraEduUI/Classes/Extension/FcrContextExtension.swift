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
    
    var stringValue: String? {
        var stringValue = ""
        switch self {
        case .teacher:  stringValue = "fcr_role_teacher".agedu_localized()
        case .student:  stringValue = "fcr_role_student".agedu_localized()
        default:        return nil
        }
        guard !UIDevice.current.agora_is_chinese_language else {
            return stringValue
        }
        
        return "\(stringValue) "
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
