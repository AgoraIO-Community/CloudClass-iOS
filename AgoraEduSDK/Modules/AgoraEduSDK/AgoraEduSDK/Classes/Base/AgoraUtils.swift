//
//  Utils.swift
//  AgoraEduSDK
//
//  Created by SRS on 2021/1/27.
//

import UIKit

// MARK: LocalResource
public func AgoraBundle(_ aClass: AnyClass) -> Bundle? {
    let bundle = Bundle(for: aClass)
    if let url = bundle.url(forResource: "AgoraEduSDK", withExtension: "bundle") {
        return Bundle(url: url)
    } else {
        return nil
    }
}

public func AgoraImageWithName(_ imgName: String, _ aClass: AnyClass) -> UIImage? {
    
    guard let bundle = AgoraBundle(aClass) else {
        return nil
    }
    
    return UIImage(named: imgName, in: bundle, compatibleWith: nil)
}

public func AgoraLocalizedString(_ key: String, _ aClass: AnyClass) -> String? {
    
    guard let bundle = AgoraBundle(aClass) else {
        return nil
    }
    
    return NSLocalizedString(key, tableName: nil, bundle: bundle, value: "", comment: "")
}

public func AgoraImgae(name: String) -> UIImage {
    guard let bundle = AgoraBundle(AgoraLocationAssistant.shared().classForCoder) else {
        fatalError()
    }
    
    return UIImage(named: name,
                   in: bundle,
                   compatibleWith: nil)!
}

class AgoraLocationAssistant: NSObject {
    static let object = AgoraLocationAssistant()
    
    static func shared() -> AgoraLocationAssistant {
        return object
    }
}

extension TimeInterval {
    static let animation = 0.25
}

