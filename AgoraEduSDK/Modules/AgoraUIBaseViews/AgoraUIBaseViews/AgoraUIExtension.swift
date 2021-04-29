//
//  AgoraUIExtension.swift
//  AgoraUIBaseViews
//
//  Created by Cavan on 2021/4/20.
//

import UIKit

// MARK: - String
public extension String {
    func agora_size(font: UIFont,
                    width: CGFloat = CGFloat(MAXFLOAT),
                    height: CGFloat = CGFloat(MAXFLOAT)) -> CGSize {
        let options: NSStringDrawingOptions = [.usesLineFragmentOrigin,
                                               .usesFontLeading]
        let text = self as NSString
        let boundingRect = text.boundingRect(with: CGSize(width: width,
                                                          height: height),
                                             options: options,
                                             attributes: [NSAttributedString.Key.font: font],
                                             context: nil)
        return CGSize(width: boundingRect.size.width,
                      height: boundingRect.size.height)
    }
    
    static func agora_localized_string(_ key: String,
                                       object: NSObject,
                                       resource: String) -> String {
        guard let bundle = Bundle.agora_bundle(object: object,
                                               resource: resource) else {
            return ""
        }
        
        return NSLocalizedString(key,
                                 bundle: bundle,
                                 comment: "")
    }
}

// MARK: - UIScreen
public extension UIScreen {
    static var agora_width: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    static var agora_height: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    static var agora_is_notch: Bool {
        if #available(iOS 11.0, *),
           let safeAreaInsets = UIApplication.shared.keyWindow?.safeAreaInsets  {
            return safeAreaInsets.left > 0.0 ||
                safeAreaInsets.top > 0.0 ||
                safeAreaInsets.right > 0.0 ||
                safeAreaInsets.bottom > 0.0
        } else {
            return false
        }
    }
    
    static var agora_safe_area_bottom: CGFloat {
        if #available(iOS 11.0, *),
           let safeAreaInsets = UIApplication.shared.keyWindow?.safeAreaInsets  {
            return safeAreaInsets.bottom
        } else {
            return 0
        }
    }
    
    static var agora_safe_area_left: CGFloat {
        if #available(iOS 11.0, *),
           let safeAreaInsets = UIApplication.shared.keyWindow?.safeAreaInsets  {
            return safeAreaInsets.left
        } else {
            return 0
        }
    }
    
    static var agora_safe_area_right: CGFloat {
        if #available(iOS 11.0, *),
           let safeAreaInsets = UIApplication.shared.keyWindow?.safeAreaInsets  {
            return safeAreaInsets.right
        } else {
            return 0
        }
    }
    
    static var agora_safe_area_top: CGFloat {
        if #available(iOS 11.0, *),
           let safeAreaInsets = UIApplication.shared.keyWindow?.safeAreaInsets  {
            return safeAreaInsets.top
        } else {
            return 0
        }
    }
}

// MARK: - TimeInterval
public extension TimeInterval {
    static let agora_animation = 0.25
}

// MARK: - Bundle
public extension Bundle {
    static func agora_bundle(object: NSObject,
                             resource: String) -> Bundle? {
        let bundle = Bundle(for: object.classForCoder)
        if let url = bundle.url(forResource: resource,
                                withExtension: "bundle") {
            return Bundle(url: url)
        } else {
            return nil
        }
    }
}

// MARK: - UIImage
public extension UIImage {
    static func agora_bundle(object: NSObject,
                             resource: String,
                             name: String) -> UIImage? {
        if let bundle = Bundle.agora_bundle(object: object,
                                            resource: resource) {
            return UIImage(named: name,
                           in: bundle,
                           compatibleWith: nil)
        } else {
            return nil
        }
    }
}
