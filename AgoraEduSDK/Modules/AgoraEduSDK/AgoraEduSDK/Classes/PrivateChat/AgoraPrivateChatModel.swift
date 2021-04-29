//
//  AgoraPrivateChatModel.swift
//  AgoraEduSDK
//
//  Created by SRS on 2021/4/10.
//

import Foundation

// MARK: Cause--举手状态变化
struct AgoraPrivateChat: Decodable {
    var cmd: AgoraCauseType = .streamGroupsAdd
}

public struct AgoraPrivateChatInfo: Decodable {
    public var users: [AgoraPrivateChatUserInfo] = []
    public var streams: [AgoraPrivateChatStreamInfo] = []
}

public struct AgoraPrivateChatStreamInfo: Decodable {
    public var streamUuid: String = ""
    // 是否开启了私密， 0=没有， 1=有
    public var audio: Int = 0
    public var video: Int = 0
}

public struct AgoraPrivateChatUserInfo: Decodable {
    public var userUuid: String = ""
}

