//
//  AgoraModels.swift
//  AgoraEduSDK
//
//  Created by SRS on 2021/3/14.
//

import Foundation
import EduSDK


@objc public enum AgoraChatLoadingState: Int {
    case none = 1, loading, success, failure
}

@objc public enum AgoraChatMessageType: Int {
    case text = 1
}

@objcMembers public class AgoraChatUserInfoModel: NSObject {
    public var role: AgoraRTERoleType = .invalid
    public var userName: String = ""
    public var userUuid: String = ""
}
@objcMembers public class AgoraChatMessageInfoModel: NSObject {
    public var messageId: Int = 0
    public var peerMessageId: String = ""
    public var message: String = ""
    public var type: AgoraChatMessageType = .text
    public var fromUser : AgoraChatUserInfoModel?
    public var sensitiveWords : [String]?
    public var sendTime: Int64 = 0
}
@objcMembers class AgoraChatMessageInfosModel: NSObject {
    var total: Int = 0
    var list: [AgoraChatMessageInfoModel] = []
    var nextId: String?
    var count: Int = 0
    
    static func modelContainerPropertyGenericClass() -> [String: Any] {
        return ["list" : AgoraChatMessageInfoModel.self]
    }
}
@objcMembers class AgoraChatMessageModel: AgoraBaseModel {
    var data: AgoraChatMessageInfosModel?
}
