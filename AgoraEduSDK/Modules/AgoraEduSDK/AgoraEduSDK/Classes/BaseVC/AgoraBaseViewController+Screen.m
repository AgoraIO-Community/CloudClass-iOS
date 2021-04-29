//
//  AgoraBaseViewController+Screen.m
//  AgoraEduSDK
//
//  Created by LYY on 2021/3/18.
//

#import "AgoraBaseViewController+Screen.h"

@implementation AgoraBaseViewController (Screen)

#pragma mark VCProcessDelegate
- (void)onUpdateScreenShareState:(BOOL)sharing streamUuid:(NSString *)streamUuid {
    [self.eventDispatcher onUpdateScreenShareState:sharing streamUuid:streamUuid];
}

- (void)onShowScreenShareTips:(NSString *)message {
    [self.eventDispatcher onShowScreenShareTips:message];
}

#pragma mark AgoraEduScreenShareContext
- (void)registerEventHandler:(id<AgoraEduScreenShareHandler>)handler {
    [self.eventDispatcher registerWithObject:handler];
}

@end
