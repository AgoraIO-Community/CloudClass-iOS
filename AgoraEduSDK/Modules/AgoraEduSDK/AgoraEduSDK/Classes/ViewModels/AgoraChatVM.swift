//
//  AgoraChatVM.swift
//  AgoraEduSDK
//
//  Created by SRS on 2021/3/14.
//

import Foundation
import AgoraUIEduBaseViews
import AgoraEduSDK.AgoraEduSDKFiles
import AgoraEduContext
import EduSDK

@objc public enum AgoraChatMode: Int {
    case room, conversation
}

@objcMembers public class AgoraChatVM: AgoraBaseVM {
    
    // ServerId:LocalId
    fileprivate var msgsIdMapping = [String : String]()
    fileprivate var chatInfos: [AgoraEduContextChatInfo] = []
    fileprivate var conversationInfos: [AgoraEduContextChatInfo] = []

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
        
        var messageId = "0"
        if rteMessage.peerMessageId != nil {
            messageId = rteMessage.peerMessageId
        } else {
            messageId = "\(rteMessage.messageId)"
        }
        
        if let id = self.msgsIdMapping[messageId] {
            chatInfo.id = id
        } else {
            chatInfo.id = messageId
        }
    
        chatInfo.message = rteMessage.message
        chatInfo.user = user
        chatInfo.sendState = .success
        chatInfo.type = AgoraEduContextChatType(rawValue: rteMessage.type) ?? .text
        chatInfo.time = Int64(rteMessage.timestamp)
        chatInfo.from = form
        
        return chatInfo
    }
    
    // MARK: 单禁言
    public func updateUserChat(_ rteUser: AgoraRTEUser,
                                    cause: Any?,
                                    completeBlock: @escaping (_ muteChat: Bool, _ toUser: AgoraEduContextUserInfo, _ byUser:AgoraEduContextUserInfo) -> Void) {
        guard let `cause` = cause as? Dictionary<String, Any>,
              (cause["cmd"] as? Int ?? 0) == AgoraCauseType.peerChatEnable.rawValue,
              let data = cause["data"] as? Dictionary<String, Any> else {
            return
        }
        
        AgoraEduManager.share().roomManager?.getFullUserList(success: { [weak self] (rteUsers) in
            
            guard let `self` = self else {
                return
            }
            
            let muteChat = (data["muteChat"] as? Int) ?? 0
            
            let toUser = self.kitUserInfo(rteUser)
            
            var byUser: AgoraEduContextUserInfo?
            if let teacher = rteUsers.first(where: {$0.role == .teacher}) {
                byUser = self.kitUserInfo(teacher)
            } else {
                let rteTeacher = AgoraRTEBaseUser(userUuid: "")
                rteTeacher.role = .invalid
                rteTeacher.userName = ""
                byUser = self.kitUserInfo(rteTeacher)
            }

            completeBlock(muteChat == 1, toUser, byUser!)
            
        }, failure: { (error) in
            
        })
    }
}

extension AgoraChatVM {
    fileprivate func extractedFunc() -> AgoraEduContextChatInfo {
        return AgoraEduContextChatInfo()
    }
    
    @discardableResult public func sendMessage(_ message: String,
                                               messageId: String,
                                               mode: AgoraChatMode,
                                               successBlock: @escaping (_ info: AgoraEduContextChatInfo) -> Void,
                                               failureBlock: @escaping (_ error: AgoraEduContextError, _ info: AgoraEduContextChatInfo) -> Void) -> AgoraEduContextChatInfo {
        
        var kitChatInfo: AgoraEduContextChatInfo!
        for chatInfo in self.chatInfos {
            if chatInfo.id == messageId {
                chatInfo.sendState = .inProgress
                kitChatInfo = chatInfo
                break
            }
        }
        
        let sendTime = Int64(Date().timeIntervalSince1970)
        if kitChatInfo == nil {
            let kitInfo = extractedFunc()
            kitInfo.id = "\(sendTime)"
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
        
        if mode == .room {
            AgoraHTTPManager.roomChat(withConfig: chatConfig) {[weak self] (model) in
                kitChatInfo.sendState = .success
                self?.msgsIdMapping["\(model.messageId)"] = kitChatInfo.id
                successBlock(kitChatInfo)
            } failure: {[weak self] (error, code) in
                if let `self` = self {
                    kitChatInfo.sendState = .failure
                    failureBlock(self.kitError(error), kitChatInfo)
                }
            }
        } else {
            AgoraHTTPManager.conversationChat(withConfig: chatConfig) {[weak self] (model) in
                kitChatInfo.sendState = .success
                self?.msgsIdMapping[model.peerMessageId] = kitChatInfo.id
                successBlock(kitChatInfo)
            } failure: {[weak self] (error, code) in
                if let `self` = self {
                    kitChatInfo.sendState = .failure
                    failureBlock(self.kitError(error), kitChatInfo)
                }
            }
        }
        
        return kitChatInfo
    }
    
    @discardableResult public func resendMessage(_ message: String,
                                                 messageId: String,
                                                 mode: AgoraChatMode,
                                                 successBlock: @escaping (_ info: AgoraEduContextChatInfo) -> Void,
                                                 failureBlock: @escaping (_ error: AgoraEduContextError, _ info: AgoraEduContextChatInfo) -> Void) -> AgoraEduContextChatInfo {
        return self.sendMessage(message,
                                messageId: messageId,
                                mode: mode,
                                successBlock: successBlock,
                                failureBlock: failureBlock)
    }
    
    public func fetchHistoryMessages(_ startId: String,
                                     count: Int,
                                     sort:Int = 0,
                                     mode: AgoraChatMode,
                                     successBlock: @escaping (_ models: [AgoraEduContextChatInfo]) -> Void,
                                     failureBlock: @escaping (_ error: AgoraEduContextError) -> Void) {
        let baseURL = AgoraHTTPManager.getBaseURL()
        var url = ""
        let headers = AgoraHTTPManager.headers(withUId: config.userUuid, userToken: "", token: config.token)
        var parameters = [String: Any]()
        
        if mode == .room {
            url = "\(baseURL)/edu/apps/\(config.appId)/v2/rooms/\(config.roomUuid)/chat/messages"
            
            var nextId = Int(startId) ?? 0
            for key in self.msgsIdMapping.keys {
                if self.msgsIdMapping[key] == startId {
                    nextId = Int(key) ?? 0
                }
            }
            nextId = sort == 0 ? nextId - 1 : nextId + 1
            
            parameters = ["sort": sort, "nextId": nextId, "count": 100]
            if nextId <= 0 {
                parameters = ["sort": sort, "count": 100]
            }
            
        } else {
            url = "\(baseURL)/edu/apps/\(config.appId)/v2/rooms/\(config.roomUuid)/conversation/students/\(config.userUuid)/messages"
            
            parameters = ["sort": sort, "nextId": startId, "count": 100]
            if startId.count == 0 || startId == "0" {
                parameters = ["sort": sort, "count": 100]
            }
        }
        
        AgoraHTTPManager.fetchDispatch(.get,
                                       url: url,
                                       parameters: parameters,
                                       headers: headers,
                                       parseClass: AgoraChatMessageModel.self) { [weak self] (any) in
            guard let `self` = self else {
                return
            }
            
            var kitChatInfos = [AgoraEduContextChatInfo]()
            if let model = any as? AgoraChatMessageModel,
               let list = model.data?.list {
                for info in list {
                    if let chatInfo = self.kitChatInfo(info) {
                        kitChatInfos.append(chatInfo)
                    }
                }
                
                if mode == .room {
                    self.chatInfos.insert(contentsOf: kitChatInfos.reversed(), at: 0)
                } else {
                    self.conversationInfos.insert(contentsOf: kitChatInfos.reversed(), at: 0)
                }
                
                
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
        if model.peerMessageId != nil && model.peerMessageId.count > 0 {
            chatInfo.id = model.peerMessageId
        } else {
            chatInfo.id = "\(model.messageId)"
        }
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
