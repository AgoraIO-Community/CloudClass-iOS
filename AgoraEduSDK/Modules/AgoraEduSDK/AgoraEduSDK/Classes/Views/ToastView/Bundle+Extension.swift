//
//  Bundle+Extension.swift
//  AgoraSceneUI
//
//  Created by ZYP on 2021/1/13.
//

import UIKit

class AgoraEduBundleEmptyClass {}
extension Bundle {
    static var agoraEduBundle: Bundle {
        let path = Bundle(for: AgoraEduBundleEmptyClass.self).resourcePath! + "/AgoraEduSDK.bundle"
        return Bundle(path: path) ?? Bundle.main
    }
    
    func image(name: String) -> UIImage? {
        return UIImage(named: name, in: Bundle.agoraEduBundle, compatibleWith: nil)
    }
}
