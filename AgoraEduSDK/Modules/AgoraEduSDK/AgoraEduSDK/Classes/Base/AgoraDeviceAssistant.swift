//
//  DeviceAssistant.swift
//  Center
//
//  Created by CavanSu on 2020/2/13.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit

struct AgoraDeviceAssistant {
    static var owner: String {
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
    
    struct OS {
        static var name: String {
            #if os(iOS)
            return "iOS"
            #else
            return "Mac"
            #endif
        }
        
        static var version: String {
            #if os(iOS)
            return UIDevice.current.systemVersion
            #else
            let systemVersion = ProcessInfo.processInfo.operatingSystemVersion
            let osVersion = "\(systemVersion.majorVersion).\(systemVersion.minorVersion).\(systemVersion.patchVersion)"
            return osVersion
            #endif
        }
        
        static var isPad: Bool {
            #if os(iOS)
            return UIDevice.current.userInterfaceIdiom == .pad
            #else
            return false
            #endif
        }
    }
    
    struct Language {
        static var isChinese: Bool {
            if let language = Bundle.main.preferredLocalizations.first,
                language == "zh-Hans" {
                return true
            } else {
                return false
            }
        }
    }
}
