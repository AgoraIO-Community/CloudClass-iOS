//
//  FcrLocalization.swift
//  AgoraEducation
//
//  Created by Jonathan on 2022/7/19.
//  Copyright © 2022 Agora. All rights reserved.
//

import Foundation

public enum FcrSurpportLanguage: String {
    case zh_cn = "zh-Hans"
    case en = "en"
    case zh_tw = "zh-Hant"
}

public class FcrLocalization {
    
    static let shared = FcrLocalization()
    
    private let kLanguage = "com.agora.language"
    private let kEmpty = "empty"
    
    // 语言设置
    public var language: FcrSurpportLanguage? {
        get {
            if let saved = UserDefaults.standard.object(forKey: kLanguage) as? String {
                return FcrSurpportLanguage.init(rawValue: saved)
            }
            return nil
        }
    }
    
    fileprivate var languageBundle: Bundle?
    
    init() {
        setupDefaultLanguage()
        updateLanguageBundle()
    }
    
    public func setupNewLanguage(_ language: FcrSurpportLanguage) {
        UserDefaults.standard.set(language.rawValue,
                                  forKey: kLanguage)
        updateLanguageBundle()
    }
    
    private func setupDefaultLanguage() {
        guard self.language == nil else {
            return
        }
        if let language = Bundle.main.preferredLocalizations.first,
           language == FcrSurpportLanguage.zh_cn.rawValue {
            UserDefaults.standard.set(FcrSurpportLanguage.zh_cn.rawValue,
                                      forKey: kLanguage)
        } else {
            UserDefaults.standard.set(FcrSurpportLanguage.en.rawValue,
                                      forKey: kLanguage)
        }
    }
    
    private func updateLanguageBundle() {
        if let bundlePath = Bundle.main.path(forResource: self.language?.rawValue,
                                             ofType: "lproj") {
            self.languageBundle = Bundle(path: bundlePath)
        } else {
            self.languageBundle = nil
        }
    }
}

extension String {
    func ag_localized() -> String {
        if let bundle = FcrLocalization.shared.languageBundle {
            return bundle.localizedString(forKey: self,
                                          value: nil,
                                          table: nil)
        } else {
            return NSLocalizedString(self,
                                     comment: "")
        }
    }
}
