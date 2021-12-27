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

@objcMembers public class AgoraEduContextClassInfo: NSObject {
    /// 课堂状态
    public var state: AgoraEduContextClassState = .before
    
    public var startTime: Int64
    
    public var duration: Int64
    
    public var closeDelay: Int64
    
    public init(state: AgoraEduContextClassState,
                startTime: Int64,
                duration: Int64,
                closeDelay: Int64) {
        self.state = state
        self.startTime = startTime
        self.duration = duration
        self.closeDelay = closeDelay
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

// MARK: - Media
@objcMembers public class AgoraEduContextVideoStreamConfig: NSObject {
    /// 视频宽
    public var dimensionWidth: UInt = 320
    /// 视频高
    public var dimensionHeight: UInt = 240
    /// 视频帧率
    public var frameRate: UInt = 15
    /// 视频码率
    public var bitRate: UInt = 200
    /// 是否镜像
    public var isMirror: Bool = false
    
    public init(dimensionWidth: UInt,
                dimensionHeight: UInt,
                frameRate: UInt,
                bitRate: UInt,
                isMirror: Bool) {
        super.init()
        self.dimensionWidth = dimensionWidth
        self.dimensionHeight = dimensionHeight
        self.frameRate = frameRate
        self.bitRate = bitRate
        self.isMirror = isMirror
    }
    
    public static func defaultConfig() -> AgoraEduContextVideoStreamConfig {
        return AgoraEduContextVideoStreamConfig(dimensionWidth: 320,
                                                dimensionHeight: 240,
                                                frameRate: 15,
                                                bitRate: 200,
                                                isMirror: false)
    }
}

@objcMembers public class AgoraEduContextRenderConfig: NSObject {
    public var mode: AgoraEduContextVideoRenderMode = .hidden
    public var isMirror: Bool = false
}

@objcMembers public class AgoraEduContextDeviceInfo: NSObject {
    /// 设备 Id
    public var deviceId: String
    /// 设备名
    public var deviceName: String
    /// 设备类型
    public var deviceType: AgoraEduContextDeviceType
    
    public init(deviceId: String,
                deviceName: String,
                deviceType: AgoraEduContextDeviceType) {
        self.deviceId = deviceId
        self.deviceName = deviceName
        self.deviceType = deviceType
        super.init()
    }
}

// MARK: - Stream
@objcMembers public class AgoraEduContextStreamInfo: NSObject {
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
    /// 流的音频源状态
    public let videoSourceState: AgoraEduContextMediaSourceState
    /// 流的音频源状态
    public let audioSourceState: AgoraEduContextMediaSourceState
    /// 流的拥有者
    public let owner: AgoraEduContextUserInfo
    
    public init(streamUuid: String,
                streamName: String,
                streamType: AgoraEduContextMediaStreamType,
                videoSourceType: AgoraEduContextVideoSourceType,
                audioSourceType: AgoraEduContextAudioSourceType,
                videoSourceState: AgoraEduContextMediaSourceState,
                audioSourceState: AgoraEduContextMediaSourceState,
                owner: AgoraEduContextUserInfo) {
        self.streamUuid = streamUuid
        self.streamName = streamName
        self.streamType = streamType
        self.videoSourceType = videoSourceType
        self.audioSourceType = audioSourceType
        self.videoSourceState = videoSourceState
        self.audioSourceState = audioSourceState
        self.owner = owner
    }
}

// MARK: - AgoraEduContextError
@objcMembers public class AgoraEduContextError: NSObject {
    // 错误Code
    public var code: Int = 0
    // 错误消息
    public var message: String?
    
    public init(code: Int,
                message: String? = nil) {
        self.code = code
        self.message = message
    }
}
