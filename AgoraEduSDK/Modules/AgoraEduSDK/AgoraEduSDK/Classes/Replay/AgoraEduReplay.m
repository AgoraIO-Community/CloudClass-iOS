//
//  AgoraEduReplay.m
//  AgoraEduSDK
//
//  Created by SRS on 2021/1/9.
//

#import <AgoraUIEduBaseViews/AgoraUIEduBaseViews-Swift.h>
#import "AgoraEduReplay.h"
#import "AgoraEduTopVC.h"
#import "AgoraManagerCache.h"
#import "AgoraEduEnums.h"
#import "AgoraEduManager.h"

@interface AgoraEduReplay ()
@end

@implementation AgoraEduReplay
- (void)destory {
    Class class = Agora_Replay_Class;
    if (class != nil) {
        if (![AgoraEduTopVC.topVC isKindOfClass:class]) {
            // 当前房间上层还有其他页面，无法destory
            [self showToast:AgoraLocalizedString(@"DismissVCText", nil)];
            return;
        }
        [self dismissVC];
    }
}

- (void)dismissVC {
//    id<AgoraEduReplayDelegate> delegate = AgoraManagerCache.share.replayDelegate;
//    if ([delegate respondsToSelector:@selector(replay:didReceivedEvent:)]) {
//        [delegate replay:self didReceivedEvent:AgoraEduEventDestroyed];
//    }
//    
//    AgoraManagerCache.share.replayDelegate = nil;
//    AgoraManagerCache.share.replay = nil;
//    
//    UIViewController *vc = AgoraEduTopVC.topVC;
//    [vc dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark ReplayVCDelegate
- (void)onReplayDismiss {
    [self dismissVC];
}

#pragma mark Private
- (void)showToast:(NSString *)msg {
    [AgoraUtils showToastWithMessage:msg];
}
@end
