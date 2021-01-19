//
//  VideoReplayService.h
//  AgoraReplay
//
//  Created by SRS on 2020/7/20.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "ReplayConfiguration.h"

@protocol VideoReplayProtocol <NSObject>

@required
- (void)videoReplayStartBuffering;
- (void)videoReplayEndBuffering;
- (void)videoReplayDidFinish;
- (void)videoReplayError:(NSError * _Nullable)error;

@optional
/**
 播放状态变化，由播放变停止，或者由暂停变播放

 @param isPlaying 是否正在播放
 */
- (void)videoReplayStateChange:(BOOL)isPlaying;

/**
 缓冲进度更新

 @param loadedTimeRanges 数组内元素为 CMTimeRange，使用 CMTimeRangeValue 获取 CMTimeRange，是 video 已经加载了的缓存
 */
- (void)videoReplayLoadedTimeRangeChange:(NSArray<NSValue *> *_Nullable)loadedTimeRanges;

@end

NS_ASSUME_NONNULL_BEGIN

@interface VideoReplayService : NSObject

@property (nonatomic, weak, nullable) id<VideoReplayProtocol> delegate;

- (void)initWithConfiguration:(ReplayConfiguration *)config success:(void (^) (AVPlayer *avPlayer))successBlock failure:(void (^) (NSError * error))failBlock;

/** 播放时，播放速率。即使暂停，该值也不会变为 0 */
@property (nonatomic, assign) CGFloat playbackSpeed;

- (void)play;
- (void)pause;
- (void)seekToTime:(CMTime)time completionHandler:(void (^)(NSTimeInterval realTime, BOOL finished))completionHandler;

- (BOOL)hasEnoughBuffer;
@end

NS_ASSUME_NONNULL_END

