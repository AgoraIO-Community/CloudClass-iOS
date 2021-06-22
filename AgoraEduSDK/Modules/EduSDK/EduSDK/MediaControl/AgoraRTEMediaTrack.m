//
//  AgoraRTEMediaTrack.m
//  AgoraEduSDK
//
//  Created by SRS on 2021/6/1.
//

#import "AgoraRTEMediaTrack.h"
#import "AgoraRTCManager.h"

@implementation AgoraRTEMediaTrack
-(instancetype)init {
    if (self = [super init]) {
//        self.isStart = NO;
    }
    
    return self;
}

- (NSInteger)start {
    return 0;
}
- (NSInteger)stop {
    return 0;
}

@end


@interface AgoraRTECameraVideoTrack ()
@property (nonatomic, weak) AgoraRTCManager *rtc;
@property (nonatomic, strong) AgoraRtcVideoCanvas *localCanvas;
@end

@implementation AgoraRTECameraVideoTrack
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.rtc = [AgoraRTCManager shareManager];
        self.localCanvas = [[AgoraRtcVideoCanvas alloc] init];
        self.localCanvas.uid = 0;
        self.localCanvas.renderMode = AgoraVideoRenderModeHidden;
    }
    return self;
}

- (NSInteger)start {
    int result = [self.rtc enableLocalVideo:YES];
    return result;
}

- (NSInteger)stop {
    int result = [self.rtc enableLocalVideo:NO];
    return result;
}

- (NSInteger)switchCamera {
    int result = [self.rtc switchCamera];
    return result;
}

- (NSInteger)setView:(UIView * _Nullable)view {
    int result = 0;
    
    // clear
    if (self.localCanvas.view != nil && self.localCanvas.view != view) {
        self.localCanvas.view = nil;
        result = [self.rtc setupLocalVideo:self.localCanvas];
    }
    
    if (view == nil) {
        return result;
    }
    
    [self.rtc startPreview];
    
    self.localCanvas.view = view;
    result = [self.rtc setupLocalVideo:self.localCanvas];
    return result;
}

- (NSInteger)setRenderConfig:(AgoraRTERenderConfig *)config {
    self.localCanvas.renderMode = [self getRtcRenderModeWithRte:config.renderMode];
    int result = [self.rtc setupLocalVideo:self.localCanvas];
    return result;
}

- (NSInteger)setVideoEncoderConfig:(AgoraRTEVideoConfig *)config {

    AgoraVideoEncoderConfiguration *configuration = [AgoraVideoEncoderConfiguration new];
    configuration.dimensions = CGSizeMake(config.videoDimensionWidth, config.videoDimensionHeight);
    configuration.frameRate = config.frameRate;
    configuration.bitrate = config.bitrate;
    configuration.orientationMode = AgoraVideoOutputOrientationModeAdaptative;
    
    switch (config.degradationPreference) {
        case AgoraRTEDegradationMaintainQuality:
            configuration.degradationPreference = AgoraDegradationMaintainQuality;
            break;
        case AgoraRTEDegradationMaintainFramerate:
            configuration.orientationMode = AgoraDegradationMaintainFramerate;
            break;
        case AgoraRTEDegradationBalanced:
            configuration.orientationMode = AgoraDegradationBalanced;
            break;
        default:
            break;
    }
    
    NSInteger result = [self.rtc setVideoEncoderConfiguration:configuration];
    return result;
}

- (AgoraVideoRenderMode)getRtcRenderModeWithRte:(AgoraRTERenderMode)rte {
    switch (rte) {
        case AgoraRTERenderModeHidden:
            return AgoraVideoRenderModeHidden;
            break;
        case AgoraRTERenderModeFit:
            return AgoraVideoRenderModeFit;
            break;
    }
}
@end


@interface AgoraRTEMicrophoneAudioTrack ()
@property (nonatomic, weak) AgoraRTCManager *rtc;
@end

@implementation AgoraRTEMicrophoneAudioTrack
- (instancetype)init {
    if (self = [super init]) {
        self.rtc = [AgoraRTCManager shareManager];
    }
    
    return self;
}

- (NSInteger)start {
    int result = [self.rtc enableLocalAudio:YES];
    return result;
}

- (NSInteger)stop {
    int result = [self.rtc enableLocalAudio:NO];
    return result;
}
@end
