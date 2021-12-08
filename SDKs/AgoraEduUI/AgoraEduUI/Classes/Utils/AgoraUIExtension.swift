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
// 以375*667作为缩放标准
fileprivate var kScale: CGFloat = {
    let width = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
    let height = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
    if width/height > 667.0/375.0 {
        return height / 375.0
    } else {
        return width / 667.0
    }
}()
fileprivate let kPad = UIDevice.current.userInterfaceIdiom == .pad
struct AgoraFit {
    static func scale(_ value: CGFloat) -> CGFloat {
        return value * kScale
    }
    
    static func os(phone: CGFloat, pad: CGFloat) -> CGFloat {
        return kPad ? pad : phone
    }
}

extension UIViewController {
    /// 获取最顶层的ViewController
    @objc public static func ag_topViewController() -> UIViewController {
        let window = ag_topWindow()
        guard let rootViewController = window.rootViewController else {
            fatalError()
        }
        var topVC: UIViewController?
        var viewController = rootViewController
        while true {
            if let presented = viewController.presentedViewController {
                viewController = presented
                continue
            }
            if let navigation = viewController as? UINavigationController,
               let navigationTop = navigation.topViewController {
                viewController = navigationTop
                continue
            }
            if let tabBar = viewController as? UITabBarController,
               let selected = tabBar.selectedViewController {
                viewController = selected
                continue
            }
            break
        }
        topVC = viewController
        guard let vc = topVC else {
            fatalError()
        }
        return vc
    }
    
    private static func ag_topWindow() -> UIWindow {
        var keyWindow: UIWindow?
        var windows: [UIWindow]?
        if let delegate = UIApplication.shared.delegate,
           let window = delegate.window {
            keyWindow = window
        }
        if #available(iOS 13.0, *),
           let connectedScenes = UIApplication.shared.connectedScenes as? [UIWindowScene] {
            for windowScene in connectedScenes where windowScene.activationState == .foregroundActive {
                windows = windowScene.windows
                break
            }
        } else {
            windows = UIApplication.shared.windows
        }
        if let activeWindows = windows {
            for window in activeWindows {
                if window.isHidden == true {
                    continue
                }
                if window.isOpaque == false {
                    continue
                }
                if window.bounds.equalTo(UIScreen.main.bounds) == false {
                    continue
                }
                keyWindow = window
            }
        }
        guard let window = keyWindow else {
            fatalError()
        }
        return window
    }
}
