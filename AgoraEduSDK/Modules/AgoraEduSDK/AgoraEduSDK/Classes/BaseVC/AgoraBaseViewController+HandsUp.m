//
//  AgoraBaseViewController+HandsUp.m
//  AgoraEduSDK
//
//  Created by LYY on 2021/3/15.
//

#import "AgoraBaseViewController+HandsUp.h"

@implementation AgoraBaseViewController (HandsUp)

#pragma mark VCProcessDelegate
- (void)onSetHandsUpEnable:(BOOL)enable {
    [self.eventDispatcher onSetHandsUpEnable:enable];
}

- (void)onSetHandsUpState:(AgoraEduContextHandsUpState)state {
    [self.eventDispatcher onSetHandsUpState:state];
}

- (void)onShowHandsUpTips:(NSString *)message {
    [self.eventDispatcher onShowHandsUpTips:message];
}

#pragma mark - AgoraEduHandsUpContext
- (void)updateHandsUpState:(AgoraEduContextHandsUpState)state {
    
    AgoraWEAK(self);
    [self.handsUpVM updateHandsUpInfoWithState:state successBlock:^{
        [weakself.eventDispatcher onUpdateHandsUpStateResult:nil];
        
        [weakself onSetHandsUpState:state];
        
    } failureBlock:^(AgoraEduContextError *error) {
        [weakself.eventDispatcher onUpdateHandsUpStateResult:error];
    }];
}

// 事件监听
- (void)registerEventHandler:(id<AgoraEduHandsUpHandler>)handler {
    [self.eventDispatcher registerWithObject:handler eventType:AgoraUIEventTypeHandsup];
}
@end
