//
//  AgoraEduClassroom.m
//  AgoraEduSDK
//
//  Created by SRS on 2021/1/9.
//

#import <AgoraUIEduBaseViews/AgoraUIEduBaseViews-Swift.h>
#import "AgoraEduClassroom.h"
#import "AgoraEduReplay.h"
#import "AgoraEduTopVC.h"
#import "AgoraBaseViewController.h"
#import "AgoraEduManager.h"
#import "AgoraEduManager.h"
#import "AgoraManagerCache.h"

@interface AgoraEduClassroom()
@property (nonatomic, weak) AgoraEduReplay *replay;
@end

@implementation AgoraEduClassroom
// 判断是否有
- (void)destroy {
    if (!AgoraManagerCache.share.sdkReady) {
        NSString *msg = [NSString stringWithFormat:@"%@%@", @"AgoraEduClassroom", AgoraLocalizedString(@"UnInitializedText", nil)];
        
        [self showToast:msg];
        return;
    }
    
    if (self.replay == nil) {
        if (![AgoraEduTopVC.topVC isKindOfClass:AgoraBaseViewController.class]) {
            // 页面上层还有其他页面，无法destory
            [self showToast:AgoraLocalizedString(@"DismissVCText", nil)];
            return;
        }
    } else {
        Class class = Agora_Replay_Class;
        if (class != nil) {
            if (![AgoraEduTopVC.topVC isKindOfClass:class]) {
                [self showToast:AgoraLocalizedString(@"DismissVCText", nil)];
                return;
            }
        }
    }
    
    [AgoraEduClassroom dismissVC:AgoraManagerCache.share.classroomDelegate classroom:AgoraManagerCache.share.classroom];
    [AgoraEduManager releaseResource];
}

+ (void)dismissVC:(id<AgoraEduClassroomDelegate>)delegate
        classroom:(AgoraEduClassroom *)classroom {
    if ([delegate respondsToSelector:@selector(classroom:didReceivedEvent:)]) {
        [delegate classroom:classroom didReceivedEvent:AgoraEduEventDestroyed];
    }
    
    UIViewController *vc = AgoraEduTopVC.topVC;
    
    Class class = Agora_Replay_Class;
    if (class != nil) {
        if ([vc isKindOfClass:class]) {
            [vc dismissViewControllerAnimated:NO completion:^{
                [vc dismissViewControllerAnimated:YES completion:nil];
            }];
        } else {
            [vc dismissViewControllerAnimated:YES completion:nil];
        }
    } else {
        [vc dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark Private
- (void)showToast:(NSString *)msg {
    [AgoraUtils showToastWithMessage:msg];
}

@end
