//
//  LoginWebViewController.swift
//  AgoraEducation
//
//  Created by Jonathan on 2022/7/11.
//  Copyright © 2022 Agora. All rights reserved.
//
import AgoraUIBaseViews
import AgoraEduUI
import WebKit
import UIKit

class LoginWebViewController: FcrOutsideClassBaseController {
    
    private var webView = WKWebView()
    
    public var urlStr: String?
    
    public var onComplete: (() -> Void)?
    
    private var debugButton = UIButton(type: .custom)
    
    private var debugCount: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self
        view.addSubview(webView)
        webView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
        if let urlStr = urlStr {
            let myURL = URL(string:urlStr)
            let myRequest = URLRequest(url: myURL!)
            webView.load(myRequest)
        }
        
        debugButton.backgroundColor = .clear
        debugButton.addTarget(self,
                              action: #selector(onTouchDebug),
                              for: .touchUpInside)
        view.addSubview(debugButton)
        
        debugButton.mas_makeConstraints { make in
            make?.height.equalTo()(60)
            make?.width.equalTo()(40)
            make?.left.bottom().equalTo()(0)
        }
    }
    
    @objc func onTouchDebug() {
        guard debugCount >= 10 else {
            debugCount += 1
            return
        }
        FcrUserInfoPresenter.shared.qaMode = true
        dismiss(animated: true)
    }
    
    func fetchUserInfo() {
        AgoraLoading.loading()
        FcrOutsideClassAPI.fetchUserInfo { rsp in
            AgoraLoading.hide()
            guard let data = rsp["data"] as? [String: Any] else {
                return
            }
            if let companyId = data["companyId"] as? String {
                FcrUserInfoPresenter.shared.companyId = companyId
            }
            if let displayName = data["displayName"] as? String {
                FcrUserInfoPresenter.shared.nickName = displayName
            }
            self.dismiss(animated: true,
                         completion: self.onComplete)
        } onFailure: { code, msg in
            AgoraLoading.hide()
            self.dismiss(animated: true,
                         completion: self.onComplete)
        }
    }
}
// MARK: - WKNavigationDelegate
extension LoginWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView,
                 didStartProvisionalNavigation navigation: WKNavigation!) {
        print("login web view start load")
    }
    
    func webView(_ webView: WKWebView,
                 didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        
    }
    
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationResponse: WKNavigationResponse,
                 decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        guard let url = navigationResponse.response.url?.absoluteURL,
              let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems else {
            decisionHandler(.allow)
            return
        }
        if queryItems.contains(where: {$0.name == "accessToken"}),
           queryItems.contains(where: {$0.name == "refreshToken"}) {
            // 获取登录结果
            queryItems.forEach { item in
                if item.name == "accessToken",
                   let accessToken = item.value {
                    FcrUserInfoPresenter.shared.accessToken = accessToken
                } else if item.name == "refreshToken",
                          let refreshToken = item.value {
                    FcrUserInfoPresenter.shared.refreshToken = refreshToken
                }
            }
            fetchUserInfo()
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}
