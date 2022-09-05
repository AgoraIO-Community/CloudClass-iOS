//
//  AppDelegate.swift
//  AgoraBuilder
//
//  Created by Cavan on 2022/7/19.
//

import UIKit
import AgoraInvigilatorSDK
import AgoraInvigilatorUI
import AgoraEduContext

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    internal var window: UIWindow?
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow.init(frame: UIScreen.main.bounds)
        window?.rootViewController = ViewController()
        window?.makeKeyAndVisible()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let config = AgoraInvigilatorLaunchConfig(userName: "111111",
                                                  userUuid: "111111",
                                                  userRole: .student,
                                                  roomName: "aaaaaa",
                                                  roomUuid: "aaaaaa",
                                                  roomType: .FcrUISceneTypeSmall,
                                                  appId: "aaaaaa",
                                                  token: "aaaaaa")
        AgoraInvigilatorSDK.launch(config) {
            print("success")
        } failure: { error in
            print("error")
        }
    }
}

