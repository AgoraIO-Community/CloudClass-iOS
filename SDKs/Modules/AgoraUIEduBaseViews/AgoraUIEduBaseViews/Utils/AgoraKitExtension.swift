//
//  AgoraAppleExtension.swift
//  AgoraUIEduBaseViews
//
//  Created by Cavan on 2021/3/17.
//

import UIKit
import AgoraUIBaseViews

// MARK: - UIImage
public func AgoraKitImage(_ name: String) -> UIImage? {
    let object = AgoraKitBundleAssistant.shared()
    return UIImage.agora_bundle(object: AgoraKitBundleAssistant.shared(),
                                resource: object.resource,
                                name: name)
}

public func AgoraKitImage(object: NSObject,
                          resource: String,
                          name: String) -> UIImage? {
    return UIImage.agora_bundle(object: object,
                                resource: resource,
                                name: name)
}

// MARK: - String
extension String {
    func agoraKitSize(font: UIFont,
                      width: CGFloat = CGFloat(MAXFLOAT),
                      height: CGFloat = CGFloat(MAXFLOAT)) -> CGSize {
        let size = agora_size(font: font,
                              width: width,
                              height: height)
        return CGSize(width: size.width + 1,
                      height: size.height + 1)
    }
}

// MARK - Localized
public func AgoraKitLocalizedString(_ key: String) -> String {
    let object = AgoraKitBundleAssistant.shared()
    return String.agora_localized_string(key,
                                         object: object,
                                         resource: object.resource)
}

public func AgoraKitLocalizedString(_ key: String,
                                    object: NSObject,
                                    resource: String) -> String {
    return String.agora_localized_string(key,
                                  object: object,
                                  resource: resource)
}

// MARK: - Bundle
public extension Bundle {
    static func agoraUIEduBaseBundle() -> Bundle? {
        let object = AgoraKitBundleAssistant.shared()
        let bundle = Bundle.agora_bundle(object: object,
                                         resource: object.resource)
        return bundle
    }
}

class AgoraKitBundleAssistant: NSObject {
    static let object = AgoraKitBundleAssistant()
    
    let resource = "AgoraUIEduBaseViews"
    
    static func shared() -> AgoraKitBundleAssistant {
        return object
    }
}
