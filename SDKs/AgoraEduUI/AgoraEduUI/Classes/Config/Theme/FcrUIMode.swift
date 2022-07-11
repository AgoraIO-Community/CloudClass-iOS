//
//  AgoraColorGroup.swift
//  AgoraEduUI
//
//  Created by Cavan on 2022/3/17.
//

import AgoraUIBaseViews
import UIKit

@objc public enum AgoraUIMode: Int {
    case agoraLight
    case agoraDark
}

var UIMode: AgoraUIMode = .agoraLight {
    didSet {
        if #available(iOS 13.0, *) {
            let style: UIUserInterfaceStyle = (UIMode == .agoraDark) ? .dark : .light
            UIViewController.ag_topViewController().overrideUserInterfaceStyle = style
        }
    }
}

