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
    /** 查询课堂详情*/
    static func fetchRoomDetail(roomId: String,
                                onSuccess: (([String: Any]) -> Void)?,
                                onFailure: ((Int, String) -> Void)?) {
        let companyId = FcrUserInfoPresenter.shared.companyId
        let url = FcrEnvironment.shared.server + "/edu/companys/\(companyId)/v1/rooms/\(roomId)"
        let event = ArRequestEvent(name: "fetch room detail")
        let type = ArRequestType.http(.get,
                                      url: url)
        let task = ArRequestTask(event: event,
                                 type: type,
                                 header: ["Authorization": FcrUserInfoPresenter.shared.accessToken])
        FcrRequest(task: task,
                   onSuccess: onSuccess,
                   onFailure: onFailure).sendRequest()
    }
    /** 查询课堂列表*/
    static func fetchRoomList(nextId: String?,
                              count: UInt,
                              onSuccess: (([String: Any]) -> Void)?,
                              onFailure: ((Int, String) -> Void)?) {
        let companyId = FcrUserInfoPresenter.shared.companyId
        let url = FcrEnvironment.shared.server + "/edu/companys/\(companyId)/v1/rooms"
        let event = ArRequestEvent(name: "fetch room list")
        let type = ArRequestType.http(.get,
                                      url: url)
        var params: [String : Any] = ["count": count]
        if let v = nextId {
            params.updateValue(v, forKey: "nextId")
        }
        let task = ArRequestTask(event: event,
                                 type: type,
                                 header: ["Authorization": FcrUserInfoPresenter.shared.accessToken],
                                 parameters: params)
        FcrRequest(task: task,
                   onSuccess: onSuccess,
                   onFailure: onFailure).sendRequest()
    }
    /** 创建课堂*/
    static func createClassRoom(roomName: String,
                                roomType: Int,
                                startTime: UInt,
                                endTine: UInt,
                                roomProperties: [String: Any]?,
                                onSuccess: (([String: Any]) -> Void)?,
                                onFailure: ((Int, String) -> Void)?) {
        let companyId = FcrUserInfoPresenter.shared.companyId
        let url = FcrEnvironment.shared.server + "/edu/companys/\(companyId)/v1/rooms"
        let event = ArRequestEvent(name: "Create ClassRoom")
        let type = ArRequestType.http(.post,
                                      url: url)
        let params: [String : Any] = ["roomName": roomName,
                                      "roomType": roomType,
                                      "startTime": startTime,
                                      "endTime": endTine,
                                      "roomProperties": roomProperties ?? [:]]
        let task = ArRequestTask(event: event,
                                 type: type,
                                 header: ["Authorization": FcrUserInfoPresenter.shared.accessToken],
                                 parameters: params)
        FcrRequest(task: task,
                   onSuccess: onSuccess,
                   onFailure: onFailure).sendRequest()
    }
    /** 用户注销*/
    static func logoff(onSuccess: (([String: Any]) -> Void)?,
                       onFailure: ((Int, String) -> Void)?) {
        let url = FcrEnvironment.shared.server + "/sso/v2/users/auth"
        let event = ArRequestEvent(name: "FcrOutsideClassAPI buildToken")
        let type = ArRequestType.http(.delete,
                                      url: url)
        let accessToken = FcrUserInfoPresenter.shared.accessToken
        let task = ArRequestTask(event: event,
                                 type: type,
                                 header: ["Authorization": accessToken])
        FcrRequest(task: task,
                   onSuccess: onSuccess,
                   onFailure: onFailure).sendRequest()
    }
    /** 获取用户基本信息*/
    static func fetchUserInfo(onSuccess: (([String: Any]) -> Void)?,
                              onFailure: ((Int, String) -> Void)?) {
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
                               onFailure: ((Int, String) -> Void)?) {
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
    static func buildToken(roomUuid: String,
                           userRole: Int,
                           userId: String,
                           onSuccess: (([String: Any]) -> Void)?,
                           onFailure: ((Int, String) -> Void)?) {
        let url = FcrEnvironment.shared.server + "/edu/v4/rooms/\(roomUuid)/roles/\(userRole)/users/\(userId)/token"
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
                               onFailure: ((Int, String) -> Void)?) {
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
                             onFailure: ((Int, String) -> Void)?) {
        let refreshToken = FcrUserInfoPresenter.shared.refreshToken
        if refreshToken.isEmpty {
            onFailure?(0, "")
            // 全token失效
            FcrUserInfoPresenter.shared.logout {
                LoginStartViewController.showLoginIfNot(complete: nil)
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
                onFailure?(0, "")
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
    
    private var onFailure: ((Int, String) -> Void)?
    
    init(task: ArRequestTask,
         onSuccess: (([String: Any]) -> Void)?,
         onFailure: ((Int, String) -> Void)?) {
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
                } onFailure: { code, msg in
                    self.onFailure?(code, msg)
                }
            } else if code == 400 { // 全token失效
                self.onFailure?(0, "Access Denied")
                FcrUserInfoPresenter.shared.logout {
                    LoginStartViewController.showLoginIfNot(complete: nil)
                }
            } else {
                self.onFailure?(code, error.localizedDescription)
            }
            return .resign
        })
    }
}
