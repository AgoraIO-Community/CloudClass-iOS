//
//  AppDelegate.swift
//  AgoraBuilder
//
//  Created by Cavan on 2022/7/19.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    internal var window: UIWindow?
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow.init(frame: UIScreen.main.bounds)
        let scene = ViewController()
        window?.rootViewController = scene
        window?.makeKeyAndVisible()
        return true
    }
}

