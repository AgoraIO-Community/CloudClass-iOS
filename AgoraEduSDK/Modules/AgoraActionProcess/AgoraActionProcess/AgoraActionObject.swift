//
//  AgoraActionObject.swift
//  AgoraActionProcess
//
//  Created by SRS on 2020/11/30.
//

import Foundation

public let AgoraActionHTTPOK = 0

// MARK: Config
public struct AgoraActionConfig {
    public var appId: String = ""
    public var roomUuid: String = ""
    public var userUuid: String = ""
    public var token: String = ""
    public var baseURL: String = ""
    
    public init(inAppId: String,
                inRoomId: String,
                inUserUuid: String,
                inToken: String,
                inBaseURL: String) {
        self.appId = inAppId
        self.roomUuid = inRoomId
        self.userUuid = inUserUuid
        self.token = inToken
        self.baseURL = inBaseURL
    }
}

// MARK : HTTP_Request
/// 1.学生举手上麦 2.老师同意学生上麦 3.老师拒绝学生举手 4.学生取消举手 5.学生下麦 6.老师让学生下麦 7.老师超时未响应
@objc public enum AgoraActionStateType: Int, Decodable {
    case `default`          = 0
    case handsUp            = 1
    case accepted           = 2
    case rejected           = 3
    case handsDown          = 4
    case cancel             = 5
    case canceled           = 6
    case applyTimeOut       = 7
}

@objcMembers public class AgoraActionStartOptions: NSObject {
    public var toUserUuid: String = ""
    public var actionType: AgoraActionStateType = .handsUp
    
    public init(toUserUuid: String,
                actionType: AgoraActionStateType){
        self.toUserUuid = toUserUuid
        self.actionType = actionType
    }
}

@objcMembers public class AgoraActionResponse:NSObject, Decodable {
    public var code: Int = AgoraActionHTTPOK
    public var msg: String = ""
}

public enum AgoraActionProcessUuid: String, Decodable {
    case handsUp          = "handsUp"
}

@objcMembers public class AgoraActionProperties:NSObject, Decodable {
    public var enabled: Int = 0 // 是否开启 1开 0关
    public var type: Int = 1  // 1申请 2邀请
    public var timeout: Int = 60 // 超时时间，单位秒
    public var maxWait: Int = 10 // 最大等待人数
    public var maxAccept: Int = 10 // 最大接受人数
    public var progress: [AgoraProgressInfo] = []
    public var accepted: [AgoraAcceptedInfo] = []
}

@objcMembers public class AgoraProgressInfo:NSObject, Decodable {
    public var userUuid: String?
    public var ts: Int64?
}

@objcMembers public class AgoraAcceptedInfo:NSObject, Decodable {
    public var userUuid: String = ""
}

// MARK: Cause
@objc public enum AgoraActionCauseType: Int, Decodable {
    case processState          = 5
    case actionState           = 501
}

// MARK: Cause--举手状态变化
public struct AgoraActionCauseProcessState: Decodable {
    public var cmd: AgoraActionCauseType = .processState
    public var data: AgoraActionCauseProcessStateData
}
public struct AgoraActionCauseProcessStateData: Decodable {
    public var processUuid: AgoraActionProcessUuid = .handsUp
}

// MARK: Cause--举手
public struct AgoraActionCauseHandsUp: Decodable {
    public var cmd: AgoraActionCauseType = .actionState
    public var data: AgoraActionCauseHandsUpData
}

public struct AgoraActionCauseHandsUpData: Decodable {
    public var processUuid: AgoraActionProcessUuid = .handsUp
    public var addProgress: [AgoraProgressInfo] = []
    public var actionType: AgoraActionStateType = .handsUp
}

// MARK: Cause--同意举手
public struct AgoraActionCauseAccepted: Decodable {
    public var cmd: AgoraActionCauseType = .actionState
    public var data: AgoraActionCauseAcceptedData
}
public struct AgoraActionCauseAcceptedData: Decodable {
    public var processUuid: AgoraActionProcessUuid = .handsUp
//    老师直接让学生上台removeProgress:[null]
//    public var removeProgress: [AgoraProgressInfo]? = []
    public var addAccepted: [AgoraAcceptedInfo] = []
    public var actionType: AgoraActionStateType = .accepted
}

// MARK: Cause--拒绝举手
public struct AgoraActionCauseRejected: Decodable {
    public var cmd: AgoraActionCauseType = .actionState
    public var data: AgoraActionCauseRejectedData
}
public struct AgoraActionCauseRejectedData: Decodable {
    public var processUuid: AgoraActionProcessUuid = .handsUp
    public var removeProgress: [AgoraProgressInfo] = []
    public var actionType: AgoraActionStateType = .rejected // .rejected或者 .applyTimeOut
}

// MARK: Cause--取消举手
public struct AgoraActionCauseHandsDown: Decodable {
    public var cmd: AgoraActionCauseType = .actionState
    public var data: AgoraActionCauseHandsDownData
}
public struct AgoraActionCauseHandsDownData: Decodable {
    public var processUuid: AgoraActionProcessUuid = .handsUp
    public var removeProgress: [AgoraProgressInfo] = []
    public var actionType: AgoraActionStateType = .handsDown
}

// MARK: Cause--下麦
public struct AgoraActionCauseCancel: Decodable {
    public var cmd: AgoraActionCauseType = .actionState
    public var data: AgoraActionCauseCancelData
}
public struct AgoraActionCauseCancelData: Decodable {
    public var processUuid: AgoraActionProcessUuid = .handsUp
    public var removeAccepted: [AgoraAcceptedInfo] = []
    public var actionType: AgoraActionStateType = .cancel  // .cancel或者.canceled
}

// MARK: Cause--集合
public struct AgoraActionCause {
    public var state: AgoraActionCauseProcessState?
    public var handsUp: AgoraActionCauseHandsUp?
    public var accepted: AgoraActionCauseAccepted?
    public var rejected: AgoraActionCauseRejected?
    public var handsDown: AgoraActionCauseHandsDown?
    public var cancel: AgoraActionCauseCancel?
}
