//
//  AgoraAppleExtension.swift
//  AgoraUIEduBaseViews
//
//  Created by Cavan on 2021/3/17.
//

import AgoraUIBaseViews

// MARK: - UIImage
public func AgoraUIImage(object: NSObject,
                         name: String) -> UIImage? {
    let resource = "AgoraEduUI"
    return UIImage.agora_bundle(object: object,
                                resource: resource,
                                name: name)
}

// MARK - Localized
public func AgoraUILocalizedString(_ key: String,
                                   object: NSObject) -> String {
    let resource = "AgoraEduUI"
    return String.agora_localized_string(key,
                                         object: object,
                                         resource: resource)
}

/** 尺寸适配*/
fileprivate let kShortSide = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
fileprivate let kReferenceShort: Float = 768.0
fileprivate let kPad = UIDevice.current.userInterfaceIdiom == .pad
struct AgoraFit {
    static func scale(_ value: CGFloat) -> CGFloat {
        return kPad ? value : value * 0.79
    }
    
    static func os(phone: CGFloat, pad: CGFloat) -> CGFloat {
        return kPad ? pad : phone
    }
}
