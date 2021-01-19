//
//  AgoraActionObject.swift
//  AgoraActionProcess
//
//  Created by SRS on 2020/11/30.
//

import Foundation

public let AgoraActionHTTPOK = 0

public struct AgoraActionConfig {
    public var appId: String = ""
    public var roomUuid: String = ""
    public var userToken: String = ""
    public var userUuid: String = ""
    public var token: String = ""
    
    public var baseURL: String = ""
}

public enum AgoraActionType: Int, Codable {
    case apply = 1, invitation, accept, reject, cancel
}

public enum AgoraActionStopType: Int {
    case ignoreAck = 0, waitAck
}

public struct AgoraActionOptions {
    
    public var actionType: AgoraActionType = .apply
    
    // How many people are allowed to apply / invite at the same time
    // 最多允许接受多少人同时申请/邀请
    public var maxWait: Int = 4
    // Unresponsive timeout (seconds)
    // 未响应超时时间(秒)
    public var timeout: Int = 10
    
    public var processUuid: String = ""
}

// params
public struct AgoraActionStartOptions {
    public var toUserUuid: String = ""
    public var processUuid: String = ""
    public var fromUserUuid: String = ""
    public var payload: [String: Any] = [:]
}
public struct AgoraActionStopOptions {
    public var toUserUuid: String = ""
    public var processUuid: String = ""
    public var action: AgoraActionType = .accept
    public var fromUserUuid: String = ""
    public var payload: [String: Any] = [:]
    public var waitAck: AgoraActionStopType = .waitAck
}

// response
public struct AgoraActionUser {
    public var userUuid: String = ""
    public var userName: String = ""
    public var role: String = ""
}
public struct AgoraActionInfoResponse {
    public var processUuid: String = ""
    public var action: AgoraActionType = .accept
    public var fromUser: AgoraActionUser
    public var payload: [String: Any] = [:]
}
public struct AgoraActionConfigInfoResponse: Codable {
    public var maxAccept: Int = 0
    public var maxWait: Int = 0
    public var timeout: Int = 0
    public var processUuid: String = ""
    
    private enum CodingKeys: String, CodingKey {
        case maxAccept, maxWait, timeout
    }
}
public struct AgoraActionResponse {
    public var code: Int = AgoraActionHTTPOK
    public var msg: String = ""
}
