//
//  AgoraChatPanelModel.swift
//  AgoraEduSDK
//
//  Created by SRS on 2021/2/1.
//

import Foundation
import EduSDK

enum AgoraChatLoadingState: Int {
    case none = 1, loading, success, failure
}

enum AgoraChatMessageType: Int {
    case text = 0, userInout
}

//@objcMembers public class AgoraChatMessageModel: NSObject {
//    public var messageId = 0
//    public var message = ""
//
//    public var userName = ""
//
//    public var type:AgoraChatMessageType = .text
//
//    public var isSelf = false
//    public var translateState: AgoraChatLoadingState = .none
//    public var sendState: AgoraChatLoadingState = .none
//    public var translateMessage = ""
//    public var cellHeight: Float = 0
//}

class AgoraChatUserInfoModel: NSObject {
    var role: AgoraRTERoleType = .invalid
    var userName: String = ""
    var userUuid: String = ""
}
class AgoraChatMessageInfoModel: NSObject {
    var sequence: Int = 0
    var message: String = ""
    var type: AgoraChatMessageType = .text
    var fromUser : AgoraChatUserInfoModel?
    var sendTime: Int = 0
    
    var isSelf = false
    var translateState: AgoraChatLoadingState = .none
    var sendState: AgoraChatLoadingState = .none
    var translateMessage = ""
    
    var cellHeight: Float = 0
}
class AgoraChatMessageInfosModel: NSObject {
    var total: Int = 0
    var list: [AgoraChatMessageInfoModel] = []
    var nextId: Int?
    var count: Int = 0
}
class AgoraChatMessageModel: AgoraBaseModel {
    var data: AgoraChatMessageInfosModel?
}
