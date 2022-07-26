//
//  AgoraColorGroup.swift
//  AgoraEduUI
//
//  Created by Cavan on 2022/3/17.
//

import AgoraUIBaseViews
import UIKit

@objc public enum FcrUIMode: Int {
    case agoraLight
    case agoraDark
}

@objc public enum FcrLanguage: Int {
    case followSystem
    case simplified
    case english
}

class FcrUIGlobal {
    
    static var uiMode: FcrUIMode = .agoraLight
    
    static var launguage: FcrLanguage = .followSystem {
        didSet {
            guard launguage != oldValue else {
                return
            }
            var languageSimble = ""
            switch launguage {
            case .followSystem:
                languageSimble = "empty"
            case .simplified:
                languageSimble = "zh-Hans"
            case .english:
                languageSimble = "en"
            }
            if let eduUIBundle = Bundle.agora_bundle("AgoraEduUI"),
               let languagePath = eduUIBundle.path(forResource: languageSimble,
                                                   ofType: "lproj") {
                languageBundle = Bundle(path: languagePath)
            } else {
                languageBundle = nil
            }
        }
    }
    // 当前使用的语言包
    static var languageBundle: Bundle?
}




