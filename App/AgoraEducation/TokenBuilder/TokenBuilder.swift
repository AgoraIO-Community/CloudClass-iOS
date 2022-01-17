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
    
    func buildByServer(region: String,
                       userUuid: String,
                       environment: Environment,
                       success: @escaping SuccessCompletion,
                       failure: @escaping FailureCompletion) {
        var urlSubFirst: String
        
        switch environment {
        case .dev:
            urlSubFirst = "https://api-solutions-dev.bj2.agoralab.co/edu/v2/users"
        case .pre:
            urlSubFirst = "https://api-solutions-pre.bj2.agoralab.co/edu/v2/users"
        case .pro:
            switch region {
            case "CN":
                urlSubFirst = "https://api-solutions.bj2.agoralab.co/edu/v2/users"
            case "NA":
                urlSubFirst = "https://api-solutions.sv3sbm.agoralab.co/edu/v2/users"
            case "EU":
                urlSubFirst = "https://api-solutions.fr3sbm.agoralab.co/edu/v2/users"
            case "AP":
                urlSubFirst = "https://api-solutions.sg3sbm.agoralab.co/edu/v2/users"
            default:
                fatalError("buildByServer, not support region: \(region)")
            }
        }
                
        let urlString = urlSubFirst + "/\(userUuid)/token"
        let event = ArRequestEvent(name: "TokenBuilder buildByServer")
        let type = ArRequestType.http(.get,
                                      url: urlString)
        let task = ArRequestTask(event: event,
                                 type: type)
        armin.request(task: task,
                      responseOnMainQueue: true,
                      success: .json({ dict in
            guard let data = dict["data"] as? [String : Any] else {
                fatalError("TokenBuilder buildByServer can not find data, dict: \(dict)")
            }
            guard let rtmToken = data["rtmToken"] as? String,
                  let appId = data["appId"] as? String,
                  let userId = data["userUuid"] as? String else {
                      fatalError("TokenBuilder buildByServer can not find value, dict: \(dict)")
                  }
            let resp = ServerResp(appId: appId,
                                  userId: userId,
                                  rtmToken: rtmToken)
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
        let rtmToken: String
    }
}
