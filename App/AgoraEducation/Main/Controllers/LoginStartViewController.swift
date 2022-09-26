//
//  LoginStartViewController.swift
//  AgoraEducation
//
//  Created by Jonathan on 2022/9/21.
//  Copyright © 2022 Agora. All rights reserved.
//

import UIKit
import AgoraUIBaseViews

class LoginStartViewController: UIViewController {
    
    public static func showLoginIfNot(complete: (() -> Void)?) {
        guard FcrUserInfoPresenter.shared.isLogin == false,
              let root = UIApplication.shared.keyWindow?.rootViewController
        else {
            complete?()
            return
        }
        let vc = LoginStartViewController()
        vc.onComplete = complete
        let navi = FcrNavigationController(rootViewController: vc)
        navi.modalPresentationStyle = .fullScreen
        navi.modalTransitionStyle = .crossDissolve
        root.present(navi, animated: true)
    }
    private let logoView = UIImageView(image: UIImage(named: "fcr_login_logo_text_en"))
    
    private let imageView = UIImageView(image: UIImage(named: "fcr_login_center_afc"))
    
    private let textView = UIImageView(image: UIImage(named: "fcr_login_text_en"))
    
    private let haloView = UIImageView(image: UIImage(named: "fcr_login_halo"))
    
    private let afcView = UIImageView(image: UIImage(named: "fcr_login_corner_afc"))
    
    private let startButton = UIButton(type: .custom)
    
    private var onComplete: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        createViews()
        createConstrains()
        createAnimation()
        localizedImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true,
                                                     animated: true)
    }
    
    public override var shouldAutorotate: Bool {
        return true
    }
    
    public override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return UIDevice.current.agora_is_pad ? .landscapeRight : .portrait
    }

    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIDevice.current.agora_is_pad ? .landscapeRight : .portrait
    }
    
    @objc func onClickStart() {
        AgoraLoading.loading()
        FcrOutsideClassAPI.getAuthWebPage { dict in
            AgoraLoading.hide()
            guard let redirectURL = dict["data"] as? String else {
                return
            }
            let vc = LoginWebViewController()
            vc.modalPresentationStyle = .fullScreen
            vc.onComplete = self.onComplete
            vc.urlStr = redirectURL
            self.navigationController?.pushViewController(vc,
                                                          animated: true)
        } onFailure: { code, msg in
            AgoraLoading.hide()
            AgoraToast.toast(message: msg,
                             type: .error)
        }
    }
}
// MARK: - Creation
private extension LoginStartViewController {
    func createViews() {
        view.addSubview(imageView)
        view.addSubview(haloView)
        view.addSubview(logoView)
        view.addSubview(textView)
        view.addSubview(afcView)
        
        startButton.setBackgroundImage(UIImage(named: "fcr_login_get_start"),
                                       for: .normal)
        startButton.addTarget(self,
                              action: #selector(onClickStart),
                              for: .touchUpInside)
        view.addSubview(startButton)
    }
    
    func createConstrains() {
        logoView.mas_makeConstraints { make in
            make?.top.equalTo()(55)
            make?.left.equalTo()(29)
        }
        imageView.mas_makeConstraints { make in
            make?.top.equalTo()(logoView.mas_bottom)?.offset()(32)
            make?.left.equalTo()(32)
        }
        textView.mas_makeConstraints { make in
            make?.top.equalTo()(imageView.mas_bottom)?.offset()(36)
            make?.left.equalTo()(32)
        }
        startButton.mas_makeConstraints { make in
            make?.top.equalTo()(textView.mas_bottom)?.offset()(33)
            make?.left.equalTo()(32)
            make?.width.equalTo()(190)
            make?.height.equalTo()(52)
        }
        afcView.mas_makeConstraints { make in
            make?.left.equalTo()(34)
            make?.bottom.equalTo()(-30)
        }
    }
    
    func createAnimation() {
        guard let bounds = UIApplication.shared.keyWindow?.bounds else {
            return
        }
        let animation = CAKeyframeAnimation(keyPath: "position")
        let point0 = CGPoint(x: 20, y: 56)
        let point1 = CGPoint(x: bounds.maxX - 20, y: 0.3 * bounds.height)
        let point2 = CGPoint(x: 20, y: 0.6 * bounds.height)
        let point3 = CGPoint(x: bounds.maxX - 20, y: bounds.maxY - 20)
        animation.values = [
            NSValue(cgPoint: point0),
            NSValue(cgPoint: point1),
            NSValue(cgPoint: point2),
            NSValue(cgPoint: point3),
            NSValue(cgPoint: point2),
            NSValue(cgPoint: point1),
            NSValue(cgPoint: point0)
        ]
        animation.duration = 24
        animation.repeatCount = MAXFLOAT
        haloView.layer.add(animation,
                           forKey: "com.agora.halo")
    }
    
    func localizedImage() {
        if FcrLocalization.shared.language == .zh_cn {
            logoView.image = UIImage(named: "fcr_login_logo_text_zh")
            textView.image = UIImage(named: "fcr_login_text_zh")
        } else {
            logoView.image = UIImage(named: "fcr_login_logo_text_en")
            textView.image = UIImage(named: "fcr_login_text_en")
        }
    }
}

