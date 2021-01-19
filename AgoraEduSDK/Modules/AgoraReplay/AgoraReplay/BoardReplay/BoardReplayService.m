//
//  BoardReplayService.m
//  AgoraReplay
//
//  Created by SRS on 2020/7/20.
//  Copyright © 2020 agora. All rights reserved.
//

#import "BoardReplayService.h"
#import <AgoraLog/AgoraLog.h>

@interface BoardReplayService()<WhiteCommonCallbackDelegate, WhitePlayerEventDelegate>
@property (nonatomic, strong) WhiteSDK * _Nullable whiteSDK;
@property (nonatomic, strong) NSString *appId;
@end

@implementation BoardReplayService

- (void)initWithConfiguration:(ReplayConfiguration *)config success:(void (^) (UIView *boardView))successBlock failure:(void (^) (NSError * error))failBlock {
    
    NSAssert(config.startTime && config.startTime.length == 13, @"startTime must be millisecond unit");
    NSAssert(config.endTime && config.endTime.length == 13, @"endTime must be millisecond unit");
    
    self.appId = config.boardConfig.boardAppid;
    
    WhiteBoardView *whiteBoardView = [[WhiteBoardView alloc] init];
    [self initWhiteSDKWithBoardView:whiteBoardView];
    
    __weak typeof(self) weakself = self;
    WhitePlayerConfig *playerConfig = [[WhitePlayerConfig alloc] initWithRoom:config.boardConfig.boardId roomToken:config.boardConfig.boardToken];
    
    // make up
    NSInteger iStartTime = [config.startTime substringToIndex:10].integerValue;
    NSInteger iDuration = labs(config.endTime.integerValue - config.startTime.integerValue) * 0.001;

    playerConfig.beginTimestamp = @(iStartTime);
    playerConfig.duration = @(iDuration);

    [self.whiteSDK createReplayerWithConfig:playerConfig callbacks:self completionHandler:^(BOOL success, WhitePlayer * _Nullable player, NSError * _Nullable error) {
        if (success) {
            weakself.whitePlayer = player;
            [weakself.whitePlayer refreshViewSize];

            if(successBlock != nil){
                successBlock(whiteBoardView);
            }
        } else {
            if(failBlock != nil){
                failBlock(error);
            }
        }
    }];
}

- (void)initWhiteSDKWithBoardView:(WhiteBoardView *)boardView {
    
    WhiteSdkConfiguration *config = [[WhiteSdkConfiguration alloc]initWithApp:self.appId];
    self.whiteSDK = [[WhiteSDK alloc] initWithWhiteBoardView:boardView config:config commonCallbackDelegate:self];
}

- (void)updateWhitePlayerPhase:(WhitePlayerPhase)phase {
    // WhitePlay 处于缓冲状态，pauseReson 加上 whitePlayerBuffering
    if (phase == WhitePlayerPhaseBuffering || phase == WhitePlayerPhaseWaitingFirstFrame) {
        [self whitePlayerStartBuffing];
    }
    // 进入暂停状态，whitePlayer 已经完成缓冲，移除 whitePlayerBufferring
    else if (phase == WhitePlayerPhasePause || phase == WhitePlayerPhasePlaying) {
        [self whitePlayerEndBuffering];
    }
}

- (void)setPlaybackSpeed:(CGFloat)playbackSpeed {
    _playbackSpeed = playbackSpeed;
    self.whitePlayer.playbackSpeed = playbackSpeed;
}

+ (UIView *)createWhiteBoardView {
    WhiteBoardView *boardView = [[WhiteBoardView alloc] init];
    return boardView;
}

- (void)play {
    [self.whitePlayer play];
}

- (void)pause {
    [self.whitePlayer pause];
}

- (void)seekToScheduleTime:(NSTimeInterval)beginTime {
    [self.whitePlayer seekToScheduleTime:beginTime];
}

#pragma mark - white player buffering
- (void)whitePlayerStartBuffing {
    if ([self.delegate respondsToSelector:@selector(whiteReplayerStartBuffering)]) {
        [self.delegate whiteReplayerStartBuffering];
    }
}

- (void)whitePlayerEndBuffering {
    if ([self.delegate respondsToSelector:@selector(whiteReplayerEndBuffering)]) {
        [self.delegate whiteReplayerEndBuffering];
    }
}

#pragma mark WhitePlayerEventDelegate
- (void)phaseChanged:(WhitePlayerPhase)phase {
    [self updateWhitePlayerPhase:phase];
}
- (void)stoppedWithError:(NSError *)error {
    if([self.delegate respondsToSelector:@selector(whiteReplayerError:)]) {
        [self.delegate whiteReplayerError: error];
    }
}
- (void)errorWhenAppendFrame:(NSError *)error {
    if([self.delegate respondsToSelector:@selector(whiteReplayerError:)]) {
        [self.delegate whiteReplayerError: error];
    }
}
- (void)errorWhenRender:(NSError *)error {
    if([self.delegate respondsToSelector:@selector(whiteReplayerError:)]) {
        [self.delegate whiteReplayerError: error];
    }
}

#pragma mark WhiteCommonCallbackDelegate
- (void)throwError:(NSError *)error {
    if([self.delegate respondsToSelector:@selector(whiteReplayerError:)]) {
        [self.delegate whiteReplayerError: error];
    }
}

- (void)dealloc {
    if(self.whitePlayer != nil) {
        [self.whitePlayer stop];
    }
    self.whitePlayer = nil;
    self.whiteSDK = nil;
}
@end


