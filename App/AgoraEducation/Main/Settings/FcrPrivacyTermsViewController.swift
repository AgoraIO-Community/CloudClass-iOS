//
//  FcrPrivacyTermsViewController.swift
//  AgoraEducation
//
//  Created by Jonathan on 2022/7/14.
//  Copyright © 2022 Agora. All rights reserved.
//

import UIKit
import WebKit

fileprivate let kAgree = "com.agora.privacyTermsAgree"
class FcrPrivacyTermsViewController: FcrOutsideClassBaseController {
    
    public static func checkPrivacyTerms(complete: (() -> Void)?) {
        guard let root = UIApplication.shared.keyWindow?.rootViewController else {
            return
        }
        if let agree = UserDefaults.standard.object(forKey: kAgree) as? Bool,
           agree == true {
            complete?()
        } else {
            let vc = FcrPrivacyTermsViewController()
            vc.modalPresentationStyle = .fullScreen
            vc.onComplete = complete
            root.present(vc, animated: true)
        }
    }
    
    /**views**/
    private lazy var termTitle = UILabel()
    private lazy var contentView = WKWebView(frame: .zero)
    private lazy var agreementView = AgreementView(frame: .zero)
    
    private var onComplete: (() -> Void)?
    
    private var haveAgreed = false {
        didSet {
            let image = haveAgreed ? UIImage(named: "checkBox_checked") : UIImage(named: "checkBox_unchecked")
            agreementView.checkButton.setImage(image,
                                               for: .normal)
            agreementView.agreeButton.isEnabled = haveAgreed
            agreementView.agreeButton.backgroundColor = haveAgreed ? UIColor(hex: 0x357BF6) : UIColor(hex: 0xC0D6FF)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
        initLayout()
    }
}

private extension FcrPrivacyTermsViewController {
   
    func initViews() {
        view.backgroundColor = .white
        
        termTitle.text = "Service_title".ag_localized()
        termTitle.textColor = .black
        termTitle.font = .boldSystemFont(ofSize: 14)
        view.addSubview(termTitle)
        
        loadUrl()
        contentView.uiDelegate = self
        view.addSubview(contentView)
        
        let image = haveAgreed ? UIImage(named: "checkBox_checked") : UIImage(named: "checkBox_unchecked")
        agreementView.checkButton.setImage(image,
                                           for: .normal)
        agreementView.checkButton.addTarget(self,
                                            action: #selector(onClickRead(_:)),
                                            for: .touchUpInside)
        
        agreementView.agreeButton.isEnabled = haveAgreed
        agreementView.agreeButton.backgroundColor = haveAgreed ? UIColor(hex: 0x357BF6) : UIColor(hex: 0xC0D6FF)
        agreementView.agreeButton.addTarget(self,
                                            action: #selector(onClickAgree(_:)),
                                            for: .touchUpInside)
        agreementView.disagreeButton.addTarget(self,
                                               action: #selector(onClickDisagree(_:)),
                                               for: .touchUpInside)
        view.addSubview(agreementView)
    }
    
    func initLayout() {
        termTitle.mas_makeConstraints { make in
            make?.top.equalTo()(48)
            make?.centerX.equalTo()(0)
        }
        agreementView.mas_makeConstraints { make in
            make?.left.right().bottom().equalTo()(0)
            make?.height.equalTo()(180)
        }
        contentView.mas_makeConstraints { make in
            make?.top.equalTo()(termTitle.mas_bottom)?.offset()(20)
            make?.left.equalTo()(20)
            make?.right.equalTo()(-20)
            make?.bottom.equalTo()(agreementView.mas_top)?.offset()(10)
        }
    }
    
    func loadUrl() {
        var urlString = ""
        if UIDevice.current.agora_is_chinese_language {
            urlString = "https://agora-adc-artifacts.s3.cn-north-1.amazonaws.com.cn/demo/education/privacy.html"
        } else {
            urlString = "https://agora-adc-artifacts.s3.cn-north-1.amazonaws.com.cn/demo/education/privacy_en.html"
        }
        if let urlRequest = URLRequest(urlString: urlString) {
            contentView.load(urlRequest)
        }
    }
    
    @objc func onClickRead(_ sender: Any) {
        haveAgreed.toggle()
    }
    
    @objc func onClickAgree(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: kAgree)
        self.dismiss(animated: true, completion: self.onComplete)
    }
    
    @objc func onClickDisagree(_ sender: UIButton) {
        exit(0)
    }
}

extension FcrPrivacyTermsViewController: WKUIDelegate {
    public func webView(_ webView: WKWebView,
                        createWebViewWith configuration: WKWebViewConfiguration,
                        for navigationAction: WKNavigationAction,
                        windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let targetFrame = navigationAction.targetFrame,
           !targetFrame.isMainFrame {
            webView.load(navigationAction.request)
        }
        return nil
    }
}

