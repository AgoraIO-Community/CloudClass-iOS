//
//  AgoraChatPanelVM.swift
//  AgoraEduSDK
//
//  Created by SRS on 2021/2/1.
//

import Foundation
import AgoraEduSDK.AgoraFiles.AgoraHTTP

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

    // send
}

