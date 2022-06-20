//
//  FcrUIModels.swift
//  AgoraClassroomSDK_iOS
//
//  Created by Cavan on 2022/4/26.
//

import AgoraUIBaseViews
import AgoraEduContext
import AgoraWidget

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
        var imageName = ""
        switch videoState {
            case .deviceOff:        imageName = "ic_member_device_off"
            case .streamForbidden:  imageName = "ic_member_device_forbidden"
            default:                break
        }
        return UIImage.agedu_named(imageName)
    }
    
    func audioImage() -> UIImage? {
        var imageName = ""
        switch audioState {
        case .normal:           imageName = "ic_mic_status_on"
        case .deviceOff:        imageName = "ic_mic_status_off"
        case .streamForbidden:  imageName = "ic_mic_status_forbidden"
        }
        return UIImage.agedu_named(imageName)
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

struct FcrWebViewWidgetItem {
    var widgetId: String
    var object: AgoraBaseWidget
    var zIndex: Int
}

// MARK: - HandsList
struct AgoraHandsUpListUserInfo {
    var userUuid: String
    var userName: String
    var isCoHost: Bool
}

// MARK: - RenderMenu
struct AgoraRenderMenuModel {
    enum AgoraRenderMenuDeviceState {
        case on, off, forbidden
        
        var micImage: UIImage? {
            switch self {
            case .on:
                return UIImage.agedu_named("ic_nameroll_mic_on")
            case .off:
                return UIImage.agedu_named("ic_nameroll_mic_off")
            case .forbidden:
                return UIImage.agedu_named("ic_member_menu_mic_forbidden")
            default:
                return nil
            }
        }
        
        var cameraImage: UIImage? {
            switch self {
            case .on:
                return UIImage.agedu_named("ic_nameroll_camera_on")
            case .off:
                return UIImage.agedu_named("ic_nameroll_camera_off")
            case .forbidden:
                return UIImage.agedu_named("ic_member_menu_camera_forbidden")
            default:
                return nil
            }
        }
    }

    // Data
    var micState = AgoraRenderMenuDeviceState.off
    var cameraState = AgoraRenderMenuDeviceState.off
    var authState = false
}

// MARK: - UserList
class AgoraUserListModel {
    
    enum AgoraUserListDeviceState {
        case on, off, forbidden
    }
    
    var uuid: String = ""
    
    var streamId: String?
    
    var name: String = "" {
        didSet {
            self.sortRank = getFirstLetterRankFromString(aString: name)
        }
    }
    
    var stageState: (isOn: Bool, isEnable: Bool) = (false, false)
    
    var authState: (isOn: Bool, isEnable: Bool) = (false, false)
    
    var cameraState: (streamOn: Bool, deviceOn: Bool, isEnable: Bool) = (false, false, false)
    
    var micState: (streamOn: Bool, deviceOn: Bool, isEnable: Bool) = (false, false, false)
    
    var rewards: Int = 0
    
    var rewardEnable: Bool = false
    
    var kickEnable: Bool = false
    
    /** 用作排序的首字母权重*/
    var sortRank: UInt32 = 0
    
    init(contextUser: AgoraEduContextUserInfo) {
        self.name = contextUser.userName
        self.uuid = contextUser.userUuid
    }
    
    func getFirstLetterRankFromString(aString: String) -> UInt32 {
        let string = aString.trimmingCharacters(in: .whitespaces)
        let c = string.substring(to: string.index(string.startIndex, offsetBy:1))
        let regexNum = "^[0-9]$"
        let predNum = NSPredicate.init(format: "SELF MATCHES %@", regexNum)
        let regexChar = "^[a-zA-Z]$"
        let predChar = NSPredicate.init(format: "SELF MATCHES %@", regexChar)
        if predNum.evaluate(with: c) {
            let n = string.substring(to: string.index(string.startIndex, offsetBy:1))
            let value = n.unicodeScalars.first?.value ?? 150
            return value + 400
        } else if predChar.evaluate(with: c) {
            return (c.unicodeScalars.first?.value ?? 0) + 300
        } else {
            let mutableString = NSMutableString.init(string: string)
            CFStringTransform(mutableString as CFMutableString, nil, kCFStringTransformToLatin, false)
            let pinyinString = mutableString.folding(options: String.CompareOptions.diacriticInsensitive, locale: NSLocale.current)
            let strPinYin = polyphoneStringHandle(nameString: string, pinyinString: pinyinString).lowercased()
            let firstString = strPinYin.substring(to: strPinYin.index(strPinYin.startIndex, offsetBy:1))
            let value = firstString.unicodeScalars.first?.value ?? 150
            return value + 100
        }
    }
    /// 多音字处理
    func polyphoneStringHandle(nameString:String, pinyinString:String) -> String {
        if nameString.hasPrefix("长") {return "chang"}
        if nameString.hasPrefix("沈") {return "shen"}
        if nameString.hasPrefix("厦") {return "xia"}
        if nameString.hasPrefix("地") {return "di"}
        if nameString.hasPrefix("重") {return "chong"}
        return pinyinString;
    }
    
    func updateWithStream(_ stream: AgoraEduContextStreamInfo?) {
        if let `stream` = stream {
            self.streamId = stream.streamUuid
            // audio
            self.micState.streamOn = stream.streamType.hasAudio
            self.micState.deviceOn = (stream.audioSourceState == .open)
            // video
            self.cameraState.streamOn = stream.streamType.hasVideo
            self.cameraState.deviceOn = (stream.videoSourceState == .open)
            
        } else {
            self.micState.streamOn = false
            self.micState.deviceOn = false
            self.cameraState.streamOn = false
            self.cameraState.deviceOn = false
        }
    }
}

struct AgoraUserListFuncState {
    var enable: Bool
    var isOn: Bool
}

struct FcrRewardViewData {
    var count: String
    var image: UIImage
    var isHidden: Bool
    
    static func create(count: Int,
                       isHidden: Bool) -> FcrRewardViewData {
        let rewardImage = UIImage.agedu_named("ic_member_reward")!
        let countString = "x\(count)"
        
        let data = FcrRewardViewData(count: countString,
                                     image: rewardImage,
                                     isHidden: isHidden)
        
        return data
    }
    
    static func ==(left: FcrRewardViewData,
                   right: FcrRewardViewData) -> Bool {
        if left.count != right.count {
            return false
        }
        
        return true
    }
    
    static func !=(left: FcrRewardViewData,
                  right: FcrRewardViewData) -> Bool {
        return !(left == right)
    }
}

struct FcrWindowRenderViewData {
    var userId: String
    var userName: String
    var streamId: String
    var videoState: FcrWindowRenderMediaViewState
    var audioState: FcrWindowRenderMediaViewState
    var reward: FcrRewardViewData
    var boardPrivilege: FcrBoardPrivilegeViewState
    
    static func ==(left: FcrWindowRenderViewData,
                   right: FcrWindowRenderViewData) -> Bool {
        if left.userId != right.userId {
            return false
        }
        
        if left.userName != right.userName {
            return false
        }
        
        if left.streamId != right.streamId {
            return false
        }
        
        if left.videoState != right.videoState {
            return false
        }
        
        if left.audioState != right.audioState {
            return false
        }
        
        if left.reward != right.reward {
            return false
        }
        
        if left.boardPrivilege != right.boardPrivilege {
            return false
        }
        
        return true
    }
    
    static func !=(left: FcrWindowRenderViewData,
                  right: FcrWindowRenderViewData) -> Bool {
        return !(left == right)
    }
    
    static func create(stream: AgoraEduContextStreamInfo,
                       rewardCount: Int,
                       boardPrivilege: Bool) -> FcrWindowRenderViewData {
        let videoState = createVideoViewState(stream: stream)
        let audioState = createAudioViewState(stream: stream)
        
        let rewardIsHidden = (stream.owner.userRole == .teacher)
        
        let reward = FcrRewardViewData.create(count: rewardCount,
                                              isHidden: rewardIsHidden)

        let privilege = FcrBoardPrivilegeViewState.create(boardPrivilege)
        
        let data = FcrWindowRenderViewData(userId: stream.owner.userUuid,
                                           userName: stream.owner.userName,
                                           streamId: stream.streamUuid,
                                           videoState: videoState,
                                           audioState: audioState,
                                           reward: reward,
                                           boardPrivilege: privilege)
        
        return data
    }
        
    private static func createVideoViewState(stream: AgoraEduContextStreamInfo) -> FcrWindowRenderMediaViewState {
        let sourceOffImage = UIImage.agedu_named("ic_member_device_off")!
        
        var videoState = FcrWindowRenderMediaViewState.none(sourceOffImage)
        
        var videoMaskCode = 0
        
        if stream.streamType.hasVideo {
            videoMaskCode += 1
        }
        
        if stream.videoSourceState == .open {
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
    
    private static func createAudioViewState(stream: AgoraEduContextStreamInfo) -> FcrWindowRenderMediaViewState {
        let sourceOffImage = UIImage.agedu_named("ic_mic_status_off")!
        
        var audioState = FcrWindowRenderMediaViewState.none(sourceOffImage)
        
        var audioMaskCode = 0
        
        if stream.streamType.hasAudio {
            audioMaskCode += 1
        }
        
        if stream.audioSourceState == .open {
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
}
