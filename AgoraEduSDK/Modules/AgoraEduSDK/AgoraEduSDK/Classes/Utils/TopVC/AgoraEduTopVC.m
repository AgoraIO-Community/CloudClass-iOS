//
//  AgoraEduTopVC.m
//  AgoraEduSDK
//
//  Created by SRS on 2021/1/5.
//

#import "AgoraEduTopVC.h"

@implementation AgoraEduTopVC
+ (UIViewController *)topVC {
    NSArray<UIWindow *> *windows = @[];
    UIWindow *kW = [UIApplication sharedApplication].delegate.window;
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene* windowScene in [UIApplication sharedApplication].connectedScenes) {
            if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                windows = windowScene.windows;
                break;
            }
        }
    } else {
        windows = [UIApplication sharedApplication].windows;
    }
    
    for (UIWindow *window in windows.reverseObjectEnumerator) {
        if (window.hidden == YES || window.opaque == NO) {
            continue;
        }
        if ([window isKindOfClass:NSClassFromString(@"UITextEffectsWindow")] ||
            [window isKindOfClass:NSClassFromString(@"UIRemoteKeyboardWindow")]) {
            continue;
        }
        if (CGRectEqualToRect(window.bounds, UIScreen.mainScreen.bounds) == NO) {
            continue;
        }
        kW = window;
        break;
    }

    
    UIViewController *topViewController = [kW rootViewController];

    while (true) {
        if (topViewController.presentedViewController) {
            topViewController = topViewController.presentedViewController;
            
        } else if ([topViewController isKindOfClass:[UINavigationController class]] && [(UINavigationController*)topViewController topViewController]) {
            topViewController = [(UINavigationController *)topViewController topViewController];
            
        } else if ([topViewController isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tab = (UITabBarController *)topViewController;
            topViewController = tab.selectedViewController;
            
        } else {
            break;
        }
    }
    
    return topViewController;
}
@end
