//
//  AgoraEduContextObjects.swift
//  AgoraUIEduBaseViews
//
//  Created by SRS on 2021/3/7.
//

import Foundation

// MARK: - Classroom
/// 房间信息
@objcMembers public class AgoraEduContextRoomInfo: NSObject {
    /// 房间Id
    public var roomUuid: String
    /// 房间名字
    public var roomName: String
    /// 房间类型
    public var roomType: AgoraEduContextRoomType
    
    public init(roomUuid: String,
                roomName: String,
                roomType: AgoraEduContextRoomType) {
        self.roomUuid = roomUuid
        self.roomName = roomName
        self.roomType = roomType
    }
}

/// 课堂信息
@objcMembers public class AgoraEduContextClassInfo: NSObject {
    /// 课堂状态
    public var state: AgoraEduContextClassState = .before
    /// 开始时间，毫秒
    public var startTime: Int64
    /// 课堂时长，秒
    public var duration: Int64
    /// 拖堂时长，秒
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

// MARK: - Group
/// 分组信息
@objcMembers public class AgoraEduContextGroupInfo: NSObject {
    // 是否开启分组
    public var state: Bool
    
    public init(state: Bool) {
        self.state = state
    }
}

// MARK: - SubRoom
@objcMembers public class AgoraEduContextSubRoomCreateConfig: NSObject {
    // 子房间名
    public var subRoomName: String
    // 邀请加入子房间的用户 Id 列表，数组可以为空
    public var invitationUserList: [String]?
    // 子房间自定义属性，可以为空
    public var subRoomProperties: [String: Any]?
    
    public init(subRoomName: String,
                invitationUserList: [String]?,
                subRoomProperties: [String: Any]?) {
        self.subRoomName = subRoomName
        self.invitationUserList = invitationUserList
        self.subRoomProperties = subRoomProperties
    }
}

@objcMembers public class AgoraEduContextSubRoomInfo: NSObject {
    // 子房间 Id
    public var subRoomUuid: String
    // 子房间名
    public var subRoomName: String
    
    public init(subRoomUuid: String,
                subRoomName: String) {
        self.subRoomUuid = subRoomUuid
        self.subRoomName = subRoomName
    }
}

@objcMembers public class AgoraEduContextSubRoomRemovedUserEvent: NSObject {
    // 用户id
    public var userUuid: String
    // 用户移除的原因
    public var reason: AgoraEduContextSubRoomRemovedUserReason
    // 操作人，可以为空
    public var operatorUser: AgoraEduContextUserInfo?
    
    public init(userUuid: String,
                reason: AgoraEduContextSubRoomRemovedUserReason,
                operatorUser: AgoraEduContextUserInfo?) {
        self.userUuid = userUuid
        self.reason = reason
        self.operatorUser = operatorUser
    }
}

// MARK: - User
/// 用户信息
@objcMembers public class AgoraEduContextUserInfo: NSObject {
    // 用户id
    public var userUuid: String
    // 用户名字
    public var userName: String
    // 用户角色
    public var userRole: AgoraEduContextUserRole
    
    public init(userUuid: String,
                userName: String,
                role: AgoraEduContextUserRole = .student) {
        self.userUuid = userUuid
        self.userName = userName
        self.userRole = role
    }
}

@objcMembers public class AgoraEduContextCarouselInfo: NSObject {
    // 轮播是否开启
    public var state: Bool
    // 每次轮播时，从用户列表抽取的方式
    public var type: AgoraEduContextCoHostCarouselType
    // 满足轮播的条件
    public var condition: AgoraEduContextCoHostCarouselCondition
    // 轮播的时间间隔，单位秒
    public var interval: Int
    // 每次轮播时，更换连麦用户的个数
    public var count: Int
    
    public init(state: Bool,
                type: AgoraEduContextCoHostCarouselType,
                condition: AgoraEduContextCoHostCarouselCondition,
                interval: Int,
                count: Int) {
        self.state = state
        self.type = type
        self.condition = condition
        self.interval = interval
        self.count = count
    }
    
    public static func defaultConfig() -> AgoraEduContextCarouselInfo {
        return AgoraEduContextCarouselInfo(state: false,
                                           type: .sequence,
                                           condition: .none,
                                           interval: 0,
                                           count: 0)
    }
}

@objcMembers public class FcrUserPorpertiesEvent: NSObject {
    public let user: AgoraEduContextUserInfo
    
    public let changedProperties: [String]
    
    public init(user: AgoraEduContextUserInfo,
                changedProperties: [String]) {
        self.user = user
        self.changedProperties = changedProperties
    }
}

// MARK: - Media
/// 视频流配置
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

@objcMembers public class FcrSnapshotInfo: NSObject {
    /// 房间id
    public var roomUuid: String
    /// 流id
    public var streamUuid: String
    /// 截图文件保存地址
    public var filePath: String
    /// 图片宽度
    public var width: UInt16
    /// 图片高度
    public var height: UInt16
    
    public init(roomUuid: String,
                streamUuid: String,
                filePath: String,
                width: UInt16,
                height: UInt16) {
        self.roomUuid = roomUuid
        self.streamUuid = streamUuid
        self.filePath = filePath
        self.width = width
        self.height = height
        super.init()
    }
}

/// 视频渲染配置
@objcMembers public class AgoraEduContextRenderConfig: NSObject {
    public var mode: AgoraEduContextVideoRenderMode = .hidden
    public var isMirror: Bool = false
}

/// 设备信息
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

/// 音频原始数据配置
@objcMembers public class FcrAudioRawDataConfig: NSObject {
    public var sampleRate: Int32 = 48000
    public var samplesPerChannel: Int64 = 1024
    public var channels: Int8 = 1
    public var mode: FcrMediaRawDataOperationMode = .readOnly
}

/// 音频原始数据信息
@objcMembers public class FcrAudioRawData: NSObject {
    public let sampleRate: Int32
    public let samplesPerChannel: Int64
    public let channels: Int8
    public let bytesPerSample: Int8
    public let timestamp: Int64
    public let buffer: NSData
    
    public init(sampleRate: Int32,
                samplesPerChannel: Int64,
                channels: Int8,
                bytesPerSample: Int8,
                timestamp: Int64,
                buffer: NSData) {
        self.sampleRate = sampleRate
        self.samplesPerChannel = samplesPerChannel
        self.channels = channels
        self.bytesPerSample = bytesPerSample
        self.timestamp = timestamp
        self.buffer = buffer
    }
}

// MARK: - Stream
/// 流信息
@objcMembers public class AgoraEduContextStreamInfo: NSObject {
    /// 流 Id
    public let streamUuid: String
    /// 流名字
    public let streamName: String
    /// 流类型
    public let streamType: AgoraEduContextMediaStreamType
    /// CDN 流地址，RTMP 协议
    public var streamRtmpUrl: String?
    /// CDN 流地址，FLV 协议
    public var streamFlvUrl: String?
    /// CDN 流协议，HLS 协议
    public var streamHlsUrl: String?
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

@objcMembers public class FcrRtmpStreamConfig: NSObject {
    /// 流 Id
    public let streamUuid: String
    /// cdn 流的分辨率宽
    public let dimensionWidth: UInt16
    /// cdn 流的分辨率高
    public let dimensionHeight: UInt16
    /// cdn 流的码率
    public let bitRate: UInt16
    /// 自定义用户信息
    public var seiOptions: [String: Any]?
    
    public init(streamUuid: String,
                dimensionWidth: UInt16,
                dimensionHeight: UInt16,
                bitRate: UInt16,
                seiOptions: [String: Any]?) {
        self.streamUuid = streamUuid
        self.dimensionWidth = dimensionWidth
        self.dimensionHeight = dimensionHeight
        self.bitRate = bitRate
        self.seiOptions = seiOptions
    }
}

// MARK: - AgoraEduContextError
/// 错误
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

// MARK: - FcrEventBatch
@objcMembers public class FcrEventBatch: NSObject {
    public let identifier: String
    
    public let total: UInt16
    
    public let index: UInt16
    
    public init(identifier: String,
                total: UInt16,
                index: UInt16) {
        self.identifier = identifier
        self.total = total
        self.index = index
    }
}
