//
//  AgoraBaseViewController+HandsUp.h
//  AgoraEduSDK
//
//  Created by LYY on 2021/3/15.
//

#import "AgoraBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface AgoraBaseViewController (HandsUp) <AgoraEduHandsUpContext>
- (void)onSetHandsUpEnable:(BOOL)enable;
- (void)onSetHandsUpState:(AgoraEduContextHandsUpState)state;
- (void)onShowHandsUpTips:(NSString *)message;
@end

NS_ASSUME_NONNULL_END
