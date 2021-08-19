//
//  AgoraRTCManager.m
//  AgoraEdu
//
//  Created by SRS on 2020/5/4.
//  Copyright © 2020 agora. All rights reserved.
//

#import "AgoraRTCManager.h"
#import "AgoraRTELogService.h"
#import "AgoraRTELogService.h"
#import <AgoraReport/AgoraReport.h>
#import <AgoraReport/AgoraReport-Swift.h>
#import <EduSDK/EduSDK-Swift.h>

#define AgoraRTCNoNullString(x) ([x isKindOfClass:NSString.class] ? x : @"")
#define AgoraRTCNoNull(x) ((x == nil) ? @"nil" : x)

@implementation AgoraRTCChannelDelegateConfig
@end

@interface RTCChannelInfo: NSObject
@property (nonatomic, strong) AgoraRtcChannel *agoraRtcChannel;
@property (nonatomic, assign) AgoraClientRole role;
@property (nonatomic, assign) BOOL isPublish;

@property (nonatomic, strong) NSString *channelId;
@property (nonatomic, strong) AgoraRTCChannelDelegateConfig *config;
@end
@implementation RTCChannelInfo
@end


@interface RTCRemoteStreamStateInfo: NSObject
@property (nonatomic, strong) NSString *channelId;
@property (nonatomic, strong) AgoraRtcRemoteVideoStats *stats;
@end
@implementation RTCRemoteStreamStateInfo
@end

@interface AgoraRTCManager()<AgoraRtcEngineDelegate, AgoraRtcChannelDelegate, AgoraSubThreadTimerDelegate>
@property (nonatomic, strong) AgoraRtcEngineKit * _Nullable rtcEngineKit;

@property (nonatomic, assign) BOOL currentEnableVideo;
@property (nonatomic, assign) BOOL currentEnableAudio;

@property (nonatomic, assign) BOOL currentMuteVideo;
@property (nonatomic, assign) BOOL currentMuteAudio;

@property (nonatomic, assign) BOOL currentMuteAllRemoteVideo;
@property (nonatomic, assign) BOOL currentMuteAllRemoteAudio;

@property (nonatomic, assign) BOOL frontCamera;

@property (nonatomic, strong) NSMutableArray<RTCChannelInfo *> *rtcChannelInfos;

@property (nonatomic, strong) NSMutableArray<RTCRemoteStreamStateInfo *> *rtcStreamStates;
@property (nonatomic, strong) AgoraSubThreadTimer *threadTimer;
@end

static AgoraRTCManager *manager = nil;

@implementation AgoraRTCManager
+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
        [manager initData];
    });
    return manager;
}

+ (NSString *)sdkVersion {
    return [AgoraRtcEngineKit getSdkVersion];
}

- (void)initData {
    self.frontCamera = YES;
    self.currentEnableVideo = NO;
    self.currentEnableAudio = NO;
    self.currentMuteAudio = NO;
    self.currentMuteVideo = NO;
    self.currentMuteAllRemoteAudio = NO;
    self.currentMuteAllRemoteVideo = NO;
    
    self.rtcChannelInfos = [NSMutableArray array];
    self.rtcStreamStates = [NSMutableArray array];
    
    if (self.threadTimer == nil) {
        self.threadTimer = [[AgoraSubThreadTimer alloc] initWithThreadName:@"io.agora.timer.event" timeInterval:2.0];
        self.threadTimer.delegate = self;
    }
}

- (void)initEngineKitWithAppid:(NSString *)appid {
    
    [AgoraRTELogService logMessageWithDescribe:@"init rtcEngineKit appid:" message:AgoraRTCNoNullString(appid)];
    
    if(self.rtcEngineKit == nil){
        self.rtcEngineKit = [AgoraRtcEngineKit sharedEngineWithAppId:appid delegate:self];
    }

    [self.rtcEngineKit enableVideo];
    [self.rtcEngineKit enableWebSdkInteroperability:YES];
    [self.rtcEngineKit enableDualStreamMode:YES];
    
    [self.rtcEngineKit disableLastmileTest];
    
    [self.threadTimer start];
}

- (int)joinChannelByToken:(NSString * _Nullable)token channelId:(NSString * _Nonnull)channelId info:(NSString * _Nullable)info uid:(NSUInteger)uid {
    
    return [self joinChannelByToken:token channelId:channelId info:info uid:uid autoSubscribeAudio:YES autoSubscribeVideo:YES];
}

- (int)joinChannelByToken:(NSString * _Nullable)token channelId:(NSString * _Nonnull)channelId info:(NSString * _Nullable)info uid:(NSUInteger)uid autoSubscribeAudio:(BOOL)autoSubscribeAudio autoSubscribeVideo:(BOOL)autoSubscribeVideo {
    
    [AgoraRTELogService logMessageWithDescribe:@"join channel:" message:@{@"roomUuid":AgoraRTCNoNullString(channelId), @"token":AgoraRTCNoNullString(token), @"uid":@(uid)}];
    
    AgoraRtcChannel *agoraRtcChannel = [self.rtcEngineKit createRtcChannel:channelId];
    [agoraRtcChannel setRtcChannelDelegate:self];
    
    BOOL isExsit = NO;
    for (RTCChannelInfo *channelInfo in self.rtcChannelInfos) {
        if ([channelInfo.channelId isEqualToString:channelId]) {
            isExsit = YES;
            channelInfo.agoraRtcChannel = agoraRtcChannel;
            channelInfo.isPublish = NO;
            channelInfo.role = AgoraClientRoleAudience;
        }
    }
    if (!isExsit) {
        RTCChannelInfo *channelInfo = [RTCChannelInfo new];
        channelInfo.agoraRtcChannel = agoraRtcChannel;
        channelInfo.isPublish = NO;
        channelInfo.role = AgoraClientRoleAudience;
        channelInfo.channelId = channelId;
        [self.rtcChannelInfos addObject:channelInfo];
    }
    
    AgoraRtcChannelMediaOptions *mediaOptions = [AgoraRtcChannelMediaOptions new];
    mediaOptions.autoSubscribeAudio = YES;//autoSubscribeAudio;
    mediaOptions.autoSubscribeVideo = YES;//autoSubscribeVideo;
    return [agoraRtcChannel joinChannelByToken:token info:info uid:uid options:mediaOptions];
}

- (void)setChannelDelegateWithConfig:(AgoraRTCChannelDelegateConfig *)config channelId:(NSString * _Nonnull)channelId {
    for (RTCChannelInfo *channelInfo in self.rtcChannelInfos) {
        if([channelInfo.channelId isEqualToString:channelId]) {
            if (channelInfo.config == nil) {
                channelInfo.config = config;
            } else {
                if (config.delegate != nil) {
                    channelInfo.config.delegate = config.delegate;
                }
                if (config.statisticsReportDelegate != nil) {
                    channelInfo.config.statisticsReportDelegate = config.statisticsReportDelegate;
                }
                if (config.streamStateDelegate != nil) {
                    channelInfo.config.streamStateDelegate = config.streamStateDelegate;
                }
                if (config.errorDelegate != nil) {
                    channelInfo.config.errorDelegate = config.errorDelegate;
                }
            }
            
            return;
        }
    }
    
    RTCChannelInfo *channelInfo = [RTCChannelInfo new];
    channelInfo.channelId = channelId;
    channelInfo.config = config;
    [self.rtcChannelInfos addObject:channelInfo];
}

#pragma mark Configuration
- (NSInteger)setVideoEncoderConfiguration:(AgoraVideoEncoderConfiguration *)configuration {
        
    NSInteger errCode = [self.rtcEngineKit setVideoEncoderConfiguration:configuration];
    
    [self.rtcEngineKit enableLocalVideo:NO];
    [self.rtcEngineKit enableLocalAudio:NO];
    
    return errCode;
}

- (int)setChannelProfile:(AgoraChannelProfile)profile {
    return [self.rtcEngineKit setChannelProfile:profile];
}

- (void)setLogFile:(NSString *)logDirPath {
    NSString *logFilePath = @"";
    if ([[logDirPath substringFromIndex:logDirPath.length-1] isEqualToString:@"/"]) {
        logFilePath = [logDirPath stringByAppendingString:@"agoraRTC.log"];
    } else {
        logFilePath = [logDirPath stringByAppendingString:@"/agoraRTC.log"];
    }
    
    [self.rtcEngineKit setLogFile:logFilePath];
    [self.rtcEngineKit setLogFileSize:512];
    [self.rtcEngineKit setLogFilter:AgoraLogFilterInfo];
}

- (int)setClientRole:(AgoraClientRole)role channelId:(NSString *)channelId {
    
    for(RTCChannelInfo *channelInfo in self.rtcChannelInfos) {
        if (channelInfo.agoraRtcChannel && [channelInfo.channelId isEqualToString:channelId]) {
            if (channelInfo.role == role) {
                return 0;
            }
            
            int code = [channelInfo.agoraRtcChannel setClientRole:role];
            if (role == AgoraClientRoleAudience) {
                [AgoraRTELogService logMessageWithDescribe:@"set role:" message:@{
                    @"roomUuid": AgoraRTCNoNullString(channelId),
                    @"role": @"AgoraClientRoleAudience",
                    @"code": @(code),
                }];
            } else if (role == AgoraClientRoleBroadcaster) {
                [AgoraRTELogService logMessageWithDescribe:@"set role:" message:@{
                    @"roomUuid": AgoraRTCNoNullString(channelId),
                    @"role": @"AgoraClientRoleBroadcaster",
                    @"code": @(code),
                }];
            }
            if (code == 0) {
                channelInfo.role = role;
            }
            return code;
        }
    }
    return 0;
}

#pragma mark Enable
- (int)enableLocalVideo:(BOOL)enable {
    
    if(enable == self.currentEnableVideo) {
        return 0;
    }
    
    int code = [self.rtcEngineKit enableLocalVideo:enable];
    [AgoraRTELogService logMessageWithDescribe:@"enableLocalVideo:" message:@{@"enable":@(enable), @"code":@(code)}];
    if (code == 0) {
        self.currentEnableVideo = enable;
    }
    return code;
}

- (int)enableLocalAudio:(BOOL)enable {
    
    if(enable == self.currentEnableAudio) {
        return 0;
    }
    
    int code = [self.rtcEngineKit enableLocalAudio:enable];
    [AgoraRTELogService logMessageWithDescribe:@"enableLocalAudio:" message:@{@"enable":@(enable), @"code":@(code)}];
    if (code == 0) {
        self.currentEnableAudio = enable;
    }
    return code;
}

#pragma mark Mute
- (int)publishChannelId:(NSString *)channelId {
    
    RTCChannelInfo *currentChannelInfo;
    for(RTCChannelInfo *channelInfo in self.rtcChannelInfos) {
        if (!(channelInfo.agoraRtcChannel && [channelInfo.channelId isEqualToString:channelId])) {
            if (channelInfo.isPublish) {
                [self setClientRole:AgoraClientRoleBroadcaster channelId:[currentChannelInfo.agoraRtcChannel getChannelId]];
                int code = [channelInfo.agoraRtcChannel unpublish];
                [AgoraRTELogService logMessageWithDescribe:@"unpublish:" message:@{@"roomUuid":AgoraRTCNoNullString(channelId), @"code":@(code)}];
                if (code == 0) {
                    channelInfo.isPublish = NO;
                } else {
                    return code;
                }
            }
        } else if (channelInfo.agoraRtcChannel) {
            currentChannelInfo = channelInfo;
        }
    }
    
    if (currentChannelInfo != nil) {
        if(!currentChannelInfo.isPublish) {
            if(currentChannelInfo.role != AgoraClientRoleBroadcaster) {
                int code = [self setClientRole:AgoraClientRoleBroadcaster channelId:[currentChannelInfo.agoraRtcChannel getChannelId]];
                if (code == 0) {
                    currentChannelInfo.isPublish = YES;
                }
                return code;
            } else {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    
                    int code = [currentChannelInfo.agoraRtcChannel publish];
                    [AgoraRTELogService logMessageWithDescribe:@"publish:" message:@{@"roomUuid":AgoraRTCNoNullString(currentChannelInfo.channelId), @"code":@(code)}];
                    
                    if (code == 0) {
                        currentChannelInfo.isPublish = YES;
                    }
                });
            }
            
            return 0;
        }
    }
    
    return 0;
}
- (int)unPublishChannelId:(NSString *)channelId {
    for(RTCChannelInfo *channelInfo in self.rtcChannelInfos) {
        if (channelInfo.agoraRtcChannel && [channelInfo.channelId isEqualToString:channelId]) {
            if (channelInfo.isPublish) {
                int code = [channelInfo.agoraRtcChannel unpublish];
                [AgoraRTELogService logMessageWithDescribe:@"unpublish:" message:@{@"roomUuid":AgoraRTCNoNullString(channelId), @"code":@(code)}];
                if (code == 0) {
                    channelInfo.isPublish = NO;
                }
                return code;
            }
            return 0;
        }
    }
    return 0;
}

- (int)muteLocalVideoStream:(BOOL)mute {
    
    if(mute == self.currentMuteVideo) {
        return 0;
    }
    
    int code = [self.rtcEngineKit muteLocalVideoStream:mute];
    [AgoraRTELogService logMessageWithDescribe:@"muteLocalVideoStream:" message:@{@"mute":@(mute), @"code":@(code)}];
    if (code == 0) {
        self.currentMuteVideo = mute;
    }
    return code;
}

- (int)muteLocalAudioStream:(BOOL)mute {
    
    if(mute == self.currentMuteAudio) {
        return 0;
    }
    
    int code = [self.rtcEngineKit muteLocalAudioStream:mute];
    [AgoraRTELogService logMessageWithDescribe:@"muteLocalAudioStream:" message:@{@"mute":@(mute), @"code":@(code)}];
    if (code == 0) {
        self.currentMuteAudio = mute;
    }
    return code;
}

- (int)muteRemoteAudioStream:(NSString *)uid mute:(BOOL)mute channelId:(NSString *)channelId {
    
    for(RTCChannelInfo *channelInfo in self.rtcChannelInfos) {
        if (channelInfo.agoraRtcChannel && [channelInfo.channelId isEqualToString:channelId]) {
            
            NSUInteger streamUid = uid.longLongValue;
            int code = [channelInfo.agoraRtcChannel muteRemoteAudioStream:streamUid mute:mute];
            
            [AgoraRTELogService logMessageWithDescribe:@"muteRemoteAudioStream:" message:@{@"roomUuid":AgoraRTCNoNullString(channelId), @"uid":AgoraRTCNoNullString(uid), @"mute":@(mute), @"code":@(code)}];
            
            return code;
        }
    }
    
    return 0;
}

- (int)muteRemoteVideoStream:(NSString *)uid mute:(BOOL)mute channelId:(NSString *)channelId {
    
    for(RTCChannelInfo *channelInfo in self.rtcChannelInfos) {
        if (channelInfo.agoraRtcChannel && [channelInfo.channelId isEqualToString:channelId]) {
            
            NSUInteger streamUid = uid.longLongValue;
            int code = [channelInfo.agoraRtcChannel muteRemoteVideoStream:streamUid mute:mute];
            
            [AgoraRTELogService logMessageWithDescribe:@"muteRemoteVideoStream:" message:@{@"roomUuid":AgoraRTCNoNullString(channelId), @"uid":AgoraRTCNoNullString(uid), @"mute":@(mute), @"code":@(code)}];
            
            return code;
        }
    }
    return 0;
}

- (int)muteAllRemoteAudioStreams:(BOOL)mute {
    
    if(mute == self.currentMuteAllRemoteAudio) {
        return 0;
    }
    
    int code = [self.rtcEngineKit muteAllRemoteAudioStreams:mute];
    [AgoraRTELogService logMessageWithDescribe:@"muteAllRemoteAudioStreams:" message:@{@"mute":@(mute),@"code":@(code)}];
    if (code == 0) {
        self.currentMuteAllRemoteAudio = mute;
    }
    return code;
}

- (int)muteAllRemoteVideoStreams:(BOOL)mute {
    
    if(mute == self.currentMuteAllRemoteVideo) {
        return 0;
    }
    
    int code = [self.rtcEngineKit muteAllRemoteVideoStreams:mute];
    [AgoraRTELogService logMessageWithDescribe:@"muteAllRemoteVideoStreams:" message:@{@"mute":@(mute),@"code":@(code)}];
    if (code == 0) {
        self.currentMuteAllRemoteVideo = mute;
    }
    return code;
}

#pragma mark Render
- (int)startPreview {
    
    int code = [self.rtcEngineKit startPreview];
    [AgoraRTELogService logMessageWithDescribe:@"startPreview:" message:@{@"code":@(code)}];
    
    return code;
}

- (int)setupLocalVideo:(AgoraRtcVideoCanvas * _Nullable)local {
    
    int code =  [self.rtcEngineKit setupLocalVideo:local];
#ifdef AgoraRtcKit_2_X
    [AgoraRTELogService logMessageWithDescribe:@"setupLocalVideo:" message:@{@"roomUuid":AgoraRTCNoNullString(local.channel), @"uid": @(local.uid), @"code":@(code)}];
#endif
#ifdef AgoraRtcKit_3_X
    [AgoraRTELogService logMessageWithDescribe:@"setupLocalVideo:" message:@{@"roomUuid":AgoraRTCNoNullString(local.channelId), @"uid": @(local.uid), @"code":@(code)}];
#endif
    
    return code;
}

- (int)setupRemoteVideo:(AgoraRtcVideoCanvas * _Nonnull)remote {
    
    int code =  [self.rtcEngineKit setupRemoteVideo:remote];
    
#ifdef AgoraRtcKit_2_X
    [AgoraRTELogService logMessageWithDescribe:@"setupRemoteVideo:" message:@{@"roomUuid":AgoraRTCNoNullString(remote.channel), @"uid": @(remote.uid), @"code":@(code)}];
#endif
#ifdef AgoraRtcKit_3_X
    [AgoraRTELogService logMessageWithDescribe:@"setupRemoteVideo:" message:@{@"roomUuid":AgoraRTCNoNullString(remote.channelId), @"uid": @(remote.uid), @"code":@(code)}];
#endif

    return code;
}

- (int)setRemoteVideoStream:(NSString *)uid type:(AgoraVideoStreamType)streamType {
    return [self.rtcEngineKit setRemoteVideoStream:uid.longLongValue type:streamType];
}

#pragma mark Lastmile
- (int)startLastmileProbeTest:(NSString *)appid dataSourceDelegate:(id<AgoraRTCRateDelegate> _Nullable)rtcDelegate {
    
    if (self.rtcEngineKit == nil) {
        self.rtcEngineKit = [AgoraRtcEngineKit sharedEngineWithAppId:appid delegate:self];
    }
    self.rateDelegate = rtcDelegate;
    return [self.rtcEngineKit enableLastmileTest];
}

#pragma mark Rate
- (NSString *)getCallIdWithChannelId:(NSString *)channelId {
    
    AgoraRtcChannel *channel = [self getRtcChannelWithChannelId:channelId];
    
    NSString *callId = [channel getCallId];
    
    [AgoraRTELogService logMessageWithDescribe:@"callId:" message:callId];
    
    return callId;
}

- (int)rate:(NSString *)callId rating:(NSInteger)rating description:(NSString *)description {
    
    int rate = [self.rtcEngineKit rate:callId rating:rating description:description];
    
    [AgoraRTELogService logMessageWithDescribe:@"rate:" message:@{@"callId":AgoraRTCNoNullString(callId), @"rating":@(rating), @"description":AgoraRTCNoNullString(description), @"rate":@(rate)}];
    
    return rate;
}

#pragma mark AudioMixing
- (int)startAudioMixing:(NSString *  _Nonnull)filePath loopback:(BOOL)loopback replace:(BOOL)replace cycle:(NSInteger)cycle {
    
    int code = [self.rtcEngineKit startAudioMixing:filePath loopback:loopback replace:replace cycle:cycle];
    
    [AgoraRTELogService logMessageWithDescribe:@"startAudioMixing:" message: @{@"filePath":AgoraRTCNoNullString(filePath), @"loopback":@(loopback), @"replace":@(replace), @"cycle":@(cycle), @"code":@(code)}];
    
    return code;
}

- (int)setAudioMixingPosition:(NSInteger)pos {
    
    int code = [self.rtcEngineKit setAudioMixingPosition:pos];
    
    [AgoraRTELogService logMessageWithDescribe:@"setAudioMixingPosition:" message:@{@"pos":@(pos), @"code":@(code)}];
    
    return code;
}

- (int)pauseAudioMixing {
    
    int code = [self.rtcEngineKit pauseAudioMixing];
    
    [AgoraRTELogService logMessageWithDescribe:@"pauseAudioMixing:" message:@{@"code":@(code)}];
    
    return code;
}

- (int)resumeAudioMixing {
    
    int code = [self.rtcEngineKit resumeAudioMixing];
    
    [AgoraRTELogService logMessageWithDescribe:@"resumeAudioMixing:" message:@{@"code":@(code)}];
    
    return code;
}

- (int)stopAudioMixing {
    
    int code = [self.rtcEngineKit stopAudioMixing];
    
    [AgoraRTELogService logMessageWithDescribe:@"stopAudioMixing:" message:@{@"code":@(code)}];
    
    return code;
}

- (int)getAudioMixingDuration {
    int duration = [self.rtcEngineKit getAudioMixingDuration];
    
    [AgoraRTELogService logMessageWithDescribe:@"getAudioMixingDuration:" message:@{@"duration": @(duration)}];
    
    return duration;
}

- (int)getAudioMixingCurrentPosition {
    int position = [self.rtcEngineKit getAudioMixingCurrentPosition];
    
    [AgoraRTELogService logMessageWithDescribe:@"getAudioMixingCurrentPosition:" message:@{@"currentPosition": @(position)}];
    
    return position;
}

- (int)adjustAudioMixingPublishVolume:(NSInteger)volume {
    int code = [self.rtcEngineKit adjustAudioMixingPublishVolume:volume];
    
    [AgoraRTELogService logMessageWithDescribe:@"adjustAudioMixingPublishVolume:" message:@{@"volume": @(volume)}];
    
    return code;
}

- (int)adjustAudioMixingPlayoutVolume:(NSInteger)volume {
    int code = [self.rtcEngineKit adjustAudioMixingPublishVolume:volume];
    
    [AgoraRTELogService logMessageWithDescribe:@"adjustAudioMixingPlayoutVolume:" message:@{@"volume": @(volume)}];
    
    return code;
}

- (int)getAudioMixingPublishVolume {
    int volume = [self.rtcEngineKit getAudioMixingPublishVolume];
    
    [AgoraRTELogService logMessageWithDescribe:@"getAudioMixingPublishVolume:" message:@{@"volume": @(volume)}];
    
    return volume;
}

- (int)getAudioMixingPlayoutVolume {
    int volume = [self.rtcEngineKit getAudioMixingPlayoutVolume];
    
    [AgoraRTELogService logMessageWithDescribe:@"getAudioMixingPlayoutVolume:" message:@{@"volume": @(volume)}];
    
    return volume;
}

#pragma mark AudioEffect
- (int)enableAudioVolumeIndication:(NSInteger)interval smooth:(NSInteger)smooth report_vad:(BOOL)report_vad {
    
    int code = [self.rtcEngineKit enableAudioVolumeIndication:interval smooth:smooth report_vad:report_vad];
    
    [AgoraRTELogService logMessageWithDescribe:@"enableAudioVolumeIndication:" message:@{@"interval":@(interval), @"smooth":@(smooth), @"report_vad":@(report_vad)}];
    
    return code;
}
- (int)setLocalVoiceChanger:(AgoraAudioVoiceChanger)voiceChanger {
    
    int code = [self.rtcEngineKit setLocalVoiceChanger:voiceChanger];
    
    [AgoraRTELogService logMessageWithDescribe:@"setLocalVoiceChanger:" message:@{@"voiceChanger":@(voiceChanger), @"code":@(code)}];
    
    return code;
}

- (int)setLocalVoiceReverbPreset:(AgoraAudioReverbPreset)reverbPreset {
    
    int code = [self.rtcEngineKit setLocalVoiceReverbPreset:reverbPreset];
    
    [AgoraRTELogService logMessageWithDescribe:@"setLocalVoiceReverbPreset:" message:@{@"reverbPreset":@(reverbPreset), @"code":@(code)}];
    
    return code;
}

#pragma mark - MediaDevice
- (int)switchCamera {
    self.frontCamera = !self.frontCamera;
    
    [AgoraRTELogService logMessageWithDescribe:@"switch camera:" message: self.frontCamera ? @"front" : @"back"];
    
    return [self.rtcEngineKit switchCamera];
}
- (int)setEnableSpeakerphone:(BOOL)enable {
    [AgoraRTELogService logMessageWithDescribe:@"enableSpeakerphone:" message: @(enable)];
    return [self.rtcEngineKit setEnableSpeakerphone:enable];
}
- (BOOL)isSpeakerphoneEnabled {
    BOOL enable = [self.rtcEngineKit isSpeakerphoneEnabled];
    [AgoraRTELogService logMessageWithDescribe:@"isSpeakerphoneEnabled:" message: @(enable)];
    return enable;
}
- (int)enableInEarMonitoring:(BOOL)enabled {
    return [self.rtcEngineKit enableInEarMonitoring:enabled];
}

#pragma mark Private Parameters
- (int)setParameters:(NSString * _Nonnull)options {
    
    int code = [self.rtcEngineKit setParameters:options];
    
    [AgoraRTELogService logMessageWithDescribe:@"setParameters:" message:@{@"options":AgoraRTCNoNullString(options), @"code":@(code)}];
    
    return code;
}

+ (NSString *_Nullable)getErrorDescription:(NSInteger)code {
    if([AgoraRtcEngineKit respondsToSelector:@selector(getErrorDescription:)]) {
        [AgoraRtcEngineKit performSelector:@selector(getErrorDescription:) withObject:@(code)];
    }
    return @"";
}

#pragma mark Release
- (void)destoryWithChannelId:(NSString *)channelId {
    [AgoraRTELogService logMessageWithDescribe:@"desotry rtc:" message:@{@"roomUuid": AgoraRTCNoNullString(channelId)}];
    
    RTCChannelInfo *rmvChannelInfo;
    for (RTCChannelInfo *channelInfo in self.rtcChannelInfos) {
        if (channelInfo.agoraRtcChannel) {
            NSString *_channelId = AgoraRTCNoNullString(channelInfo.channelId);
            if ([_channelId isEqualToString:AgoraRTCNoNullString(channelId)]) {
                rmvChannelInfo = channelInfo;
                [channelInfo.agoraRtcChannel leaveChannel];
                [channelInfo.agoraRtcChannel destroy];
            }
        }
    }
    if (rmvChannelInfo != nil) {
        [self.rtcChannelInfos removeObject:rmvChannelInfo];
    }
}

- (void)destory {
    [AgoraRTELogService logMessageWithDescribe:@"desotry rtc" message:nil];
    
    for(RTCChannelInfo *channelInfo in self.rtcChannelInfos) {
        if (channelInfo.agoraRtcChannel) {
            [channelInfo.agoraRtcChannel leaveChannel];
            [channelInfo.agoraRtcChannel destroy];
        }
    }
    [self.rtcStreamStates removeAllObjects];
    [self.rtcChannelInfos removeAllObjects];
    [self.threadTimer stop];
    
    [self.rtcEngineKit stopPreview];
    
    BOOL cameraBackup = self.frontCamera;
    [self initData];
    self.frontCamera = cameraBackup;
}

-(void)dealloc {
    [self destory];
}

#pragma mark AgoraRtcChannelDelegate
- (void)rtcChannelDidJoinChannel:(AgoraRtcChannel * _Nonnull)rtcChannel
                         withUid:(NSUInteger)uid
                         elapsed:(NSInteger) elapsed {
    
    [AgoraRTELogService logMessageWithDescribe:@"didJoinChannel:" message:@{@"roomUuid":AgoraRTCNoNullString(rtcChannel.getChannelId), @"uid":@(uid), @"elapsed":@(elapsed)}];

    [self.threadTimer start];
    
    for (RTCChannelInfo *channelInfo in self.rtcChannelInfos) {
        if (channelInfo.config && [channelInfo.channelId isEqualToString:rtcChannel.getChannelId]) {
            if ([channelInfo.config.delegate respondsToSelector:@selector(rtcChannelDidJoinChannel:withUid:)]) {
                [channelInfo.config.delegate rtcChannelDidJoinChannel:channelInfo.channelId withUid:uid];
            }
            
            return;
        }
    }
}

//
- (void)rtcChannel:(AgoraRtcChannel *_Nonnull)rtcChannel didClientRoleChanged:(AgoraClientRole)oldRole newRole:(AgoraClientRole)newRole {
    if(newRole == AgoraClientRoleBroadcaster) {
        for(RTCChannelInfo *channelInfo in self.rtcChannelInfos) {
            if (channelInfo.agoraRtcChannel && [channelInfo.channelId isEqualToString:[rtcChannel getChannelId]]) {
                if (channelInfo.isPublish) {
                    [AgoraRTELogService logMessageWithDescribe:@"publish after role change start" message:nil];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        int code = [rtcChannel publish];
                        [AgoraRTELogService logMessageWithDescribe:@"publish after role change end:" message:@{@"roomUuid":AgoraRTCNoNullString([rtcChannel getChannelId]), @"code":@(code)}];
                    });
                    
                    break;
                }
            }
        }
    }
}

- (void)rtcChannel:(AgoraRtcChannel * _Nonnull)rtcChannel
    didJoinedOfUid:(NSUInteger)uid
           elapsed:(NSInteger)elapsed {
    
    [AgoraRTELogService logMessageWithDescribe:@"didJoinedOfUid:" message:@{@"roomUuid":AgoraRTCNoNullString(rtcChannel.getChannelId), @"uid":@(uid), @"elapsed":@(elapsed)}];
    
    BOOL containsState = NO;
    for (NSInteger index = 0; index < self.rtcStreamStates.count; index++) {
        RTCRemoteStreamStateInfo *info = self.rtcStreamStates[index];
        if([info.channelId isEqualToString:[rtcChannel getChannelId]] && info.stats.uid == uid) {
            self.rtcStreamStates[index].stats = [[AgoraRtcRemoteVideoStats alloc] init];
            self.rtcStreamStates[index].stats.uid = uid;
            containsState = YES;
            break;
        }
    }
    if (!containsState) {
        RTCRemoteStreamStateInfo *info = [[RTCRemoteStreamStateInfo alloc] init];
        info.channelId = [rtcChannel getChannelId];
        info.stats = [[AgoraRtcRemoteVideoStats alloc] init];
        info.stats.uid = uid;
        [self.rtcStreamStates addObject:info];
    }
    
    for (RTCChannelInfo *channelInfo in self.rtcChannelInfos) {
        if (channelInfo.config && [channelInfo.channelId isEqualToString:rtcChannel.getChannelId]) {
            
            if ([channelInfo.config.delegate respondsToSelector:@selector(rtcChannel:didJoinedOfUid:)]) {
                [channelInfo.config.delegate rtcChannel:channelInfo.channelId didJoinedOfUid:uid];
            }
            return;
        }
    }
}

- (void)rtcChannel:(AgoraRtcChannel * _Nonnull)rtcChannel
   didOfflineOfUid:(NSUInteger)uid
            reason:(AgoraUserOfflineReason)reason {
    [AgoraRTELogService logMessageWithDescribe:@"didOfflineOfUid:" message:@{@"roomUuid":AgoraRTCNoNullString(rtcChannel.getChannelId), @"uid":@(uid), @"reason":@(reason)}];
    
    for (NSInteger index = 0; index < self.rtcStreamStates.count; index++) {
        RTCRemoteStreamStateInfo *info = self.rtcStreamStates[index];
        if([info.channelId isEqualToString:[rtcChannel getChannelId]] && info.stats.uid == uid) {
            [self.rtcStreamStates removeObject:info];
            break;
        }
    }
    
    for (RTCChannelInfo *channelInfo in self.rtcChannelInfos) {
        if (channelInfo.config && [channelInfo.channelId isEqualToString:rtcChannel.getChannelId]) {
            
            if ([channelInfo.config.delegate respondsToSelector:@selector(rtcChannel:didOfflineOfUid:)]) {
                [channelInfo.config.delegate rtcChannel:channelInfo.channelId didOfflineOfUid:uid];
            }
            
            return;
        }
    }
}
- (void)rtcChannel:(AgoraRtcChannel *)rtcChannel networkQuality:(NSUInteger)uid txQuality:(AgoraNetworkQuality)txQuality rxQuality:(AgoraNetworkQuality)rxQuality {
    
    for (RTCChannelInfo *channelInfo in self.rtcChannelInfos) {
        if (channelInfo.config && [channelInfo.channelId isEqualToString:rtcChannel.getChannelId]) {
            
            if ([channelInfo.config.delegate respondsToSelector:@selector(rtcChannel:networkQuality:txQuality:rxQuality:)]) {
                [channelInfo.config.delegate rtcChannel:channelInfo.channelId networkQuality:uid txQuality:txQuality rxQuality:rxQuality];
            }
            
            return;
        }
    }
}

#pragma mark - Rtc-Stream state
- (void)rtcChannel:(AgoraRtcChannel *)rtcChannel remoteVideoStats:(AgoraRtcRemoteVideoStats *)stats {

    for (NSInteger index = 0; index < self.rtcStreamStates.count; index++) {
        RTCRemoteStreamStateInfo *info = self.rtcStreamStates[index];
        if([info.channelId isEqualToString:[rtcChannel getChannelId]] && info.stats.uid == stats.uid) {
            self.rtcStreamStates[index].stats = stats;
            break;
        }
    }
}

- (void)rtcChannel:(AgoraRtcChannel * _Nonnull)rtcChannel
remoteVideoStateChangedOfUid:(NSUInteger)uid
             state:(AgoraVideoRemoteState)state
            reason:(AgoraVideoRemoteStateReason)reason
           elapsed:(NSInteger)elapsed {
    
    [AgoraRTELogService logMessageWithDescribe:@"remoteVideoStateChangedOfUid:"
                                    message:@{@"uid": @(uid),
                                              @"state": @(state),
                                              @"reason": @(reason),
                                              @"elapsed": @(elapsed)}];
    
    // reset
    for (NSInteger index = 0; index < self.rtcStreamStates.count; index++) {
        RTCRemoteStreamStateInfo *info = self.rtcStreamStates[index];
        if([info.channelId isEqualToString:[rtcChannel getChannelId]] && info.stats.uid == uid) {
            self.rtcStreamStates[index].stats = [[AgoraRtcRemoteVideoStats alloc] init];
            self.rtcStreamStates[index].stats.uid = uid;
            break;
        }
    }
    
    for (RTCChannelInfo *channelInfo in self.rtcChannelInfos) {
        if (channelInfo.config && [channelInfo.channelId isEqualToString:rtcChannel.getChannelId]) {
            if ([channelInfo.config.streamStateDelegate respondsToSelector:@selector(rtcRemoteVideoStateChangedOfUid:state:reason:elapsed:)]) {
                [channelInfo.config.streamStateDelegate rtcRemoteVideoStateChangedOfUid:uid state:state reason:reason elapsed:elapsed];
            }
            return;
        }
    }
}

- (void)rtcChannel:(AgoraRtcChannel * _Nonnull)rtcChannel
remoteAudioStateChangedOfUid:(NSUInteger)uid
             state:(AgoraAudioRemoteState)state
            reason:(AgoraAudioRemoteStateReason)reason
           elapsed:(NSInteger)elapsed {
    
    [AgoraRTELogService logMessageWithDescribe:@"remoteAudioStateChangedOfUid:"
                                    message:@{@"uid": @(uid),
                                              @"state": @(state),
                                              @"reason": @(reason),
                                              @"elapsed": @(elapsed)}];
    
    for (RTCChannelInfo *channelInfo in self.rtcChannelInfos) {
        if (channelInfo.config && [channelInfo.channelId isEqualToString:rtcChannel.getChannelId]) {
            if ([channelInfo.config.streamStateDelegate respondsToSelector:@selector(rtcRemoteAudioStateChangedOfUid:state:reason:elapsed:)]) {
                [channelInfo.config.streamStateDelegate rtcRemoteAudioStateChangedOfUid:uid state:state reason:reason elapsed:elapsed];
            }
            return;
        }
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine localVideoStats:(AgoraRtcLocalVideoStats *)stats {
    for (RTCChannelInfo *channelInfo in self.rtcChannelInfos) {
        if ([channelInfo.config.streamStateDelegate respondsToSelector:@selector(rtcLocalVideoStats:)]) {
            [channelInfo.config.streamStateDelegate rtcLocalVideoStats:stats];
        }
    }
}
- (void)rtcEngine:(AgoraRtcEngineKit * _Nonnull)engine
localVideoStateChange:(AgoraLocalVideoStreamState)state
            error:(AgoraLocalVideoStreamError)error {
    for (RTCChannelInfo *channelInfo in self.rtcChannelInfos) {
        if ([channelInfo.config.streamStateDelegate respondsToSelector:@selector(rtcLocalVideoStateChange:error:)]) {
            [channelInfo.config.streamStateDelegate rtcLocalVideoStateChange:state
                                                                       error:error];
        }
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine
localAudioStateChange:(AgoraAudioLocalState)state
            error:(AgoraAudioLocalError)error {
    for (RTCChannelInfo *channelInfo in self.rtcChannelInfos) {
        if ([channelInfo.config.streamStateDelegate respondsToSelector:@selector(rtcLocalAudioStateChange:error:)]) {
            [channelInfo.config.streamStateDelegate rtcLocalAudioStateChange:state error:error];
        }
    }
}

#pragma mark AgoraRtcEngineDelegate-Rate
- (void)rtcEngine:(AgoraRtcEngineKit *)engine lastmileQuality:(AgoraNetworkQuality)quality {
    if ([self.rateDelegate respondsToSelector:@selector(rtcLastmileQuality:)]) {
        [self.rateDelegate rtcLastmileQuality:quality];
    }
}

#pragma mark AgoraRtcEngineDelegate-MediaDevice
- (void)rtcEngine:(AgoraRtcEngineKit *)engine didAudioRouteChanged:(AgoraAudioOutputRouting)routing {
    if ([self.deviceDelegate respondsToSelector:@selector(rtcDidAudioRouteChanged:)]) {
        [self.deviceDelegate rtcDidAudioRouteChanged:routing];
    }
}

#pragma mark AgoraRtcEngineDelegate-AudioMixing
- (void)rtcLocalAudioMixingDidFinish:(AgoraRtcEngineKit *)engine {
    if ([self.audioMixingDelegate respondsToSelector:@selector(rtcLocalAudioMixingDidFinish)]) {
        [self.audioMixingDelegate rtcLocalAudioMixingDidFinish];
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine localAudioMixingStateDidChanged:(AgoraAudioMixingStateCode)state errorCode:(AgoraAudioMixingErrorCode)errorCode {
    if ([self.audioMixingDelegate respondsToSelector:@selector(rtcLocalAudioMixingStateDidChanged:errorCode:)]) {
        [self.audioMixingDelegate rtcLocalAudioMixingStateDidChanged:state errorCode:errorCode];
    }
}

- (void)rtcRemoteAudioMixingDidStart:(AgoraRtcEngineKit *)engine {
    if ([self.audioMixingDelegate respondsToSelector:@selector(rtcRemoteAudioMixingDidStart)]) {
        [self.audioMixingDelegate rtcRemoteAudioMixingDidStart];
    }
}

- (void)rtcRemoteAudioMixingDidFinish:(AgoraRtcEngineKit *)engine {
    if ([self.audioMixingDelegate respondsToSelector:@selector(rtcRemoteAudioMixingDidFinish)]) {
        [self.audioMixingDelegate rtcRemoteAudioMixingDidFinish];
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine reportAudioVolumeIndicationOfSpeakers:(NSArray<AgoraRtcAudioVolumeInfo *> *)speakers totalVolume:(NSInteger)totalVolume {
    for (AgoraRtcAudioVolumeInfo *user in speakers) {

        if (user.uid == 0 &&
            [self.speakerReportDelegate respondsToSelector:@selector(rtcReportAudioVolumeIndicationOfLocalSpeaker:)]) {
            [self.speakerReportDelegate rtcReportAudioVolumeIndicationOfLocalSpeaker:user];
        } else if (user.uid != 0 &&
                   [self.speakerReportDelegate respondsToSelector:@selector(rtcReportAudioVolumeIndicationOfRemoteSpeaker:)]) {
            [self.speakerReportDelegate rtcReportAudioVolumeIndicationOfRemoteSpeaker:user];
        }
    }
}

#pragma mark - AgoraRtcChanelError
- (void)rtcChannel:(AgoraRtcChannel *)rtcChannel didOccurError:(AgoraErrorCode)errorCode {
    
    for (RTCChannelInfo *channelInfo in self.rtcChannelInfos) {
        if (channelInfo.agoraRtcChannel != rtcChannel) {
            continue;
        }
        
        if ([channelInfo.config.errorDelegate respondsToSelector:@selector(rtcChannelDidOccurError:)]) {
            [channelInfo.config.errorDelegate rtcChannelDidOccurError:errorCode];
        }
    }
}

#pragma mark - AgoraRtcEngineDelegate-StatisticsReport
- (void)rtcChannel:(AgoraRtcChannel *)rtcChannel reportRtcStats:(AgoraChannelStats *)stats {
    for (RTCChannelInfo *channelInfo in self.rtcChannelInfos) {
        if (channelInfo.agoraRtcChannel != rtcChannel) {
            continue;
        }
        
        if ([channelInfo.config.statisticsReportDelegate respondsToSelector:@selector(rtcReportRtcStats:)]) {
            [channelInfo.config.statisticsReportDelegate rtcReportRtcStats:stats];
        }
    }
}

- (void)rtcChannel:(AgoraRtcChannel *)rtcChannel videoSizeChangedOfUid:(NSUInteger)uid size:(CGSize)size rotation:(NSInteger)rotation {
    for (RTCChannelInfo *channelInfo in self.rtcChannelInfos) {
        if (channelInfo.agoraRtcChannel != rtcChannel) {
            continue;
        }
        
        if ([channelInfo.config.statisticsReportDelegate respondsToSelector:@selector(rtcVideoSizeChangedOfUid:size:rotation:)]) {
            [channelInfo.config.statisticsReportDelegate rtcVideoSizeChangedOfUid:uid size:size rotation:rotation];
        }
    }
}

- (AgoraRtcChannel *)getRtcChannelWithChannelId:(NSString *)channelId {
    for (RTCChannelInfo *info in self.rtcChannelInfos) {
        if (info.channelId == channelId) {
            return info.agoraRtcChannel;
        }
    }
    
    return nil;
}

#pragma mark AgoraSubThreadTimerDelegate
- (void)perLoop {
    for (RTCChannelInfo *channelInfo in self.rtcChannelInfos) {
        if (channelInfo.config == nil || ![channelInfo.config.streamStateDelegate respondsToSelector:@selector(rtcRemoteVideoStats:)]) {
            continue;
        }
        
        for (RTCRemoteStreamStateInfo *streamStateInfo in self.rtcStreamStates) {
            if ([channelInfo.channelId isEqualToString:streamStateInfo.channelId]) {
                [channelInfo.config.streamStateDelegate rtcRemoteVideoStats:streamStateInfo.stats];
                break;
            }
        }
    }
}

@end
