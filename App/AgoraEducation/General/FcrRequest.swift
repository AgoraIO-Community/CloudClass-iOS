//
//  FcrRequest.swift
//  AgoraEducation
//
//  Created by Jonathan on 2022/7/7.
//  Copyright © 2022 Agora. All rights reserved.
//

import UIKit
import Armin

class FcrOutsideClassAPI {
    /** 获取用户基本信息*/
    static func fetchUserInfo(onSuccess: (([String: Any]) -> Void)?,
                              onFailure: ((String) -> Void)?) {
        let url = FcrEnvironment.shared.server + "/sso/v2/users/info"
        let event = ArRequestEvent(name: "FcrOutsideClassAPI buildToken")
        let type = ArRequestType.http(.get,
                                      url: url)
        let accessToken = FcrUserInfoPresenter.shared.accessToken
        let task = ArRequestTask(event: event,
                                 type: type,
                                 header: ["Authorization": accessToken])
        FcrRequest(task: task,
                   onSuccess: onSuccess,
                   onFailure: onFailure).sendRequest()
    }
    
    /** free buildToken
     */
    static func freeBuildToken(roomId: String,
                               userRole: Int,
                               userId: String,
                               onSuccess: (([String: Any]) -> Void)?,
                               onFailure: ((String) -> Void)?) {
        let url = FcrEnvironment.shared.server + "/edu/v3/rooms/\(roomId)/roles/\(userRole)/users/\(userId)/token"
        let event = ArRequestEvent(name: "FcrOutsideClassAPI buildToken")
        let type = ArRequestType.http(.get,
                                      url: url)
        let task = ArRequestTask(event: event,
                                 type: type)
        FcrRequest(task: task,
                   onSuccess: onSuccess,
                   onFailure: onFailure).sendRequest()
    }
    /** 服务端buildToken
     */
    static func buildToken(roomId: String,
                           userRole: Int,
                           userId: String,
                           onSuccess: (([String: Any]) -> Void)?,
                           onFailure: ((String) -> Void)?) {
        let url = FcrEnvironment.shared.server + "/edu/v4/rooms/\(roomId)/roles/\(userRole)/users/\(userId)/token"
        let event = ArRequestEvent(name: "FcrOutsideClassAPI buildToken")
        let type = ArRequestType.http(.get,
                                      url: url)
        let accessToken = FcrUserInfoPresenter.shared.accessToken
        let task = ArRequestTask(event: event,
                                 type: type,
                                 header: ["Authorization": accessToken])
        FcrRequest(task: task,
                   onSuccess: onSuccess,
                   onFailure: onFailure).sendRequest()
    }
    /** 从服务端获取授权地址
     */
    static func getAuthWebPage(onSuccess: (([String: Any]) -> Void)?,
                               onFailure: ((String) -> Void)?) {
        let url = FcrEnvironment.shared.server + "/sso/v2/users/oauth/redirectUrl"
        let event = ArRequestEvent(name: "FcrOutsideClassAPI getAuthWebPage")
        let type = ArRequestType.http(.post,
                                      url: url)
        let params = ["redirectUrl": "https://sso2.agora.io/",
                      "toRegion": FcrEnvironment.shared.region.rawValue]
        let task = ArRequestTask(event: event,
                                 type: type,
                                 parameters: params)
        FcrRequest(task: task,
                   onSuccess: onSuccess,
                   onFailure: onFailure).sendRequest()
    }
    /** 刷新access_token
     */
    static func refreshToken(onSuccess: (([String: Any]) -> Void)?,
                             onFailure: ((String) -> Void)?) {
        let refreshToken = FcrUserInfoPresenter.shared.refreshToken
        if refreshToken.isEmpty {
            onFailure?("")
            // 全token失效
            FcrUserInfoPresenter.shared.logout {
                LoginWebViewController.showLoginIfNot(complete: nil)
            }
            return
        }
        let url = FcrEnvironment.shared.server + "/sso/v2/users/refresh/refreshToken/\(refreshToken)"
        let event = ArRequestEvent(name: "FcrOutsideClassAPI refreshToken")
        let type = ArRequestType.http(.post,
                                      url: url)
        let task = ArRequestTask(event: event,
                                 type: type)
        FcrRequest(task: task,
                   onSuccess: { dict in
            guard let data = dict["data"] as? [String: Any],
                  let accessToken = data["accessToken"] as? String,
                  let refreshToken = data["refreshToken"] as? String
            else {
                onFailure?("")
                return
            }
            FcrUserInfoPresenter.shared.accessToken = accessToken
            FcrUserInfoPresenter.shared.refreshToken = refreshToken
            onSuccess?(dict)
        }, onFailure: onFailure).sendRequest()
    }
}

fileprivate class FcrRequest {
    
    private let armin = Armin()
    
    private let task: ArRequestTask
    
    private var onSuccess: (([String: Any]) -> Void)?
    
    private var onFailure: ((String) -> Void)?
    
    init(task: ArRequestTask,
         onSuccess: (([String: Any]) -> Void)?,
         onFailure: ((String) -> Void)?) {
        self.task = task
        self.onSuccess = onSuccess
        self.onFailure = onFailure
    }
    
    func sendRequest() {
        armin.request(task: task,
                      responseOnMainQueue: true,
                      success: .json({ dict in
            self.onSuccess?(dict)
        }), failRetry: { error in
            guard let code = error.code else {
                return .resign
            }
            if code == 401 { // access token 失效
                FcrOutsideClassAPI.refreshToken { dict in
                    // 刷新token后重新发起请求
                    self.sendRequest()
                } onFailure: { msg in
                    self.onFailure?(msg)
                }
            } else if code == 400 { // 全token失效
                FcrUserInfoPresenter.shared.logout {
                    LoginWebViewController.showLoginIfNot(complete: nil)
                }
            } else {
                self.onFailure?(error.localizedDescription)
            }
            return .resign
        })
    }
}
