//
//  AgoraChatPanelModel.swift
//  AgoraEduSDK
//
//  Created by SRS on 2021/2/1.
//

import Foundation
import EduSDK

@objc public enum AgoraChatLoadingState: Int {
    case none = 1, loading, success, failure
}

@objc public enum AgoraChatMessageType: Int {
    case text = 1, userInout
}

@objcMembers public class AgoraChatUserInfoModel: NSObject {
    public var role: AgoraRTERoleType = .invalid
    public var userName: String = ""
    public var userUuid: String = ""
}
@objcMembers public class AgoraChatMessageInfoModel: NSObject {
    public var sequence: Int = 0
    public var message: String = ""
    public var type: AgoraChatMessageType = .text
    public var fromUser : AgoraChatUserInfoModel?
    public var sendTime: Int64 = 0
    
    public var isSelf = false
    public var translateState: AgoraChatLoadingState = .none
    public var sendState: AgoraChatLoadingState = .none
    public var translateMessage = ""
    
    public var cellHeight: CGFloat = 0
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

// translate
@objcMembers class AgoraChatTranslateInfoModel: NSObject {
    var translation = ""
}
@objcMembers class AgoraChatTranslateModel: AgoraBaseModel {
    var data: AgoraChatTranslateInfoModel?
}
