//
//  AgoraEduContextObjects.swift
//  AgoraUIEduBaseViews
//
//  Created by SRS on 2021/3/7.
//

import Foundation

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

@objc public enum AgoraEduContextApplianceType: Int {
    // 选择、笔、矩形、圆形、线形、橡皮擦
    case select, pen, rect, circle, line, eraser, clicker
}

/// Room
@objcMembers public class AgoraEduContextRoomInfo: NSObject {
    // 房间Id
    public var roomUuid: String
    // 房间名字
    public var roomName: String
    
    public init(roomUuid: String,
                roomName: String) {
        self.roomUuid = roomUuid
        self.roomName = roomName
    }
}

@objc public enum AgoraEduContextClassState: Int {
    // 教室状态： 默认、开始、结束、关闭
    case `default`, start, end, close
}

@objc public enum AgoraEduContextAppType: Int {
    // 场景：1V1、小班课
    case oneToOne = 0, lecture = 2, small = 4
}

@objc public enum AgoraEduContextNetworkQuality: Int {
    // 网络状态：未知、好、一般、差
    case unknown, good, medium, bad
}

@objc public enum AgoraEduContextConnectionState: Int {
    // 连接状态：断开、连接中、连接上、重连中、中止
    case disconnected, connecting, connected, reconnecting, aborted
}

/// User
@objcMembers public class AgoraEduContextUserInfo: NSObject {
    // 用户id
    public var userUuid: String = ""
    // 用户名字
    public var userName: String = ""
    // 用户角色
    public var role: AgoraEduContextUserRole = .student
    // 用户属性
    public var userProperties: [String : Any]?
}

@objc public enum AgoraEduContextUserRole: Int {
    // 角色： 老师、学生、助教
    case teacher = 1, student, assistant
}

/// PrivateChat
@objcMembers public class AgoraEduContextPrivateChatInfo: NSObject {
    public var fromUser: AgoraEduContextUserInfo
    public var toUser: AgoraEduContextUserInfo
    
    public init(fromUser: AgoraEduContextUserInfo,
                toUser: AgoraEduContextUserInfo) {
        self.fromUser = fromUser
        self.toUser = toUser
    }
}

/// Chat
@objcMembers public class AgoraEduContextChatInfo: NSObject {
    // 消息Id
    public var id: String = ""
    // 消息内容
    public var message: String = ""
    // 消息所属人员信息
    public var user: AgoraEduContextUserInfo?
    // 消息发送状态
    public var sendState: AgoraEduContextChatState = .default
    // 消息发送类型
    public var type: AgoraEduContextChatType = .text
    // 消息时间， 毫秒级时间戳
    public var time: Int64 = 0
    // 消息来自本地还是远端
    public var from: AgoraEduContextChatFrom = .local
}

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

/// list
@objc public enum AgoraEduContextDeviceState: Int {
    // 设备状态：不可用、可用, 关闭
    case notAvailable, available, close
}

@objcMembers public class AgoraEduContextUserDetailInfo: NSObject {
    // 人员信息
    public var user: AgoraEduContextUserInfo
    // 是不是自己
    public var isSelf: Bool = true
    // 流id
    public var streamUuid: String = ""
    // 是否在线
    public var onLine: Bool = false
    // 是否在台上
    public var coHost: Bool = false
    // 是否有白板权限
    public var boardGranted: Bool = false
    // 设备：摄像头是否可用
    public var cameraState: AgoraEduContextDeviceState = .notAvailable
    // 设备：麦克风是否可用
    public var microState: AgoraEduContextDeviceState = .notAvailable
    // 流：是否有视频
    public var enableVideo: Bool = false
    // 流：是否有音频
    public var enableAudio: Bool = false
    // 是否可以聊天
    public var enableChat: Bool = true
    // 奖励数量
    public var rewardCount: Int = 0
    
    public init(user: AgoraEduContextUserInfo) {
        self.user = user
        super.init()
    }
}

/// HandsUp
@objc public enum AgoraEduContextHandsUpState : Int {
    // 举手状态： 默认、举手、放手
    case `default`
    case handsUp
    case handsDown
}

/// ScreenShare
@objc public enum AgoraEduContextScreenShareState : Int {
    // 屏幕分享状态：开始、暂停、停止
    case start, pause, stop
}

/// Device
@objc public enum EduContextCameraFacing : Int {
    // 摄像头方向：前置、后置
    case front, back
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
    
    public init(cameraEnabled: Bool, cameraFacing: EduContextCameraFacing, micEnabled: Bool, speakerEnabled: Bool) {
        super.init()
        
        self.cameraEnabled = cameraEnabled
        self.cameraFacing = cameraFacing
        self.micEnabled = micEnabled
        self.speakerEnabled = speakerEnabled
    }
}

@objc public enum EduContextWidgetType: Int {
    case im
}

/// 媒体类型
@objc public enum EduContextMediaStreamType : Int {
    case audio, video, all
}
