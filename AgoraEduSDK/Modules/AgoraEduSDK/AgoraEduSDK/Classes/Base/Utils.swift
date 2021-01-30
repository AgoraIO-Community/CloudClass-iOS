//
//  Utils.swift
//  AgoraEduSDK
//
//  Created by SRS on 2021/1/27.
//

import UIKit

// MARK: Constraint
public let Constraint_Id_X = "Constraint_Id_X"
public let Constraint_Id_Y = "Constraint_Id_Y"
public let Constraint_Id_CenterX = "Constraint_Id_CenterX"
public let Constraint_Id_CenterY = "Constraint_Id_CenterY"
public let Constraint_Id_Width = "Constraint_Id_Width"
public let Constraint_Id_Height = "Constraint_Id_Height"
public let Constraint_Id_Right = "Constraint_Id_Right"
public let Constraint_Id_Bottom = "Constraint_Id_Bottom"
extension UIView {
    func constraint(_ withIdentifier:String, _ constraints:[NSLayoutConstraint]) -> NSLayoutConstraint? {
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

