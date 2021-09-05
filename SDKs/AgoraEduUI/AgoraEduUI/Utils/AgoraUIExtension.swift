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
