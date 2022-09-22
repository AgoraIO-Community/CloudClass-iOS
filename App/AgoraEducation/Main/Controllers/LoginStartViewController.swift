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
    
    private let textView = UIImageView(image: UIImage(named: "fcr_room_list_login_text"))
    
    private let haloView = UIImageView(image: UIImage(named: "fcr_room_list_login_halo"))
    
    private let startButton = UIButton(type: .custom)
    
    private var onComplete: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        createViews()
        createConstrains()
        createAnimation()
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
        } onFailure: { msg in
            AgoraLoading.hide()
            AgoraToast.toast(message: msg,
                             type: .error)
        }
    }
}
// MARK: - Creation
private extension LoginStartViewController {
    func createViews() {
        view.addSubview(haloView)
        
        view.addSubview(textView)
        
        startButton.setBackgroundImage(UIImage(named: "fcr_room_list_get_start"),
                                       for: .normal)
        startButton.addTarget(self,
                              action: #selector(onClickStart),
                              for: .touchUpInside)
        view.addSubview(startButton)
    }
    
    func createConstrains() {
        textView.mas_makeConstraints { make in
            make?.left.equalTo()(32)
            make?.centerY.equalTo()(0)
        }
        startButton.mas_makeConstraints { make in
            make?.left.equalTo()(32)
            make?.bottom.equalTo()(-163)
            make?.width.equalTo()(190)
            make?.height.equalTo()(52)
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
        haloView.layer.add(animation, forKey: "com.agora.halo")
    }
}

