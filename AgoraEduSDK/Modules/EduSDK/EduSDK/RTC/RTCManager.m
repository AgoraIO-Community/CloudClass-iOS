//
//  RTCManager.m
//  AgoraEdu
//
//  Created by SRS on 2020/5/4.
//  Copyright © 2020 agora. All rights reserved.
//

#import "RTCManager.h"
#import "AgoraLogService.h"

#define NoNullString(x) ([x isKindOfClass:NSString.class] ? x : @"")

@implementation RTCChannelDelegateConfig
@end

@interface RTCChannelInfo: NSObject
@property (nonatomic, strong) AgoraRtcChannel *agoraRtcChannel;
@property (nonatomic, assign) AgoraClientRole role;
@property (nonatomic, assign) BOOL isPublish;

@property (nonatomic, strong) NSString *channelId;
@property (nonatomic, strong) RTCChannelDelegateConfig *config;
@end
@implementation RTCChannelInfo
@end

@interface RTCManager()<AgoraRtcEngineDelegate, AgoraRtcChannelDelegate>
@property (nonatomic, strong) AgoraRtcEngineKit * _Nullable rtcEngineKit;

@property (nonatomic, assign) BOOL currentEnableVideo;
@property (nonatomic, assign) BOOL currentEnableAudio;

@property (nonatomic, assign) BOOL currentMuteVideo;
@property (nonatomic, assign) BOOL currentMuteAudio;

@property (nonatomic, assign) BOOL currentMuteAllRemoteVideo;
@property (nonatomic, assign) BOOL currentMuteAllRemoteAudio;

@property (nonatomic, assign) BOOL frontCamera;

@property (nonatomic, strong) NSMutableArray<RTCChannelInfo *> *rtcChannelInfos;
@end

static RTCManager *manager = nil;

@implementation RTCManager
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
}

- (void)initEngineKitWithAppid:(NSString *)appid {
    
    [AgoraLogService logMessageWithDescribe:@"init rtcEngineKit appid:" message:NoNullString(appid)];
    
    if(self.rtcEngineKit == nil){
        self.rtcEngineKit = [AgoraRtcEngineKit sharedEngineWithAppId:appid delegate:self];
    }
    [self.rtcEngineKit disableLastmileTest];
}

- (int)joinChannelByToken:(NSString * _Nullable)token channelId:(NSString * _Nonnull)channelId info:(NSString * _Nullable)info uid:(NSUInteger)uid {
    
    return [self joinChannelByToken:token channelId:channelId info:info uid:uid autoSubscribeAudio:YES autoSubscribeVideo:YES];
}

- (int)joinChannelByToken:(NSString * _Nullable)token channelId:(NSString * _Nonnull)channelId info:(NSString * _Nullable)info uid:(NSUInteger)uid autoSubscribeAudio:(BOOL)autoSubscribeAudio autoSubscribeVideo:(BOOL)autoSubscribeVideo {
    
    [AgoraLogService logMessageWithDescribe:@"join channel:" message:@{@"roomUuid":NoNullString(channelId), @"token":NoNullString(token), @"uid":@(uid)}];
    
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

- (void)setChannelDelegateWithConfig:(RTCChannelDelegateConfig *)config channelId:(NSString * _Nonnull)channelId {
    for (RTCChannelInfo *channelInfo in self.rtcChannelInfos) {
        if([channelInfo.channelId isEqualToString:channelId]) {
            if (channelInfo.config == nil) {
                channelInfo.config = config;
            } else {
                if (config.delegate != nil) {
                    channelInfo.config.delegate = config.delegate;
                }
                if (config.speakerReportDelegate != nil) {
                    channelInfo.config.speakerReportDelegate = config.speakerReportDelegate;
                }
                if (config.statisticsReportDelegate != nil) {
                    channelInfo.config.statisticsReportDelegate = config.statisticsReportDelegate;
                }
                if (config.streamStateDelegate != nil) {
                    channelInfo.config.streamStateDelegate = config.streamStateDelegate;
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
    
    [self.rtcEngineKit enableVideo];
    [self.rtcEngineKit enableWebSdkInteroperability:YES];
    [self.rtcEngineKit enableDualStreamMode:YES];
    
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
                [AgoraLogService logMessageWithDescribe:@"set role:" message:@{
                    @"roomUuid": NoNullString(channelId),
                    @"role": @"AgoraClientRoleAudience",
                    @"code": @(code),
                }];
            } else if (role == AgoraClientRoleBroadcaster) {
                [AgoraLogService logMessageWithDescribe:@"set role:" message:@{
                    @"roomUuid": NoNullString(channelId),
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
    [AgoraLogService logMessageWithDescribe:@"enableLocalVideo:" message:@{@"enable":@(enable), @"code":@(code)}];
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
    [AgoraLogService logMessageWithDescribe:@"enableLocalAudio:" message:@{@"enable":@(enable), @"code":@(code)}];
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
                [AgoraLogService logMessageWithDescribe:@"unpublish:" message:@{@"roomUuid":NoNullString(channelId), @"code":@(code)}];
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
                    [AgoraLogService logMessageWithDescribe:@"publish:" message:@{@"roomUuid":NoNullString(currentChannelInfo.channelId), @"code":@(code)}];
                    
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
                [AgoraLogService logMessageWithDescribe:@"unpublish:" message:@{@"roomUuid":NoNullString(channelId), @"code":@(code)}];
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
    [AgoraLogService logMessageWithDescribe:@"muteLocalVideoStream:" message:@{@"mute":@(mute), @"code":@(code)}];
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
    [AgoraLogService logMessageWithDescribe:@"muteLocalAudioStream:" message:@{@"mute":@(mute), @"code":@(code)}];
    if (code == 0) {
        self.currentMuteAudio = mute;
    }
    return code;
}

- (int)muteRemoteAudioStream:(NSString *)uid mute:(BOOL)mute channelId:(NSString *)channelId {
    
    for(RTCChannelInfo *channelInfo in self.rtcChannelInfos) {
        if (channelInfo.agoraRtcChannel && [channelInfo.channelId isEqualToString:channelId]) {
            
            NSUInteger streamUid = uid.integerValue;
            int code = [channelInfo.agoraRtcChannel muteRemoteAudioStream:streamUid mute:mute];
            
            [AgoraLogService logMessageWithDescribe:@"muteRemoteAudioStream:" message:@{@"roomUuid":NoNullString(channelId), @"uid":NoNullString(uid), @"mute":@(mute), @"code":@(code)}];
            
            return code;
        }
    }
    
    return 0;
}

- (int)muteRemoteVideoStream:(NSString *)uid mute:(BOOL)mute channelId:(NSString *)channelId {
    
    for(RTCChannelInfo *channelInfo in self.rtcChannelInfos) {
        if (channelInfo.agoraRtcChannel && [channelInfo.channelId isEqualToString:channelId]) {
            
            NSUInteger streamUid = uid.integerValue;
            int code = [channelInfo.agoraRtcChannel muteRemoteVideoStream:streamUid mute:mute];
            
            [AgoraLogService logMessageWithDescribe:@"muteRemoteVideoStream:" message:@{@"roomUuid":NoNullString(channelId), @"uid":NoNullString(uid), @"mute":@(mute), @"code":@(code)}];
            
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
    [AgoraLogService logMessageWithDescribe:@"muteAllRemoteAudioStreams:" message:@{@"mute":@(mute),@"code":@(code)}];
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
    [AgoraLogService logMessageWithDescribe:@"muteAllRemoteVideoStreams:" message:@{@"mute":@(mute),@"code":@(code)}];
    if (code == 0) {
        self.currentMuteAllRemoteVideo = mute;
    }
    return code;
}

#pragma mark Render
- (int)startPreview {
    
    int code = [self.rtcEngineKit startPreview];
    [AgoraLogService logMessageWithDescribe:@"startPreview:" message:@{@"code":@(code)}];
    
    return code;
}

- (int)setupLocalVideo:(AgoraRtcVideoCanvas * _Nullable)local {
    
    int code =  [self.rtcEngineKit setupLocalVideo:local];
    [AgoraLogService logMessageWithDescribe:@"setupLocalVideo:" message:@{@"roomUuid":local.channel, @"uid": @(local.uid), @"code":@(code)}];
    
    return code;
}

- (int)setupRemoteVideo:(AgoraRtcVideoCanvas * _Nonnull)remote {
    
    int code =  [self.rtcEngineKit setupRemoteVideo:remote];
    [AgoraLogService logMessageWithDescribe:@"setupRemoteVideo:" message:@{@"roomUuid":remote.channel, @"uid": @(remote.uid), @"code":@(code)}];
    
    return code;
}

- (int)setRemoteVideoStream:(NSString *)uid type:(AgoraVideoStreamType)streamType {
    return [self.rtcEngineKit setRemoteVideoStream:uid.integerValue type:streamType];
}

#pragma mark Lastmile
- (int)startLastmileProbeTest:(NSString *)appid dataSourceDelegate:(id<RTCRateDelegate> _Nullable)rtcDelegate {
    
    if (self.rtcEngineKit == nil) {
        self.rtcEngineKit = [AgoraRtcEngineKit sharedEngineWithAppId:appid delegate:self];
    }
    self.rateDelegate = rtcDelegate;
    return [self.rtcEngineKit enableLastmileTest];
}

#pragma mark Rate
- (NSString *)getCallId {
    NSString *callid = [self.rtcEngineKit getCallId];
    
    [AgoraLogService logMessageWithDescribe:@"callId:" message:callid];
    
    return callid;
}

- (int)rate:(NSString *)callId rating:(NSInteger)rating description:(NSString *)description {
    
    int rate = [self.rtcEngineKit rate:callId rating:rating description:description];
    
    [AgoraLogService logMessageWithDescribe:@"rate:" message:@{@"callId":NoNullString(callId), @"rating":@(rating), @"description":NoNullString(description), @"rate":@(rate)}];
    
    return rate;
}

#pragma mark AudioMixing
- (int)startAudioMixing:(NSString *  _Nonnull)filePath loopback:(BOOL)loopback replace:(BOOL)replace cycle:(NSInteger)cycle {
    
    int code = [self.rtcEngineKit startAudioMixing:filePath loopback:loopback replace:replace cycle:cycle];
    
    [AgoraLogService logMessageWithDescribe:@"startAudioMixing:" message: @{@"filePath":NoNullString(filePath), @"loopback":@(loopback), @"replace":@(replace), @"cycle":@(cycle), @"code":@(code)}];
    
    return code;
}

- (int)setAudioMixingPosition:(NSInteger)pos {
    
    int code = [self.rtcEngineKit setAudioMixingPosition:pos];
    
    [AgoraLogService logMessageWithDescribe:@"setAudioMixingPosition:" message:@{@"pos":@(pos), @"code":@(code)}];
    
    return code;
}

- (int)pauseAudioMixing {
    
    int code = [self.rtcEngineKit pauseAudioMixing];
    
    [AgoraLogService logMessageWithDescribe:@"pauseAudioMixing:" message:@{@"code":@(code)}];
    
    return code;
}

- (int)resumeAudioMixing {
    
    int code = [self.rtcEngineKit resumeAudioMixing];
    
    [AgoraLogService logMessageWithDescribe:@"resumeAudioMixing:" message:@{@"code":@(code)}];
    
    return code;
}

- (int)stopAudioMixing {
    
    int code = [self.rtcEngineKit stopAudioMixing];
    
    [AgoraLogService logMessageWithDescribe:@"stopAudioMixing:" message:@{@"code":@(code)}];
    
    return code;
}

- (int)getAudioMixingDuration {
    int duration = [self.rtcEngineKit getAudioMixingDuration];
    
    [AgoraLogService logMessageWithDescribe:@"getAudioMixingDuration:" message:@{@"duration": @(duration)}];
    
    return duration;
}

- (int)getAudioMixingCurrentPosition {
    int position = [self.rtcEngineKit getAudioMixingCurrentPosition];
    
    [AgoraLogService logMessageWithDescribe:@"getAudioMixingCurrentPosition:" message:@{@"currentPosition": @(position)}];
    
    return position;
}

- (int)adjustAudioMixingPublishVolume:(NSInteger)volume {
    int code = [self.rtcEngineKit adjustAudioMixingPublishVolume:volume];
    
    [AgoraLogService logMessageWithDescribe:@"adjustAudioMixingPublishVolume:" message:@{@"volume": @(volume)}];
    
    return code;
}

- (int)adjustAudioMixingPlayoutVolume:(NSInteger)volume {
    int code = [self.rtcEngineKit adjustAudioMixingPublishVolume:volume];
    
    [AgoraLogService logMessageWithDescribe:@"adjustAudioMixingPlayoutVolume:" message:@{@"volume": @(volume)}];
    
    return code;
}

- (int)getAudioMixingPublishVolume {
    int volume = [self.rtcEngineKit getAudioMixingPublishVolume];
    
    [AgoraLogService logMessageWithDescribe:@"getAudioMixingPublishVolume:" message:@{@"volume": @(volume)}];
    
    return volume;
}

- (int)getAudioMixingPlayoutVolume {
    int volume = [self.rtcEngineKit getAudioMixingPlayoutVolume];
    
    [AgoraLogService logMessageWithDescribe:@"getAudioMixingPlayoutVolume:" message:@{@"volume": @(volume)}];
    
    return volume;
}

#pragma mark AudioEffect
- (int)setLocalVoiceChanger:(AgoraAudioVoiceChanger)voiceChanger {
    
    int code = [self.rtcEngineKit setLocalVoiceChanger:voiceChanger];
    
    [AgoraLogService logMessageWithDescribe:@"setLocalVoiceChanger:" message:@{@"voiceChanger":@(voiceChanger), @"code":@(code)}];
    
    return code;
}

- (int)setLocalVoiceReverbPreset:(AgoraAudioReverbPreset)reverbPreset {
    
    int code = [self.rtcEngineKit setLocalVoiceReverbPreset:reverbPreset];
    
    [AgoraLogService logMessageWithDescribe:@"setLocalVoiceReverbPreset:" message:@{@"reverbPreset":@(reverbPreset), @"code":@(code)}];
    
    return code;
}

#pragma mark - MediaDevice
- (int)switchCamera {
    self.frontCamera = !self.frontCamera;
    
    [AgoraLogService logMessageWithDescribe:@"switch camera:" message: self.frontCamera ? @"front" : @"back"];
    
    return [self.rtcEngineKit switchCamera];
}

- (int)enableInEarMonitoring:(BOOL)enabled {
    return [self.rtcEngineKit enableInEarMonitoring:enabled];
}

#pragma mark Private Parameters
- (int)setParameters:(NSString * _Nonnull)options {
    
    int code = [self.rtcEngineKit setParameters:options];
    
    [AgoraLogService logMessageWithDescribe:@"setParameters:" message:@{@"options":NoNullString(options), @"code":@(code)}];
    
    return [self.rtcEngineKit setParameters:options];
}

+ (NSString *_Nullable)getErrorDescription:(NSInteger)code {
    if([AgoraRtcEngineKit respondsToSelector:@selector(getErrorDescription:)]) {
        [AgoraRtcEngineKit performSelector:@selector(getErrorDescription:) withObject:@(code)];
    }
    return @"";
}

#pragma mark Release
- (void)destoryWithChannelId:(NSString *)channelId {
    [AgoraLogService logMessageWithDescribe:@"desotry rtc:" message:@{@"roomUuid": NoNullString(channelId)}];
    
    RTCChannelInfo *rmvChannelInfo;
    for (RTCChannelInfo *channelInfo in self.rtcChannelInfos) {
        if (channelInfo.agoraRtcChannel) {
            NSString *_channelId = NoNullString(channelInfo.channelId);
            if ([_channelId isEqualToString:NoNullString(channelId)]) {
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
    [AgoraLogService logMessageWithDescribe:@"desotry rtc" message:nil];
    
    for(RTCChannelInfo *channelInfo in self.rtcChannelInfos) {
        if (channelInfo.agoraRtcChannel) {
            [channelInfo.agoraRtcChannel leaveChannel];
            [channelInfo.agoraRtcChannel destroy];
        }
    }
    
    [self.rtcEngineKit stopPreview];
    
    [self initData];
}

-(void)dealloc {
    [self destory];
}

#pragma mark AgoraRtcChannelDelegate
- (void)rtcChannelDidJoinChannel:(AgoraRtcChannel * _Nonnull)rtcChannel
                         withUid:(NSUInteger)uid
                         elapsed:(NSInteger) elapsed {
    
    [AgoraLogService logMessageWithDescribe:@"didJoinChannel:" message:@{@"roomUuid":NoNullString(rtcChannel.getChannelId), @"uid":@(uid), @"elapsed":@(elapsed)}];
    
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
                    [AgoraLogService logMessageWithDescribe:@"publish after role change start" message:nil];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        int code = [rtcChannel publish];
                        [AgoraLogService logMessageWithDescribe:@"publish after role change end:" message:@{@"roomUuid":NoNullString([rtcChannel getChannelId]), @"code":@(code)}];
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
    [AgoraLogService logMessageWithDescribe:@"didJoinedOfUid:" message:@{@"roomUuid":NoNullString(rtcChannel.getChannelId), @"uid":@(uid), @"elapsed":@(elapsed)}];
    
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
    [AgoraLogService logMessageWithDescribe:@"didOfflineOfUid:" message:@{@"roomUuid":NoNullString(rtcChannel.getChannelId), @"uid":@(uid), @"reason":@(reason)}];
    
    for (RTCChannelInfo *channelInfo in self.rtcChannelInfos) {
        if (channelInfo.config && [channelInfo.channelId isEqualToString:rtcChannel.getChannelId]) {
            
            if ([channelInfo.config.delegate respondsToSelector:@selector(rtcChannel:didOfflineOfUid:)]) {
                [channelInfo.config.delegate rtcChannel:channelInfo.channelId didOfflineOfUid:uid];
            }
            
            return;
        }
    }
}

- (void)rtcChannel:(AgoraRtcChannel * _Nonnull)rtcChannel networkQuality:(NSUInteger)uid txQuality:(AgoraNetworkQuality)txQuality rxQuality:(AgoraNetworkQuality)rxQuality {

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
- (void)rtcChannel:(AgoraRtcChannel * _Nonnull)rtcChannel
remoteVideoStateChangedOfUid:(NSUInteger)uid
             state:(AgoraVideoRemoteState)state
            reason:(AgoraVideoRemoteStateReason)reason
           elapsed:(NSInteger)elapsed {
    
    [AgoraLogService logMessageWithDescribe:@"remoteVideoStateChangedOfUid:"
                                    message:@{@"uid": @(uid),
                                              @"state": @(state),
                                              @"reason": @(reason),
                                              @"elapsed": @(elapsed)}];
    
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
    
    [AgoraLogService logMessageWithDescribe:@"remoteAudioStateChangedOfUid:"
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
            [channelInfo.config.streamStateDelegate rtcLocalAudioStateChange:state
                                                                       error:error];
        }
    }
}

#pragma mark AgoraRtcEngineDelegate-Rate
- (void)rtcEngine:(AgoraRtcEngineKit *_Nonnull)engine lastmileQuality:(AgoraNetworkQuality)quality {
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
        for (RTCChannelInfo *channelInfo in self.rtcChannelInfos) {
            if (!(channelInfo.config && [channelInfo.channelId isEqualToString:user.channelId])) {
                continue;
            }
            
            if (user.uid == 0 &&
                [channelInfo.config.speakerReportDelegate respondsToSelector:@selector(rtcReportAudioVolumeIndicationOfLocalSpeaker:)]) {
                [channelInfo.config.speakerReportDelegate rtcReportAudioVolumeIndicationOfLocalSpeaker:user];
            } else if (user.uid != 0 &&
                       [channelInfo.config.speakerReportDelegate respondsToSelector:@selector(rtcReportAudioVolumeIndicationOfRemoteSpeaker:)]) {
                [channelInfo.config.speakerReportDelegate rtcReportAudioVolumeIndicationOfRemoteSpeaker:user];
            }
            break;
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

@end
