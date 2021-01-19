//
//  ReplayManager.m
//  AgoraReplay
//
//  Created by SRS on 2020/7/20.
//  Copyright © 2020 agora. All rights reserved.
//

#import "ReplayManager.h"
#import <AgoraLog/AgoraLog.h>
#import "BoardReplayService.h"
#import "VideoReplayService.h"

#define WEAK(object) __weak typeof(object) weak##object = object

@interface ReplayManager ()<VideoReplayProtocol, WhiteReplayProtocol> {
    CADisplayLink *_displayLink;
    NSInteger _frameInterval;
    NSTimeInterval _displayDurationTime;
}

@property (nonatomic, assign, readwrite) ReplayPauseReason pauseReason;

@property (nonatomic, strong) BoardReplayService *boardReplayService;
@property (nonatomic, strong) VideoReplayService *videoReplayService;

@property (nonatomic, copy) NSString *classStartTime;
@property (nonatomic, copy) NSString *classEndTime;

@end

@implementation ReplayManager

- (instancetype)init {
    if(self = [super init]){

        _frameInterval = 60;
        _displayDurationTime = 0;
        
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(onDisplayLink:)];
        _displayLink.preferredFramesPerSecond =_frameInterval;
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        _displayLink.paused = YES;
        
        _pauseReason = ReplayPauseReasonInit;
        
        [self registerNotification];
    }
    return self;
}

#pragma mark - Notification
- (void)registerNotification {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    
}

- (void)applicationWillResignActive {
    if(!_displayLink.paused) {
        [self pause];
        if ([self.delegate respondsToSelector:@selector(replayPause)]) {
            [self.delegate replayPause];
        }
    }
}

- (void)joinReplayWithConfiguration:(ReplayConfiguration *)config success:(void (^) (UIView *boardView, AVPlayer *avPlayer))successBlock failure:(void (^) (NSError * error))failureBlock {
    
    self.classStartTime = config.startTime;
    self.classEndTime = config.endTime;

    self.boardReplayService = [BoardReplayService new];
    self.videoReplayService = [VideoReplayService new];
    self.boardReplayService.delegate = self;
    self.videoReplayService.delegate = self;
    WEAK(self);
    [self.boardReplayService initWithConfiguration:config success:^(UIView * _Nonnull boardView) {
        
        [weakself.videoReplayService initWithConfiguration:config success:^(AVPlayer * _Nonnull avPlayer) {
            
            if(successBlock){
                successBlock(boardView, avPlayer);
            }
            
        } failure:failureBlock];
        
    } failure:failureBlock];
}

- (void)onDisplayLink: (CADisplayLink *)displayLink {
    
    NSTimeInterval classDurationTime = self.classEndTime.integerValue - self.classStartTime.integerValue;
    
    _displayDurationTime += displayLink.duration;

    if(_displayDurationTime * 1000 > classDurationTime) {
        [self finish];
        return;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(replayTimeChanged:)]) {
        [_delegate replayTimeChanged:_displayDurationTime];
    }
}

- (void)stopDisplayLink {
    if (_displayLink){
        [_displayLink invalidate];
        _displayLink = nil;
    }
}

#pragma mark - Play Control
- (void)setPlaybackSpeed:(CGFloat)playbackSpeed {
    _playbackSpeed = playbackSpeed;
    [self.videoReplayService setPlaybackSpeed:playbackSpeed];
    [self.boardReplayService setPlaybackSpeed:playbackSpeed];
}

#pragma mark - Public Methods

- (void)play {
    
    self.pauseReason = self.pauseReason & ~SyncManagerWaitingPauseReasonPlayerPause;
    [self.videoReplayService play];
    
    // video 将直接播放，whitePlayer 也直接播放
    if ([self.videoReplayService hasEnoughBuffer]) {
        [self.boardReplayService play];
        
        _displayLink.paused = NO;
    }
}

- (void)pause {
    self.pauseReason = self.pauseReason | SyncManagerWaitingPauseReasonPlayerPause;
    
    _displayLink.paused = YES;
    [self.videoReplayService pause];
    [self.boardReplayService pause];
}

- (void)finish {
    _displayLink.paused = YES;
    if ([self.delegate respondsToSelector:@selector(replayDidFinish)]) {
        [self.delegate replayDidFinish];
    }
}

- (void)seekToTime:(CMTime)time completionHandler:(void (^)(BOOL finished))handler {
        
    NSTimeInterval seekTime = CMTimeGetSeconds(time);
    [self.boardReplayService seekToScheduleTime:seekTime];
    [self setDisplayDurationTime:seekTime];

    // 如果seek超出视频长度，finished为false，并且默认seek到最后一帧
    [self.videoReplayService seekToTime:time completionHandler:^(NSTimeInterval realTime, BOOL finished) {
        handler(finished);
    }];
}

- (void)setDisplayDurationTime:(NSTimeInterval)time {
    _displayDurationTime = time;
}

#pragma mark VideoReplayProtocol
- (void)videoReplayStartBuffering {
    if ([self.delegate respondsToSelector:@selector(replayStartBuffering)]) {
        [self.delegate replayStartBuffering];
    }
    
    //加上 native 缓冲标识
    self.pauseReason = self.pauseReason | ReplayPauseReasonWaitingVideoReplayerBuffering;
    
    //whitePlayer 加载 buffering 的行为，一旦开始，不会停止。所以直接暂停播放即可。
    [self.boardReplayService pause];
    _displayLink.paused = YES;
}

- (void)videoReplayEndBuffering {
    BOOL isBuffering = !(self.pauseReason & ReplayPauseReasonWaitingWhitePlayerBuffering) || (self.pauseReason & ReplayPauseReasonWaitingVideoReplayerBuffering);

    self.pauseReason = self.pauseReason & ~ReplayPauseReasonWaitingVideoReplayerBuffering;

    /**
     1. WhitePlayer 还在缓冲(01)，暂停
     2. WhitePlayer 不在缓冲(00)，结束缓冲
     */
    if (self.pauseReason & ReplayPauseReasonWaitingWhitePlayerBuffering) {
        [self.videoReplayService pause];
    } else if (!isBuffering && [self.delegate respondsToSelector:@selector(replayEndBuffering)]) {
        [self.delegate replayEndBuffering];
    } else if (self.pauseReason == ReplayPauseReasonNone && [self.delegate respondsToSelector:@selector(replayEndBuffering)]) {
        [self.delegate replayEndBuffering];
    }
    
    /**
     1. 目前是播放状态（100），没有任何一个播放器，处于缓冲，调用两端播放API
     2. 目前是主动暂停（000），暂停白板
     3. whitePlayer 还在缓存（101、110），已经在处理缓冲回调的位置，处理完毕
     */
    if (self.pauseReason == ReplayPauseReasonNone) {
        [self.videoReplayService play];
        [self.boardReplayService play];
        _displayLink.paused = NO;
    } else if (self.pauseReason & SyncManagerWaitingPauseReasonPlayerPause) {
        [self.videoReplayService pause];
        [self.boardReplayService pause];
    }
}
- (void)videoReplayDidFinish {
    if ([self.delegate respondsToSelector:@selector(videoReplayDidFinish)]) {
        [self.delegate videoReplayDidFinish];
    }
}

- (void)videoReplayPause {
    if(!_displayLink.paused) {
        [self pause];
        if ([self.delegate respondsToSelector:@selector(replayPause)]) {
            [self.delegate replayPause];
        }
    }
}

- (void)videoReplayError:(NSError * _Nullable)error {
    
    [self pause];
    if ([self.delegate respondsToSelector:@selector(replayError:)]) {
        [self.delegate replayError:error];
    }
}

#pragma mark WhiteReplayProtocol
- (void)whiteReplayerStartBuffering {
    if ([self.delegate respondsToSelector:@selector(replayStartBuffering)]) {
        [self.delegate replayStartBuffering];
    }
    
    self.pauseReason = self.pauseReason | ReplayPauseReasonWaitingWhitePlayerBuffering;
    
    [self.videoReplayService pause];
    
    _displayLink.paused = YES;
}
- (void)whiteReplayerEndBuffering {
    
    BOOL isBuffering = !(self.pauseReason & ReplayPauseReasonWaitingWhitePlayerBuffering) || (self.pauseReason & ReplayPauseReasonWaitingVideoReplayerBuffering);
    
    self.pauseReason = self.pauseReason & ~ReplayPauseReasonWaitingWhitePlayerBuffering;

    /**
     1. native 还在缓存(10)，主动暂停 whitePlayer
     2. native 不在缓存(00)，缓冲结束
     */
    if (self.pauseReason & ReplayPauseReasonWaitingVideoReplayerBuffering) {
        [self.boardReplayService pause];
    } else if (!isBuffering && [self.delegate respondsToSelector:@selector(replayEndBuffering)]) {
        [self.delegate replayEndBuffering];
    } else if (self.pauseReason == ReplayPauseReasonNone && [self.delegate respondsToSelector:@selector(replayEndBuffering)]) {
        [self.delegate replayEndBuffering];
    }
    
    /**
     1. 目前是播放状态（100），没有任何一个播放器，处于缓冲，调用两端播放API
     2. 目前是主动暂停（000），暂停白板
     3. native 还在缓存（110、010），已经在处理缓冲回调的位置，处理完毕
     */
    if (self.pauseReason == ReplayPauseReasonNone) {
        [self.videoReplayService play];
        [self.boardReplayService play];
        _displayLink.paused = NO;
    } else if (self.pauseReason & SyncManagerWaitingPauseReasonPlayerPause) {
        [self.videoReplayService pause];
        [self.boardReplayService pause];
    }
}
- (void)whiteReplayerDidFinish {
    if ([self.delegate respondsToSelector:@selector(boardReplayDidFinish)]) {
        [self.delegate boardReplayDidFinish];
    }
}
- (void)whiteReplayerError:(NSError * _Nullable)error {
    [self pause];
    if ([self.delegate respondsToSelector:@selector(replayError:)]) {
        [self.delegate replayError:error];
    }
}

- (void)leaveReplay {
    [NSNotificationCenter.defaultCenter removeObserver:self];
    [self stopDisplayLink];
}

- (void)dealloc {
    [self leaveReplay];
}

@end
