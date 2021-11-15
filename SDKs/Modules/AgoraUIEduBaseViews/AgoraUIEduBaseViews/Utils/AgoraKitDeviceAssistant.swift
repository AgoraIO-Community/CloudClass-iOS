//
//  DeviceAssistant.swift
//  Center
//
//  Created by CavanSu on 2020/2/13.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit

public struct AgoraKitDeviceAssistant {
    public static var owner: String {
        #if os(iOS)
        return UIDevice.current.name
        #else
        var owner = ""
        if let name = Host.current().localizedName {
            owner = name
        }
        return owner
        #endif
    }
    
    public struct OS {
        public static var name: String {
            #if os(iOS)
            return "iOS"
            #else
            return "Mac"
            #endif
        }
        
        public static var version: String {
            #if os(iOS)
            return UIDevice.current.systemVersion
            #else
            let systemVersion = ProcessInfo.processInfo.operatingSystemVersion
            let osVersion = "\(systemVersion.majorVersion).\(systemVersion.minorVersion).\(systemVersion.patchVersion)"
            return osVersion
            #endif
        }
        
        public static var isPad: Bool {
            #if os(iOS)
            return UIDevice.current.userInterfaceIdiom == .pad
            #else
            return false
            #endif
        }
        
        public static var hasSafeArea: Bool {
            #if os(iOS)
            if #available(iOS 11.0, *) {
                if let safeAreaInsets = UIApplication.shared.keyWindow?.safeAreaInsets {
                    return safeAreaInsets.left > 0.0 ||
                    safeAreaInsets.top > 0.0 ||
                    safeAreaInsets.right > 0.0 ||
                    safeAreaInsets.bottom > 0.0
                }
            }
            return false
            #else
            return false
            #endif
        }
    }
    
    public struct Language {
        public static var isChinese: Bool {
            if let language = Bundle.main.preferredLocalizations.first,
                language == "zh-Hans" {
                return true
            } else {
                return false
            }
        }
    }
}
