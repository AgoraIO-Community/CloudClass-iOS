//
//  RTCManager.h
//  AgoraEdu
//
//  Created by SRS on 2020/5/4.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>

#if __has_include(<AgoraRtcKit/AgoraRtcEngineKit.h>)
#import <AgoraRtcKit/AgoraRtcEngineKit.h>
#elif __has_include(<AgoraRtcEngineKit/AgoraRtcEngineKit.h>)
#import <AgoraRtcEngineKit/AgoraRtcEngineKit.h>
#else
# error "Invalid import"
#endif

#import "RTCManagerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface RTCChannelDelegateConfig: NSObject
@property (nonatomic, weak) id<RTCManagerDelegate> delegate;
@property (nonatomic, weak) id<RTCSpeakerReportDelegate> speakerReportDelegate;
@property (nonatomic, weak) id<RTCStatisticsReportDelegate> statisticsReportDelegate;
@property (nonatomic, weak) id<RTCStreamStateDelegate> streamStateDelegate;
@end

@interface RTCManager : NSObject

@property (nonatomic, weak) id<RTCRateDelegate> rateDelegate;
@property (nonatomic, weak) id<RTCMediaDeviceDelegate> deviceDelegate;
@property (nonatomic, weak) id<RTCAudioMixingDelegate> audioMixingDelegate;

+ (instancetype)shareManager;
+ (NSString *)sdkVersion;

// Init
- (void)initEngineKitWithAppid:(NSString *)appid;

// JoinChannel
- (int)joinChannelByToken:(NSString * _Nullable)token channelId:(NSString * _Nonnull)channelId info:(NSString * _Nullable)info uid:(NSUInteger)uid;
- (int)joinChannelByToken:(NSString * _Nullable)token channelId:(NSString * _Nonnull)channelId info:(NSString * _Nullable)info uid:(NSUInteger)uid autoSubscribeAudio:(BOOL)autoSubscribeAudio autoSubscribeVideo:(BOOL)autoSubscribeVideo;

- (void)setChannelDelegateWithConfig:(RTCChannelDelegateConfig *)config channelId:(NSString * _Nonnull)channelId;

// Configuration
- (NSInteger)setVideoEncoderConfiguration:(AgoraVideoEncoderConfiguration *)configuration;
- (int)setChannelProfile:(AgoraChannelProfile)profile;
- (void)setLogFile:(NSString *)logDirPath;
- (int)setClientRole:(AgoraClientRole)role channelId:(NSString *)channelId;

// Enable
- (int)enableLocalAudio:(BOOL)enable;
- (int)enableLocalVideo:(BOOL)enable;

// Mute
- (int)publishChannelId:(NSString *)channelId;
- (int)unPublishChannelId:(NSString *)channelId;
- (int)muteLocalVideoStream:(BOOL)mute;
- (int)muteLocalAudioStream:(BOOL)mute;
- (int)muteRemoteAudioStream:(NSString *)uid mute:(BOOL)mute channelId:(NSString *)channelId;
- (int)muteRemoteVideoStream:(NSString *)uid mute:(BOOL)mute channelId:(NSString *)channelId;
- (int)muteAllRemoteAudioStreams:(BOOL)mute;
- (int)muteAllRemoteVideoStreams:(BOOL)mute;

// Render
- (int)startPreview;
- (int)setupLocalVideo:(AgoraRtcVideoCanvas * _Nullable)local;
- (int)setupRemoteVideo:(AgoraRtcVideoCanvas * _Nonnull)remote;
- (int)setRemoteVideoStream:(NSString *)uid type:(AgoraVideoStreamType)streamType;

// AudioMixing
- (int)startAudioMixing:(NSString *  _Nonnull)filePath loopback:(BOOL)loopback replace:(BOOL)replace cycle:(NSInteger)cycle;
- (int)setAudioMixingPosition:(NSInteger)pos;
- (int)pauseAudioMixing;
- (int)resumeAudioMixing;
- (int)stopAudioMixing;
- (int)getAudioMixingDuration;
- (int)getAudioMixingCurrentPosition;
- (int)adjustAudioMixingPublishVolume:(NSInteger)volume;
- (int)adjustAudioMixingPlayoutVolume:(NSInteger)volume;
- (int)getAudioMixingPlayoutVolume;

// AudioEffect
- (int)setLocalVoiceChanger:(AgoraAudioVoiceChanger)voiceChanger;
- (int)setLocalVoiceReverbPreset:(AgoraAudioReverbPreset)reverbPreset;

// MediaDevice
- (int)switchCamera;
- (int)enableInEarMonitoring:(BOOL)enabled;

// Private Parameters
- (int)setParameters:(NSString * _Nonnull)options;

// Lastmile
- (int)startLastmileProbeTest:(NSString *)appid dataSourceDelegate:(id<RTCRateDelegate> _Nullable)rtcDelegate;

// Rate
- (NSString *)getCallId;
- (int)rate:(NSString *)callId rating:(NSInteger)rating description:(NSString *)description;

+ (NSString *_Nullable)getErrorDescription:(NSInteger)code;

- (void)destoryWithChannelId:(NSString *)channelId;
- (void)destory;

#pragma mark Unavailable Initializers
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
