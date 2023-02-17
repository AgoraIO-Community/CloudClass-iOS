//
//  FcrUIModels.swift
//  AgoraEduUI
//
//  Created by Cavan on 2022/4/26.
//

import AgoraUIBaseViews
import AgoraEduCore
import AgoraWidget

// MARK: - Stream window
struct FcrRewardViewData {
    var count: String
    var image: UIImage
    var isHidden: Bool
    
    static func create(count: Int,
                       isHidden: Bool) -> FcrRewardViewData {
        let rewardImage = UIConfig.studentVideo.mask.rewardImage!
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

struct FcrStreamWindowViewData {
    var userId: String
    var userName: String
    var streamId: String
    var videoState: FcrStreamWindowMediaViewState
    var audioState: FcrStreamWindowMediaViewState
    var reward: FcrRewardViewData
    var boardPrivilege: FcrBoardPrivilegeViewState
    
    static func ==(left: FcrStreamWindowViewData,
                   right: FcrStreamWindowViewData) -> Bool {
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
    
    static func !=(left: FcrStreamWindowViewData,
                   right: FcrStreamWindowViewData) -> Bool {
        return !(left == right)
    }
    
    static func create(stream: AgoraEduContextStreamInfo,
                       rewardCount: Int,
                       boardPrivilege: Bool) -> FcrStreamWindowViewData {
        let videoState = createVideoViewState(stream: stream)
        let audioState = createAudioViewState(stream: stream)
        
        let rewardIsHidden = (stream.owner.userRole == .teacher)
        
        let reward = FcrRewardViewData.create(count: rewardCount,
                                              isHidden: rewardIsHidden)
        
        let privilege = FcrBoardPrivilegeViewState.create(boardPrivilege)
        
        let data = FcrStreamWindowViewData(userId: stream.owner.userUuid,
                                           userName: stream.owner.userName,
                                           streamId: stream.streamUuid,
                                           videoState: videoState,
                                           audioState: audioState,
                                           reward: reward,
                                           boardPrivilege: privilege)
        
        return data
    }
    
    private static func createVideoViewState(stream: AgoraEduContextStreamInfo) -> FcrStreamWindowMediaViewState {
        let maskConfig = UIConfig.studentVideo.mask
        let sourceOffImage = maskConfig.cameraOffImage!
        
        var videoState = FcrStreamWindowMediaViewState.none(sourceOffImage)
        
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
            videoState = FcrStreamWindowMediaViewState.hasStreamPublishPrivilege(sourceOffImage)
            // mediaSourceOpen
        case 2:
            let noPrivilegeImage = maskConfig.cameraForbiddenImage!
            videoState = FcrStreamWindowMediaViewState.mediaSourceOpen(noPrivilegeImage)
            // both
        case 3:
            videoState = FcrStreamWindowMediaViewState.both(nil)
        default:
            break
        }
        
        return videoState
    }
    
    private static func createAudioViewState(stream: AgoraEduContextStreamInfo) -> FcrStreamWindowMediaViewState {
        let config = UIConfig.studentVideo.mask
        let sourceOffImage = config.micOffImage!
        
        var audioState = FcrStreamWindowMediaViewState.none(sourceOffImage)
        
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
            audioState = FcrStreamWindowMediaViewState.hasStreamPublishPrivilege(sourceOffImage)
            // mediaSourceOpen
        case 2:
            let noPrivilegeImage = config.micForbiddenImage!
            audioState = FcrStreamWindowMediaViewState.mediaSourceOpen(noPrivilegeImage)
            // both
        case 3:
            let image = config.micOnImage!
            audioState = FcrStreamWindowMediaViewState.both(image)
        default:
            break
        }
        
        return audioState
    }
}

struct FcrDetachedStreamWindowWidgetItem {
    enum ItemType: Int {
        case screen, camera
    }
    
    var widgetObjectId: String
    var type: ItemType
    var data: FcrStreamWindowViewData
    var zIndex: Int
    
    static func ==(left: FcrDetachedStreamWindowWidgetItem,
                   right: FcrDetachedStreamWindowWidgetItem) -> Bool {
        if left.type.rawValue != right.type.rawValue {
            return false
        }
        
        if left.data != right.data {
            return false
        }
        
        if left.zIndex != right.zIndex {
            return false
        }
        
        return true
    }
    
    static func !=(left: FcrDetachedStreamWindowWidgetItem,
                   right: FcrDetachedStreamWindowWidgetItem) -> Bool {
        return !(left == right)
    }
    
    static func create(widgetObjectId: String,
                       stream: AgoraEduContextStreamInfo,
                       rewardCount: Int,
                       boardPrivilege: Bool,
                       zIndex: Int) -> FcrDetachedStreamWindowWidgetItem {
        let data = FcrStreamWindowViewData.create(stream: stream,
                                                  rewardCount: rewardCount,
                                                  boardPrivilege: boardPrivilege)
        
        let type: ItemType = ((stream.videoSourceType == .camera) ? .camera : .screen)
        
        let item = FcrDetachedStreamWindowWidgetItem(widgetObjectId: widgetObjectId,
                                                     type: type,
                                                     data: data,
                                                     zIndex: zIndex)
        return item
    }
}

// MARK: - WebView
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
    }
    
    // Data
    var micState = AgoraRenderMenuDeviceState.off
    var cameraState = AgoraRenderMenuDeviceState.off
    var authState = false
}

// MARK: - UserList
class AgoraRosterModel {
    
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
}

struct AgoraUserListFuncState {
    var enable: Bool
    var isOn: Bool
}
