//
//  AgoraEduClassroom.m
//  AgoraEduSDK
//
//  Created by SRS on 2021/1/9.
//

#import "AgoraEduClassroom.h"
#import "AgoraEduReplay.h"
#import "AgoraEduTopVC.h"
#import "AgoraBaseViewController.h"
#import "AgoraEduManager.h"
#import "UIView+AgoraEduToast.h"
#import "AgoraEduManager.h"

@interface AgoraEduClassroom()
@property (nonatomic, weak) AgoraEduReplay *replay;
@end

@implementation AgoraEduClassroom

// 判断是否有
- (void)destory {
    
    if (!AgoraEduManager.shareManager.sdkReady) {
        NSString *msg = [NSString stringWithFormat:@"%@%@", @"AgoraEduClassroom", AgoraEduLocalizedString(@"UnInitializedText", nil)];
        
        [self showToast:msg];
        return;
    }
    
    if (self.replay == nil) {
        if (![AgoraEduTopVC.topVC isKindOfClass:AgoraBaseViewController.class]) {
            // 页面上层还有其他页面，无法destory
            [self showToast:AgoraEduLocalizedString(@"DismissVCText", nil)];
            return;
        }
    } else {
        Class class = Agora_Replay_Class;
        if (class != nil) {
            if (![AgoraEduTopVC.topVC isKindOfClass:class]) {
                [self showToast:AgoraEduLocalizedString(@"DismissVCText", nil)];
                return;
            }
        }
    }
    
    [AgoraEduClassroom dismissVC:AgoraEduManager.shareManager.classroomDelegate classroom:AgoraEduManager.shareManager.classroom];
    [AgoraEduManager releaseResource];
}

+ (void)dismissVC:(id<AgoraEduClassroomDelegate>)delegate classroom:(AgoraEduClassroom *)classroom {
    
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
    [[UIApplication sharedApplication].windows.firstObject makeToast:msg];
}

@end
