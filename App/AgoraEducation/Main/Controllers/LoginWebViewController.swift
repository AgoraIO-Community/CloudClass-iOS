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
                return
            }
            let vc = LoginWebViewController()
            vc.modalPresentationStyle = .fullScreen
            vc.onComplete = complete
            vc.urlStr = redirectURL
            root.present(vc, animated: true)
        } onFailure: { msg in
            AgoraLoading.hide()
            AgoraToast.toast(message: msg,
                             type: .error)
        }
    }
    
    private var webView = WKWebView()
    
    private var urlStr: String?
    
    private var onComplete: (() -> Void)?
    
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
            decisionHandler(.cancel)
            dismiss(animated: true, completion: onComplete)
        } else {
            decisionHandler(.allow)
        }
    }
}
