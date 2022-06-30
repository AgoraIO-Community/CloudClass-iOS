//
//  TokenBuilder.swift
//  AgoraEducation
//
//  Created by ZYP on 2021/10/19.
//  Copyright © 2021 Agora. All rights reserved.
//

import Foundation
import Armin

class TokenBuilder {
    enum Environment {
        case dev, pre, pro
    }
    
    enum Region {
        case cn, na, eu, ap
    }
    
    typealias FailureCompletion = (Error) -> ()
    typealias SuccessCompletion = (ServerResp) -> ()
    
    private let armin = Armin()
    
    func buildByAppId(_ appId: String,
                      appCertificate: String,
                      userUuid: String) -> String {
        return RtmTokenTool.token(appId,
                                  appCertificate: appCertificate,
                                  uid: userUuid)
    }
    
    func buildByServer(environment: Environment,
                       region: Region,
                       roomId: String,
                       userId: String,
                       userRole: Int,
                       success: @escaping SuccessCompletion,
                       failure: @escaping FailureCompletion) {
        var host: String
        
        switch environment {
        case .dev:
            host = "https://api-solutions-dev.bj2.agoralab.co"
        case .pre:
            host = "https://api-solutions-pre.bj2.agoralab.co"
        case .pro:
            switch region {
            case .cn:
                host = "https://api-solutions.bj2.agoralab.co"
            case .na:
                host = "https://api-solutions.sv3sbm.agoralab.co"
            case .eu:
                host = "https://api-solutions.fr3sbm.agoralab.co"
            case .ap:
                host = "https://api-solutions.sg3sbm.agoralab.co"
            }
        }
                
        let url = host + "/edu/v3/rooms/\(roomId)/roles/\(userRole)/users/\(userId)/token"
        let event = ArRequestEvent(name: "TokenBuilder buildByServer")
        let type = ArRequestType.http(.get,
                                      url: url)
        let task = ArRequestTask(event: event,
                                 type: type)
        armin.request(task: task,
                      responseOnMainQueue: true,
                      success: .json({ dict in
                        guard let data = dict["data"] as? [String : Any] else {
                            fatalError("TokenBuilder buildByServer can not find data, dict: \(dict)")
                        }
                        guard let token = data["token"] as? String,
                              let appId = data["appId"] as? String,
                              let userId = data["userUuid"] as? String else {
                            fatalError("TokenBuilder buildByServer can not find value, dict: \(dict)")
                        }
                        let resp = ServerResp(appId: appId,
                                              userId: userId,
                                              token: token)
                        success(resp)
                      }), failRetry: { error in
                        failure(error)
                        return .resign
                      })
    }
}

extension TokenBuilder {
    struct ServerResp {
        let appId: String
        let userId: String
        let token: String
    }
}
