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
    // 教室状态： 默认、开始、结束、关闭
    case `default`, start, end, close
}

// MARK: - User
@objc public enum AgoraEduContextUserRole: Int {
    // 角色： 老师、学生、助教
    case teacher = 1, student, assistant
}

// MARK: - Chat
@objc public enum AgoraEduContextChatState: Int {
    // 状态：默认、发送中、成功、失败
    case `default`, inProgress, success, failure
}

@objc public enum AgoraEduContextChatType: Int {
    // 文本
    case text = 1
}

@objc public enum AgoraEduContextChatFrom: Int {
    // 消息来源：本地、远端
    case local = 1, remote
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
@objc public enum AgoraEduContextRenderMode: Int {
    case hidden, fit
}

@objc public enum AgoraEduContextVideoMirrorMode: Int {
    case auto, enabled,disabled
}

@objc public enum EduContextCameraFacing: Int {
    // 摄像头方向：前置、后置
    case front, back
}

@objc public enum EduContextMediaStreamType: Int {
    case audio, video, all
}

@objc public enum AgoraEduContextScreenShareState: Int {
    // 屏幕分享状态：开始、暂停、停止
    case start, pause, stop
}

@objc public enum AgoraEduContextDeviceState: Int {
    // 设备状态：不可用、可用, 关闭
    case notAvailable = 0, available = 1, close = 2
}

// MARK: - Widget
@objc public enum EduContextWidgetType: Int {
    case im, bigWindow, rtmchat, cloud
}

// MARK: - Stream
/// 视频源
@objc public enum AgoraEduContextVideoSourceType: Int {
    /// 视频源损坏
    case invalid = -1
    /// 无视频源或视频源关闭
    case none = 0
    /// 摄像头
    case camera = 1
    /// 屏幕
    case screen = 2
}

/// 音频源
@objc public enum AgoraEduContextAudioSourceType: Int {
    /// 音频源损坏
    case invalid = -1
    /// 无音频源或音频源关闭
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
    case audioAndVideo = 3
}

/// 订阅高/低视频分辨率
@objc public enum AgoraEduContextVideoStreamSubscribeLevel: Int {
    /// 订阅双流中的低分辨率视频流
    case low = 1
    /// 订阅双流中的高分辨率视频流
    case high = 2
}
