//
//  AgoraEduContextEnums.swift
//  AgoraEduContext
//
//  Created by Cavan on 2021/9/16.
//

import Foundation

// MARK: - White board
@objc public enum AgoraEduContextApplianceType: Int {
    // 选择、笔、矩形、圆形、线形、橡皮擦
    case select, pen, rect, circle, line, eraser, clicker
}

// MARK: - Classroom
@objc public enum AgoraEduContextRoomType: Int {
    // 场景：1V1、小班课
    case oneToOne = 0, lecture = 2, small = 4, paintingSmall = 5
}

@objc public enum AgoraEduContextClassState: Int {
    /// 课前
    case before = 0
    /// 课中
    case during = 1
    /// 课后
    case after = 2
}

// MARK: - User
@objc public enum AgoraEduContextUserRole: Int {
    /// 老师
    case teacher = 1
    /// 学生
    case student = 2
    /// 助教
    case assistant = 3
}

@objc public enum AgoraEduContextUserLeaveReason: Int {
    // 正常离开
    case normal = 0
    // 被踢
    case kickOut = 1
}

// MARK: - Network
@objc public enum AgoraEduContextNetworkQuality: Int {
    // 网络状态：未知、好、一般、差
    case unknown, good, medium, bad
}

@objc public enum AgoraEduContextConnectionState: Int {
    // 连接状态：断开、连接中、连接上、重连中、中止
    case disconnected, connecting, connected, reconnecting, aborted
}

// MARK: - HandsUp
@objc public enum AgoraEduContextHandsUpState: Int {
    // 举手状态： 默认、举手、放手
    case `default`
    case handsUp
    case handsDown
}

@objc public enum AgoraEduContextHandsUpResult: Int {
    case rejected
    case accepted
    case timeout
}

// MARK: - Media
@objc public enum AgoraEduContextVideoRenderMode: Int {
    case hidden = 1, fit = 2
}

@objc public enum AgoraEduContextScreenShareState: Int {
    // 屏幕分享状态：开始、暂停、停止
    case start, pause, stop
}

@objc public enum AgoraEduContextDeviceType: Int {
    /// 摄像头
    case camera = 1
    /// 麦克风
    case mic = 2
    /// 扬声器、喇叭
    case speaker = 3
}

@objc public enum AgoraEduContextDeviceState: Int {
    /// 设备错误
    case error = -1
    /// 设备关闭
    case close = 0
    /// 设备开启
    case open = 1
}

@objc public enum AgoraEduContextMediaSourceState: Int {
    /// 媒体源错误
    case error = -1
    /// 媒体源关闭
    case close = 0
    /// 媒体源开启
    case open = 1
}

// MARK: - Stream
/// 视频源
@objc public enum AgoraEduContextVideoSourceType: Int {
    /// 无视频源
    case none = 0
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
    case mic = 1
}

/// 流类型
@objc public enum AgoraEduContextMediaStreamType: Int {
    /// 及无音频也无视频
    case none = 0
    /// 只有音频
    case audio = 1
    /// 只有视频
    case video = 2
    /// 既有音频也有视频
    case both = 3
}

/// 订阅高/低视频分辨率
@objc public enum AgoraEduContextVideoStreamSubscribeLevel: Int {
    /// 订阅双流中的低分辨率视频流
    case low = 1
    /// 订阅双流中的高分辨率视频流
    case high = 2
}
