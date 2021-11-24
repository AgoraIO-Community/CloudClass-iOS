//
//  AgoraEduUI.swift
//  AgoraEduUI
//
//  Created by SRS on 2021/3/13.
//

import AgoraEduContext
import AgoraWidget

@objc public enum AgoraEduUIExitReason: Int {
    case normal, kickOut
}

@objc public protocol AgoraEduUIDelegate: NSObjectProtocol {
    func eduUI(_ eduUI: AgoraEduUI,
               didExited reason: AgoraEduUIExitReason)
}

@objcMembers public class AgoraEduUI: NSObject {
    public private(set) var presentedUIManager: AgoraEduUIManager?
    public weak var delegate: AgoraEduUIDelegate?
    
    public func launch(contextPool: AgoraEduContextPool,
                       completion: (() -> Void)?) {
        var manager: AgoraEduUIManager
        
        let roomType = contextPool.room.getRoomInfo().roomType
        
        switch roomType {
        case .oneToOne:
            manager = AgoraOneToOneUIManager(contextPool: contextPool,
                                             delegate: self)
        case .small:
            manager = AgoraSmallUIManager(contextPool: contextPool,
                                          delegate: self)
        case .lecture:
            manager = AgoraLectureUIManager(contextPool: contextPool,
                                            delegate: self)
        case .paintingSmall:
            manager = AgoraPaintingUIManager(contextPool: contextPool,
                                             delegate: self)
        default:
            fatalError()
        }
        
        presentedUIManager = manager
        manager.modalPresentationStyle = .fullScreen
        
        let topVC = findTopViewController()
        topVC.present(manager,
                      animated: true,
                      completion: completion)
    }
    
    deinit {
        print("ui deinit")
    }
    
    private func findTopViewController() -> UIViewController {
        let window = findTopWindow()
        
        guard let rootViewController = window.rootViewController else {
            fatalError()
        }
        
        var topVC: UIViewController?
        
        var viewController = rootViewController
        
        // 循环找出最合适的 VC
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
    
    private func findTopWindow() -> UIWindow {
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

extension AgoraEduUI: AgoraEduUIManagerDelegate {
    public func manager(manager: AgoraEduUIManager,
                        didExited reason: AgoraEduUIExitReason) {
        presentedUIManager = nil
        
        manager.dismiss(animated: true) { [weak self] in
            guard let `self` = self else {
                return
            }
            
            self.delegate?.eduUI(self,
                                 didExited: reason)
        }
    }
}
