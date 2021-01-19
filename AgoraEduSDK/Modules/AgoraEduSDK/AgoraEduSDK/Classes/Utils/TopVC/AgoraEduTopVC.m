//
//  AgoraEduTopVC.m
//  AgoraEduSDK
//
//  Created by SRS on 2021/1/5.
//

#import "AgoraEduTopVC.h"

@implementation AgoraEduTopVC

+ (UIViewController *)topVC {
    UIWindow *kW = nil;
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene* windowScene in [UIApplication sharedApplication].connectedScenes)
        {
            if (windowScene.activationState == UISceneActivationStateForegroundActive)
            {
                kW = windowScene.windows.firstObject;
                
                break;
            }
        }
    }else{
        kW = [UIApplication sharedApplication].windows.firstObject;
    }
    
    UIViewController *topViewController = [kW rootViewController];
    
    while (true) {
        if (topViewController.presentedViewController)
        {
            topViewController = topViewController.presentedViewController;
            
        } else if ([topViewController isKindOfClass:[UINavigationController class]] && [(UINavigationController*)topViewController topViewController])
        {
            topViewController = [(UINavigationController *)topViewController topViewController];
            
        } else if ([topViewController isKindOfClass:[UITabBarController class]])
        {
            UITabBarController *tab = (UITabBarController *)topViewController;
            topViewController = tab.selectedViewController;
            
        } else {
            break;
        }
    }
    
    return topViewController;
}
@end
