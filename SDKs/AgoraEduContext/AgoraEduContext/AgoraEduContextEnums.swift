//
//  AgoraEduContextEnums.swift
//  AgoraEduContext
//
//  Created by Cavan on 2021/9/16.
//

import Foundation

// MARK: - Classroom
/// 房间类型
@objc public enum AgoraEduContextRoomType: Int {
    /// 1V1
    case oneToOne      = 0
    /// 小班课
    case small         = 4
    /// 大班课
    case lecture       = 2
}

/// 课堂状态
@objc public enum AgoraEduContextClassState: Int {
    /// 课前
    case before = 0
    /// 课中
    case during = 1
    /// 课后
    case after  = 2
}

/// 录制状态
@objc public enum FcrRecordingState: Int {
    /// 未录制
    case stopped  = 0
    /// 录制启动中
    case starting = 1
    /// 正在录制
    case started  = 2
}

// MARK: - SubRoom
/// 
@objc public enum AgoraEduContextSubRoomRemovedUserReason: Int {
    /// 用户自己移除
    case normal = 0
    /// 用户被他人移除
    case kickOut = 1
}

// MARK: - User
/// 用户角色
@objc public enum AgoraEduContextUserRole: Int {
    /// 老师
    case teacher   = 1
    /// 学生
    case student   = 2
    /// 助教
    case assistant = 3
    /// 观众
    case observer  = 4
}

/// 用户离开原因
@objc public enum AgoraEduContextUserLeaveReason: Int {
    /// 正常离开
    case normal  = 0
    /// 被踢
    case kickOut = 1
}

// MARK: - Network
/// 网络质量
@objc public enum AgoraEduContextNetworkQuality: Int {
    /// 未知
    case unknown
    /// 好
    case good
    /// 一般
    case medium
    /// 差
    case bad
    /// 断网
    case down
}

/// 每次轮播时，从用户列表抽取的方式
@objc public enum AgoraEduContextCoHostCarouselType: Int {
    /// 顺序
    case sequence = 1
    /// 随机
    case random = 2
}

/// 满足轮播的条件
@objc public enum AgoraEduContextCoHostCarouselCondition: Int {
    /// 无条件
    case none = 1
    /// 摄像头开启
    case cameraOpened = 2
}

/// 连接状态
@objc public enum AgoraEduContextConnectionState: Int {
    /// 断开
    case disconnected
    /// 连接中
    case connecting
    /// 连接
    case connected
    /// 重连中
    case reconnecting
    /// 中止
    case aborted
}

// MARK: - Media
/// 渲染模式
@objc public enum AgoraEduContextVideoRenderMode: Int {
    case hidden = 1
    case fit    = 2
}

/// 设备类型
@objc public enum AgoraEduContextDeviceType: Int {
    /// 摄像头
    case camera  = 1
    /// 麦克风
    case mic     = 2
    /// 扬声器、喇叭
    case speaker = 3
}

/// 设备状态
@objc public enum AgoraEduContextDeviceState: Int {
    /// 设备错误
    case error = -1
    /// 设备关闭
    case close = 0
    /// 设备开启
    case open  = 1
}

/// 媒体源
@objc public enum AgoraEduContextMediaSourceState: Int {
    /// 媒体源错误
    case error = -1
    /// 媒体源关闭
    case close = 0
    /// 媒体源开启
    case open  = 1
}

/// 系统设备
@objc public enum AgoraEduContextSystemDevice: Int {
    case frontCamera = 1
    case backCamera  = 2
    case mic         = 3
    case speaker     = 4
}

/// 媒体原始数据操作
@objc public enum FcrMediaRawDataOperationMode: Int {
    case readOnly = 0
}

@objc public enum FcrAudioRawDataPosition: Int {
    case record = 2
}

// MARK: - Stream
/// 视频源
@objc public enum AgoraEduContextVideoSourceType: Int {
    /// 无视频源
    case none   = 0
    /// 摄像头
    case camera = 1
    /// 屏幕
    case screen = 2
}

/// 音频源
@objc public enum AgoraEduContextAudioSourceType: Int {
    /// 无音频源
    case none = 0
    /// 麦克风
    case mic  = 1
}

/// 流类型
@objc public enum AgoraEduContextMediaStreamType: Int {
    /// 及无音频也无视频
    case none  = 0
    /// 只有音频
    case audio = 1
    /// 只有视频
    case video = 2
    /// 既有音频也有视频
    case both  = 3
}

/// 订阅高/低视频分辨率
@objc public enum AgoraEduContextVideoStreamSubscribeLevel: Int {
    /// 订阅双流中的低分辨率视频流
    case low  = 1
    /// 订阅双流中的高分辨率视频流
    case high = 2
}
