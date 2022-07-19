//
//  LoginWebViewController.swift
//  AgoraEducation
//
//  Created by Jonathan on 2022/7/11.
//  Copyright © 2022 Agora. All rights reserved.
//

import AgoraUIBaseViews
import AgoraEduUI
import UIKit
import WebKit

class LoginWebViewController: UIViewController {
    
    public static func showLoginIfNot(complete: (() -> Void)?) {
        guard FcrUserInfoPresenter.shared.isLogin == false else {
            complete?()
            return
        }
        AgoraLoading.loading()
        FcrOutsideClassAPI.getAuthWebPage { dict in
            AgoraLoading.hide()
            guard let redirectURL = dict["data"] as? String,
                  let root = UIApplication.shared.keyWindow?.rootViewController
            else {
                AgoraToast.toast(msg: "")
                return
            }
            let vc = LoginWebViewController()
            vc.modalPresentationStyle = .fullScreen
            vc.onComplete = complete
            vc.urlStr = redirectURL
            root.present(vc, animated: true)
        } onFailure: { msg in
            AgoraLoading.hide()
            AgoraToast.toast(msg: msg)
        }
    }
    
    private var webView = WKWebView()
    
    private var urlStr: String?
    
    private var onComplete: (() -> Void)?

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
        if queryItems.contains(where: {$0.name == "refresh_token"}),
           queryItems.contains(where: {$0.name == "access_token"}) {
            // 获取登录结果
            queryItems.forEach { item in
                if item.name == "access_token",
                   let accessToken = item.value {
                    FcrUserInfoPresenter.shared.accessToken = accessToken
                } else if item.name == "refresh_token",
                          let refreshToken = item.value {
                    FcrUserInfoPresenter.shared.refreshToken = refreshToken
                }
            }
            decisionHandler(.cancel)
            dismiss(animated: true, completion: onComplete)
        } else {
            decisionHandler(.allow)
        }
    }
}
