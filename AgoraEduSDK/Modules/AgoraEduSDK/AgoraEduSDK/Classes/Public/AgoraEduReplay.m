//
//  AgoraEduReplay.m
//  AgoraEduSDK
//
//  Created by SRS on 2021/1/9.
//

#import "AgoraEduReplay.h"
#import "AgoraEduTopVC.h"
#import "UIView+AgoraEduToast.h"

@interface AgoraEduReplay ()
@end

@implementation AgoraEduReplay
- (void)destory {
    
    Class class = Agora_Replay_Class;
    if (class != nil) {
        if (![AgoraEduTopVC.topVC isKindOfClass:class]) {
            // 当前房间上层还有其他页面，无法destory
            [self showToast:AgoraEduLocalizedString(@"DismissVCText", nil)];
            return;
        }
        [self dismissVC];
    }
}

- (void)dismissVC {
    
    id<AgoraEduReplayDelegate> delegate = AgoraEduManager.shareManager.replayDelegate;
    if ([delegate respondsToSelector:@selector(replay:didReceivedEvent:)]) {
        [delegate replay:self didReceivedEvent:AgoraEduEventDestroyed];
    }
    
    AgoraEduManager.shareManager.replayDelegate = nil;
    AgoraEduManager.shareManager.replay = nil;
    
    UIViewController *vc = AgoraEduTopVC.topVC;
    [vc dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark ReplayVCDelegate
- (void)onReplayDismiss {
    [self dismissVC];
}

#pragma mark Private
- (void)showToast:(NSString *)msg {
    [[UIApplication sharedApplication].windows.firstObject makeToast:msg];
}
@end
