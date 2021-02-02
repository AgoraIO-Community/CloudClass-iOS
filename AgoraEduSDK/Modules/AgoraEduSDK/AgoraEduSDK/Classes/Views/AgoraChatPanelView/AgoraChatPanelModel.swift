//
//  AgoraChatPanelModel.swift
//  AgoraEduSDK
//
//  Created by SRS on 2021/2/1.
//

import Foundation

@objc public enum AgoraChatLoadingState: Int {
    case none = 1, loading, success, failure
}

@objc public enum AgoraChatMessageType: Int {
    case text = 0, userInout
}

@objcMembers public class AgoraChatMessageModel: NSObject {
    public var messageId = 0
    public var message = ""
    public var translateMessage = ""
    public var userName = ""
    
    public var type:AgoraChatMessageType = .text
    
    public var isSelf = false
    public var translateState: AgoraChatLoadingState = .none
    public var sendState: AgoraChatLoadingState = .none
    
    public var cellHeight: Float = 0
}
