//
//  ReplayNoVideoViewController.m
//  AgoraEducation
//
//  Created by SRS on 2019/12/10.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "AgoraReplayViewController.h"
#import "AgoraReplayControlView.h"
#import "AgoraReplayTouchButton.h"
#import "AgoraReplayLoadingView.h"
#import "UIView+AgoraConstraint.h"
#import "AgoraReplayVideoView.h"
#import <YYModel/YYModel.h>

@interface AgoraReplayViewController ()<AgoraReplayControlViewDelegate, AgoraReplayDelegate>

@property (weak, nonatomic) IBOutlet UIView *whiteboardBaseView;
@property (weak, nonatomic) IBOutlet UIView *controlBgView;
@property (weak, nonatomic) AgoraReplayControlView *controlView;
@property (weak, nonatomic) IBOutlet UIView *loadingBgView;
@property (weak, nonatomic) AgoraReplayLoadingView *loadingView;
@property (weak, nonatomic) IBOutlet AgoraReplayTouchButton *backButton;
@property (weak, nonatomic) IBOutlet UIView *playBackgroundView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIView *teacherView;
@property (weak, nonatomic) IBOutlet UIImageView *defaultTeacherImage;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

@property (nonatomic, assign) BOOL playFinished;
// can seek when has buffer only for m3u8 video
@property (nonatomic, assign) BOOL canSeek;
@property (nonatomic, assign) BOOL bClickPlayButton;

// replay
@property (nonatomic, strong) AgoraReplayManager *replayManager;
@property (nonatomic, weak) UIView *boardView;
@property (nonatomic, weak) AgoraReplayVideoView *videoView;

@end

@implementation AgoraReplayViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    [self initData];
}

- (void)setConfigParams:(NSDictionary *)configParams {
    self.config = [AgoraReplayConfiguration.class yy_modelWithDictionary:configParams];
}

- (void)initData {

    self.canSeek = NO;
    self.bClickPlayButton = NO;
    self.playFinished = NO;

    self.controlView.delegate = self;

    self.replayManager = [AgoraReplayManager new];
    self.replayManager.delegate = self;

    NSAssert(self.config.videoConfig.urlString != nil && self.config.videoConfig.urlString.length > 0, @"can't find record video");
    [self setupReplay];
}

- (void)setupReplay {

    __weak typeof(self) weakself = self;
    [self.replayManager joinReplayWithConfiguration:self.config success:^(UIView * _Nonnull boardView, AVPlayer * _Nonnull avPlayer) {

        dispatch_async(dispatch_get_main_queue(), ^{

            [weakself initBoardView:boardView];
            [weakself.videoView setAVPlayer:avPlayer];

            [weakself seekToTimeInterval:0 completionHandler:^(BOOL finished) {
            }];
        });

    } failure:^(NSError * error) {
        [weakself showTipWithMessage:error.localizedDescription];
    }];
}

- (void)showTipWithMessage:(NSString *)toastMessage {

    self.tipLabel.hidden = NO;
    [self.tipLabel setText: toastMessage];

    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(disappearTipLabel) object:nil];
    [self performSelector:@selector(disappearTipLabel) withObject:toastMessage afterDelay:2];
}
- (void)disappearTipLabel {
    self.tipLabel.hidden = YES;
}

- (void)setupView {

    NSBundle *baseBundle = [NSBundle bundleForClass:AgoraReplayViewController.class];

    AgoraReplayControlView *controlView = [baseBundle loadNibNamed:@"AgoraReplayControlView" owner:self options:nil].firstObject;
    [self.controlBgView addSubview:controlView];
    [self equalFrom:controlView to:self.controlBgView];
    self.controlView = controlView;

    AgoraReplayLoadingView *loadingView = [baseBundle loadNibNamed:@"AgoraReplayLoadingView" owner:self options:nil].firstObject;
    [self.loadingBgView addSubview:loadingView];
    [self equalFrom:loadingView to:self.loadingBgView];
    self.loadingView = loadingView;

    AgoraReplayVideoView *videoView = [[AgoraReplayVideoView alloc] initWithFrame:CGRectZero];
    [self.teacherView addSubview:videoView];
    [self equalFrom:videoView to:self.teacherView];
    self.videoView = videoView;

    self.backButton.layer.cornerRadius = 6;
}

- (void)equalFrom:(UIView *)fromView to:(UIView *)toView {

    fromView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:fromView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:toView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:fromView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:toView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:fromView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:toView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:fromView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:toView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [toView addConstraints:@[topConstraint, leftConstraint, rightConstraint, bottomConstraint]];
}

- (void)initBoardView:(UIView *)boardView {
    [self.whiteboardBaseView insertSubview:boardView belowSubview:self.playBackgroundView];
    [boardView agora_EqualTo:self.whiteboardBaseView];
    self.boardView = boardView;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (void)dealloc {
    [self.replayManager leaveReplay];
    self.replayManager = nil;
}

#pragma mark Click Event
- (IBAction)onWhiteBoardClick:(id)sender {
    self.controlView.hidden = NO;

    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlView) object:nil];
    [self performSelector:@selector(hideControlView) withObject:nil afterDelay:3];
}

- (IBAction)onPlayClick:(id)sender {

    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlView) object:nil];
    [self performSelector:@selector(hideControlView) withObject:nil afterDelay:3];

    [self setPlayViewsVisible:YES];

    __weak typeof(self) weakself = self;
    if(self.playFinished) {
        self.playFinished = NO;
        [self seekToTimeInterval:0 completionHandler:^(BOOL finished) {
            [weakself.replayManager play];
        }];
    } else {
        if(!self.canSeek) {
            [self setLoadingViewVisible:YES];
        }
        [self.replayManager play];
    }
}

- (IBAction)onBackClick:(id)sender {
    
    if ([self.replayDelegate respondsToSelector:@selector(onReplayDismiss)]) {
        [self.replayDelegate onReplayDismiss];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)setLoadingViewVisible:(BOOL)onPlay {
    onPlay ? [self.loadingView showLoading] : [self.loadingView hiddenLoading];
    onPlay ? (self.playBackgroundView.hidden = NO) : (self.playBackgroundView.hidden = YES);
}

- (void)setPlayViewsVisible:(BOOL)onPlay {
    self.playBackgroundView.hidden = onPlay;
    self.playButton.hidden = onPlay;
    self.controlView.playOrPauseBtn.selected = onPlay;
}

- (void)hideControlView {
    self.controlView.hidden = YES;
}

- (void)seekToTimeInterval:(NSTimeInterval)seconds completionHandler:(void (^)(BOOL finished))completionHandler {
    CMTime cmTime = CMTimeMakeWithSeconds(seconds, 100);
    [self.replayManager seekToTime:cmTime completionHandler:completionHandler];
}

- (NSTimeInterval)timeTotleDuration {
    return (NSInteger)(self.config.endTime.integerValue - self.config.startTime.integerValue) * 0.001;
}

#pragma mark AgoraReplayControlViewDelegate
- (void)sliderTouchBegan:(float)value {
    if(!self.canSeek) {
        return;
    }
    self.controlView.sliderView.isdragging = YES;
}

- (void)sliderValueChanged:(float)value {
    if(!self.canSeek) {
        return;
    }

    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlView) object:nil];
    if ([self timeTotleDuration] > 0) {
        Float64 seconds = [self timeTotleDuration] * value;
        [self seekToTimeInterval:seconds completionHandler:^(BOOL finished) {
        }];
    }
}

- (void)sliderTouchEnded:(float)value {
    if(!self.canSeek) {
        self.controlView.sliderView.isdragging = NO;
        return;
    }

    if ([self timeTotleDuration] == 0) {
        self.controlView.sliderView.value = 0;
        return;
    }
    self.controlView.sliderView.value = value;
    float currentTime = [self timeTotleDuration] * value;

    __weak typeof(self) weakself = self;
    [self seekToTimeInterval:currentTime completionHandler:^(BOOL finished) {
        NSString *currentTimeStr = [weakself convertTimeSecond: currentTime];
        NSString *totleTimeStr = [weakself convertTimeSecond: [weakself timeTotleDuration]];
        NSString *timeStr = [NSString stringWithFormat:@"%@ / %@", currentTimeStr, totleTimeStr];
        weakself.controlView.timeLabel.text = timeStr;

        weakself.controlView.sliderView.isdragging = NO;
    }];
}

- (NSString *)convertTimeSecond:(NSInteger)timeSecond {
    NSString *theLastTime = nil;
    long second = timeSecond;
    if (timeSecond < 60) {
        theLastTime = [NSString stringWithFormat:@"00:%02zd", second];
    } else if(timeSecond >= 60 && timeSecond < 3600){
        theLastTime = [NSString stringWithFormat:@"%02zd:%02zd", second/60, second%60];
    } else if(timeSecond >= 3600){
        theLastTime = [NSString stringWithFormat:@"%02zd:%02zd:%02zd", second/3600, second%3600/60, second%60];
    }
    return theLastTime;
}

- (void)sliderTapped:(float)value {

    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlView) object:nil];

    self.controlView.sliderView.isdragging = YES;

    if([self timeTotleDuration] > 0) {
        NSInteger currentTime = [self timeTotleDuration] * value;
        __weak typeof(self) weakself = self;
        [self seekToTimeInterval:currentTime completionHandler:^(BOOL finished) {
            NSString *currentTimeStr = [weakself convertTimeSecond: currentTime];
            NSString *totleTimeStr = [weakself convertTimeSecond: [weakself timeTotleDuration]];
            NSString *timeStr = [NSString stringWithFormat:@"%@ / %@", currentTimeStr, totleTimeStr];
            weakself.controlView.timeLabel.text = timeStr;

            weakself.controlView.sliderView.isdragging = NO;
        }];
    } else {

        self.controlView.sliderView.value = 0;
        self.controlView.sliderView.isdragging = NO;
    }
}

- (void)playPauseButtonClicked:(BOOL)play {

    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlView) object:nil];

    [self setPlayViewsVisible:play];

    if(play) {
        [self performSelector:@selector(hideControlView) withObject:nil afterDelay:3];

        __weak typeof(self) weakself = self;
        if(self.playFinished) {
            self.playFinished = NO;
            [self seekToTimeInterval:0 completionHandler:^(BOOL finished) {
                [weakself.replayManager play];
            }];
        } else {
            [self.replayManager play];
        }

    } else {
        [self.replayManager pause];
    }
}

#pragma mark ReplayDelegate
- (void)replayTimeChanged:(NSTimeInterval)time {
    if(self.controlView.sliderView.isdragging){
        return;
    }

    if([self timeTotleDuration] > 0){
        float value = time / [self timeTotleDuration];
        self.controlView.sliderView.value = value;
        NSString *totleTimeStr = [self convertTimeSecond: [self timeTotleDuration]];
        NSString *currentTimeStr = [self convertTimeSecond: time];
        NSString *timeStr = [NSString stringWithFormat:@"%@ / %@", currentTimeStr, totleTimeStr];
        self.controlView.timeLabel.text = timeStr;
    }
}
- (void)replayStartBuffering {
    if(self.playButton.hidden){
        [self setLoadingViewVisible:YES];
    }
}
- (void)replayEndBuffering {
    if(self.playButton.hidden){
        [self setLoadingViewVisible:NO];
    }
    self.canSeek = YES;
}
- (void)replayDidFinish {
    [self.replayManager pause];

    [self setLoadingViewVisible:NO];
    [self setPlayViewsVisible:NO];

    self.playFinished = YES;
    self.controlView.hidden = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlView) object:nil];
}
- (void)replayPause {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlView) object:nil];
    self.controlView.hidden = NO;
    [self setPlayViewsVisible:NO];
}
- (void)replayError:(NSError * _Nullable)error {
    [self showTipWithMessage:error.localizedDescription];
}

@end
