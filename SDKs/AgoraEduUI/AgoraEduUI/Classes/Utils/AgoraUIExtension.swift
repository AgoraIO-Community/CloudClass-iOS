//
//  AgoraAppleExtension.swift
//  AgoraUIEduBaseViews
//
//  Created by Cavan on 2021/3/17.
//

import AgoraUIBaseViews

extension UIImage {
    class func agedu_named(_ named: String) -> UIImage? {
        let b = Bundle.agoraEduUI()
        return UIImage.init(named: named,
                            in: b,
                            compatibleWith: nil)
    }
}

extension Bundle {
    class func agoraEduUI() -> Bundle {
        return Bundle.ag_compentsBundleNamed("AgoraEduUI") ?? Bundle.main
    }
}

extension String {
    static func agedu_localized_replacing() -> String {
        return "{xxx}"
    }
    
    func agedu_localized() -> String {
        let bundle = Bundle.ag_compentsBundleNamed("AgoraEduUI") ?? Bundle.main
        return NSLocalizedString(self,
                                 bundle: bundle,
                                 comment: "")
    }
}

// 将 AgoraWidgetInfo.syncFrame 转化为 具体是显示在界面上的 frame
extension CGRect {
    func displayFrameFromSyncFrame(superView: UIView) -> CGRect {
        let ratioWidth = self.width
        let rationHeight = self.height
        let xaxis = self.origin.x
        let yaxis = self.origin.y
        
        let displayWidth = ratioWidth * superView.frame.width
        let displayHeight = rationHeight * superView.frame.height
        
        let MEDx = superView.frame.width - displayWidth
        let MEDy = superView.frame.height - displayHeight
        
        let displayX = xaxis * MEDx
        let displayY = yaxis * MEDy
        
        let displayFrame = CGRect(x: displayX,
                                  y: displayY,
                                  width: displayWidth,
                                  height: displayHeight)
        return displayFrame
    }
    
    func displayFrameFromSyncFrame(superView: UIView,
                                   displayWidth: CGFloat,
                                   displayHeight: CGFloat) -> CGRect {
        let xaxis = self.origin.x
        let yaxis = self.origin.y
        
        let MEDx = superView.frame.width - displayWidth
        let MEDy = superView.frame.height - displayHeight
        
        let displayX = xaxis * MEDx
        let displayY = yaxis * MEDy
        
        let displayFrame = CGRect(x: displayX,
                                  y: displayY,
                                  width: displayWidth,
                                  height: displayHeight)
        return displayFrame
    }
}

/** 尺寸适配*/
// 以375*812作为缩放标准（设计图都为iPhoneX）
fileprivate var kScale: CGFloat = {
    let width = max(UIScreen.main.bounds.width,
                    UIScreen.main.bounds.height)
    let height = min(UIScreen.main.bounds.width,
                     UIScreen.main.bounds.height)
    
    if width / height > 667.0/375.0 {
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
    
    static func os(phone: CGFloat,
                   pad: CGFloat) -> CGFloat {
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
