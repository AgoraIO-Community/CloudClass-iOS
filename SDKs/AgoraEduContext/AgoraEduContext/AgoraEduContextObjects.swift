//
//  AgoraEduContextObjects.swift
//  AgoraUIEduBaseViews
//
//  Created by SRS on 2021/3/7.
//

import Foundation

// MARK: - Classroom
@objcMembers public class AgoraEduContextRoomInfo: NSObject {
    // 房间Id
    public var roomUuid: String
    // 房间名字
    public var roomName: String
    
    public var roomType: AgoraEduContextRoomType
    
    public init(roomUuid: String,
                roomName: String,
                roomType: AgoraEduContextRoomType) {
        self.roomUuid = roomUuid
        self.roomName = roomName
        self.roomType = roomType
    }
}

// MARK: - User
@objcMembers public class AgoraEduContextUserInfo: NSObject {
    // 用户id
    public var userUuid: String
    // 用户名字
    public var userName: String
    // 用户角色
    public var role: AgoraEduContextUserRole
    
    public init(userUuid: String,
                userName: String,
                role: AgoraEduContextUserRole = .student) {
        self.userUuid = userUuid
        self.userName = userName
        self.role = role
    }
}

@objcMembers public class AgoraEduContextUserDetailInfo: AgoraEduContextUserInfo {
    // 是不是自己
    public var isLocal: Bool = false
    // 是否在线
    public var isOnLine: Bool = false
    // 是否在台上
    public var isCoHost: Bool = false
    // 是否有白板权限
    public var boardGranted: Bool = false
    // 是否可以聊天
    public var enableChat: Bool = true
    // 奖励数量
    public var rewardCount: Int = 0
    // 是否正在挥手
    public var wavingArms: Bool = false
}

// MARK: - Chat
@objcMembers public class AgoraEduContextChatInfo: NSObject {
    // 消息Id
    public var id: String
    // 消息内容
    public let message: String
    // 消息所属人员信息
    public let user: AgoraEduContextUserInfo
    // 消息发送状态
    public var sendState: AgoraEduContextChatState = .default
    // 消息发送类型
    public let type: AgoraEduContextChatType
    // 消息时间， 毫秒级时间戳
    public let time: Int64
    // 消息来自本地还是远端
    public let from: AgoraEduContextChatFrom
    // 敏感词列表
    public let sensitiveWords: [String]
    
    public init(id: String,
                message: String,
                user: AgoraEduContextUserInfo,
                sendState: AgoraEduContextChatState,
                type: AgoraEduContextChatType = .text,
                time: Int64,
                from: AgoraEduContextChatFrom = .local,
                sensitiveWords: [String]) {
        self.id = id
        self.message = message
        self.user = user
        self.sendState = sendState
        self.type = type
        self.time = time
        self.from = from
        self.sensitiveWords = sensitiveWords
    }
}

// MARK: - Media
@objcMembers public class AgoraEduContextVideoConfig: NSObject {
    // 视频宽
    public var videoDimensionWidth: UInt = 320
    // 视频高
    public var videoDimensionHeight: UInt = 240
    // 视频帧率
    public var frameRate: UInt = 15
    
    public var bitrate: UInt = 200
    
    public var mirrorMode: AgoraEduContextVideoMirrorMode = .auto
    
    public init(videoDimensionWidth: UInt,
                videoDimensionHeight: UInt,
                frameRate: UInt,
                bitrate: UInt,
                mirrorMode: AgoraEduContextVideoMirrorMode ) {
        super.init()
        self.videoDimensionWidth = videoDimensionWidth
        self.videoDimensionHeight = videoDimensionHeight
        self.frameRate = frameRate
        self.bitrate = bitrate
        self.mirrorMode = mirrorMode
    }
    
    public static func defaultConfig() -> AgoraEduContextVideoConfig {
        return AgoraEduContextVideoConfig(videoDimensionWidth: 320,
                                          videoDimensionHeight: 240,
                                          frameRate: 15,
                                          bitrate: 200,
                                          mirrorMode: .auto)
    }
}

@objcMembers public class AgoraEduContextRenderConfig: NSObject {
    public var mode: AgoraEduContextRenderMode = .hidden
    public var mirror: Bool = false
}

@objcMembers public class AgoraEduContextDeviceConfig: NSObject {
    // 是否开启摄像头
    public var cameraEnabled: Bool = true
    // 摄像头方向
    public var cameraFacing: EduContextCameraFacing = .front
    // 是否开启麦克风
    public var micEnabled: Bool = true
    // 是否开启扬声器
    public var speakerEnabled: Bool = true
    
    public init(cameraEnabled: Bool,
                cameraFacing: EduContextCameraFacing,
                micEnabled: Bool,
                speakerEnabled: Bool) {
        super.init()
        
        self.cameraEnabled = cameraEnabled
        self.cameraFacing = cameraFacing
        self.micEnabled = micEnabled
        self.speakerEnabled = speakerEnabled
    }
}

// MARK: - Stream
@objcMembers public class AgoraEduContextStream: NSObject {
    /// 流 Id
    public let streamUuid: String
    /// 流名字
    public let streamName: String
    /// 流类型
    public let streamType: AgoraEduContextMediaStreamType
    /// 流的视频源类型
    public let videoSourceType: AgoraEduContextVideoSourceType
    /// 流的音频源类型
    public let audioSourceType: AgoraEduContextAudioSourceType
    /// 流的拥有者
    public let owner: AgoraEduContextUserInfo
    
    public init(streamUuid: String,
                streamName: String,
                streamType: AgoraEduContextMediaStreamType,
                videoSourceType: AgoraEduContextVideoSourceType,
                audioSourceType: AgoraEduContextAudioSourceType,
                owner: AgoraEduContextUserInfo) {
        self.streamUuid = streamUuid
        self.streamName = streamName
        self.streamType = streamType
        self.videoSourceType = videoSourceType
        self.audioSourceType = audioSourceType
        self.owner = owner
    }
}

// MARK: - AgoraEduContextError
@objcMembers public class AgoraEduContextError: NSObject {
    // 错误Code
    public var code: Int = 0
    // 错误消息
    public var message: String = ""
    
    public init(code: Int,
                message: String?) {
        self.code = code
        self.message = message ?? ""
    }
}

// MAKR: - Private communication
@objcMembers public class AgoraEduContextPrivateChatInfo: NSObject {
    public var fromUser: AgoraEduContextUserInfo
    public var toUser: AgoraEduContextUserInfo
    
    public init(fromUser: AgoraEduContextUserInfo,
                toUser: AgoraEduContextUserInfo) {
        self.fromUser = fromUser
        self.toUser = toUser
    }
}

// MARK: - WhiteBoard

@objcMembers public class AgoraEduContextCourseware: NSObject {
    public let resourceName: String
    public let resourceUuid: String
    public let scenePath: String
    public let resourceURL: String
    public let scenes: [AgoraEduContextWhiteScene]
    /// 原始文件的扩展名
    public let ext: String
    /// 原始文件的大小 单位是字节
    public let size: Double
    /// 原始文件的更新时间
    public let updateTime: Double
    
    public init(resourceName: String,
                resourceUuid: String,
                scenePath: String,
                resourceURL: String,
                scenes: [AgoraEduContextWhiteScene],
                ext: String,
                size: Double,
                updateTime: Double) {
        self.resourceName = resourceName
        self.resourceUuid = resourceUuid
        self.scenePath = scenePath
        self.resourceURL = resourceURL
        self.scenes = scenes
        self.ext = ext
        self.size = size
        self.updateTime = updateTime
    }
}

@objcMembers public class AgoraEduContextWhiteScene: NSObject {
    public var name: String
    public var ppt: AgoraEduContextWhitePptPage
    
    public init(name: String,
                ppt: AgoraEduContextWhitePptPage) {
        self.name = name
        self.ppt = ppt
    }
}

@objcMembers public class AgoraEduContextWhitePptPage: NSObject {
    /// 图片的 URL 地址。
    public var src: String
    /// 图片的 URL 宽度。单位为像素。
    public var width: Float
    /// 图片的 URL 高度。单位为像素。
    public var height: Float
    /// 预览图片的 URL 地址
    public var previewURL: String?
    
    public init(src: String,
                width: Float,
                height: Float,
                previewURL: String?) {
        self.src = src
        self.width = width
        self.height = height
        self.previewURL = previewURL
    }
}
