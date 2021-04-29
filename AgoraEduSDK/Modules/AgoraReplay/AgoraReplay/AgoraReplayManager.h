//
//  AgoraReplayManager.h
//  AgoraReplay
//
//  Created by SRS on 2020/7/20.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "AgoraReplayConfiguration.h"
#import "AgoraReplayDelegate.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - AgoraReplayPauseReason

typedef NS_OPTIONS(NSUInteger, AgoraReplayPauseReason) {
    //正常播放
    AgoraReplayPauseReasonNone                              = 0,
    //暂停，暂停原因：白板缓冲
    AgoraReplayPauseReasonWaitingWhitePlayerBuffering       = 1 << 0,
    //暂停，暂停原因：音视频缓冲
    AgoraReplayPauseReasonWaitingVideoReplayerBuffering     = 1 << 1,
    //暂停，暂停原因：主动暂停
    ReplayManagerWaitingPauseReasonPlayerPause         = 1 << 2,
    //初始状态，暂停，全缓冲
    AgoraReplayPauseReasonInit                              = AgoraReplayPauseReasonWaitingWhitePlayerBuffering | AgoraReplayPauseReasonWaitingVideoReplayerBuffering | ReplayManagerWaitingPauseReasonPlayerPause,
};


@interface AgoraReplayManager : NSObject

@property (nonatomic, weak) id<AgoraReplayDelegate> delegate;

/** 播放时，播放速率。即使暂停，该值也不会变为 0 */
@property (nonatomic, assign) CGFloat playbackSpeed;

/** 暂停原因，默认所有 buffer + 主动暂停 */
@property (nonatomic, assign, readonly) AgoraReplayPauseReason pauseReason;

- (void)joinReplayWithConfiguration:(AgoraReplayConfiguration *)config success:(void (^) (UIView *boardView, AVPlayer *avPlayer))successBlock failure:(void (^) (NSError * error))failureBlock;

- (void)play;
- (void)pause;
- (void)seekToTime:(CMTime)time completionHandler:(void (^)(BOOL finished))handler;

- (void)leaveReplay;

@end

NS_ASSUME_NONNULL_END
