//
//  AgoraChatVM.swift
//  AgoraEduSDK
//
//  Created by SRS on 2021/3/14.
//

import Foundation
import AgoraUIEduBaseViews
import AgoraEduSDK.AgoraFiles.AgoraHTTP
import AgoraEduSDK.AgoraFiles.AgoraManager
import AgoraEduContext

@objcMembers public class AgoraChatVM: AgoraBaseVM {
    
    // ServerId:LocalId
    fileprivate var msgsIdMapping = [Int : Int]()
    fileprivate var chatInfos: [AgoraEduContextChatInfo] = []

    public func kitChatInfo(rteMessage: AgoraRTETextMessage) -> AgoraEduContextChatInfo? {
        
        guard let rteUser = self.localUserInfo else {
            return nil
        }
        
        let user = AgoraEduContextUserInfo()
        user.role = AgoraEduContextUserRole(rawValue: rteMessage.fromUser.role.rawValue) ?? .student
        user.userUuid = rteMessage.fromUser.userUuid
        user.userName = rteMessage.fromUser.userName
            
        let form: AgoraEduContextChatFrom = (user.userUuid == rteUser.userUuid) ? .local : .remote
        
        let chatInfo = AgoraEduContextChatInfo()
        chatInfo.id = self.msgsIdMapping[rteMessage.messageId] ?? rteMessage.messageId
        chatInfo.message = rteMessage.message
        chatInfo.user = user
        chatInfo.sendState = .success
        chatInfo.type = AgoraEduContextChatType(rawValue: rteMessage.type) ?? .text
        chatInfo.time = Int64(rteMessage.timestamp)
        chatInfo.from = form
        
        return chatInfo
    }
}

extension AgoraChatVM {

    @discardableResult public func sendRoomMessage(_ message: String, messageId: Int, successBlock: @escaping (_ info: AgoraEduContextChatInfo) -> Void, failureBlock: @escaping (_ error: AgoraEduContextError, _ info: AgoraEduContextChatInfo) -> Void) -> AgoraEduContextChatInfo {
        
        var kitChatInfo: AgoraEduContextChatInfo!
        for chatInfo in self.chatInfos {
            if chatInfo.id == messageId {
                chatInfo.sendState = .inProgress
                kitChatInfo = chatInfo
                break
            }
        }
        
        let sendTime = Int(Date().timeIntervalSince1970)
        if kitChatInfo == nil {
            let kitInfo = AgoraEduContextChatInfo()
            kitInfo.id = sendTime
            kitInfo.message = message
            kitInfo.user = self.kitLocalUserInfo()
            kitInfo.type = .text
            kitInfo.time = Int64(sendTime * 1000)
            kitInfo.sendState = .inProgress
            kitInfo.from = .local
            kitChatInfo = kitInfo
            
            self.chatInfos.append(kitChatInfo)
        }
        
        let chatConfig = AgoraRoomChatConfiguration()
        chatConfig.appId = self.config.appId
        chatConfig.roomUuid = self.config.roomUuid
        chatConfig.userUuid = self.config.userUuid
        chatConfig.token = self.config.token
        chatConfig.type = 1
        chatConfig.message = message
        AgoraHTTPManager.roomChat(withConfig: chatConfig) {[weak self] (model) in
            kitChatInfo.sendState = .success
            self?.msgsIdMapping[model.messageId] = kitChatInfo.id
            successBlock(kitChatInfo)
        } failure: {[weak self] (error, code) in
            if let `self` = self {
                kitChatInfo.sendState = .failure
                failureBlock(self.kitError(error), kitChatInfo)
            }
        }
        return kitChatInfo
    }
    
    @discardableResult public func resendRoomMessage(_ message: String, messageId: Int, successBlock: @escaping (_ info: AgoraEduContextChatInfo) -> Void, failureBlock: @escaping (_ error: AgoraEduContextError, _ info: AgoraEduContextChatInfo) -> Void) -> AgoraEduContextChatInfo {
        
        return self.sendRoomMessage(message, messageId: messageId, successBlock: successBlock, failureBlock: failureBlock)
    }
    
    public func fetchHistoryMessages(_ startId: Int, count: Int, sort:Int = 0, successBlock: @escaping (_ models: [AgoraEduContextChatInfo]) -> Void, failureBlock: @escaping (_ error: AgoraEduContextError) -> Void) {
        
        let baseURL = AgoraHTTPManager.getBaseURL()
        let url = "\(baseURL)/edu/apps/\(config.appId)/v2/rooms/\(config.roomUuid)/chat/messages"

        let headers = AgoraHTTPManager.headers(withUId: config.userUuid, userToken: "", token: config.token)

        var nextId: Int = startId
        for key in self.msgsIdMapping.keys {
            if self.msgsIdMapping[key] == startId {
                nextId = key
            }
        }
        nextId = sort == 0 ? nextId - 1 : nextId + 1
        
        var parameters = ["sort": sort, "nextId": nextId, "count": 100]
        if nextId <= 0 {
            parameters = ["sort": sort, "count": 100]
        }
        AgoraHTTPManager.fetchDispatch(.get, url: url, parameters: parameters, headers: headers, parseClass: AgoraChatMessageModel.self) {[weak self] (any) in
            
            guard let `self` = self else {
                return
            }
            
            var kitChatInfos = [AgoraEduContextChatInfo]()
            if let model = any as? AgoraChatMessageModel, let list = model.data?.list {
                for info in list {
                    if let chatInfo = self.kitChatInfo(info) {
                        kitChatInfos.append(chatInfo)
                    }
                }
                self.chatInfos.insert(contentsOf: kitChatInfos.reversed(), at: 0)
                successBlock(kitChatInfos)
            } else {
//                failureBlock("network error")
            }
            
        } failure: {[weak self] (error, code) in
            if let `self` = self {
                failureBlock(self.kitError(error))
            }
        }
    }
}

// MARK: Private
extension AgoraChatVM {
    
    fileprivate func kitChatInfo(_ model: AgoraChatMessageInfoModel) -> AgoraEduContextChatInfo? {
        
        let user = AgoraEduContextUserInfo()
        if let fromUser = model.fromUser {
            user.role = AgoraEduContextUserRole(rawValue: fromUser.role.rawValue) ?? .student
            user.userUuid = fromUser.userUuid
            user.userName = fromUser.userName
        }
        let form: AgoraEduContextChatFrom = (user.userUuid == self.config.userUuid) ? .local : .remote

        let msg = model.message
//        if ((fromUser.role == AgoraRTERoleTypeTeacher || textMessage.fromUser.role == AgoraRTERoleTypeAssistant) && textMessage.sensitiveWords != nil) {
//            for (NSString *sensitiveWord in textMessage.sensitiveWords) {
//
//                NSString *replaceString = @"";
//                for (NSInteger index = 0; index < sensitiveWord.length; index++) {
//                    replaceString = [NSString stringWithFormat:@"%@*", replaceString];
//                }
//                msg = [msg stringByReplacingOccurrencesOfString:sensitiveWord withString:replaceString];
//            }
//        }
        
        let chatInfo = AgoraEduContextChatInfo()
        chatInfo.id = self.msgsIdMapping[model.messageId] ?? model.messageId
        chatInfo.message = msg
        chatInfo.user = user
        chatInfo.sendState = .success
        chatInfo.type = AgoraEduContextChatType(rawValue: model.type.rawValue) ?? .text
        chatInfo.time = model.sendTime
        chatInfo.from = form
        
        return chatInfo
    }
}

// MARK: TipMessage
extension AgoraChatVM {
    public func getRoomChatTipMessage(_ muteChat: Bool) -> String? {
        let toastMsg = muteChat ? localizedString("ChatDisableToastText") : localizedString("ChatEnableToastText")
        return toastMsg
    }
}
