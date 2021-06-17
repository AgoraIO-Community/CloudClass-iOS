//
//  CountDownExtApp.h
//  AgoraEducation
//
//  Created by Cavan on 2021/4/13.
//  Copyright © 2021 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AgoraExtApp/AgoraExtApp.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CountDownDelegate <NSObject>
- (void)countDownDidStop;
- (void)countDownUpTo:(NSInteger)currrentSeconds;
@end

@protocol CountDownProtocol <NSObject>
- (void)invokeCountDownWithTotalSeconds:(NSInteger)totalSeconds
                              ifExecute:(BOOL)ifExecute;
- (void)pauseCountDown;
- (void)cancelCountDown;
@end

@interface CountDownExtApp : AgoraBaseExtApp

@end

NS_ASSUME_NONNULL_END
