//
//  AgoraChatPanelVM.swift
//  AgoraEduSDK
//
//  Created by SRS on 2021/2/1.
//

import Foundation
import AgoraEduSDK.AgoraFiles.AgoraHTTP
import AgoraEduSDK.AgoraFiles.AgoraManager

@objcMembers public class AgoraHTTPConfig: NSObject {
    public var appId: String = ""
    public var roomUuid: String = ""
    public var userUuid: String = ""
    public var userToken: String = ""
    public var token: String = ""
}

class AgoraChatPanelVM {
    
    fileprivate var httpConfig: AgoraHTTPConfig
    
    var nextId: Int?
    var sort: Int = 0
    
    var models: [AgoraChatMessageInfoModel] = []
    
    init(httpConfig: AgoraHTTPConfig) {
        self.httpConfig = httpConfig
    }
    
    // get list
    // sort 1正向 0逆向
    func getMessageList(sort:Int = 0, successBlock: @escaping (_ models: [AgoraChatMessageInfoModel]) -> Void, failureBlock: @escaping (_ errorMsg: String) -> Void) {
        
        let baseURL = AgoraHTTPManager.getBaseURL()
        let url = "\(baseURL)/edu/apps/\(httpConfig.appId)/v2/rooms/\(httpConfig.roomUuid)/chat/messages"

        let headers = AgoraHTTPManager.headers(withUId: httpConfig.userUuid, userToken: httpConfig.userToken, token: httpConfig.token)

        let parameters = (nextId == nil ? ["sort": sort] : ["sort": sort, "nextId": nextId])

        AgoraHTTPManager.fetchDispatch(.get, url: url, parameters: parameters, headers: headers, parseClass: AgoraChatMessageModel.self) {[weak self] (any) in
            
            guard let `self` = self else {
                return
            }
 
            if let model = any as? AgoraChatMessageModel {
                
                if model.code != 0 {
                    failureBlock(model.message)
                    return
                }
                self.nextId = model.data?.nextId
                
                model.data?.list.forEach({
                    $0.isSelf = ($0.fromUser?.userUuid == self.httpConfig.userUuid)
                })

                self.models.append(contentsOf: model.data?.list ?? [])
                successBlock(self.models)
                
            } else {
                failureBlock("network error")
            }
            
        } failure: { (error, code) in
            failureBlock(error.localizedDescription)
        }
    }
    
    func agoraChatMessageInfoModel(msg: String?, block:@escaping (AgoraChatMessageInfoModel?) -> Void) {
        
        if (msg == nil || msg?.count == 0) {
            return block(nil)
        }
        
        AgoraEduManager.share().roomManager?.getLocalUser(success: { (localUser) in
            
            let user = AgoraChatUserInfoModel()
            user.role = .student
            user.userName = localUser.userName
            user.userUuid = localUser.userUuid
            
            let model = AgoraChatMessageInfoModel()
            model.message = msg!
            model.type = .text
            model.fromUser = user
            model.isSelf = true
            block(model)
            
        }, failure: { (error) in
            block(nil)
        })
    }

    // send
    func sendMessage(model: AgoraChatMessageInfoModel?, successBlock: @escaping () -> Void, failureBlock: @escaping (_ errorMsg: String) -> Void) -> AgoraChatMessageInfoModel? {
        
        guard let messagModel = model else {
            return nil
        }

        messagModel.sendState = .loading
        self.models.append(messagModel)
        
        let chatConfig = AgoraRoomChatConfiguration()
        chatConfig.appId = self.httpConfig.appId
        chatConfig.roomUuid = self.httpConfig.roomUuid
        chatConfig.userUuid = self.httpConfig.userUuid
        chatConfig.userToken = self.httpConfig.userToken
        chatConfig.token = self.httpConfig.token
        chatConfig.type = 1
        chatConfig.message = messagModel.message
        AgoraHTTPManager.roomChat(withConfig: chatConfig) { (model) in
            messagModel.sendState = .success
//            messagModel.sendTime = 234ll
            
            successBlock()
            
        } failure: { (error, code) in
            messagModel.sendState = .failure
            failureBlock(error.localizedDescription)
        }

        return messagModel
    }
}

