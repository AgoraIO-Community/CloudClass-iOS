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
// 以375*667的短边作为缩放标准
fileprivate let kScale = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) / 375.0
fileprivate let kPad = UIDevice.current.userInterfaceIdiom == .pad
struct AgoraFit {
    static func scale(_ value: CGFloat) -> CGFloat {
        return value * kScale
    }
    
    static func os(phone: CGFloat, pad: CGFloat) -> CGFloat {
        return kPad ? pad : phone
    }
}
