//
//  BoardReplayService.h
//  AgoraReplay
//
//  Created by SRS on 2020/7/20.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Whiteboard/Whiteboard.h>
#import "ReplayConfiguration.h"

@protocol WhiteReplayProtocol <NSObject>

@required
- (void)whiteReplayerStartBuffering;
- (void)whiteReplayerEndBuffering;
- (void)whiteReplayerDidFinish;
- (void)whiteReplayerError:(NSError * _Nullable)error;

@optional

@end

NS_ASSUME_NONNULL_BEGIN

@interface BoardReplayService : NSObject

/** 设置 WhitePlayer，会同时更新 WhitePlayerPhase
 如果不设置，PauseReason 不会移除 CombineSyncManagerPauseReasonWaitingWhitePlayerBuffering 的 flag
 */
@property (nonatomic, strong, nullable, readwrite) WhitePlayer *whitePlayer;

@property (nonatomic, weak, nullable) id<WhiteReplayProtocol> delegate;

- (void)initWithConfiguration:(ReplayConfiguration *)config success:(void (^) (UIView *boardView))successBlock failure:(void (^) (NSError * error))failBlock;

/** 播放时，播放速率。即使暂停，该值也不会变为 0 */
@property (nonatomic, assign) CGFloat playbackSpeed;

- (void)play;
- (void)pause;
- (void)seekToScheduleTime:(NSTimeInterval)beginTime;

- (void)updateWhitePlayerPhase:(WhitePlayerPhase)phase;
@end

NS_ASSUME_NONNULL_END

