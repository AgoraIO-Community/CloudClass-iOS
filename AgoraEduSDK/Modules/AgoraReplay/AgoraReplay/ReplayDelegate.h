//
//  ReplayDelegate.h
//  AgoraReplay
//
//  Created by SRS on 2020/7/20.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ReplayDelegate <NSObject>

@required
- (void)replayTimeChanged:(NSTimeInterval)time;
- (void)replayStartBuffering;
- (void)replayEndBuffering;
- (void)replayDidFinish;

- (void)replayPause;
- (void)replayError:(NSError * _Nullable)error;

@optional
- (void)videoReplayDidFinish;
- (void)boardReplayDidFinish;

@end

NS_ASSUME_NONNULL_END
