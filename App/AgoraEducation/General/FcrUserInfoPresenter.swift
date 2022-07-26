//
//  FcrUserInfoPresenter.swift
//  AgoraEducation
//
//  Created by Jonathan on 2022/6/30.
//  Copyright © 2022 Agora. All rights reserved.
//

import UIKit
import WebKit

class FcrUserInfoPresenter {
    
    private let kAccessToken = "com.agora.accessToken"
    private let kRefreshToken = "com.agora.refreshToken"
    private let kNickName = "com.agora.nickname"
    private let kTheme = "com.agora.theme"
    private let kQAMode = "com.agora.qaMode"
    
    static let shared = FcrUserInfoPresenter()
    
    public func logout(complete: (() -> Void)?) {
        let websiteDataTypes = WKWebsiteDataStore.allWebsiteDataTypes()
        let fromDate = Date(timeIntervalSince1970: 0)
        WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes,
                                                modifiedSince: fromDate) {
            UserDefaults.standard.set(nil,
                                      forKey: self.kAccessToken)
            UserDefaults.standard.set(nil,
                                      forKey: self.kRefreshToken)
            UserDefaults.standard.set(nil,
                                      forKey: self.kNickName)
            complete?()
        }
    }
    // 是否登录
    public var isLogin: Bool {
        get {
            if let saved = UserDefaults.standard.object(forKey: kAccessToken) as? String {
                return !saved.isEmpty
            } else {
                return false
            }
        }
    }
    // login token
    public var accessToken: String {
        set {
            UserDefaults.standard.set("Bearer " + newValue, forKey:kAccessToken)
        }
        get {
            let saved = UserDefaults.standard.object(forKey: kAccessToken) as? String
            return saved ?? ""
        }
    }
    // refresh token
    public var refreshToken: String {
        set {
            UserDefaults.standard.set(newValue, forKey: kRefreshToken)
        }
        get {
            let saved = UserDefaults.standard.object(forKey: kRefreshToken) as? String
            return saved ?? ""
        }
    }
    // 昵称设置
    public var nickName: String {
        set {
            UserDefaults.standard.set(newValue, forKey: kNickName)
        }
        get {
            let saved = UserDefaults.standard.object(forKey: kNickName) as? String
            return saved ?? ""
        }
    }
    
    // Theme
    public var theme: Int {
        set {
            UserDefaults.standard.set(newValue, forKey: kTheme)
        }
        get {
            let saved = UserDefaults.standard.object(forKey: kTheme) as? Int
            return saved ?? 0
        }
    }
    // QA Mode
    public var qaMode: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: kQAMode)
        }
        get {
            let saved = UserDefaults.standard.object(forKey: kQAMode) as? Bool
            return saved ?? false
        }
    }
}
