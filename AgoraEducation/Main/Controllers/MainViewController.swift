//
//  MainViewController.swift
//  AgoraEducation
//
//  Created by LYY on 2021/4/16.
//  Copyright © 2021 Agora. All rights reserved.
//

import Foundation
import UIKit
import AgoraEduSDK
import AgoraUIEduBaseViews

@objc public class MainViewController: UINavigationController {
    private var alertView: AgoraAlertView?
    
    public override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        self.view.backgroundColor = UIColor.white
    }
    
    public override init(nibName nibNameOrNil: String?,
                         bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil,
                   bundle: nibBundleOrNil)
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarHidden(true,
                                    animated: false)
    }
    
    public override func viewDidLoad() {
        let eyeCare = UserDefaults.standard.bool(forKey: LoginConfig.USER_DEFAULT_EYE_CARE)
        let defaultConfig = AgoraEduSDKConfig.init(appId: KeyCenter.appId(),
                                                   eyeCare: eyeCare)
        AgoraClassroomSDK.setConfig(defaultConfig)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override var shouldAutorotate: Bool {
        return self.topViewController?.shouldAutorotate ?? true
    }
    
    public override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return self.topViewController?.preferredInterfaceOrientationForPresentation ?? .landscapeRight
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return self.topViewController?.supportedInterfaceOrientations ?? .landscapeRight
    }
    
    public override var prefersStatusBarHidden: Bool{
        return true
    }
}
