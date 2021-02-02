//
//  Utils.swift
//  AgoraEduSDK
//
//  Created by SRS on 2021/1/27.
//

import UIKit

// MARK: Constraint
public let Agora_Constraint_Id_X = "Agora_Constraint_Id_X"
public let Agora_Constraint_Id_Y = "Agora_Constraint_Id_Y"
public let Agora_Constraint_Id_CenterX = "Agora_Constraint_Id_CenterX"
public let Agora_Constraint_Id_CenterY = "Agora_Constraint_Id_CenterY"
public let Agora_Constraint_Id_Width = "Agora_Constraint_Id_Width"
public let Agora_Constraint_Id_Height = "Agora_Constraint_Id_Height"
public let Agora_Constraint_Id_Right = "Agora_Constraint_Id_Right"
public let Agora_Constraint_Id_Bottom = "Agora_Constraint_Id_Bottom"
public let Agora_Constraint_Id_SafeX = "Agora_Constraint_Id_SafeX"
public let Agora_Constraint_Id_SafeY = "Agora_Constraint_Id_SafeY"
public let Agora_Constraint_Id_SafeRight = "Agora_Constraint_Id_SafeRight"
public let Agora_Constraint_Id_SafeBottom = "Agora_Constraint_Id_SafeBottom"
extension UIView {
    func agoraConstraint(_ withIdentifier:String, _ constraints:[NSLayoutConstraint]) -> NSLayoutConstraint? {
        return constraints.filter{ $0.identifier == withIdentifier }.first
    }
}

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

extension TimeInterval {
    static let animation = 0.25
}

