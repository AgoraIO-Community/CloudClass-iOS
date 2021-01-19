//
//  RTCManagerDelegate.h
//  AgoraEducation
//
//  Created by SRS on 2019/12/25.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RTCManagerDelegate <NSObject>
@optional
- (void)rtcChannelDidJoinChannel:(NSString *)channelId
                         withUid:(NSUInteger)uid;
- (void)rtcChannel:(NSString *)channelId didJoinedOfUid:(NSUInteger)uid;
- (void)rtcChannel:(NSString *)channelId didOfflineOfUid:(NSUInteger)uid;
- (void)rtcChannel:(NSString *)channelId networkQuality:(NSUInteger)uid txQuality:(AgoraNetworkQuality)txQuality rxQuality:(AgoraNetworkQuality)rxQuality;
@end

@protocol RTCRateDelegate <NSObject>
@optional
- (void)rtcLastmileQuality:(AgoraNetworkQuality)quality;
@end

@protocol RTCMediaDeviceDelegate <NSObject>
- (void)rtcDidAudioRouteChanged:(AgoraAudioOutputRouting)routing;
@end

@protocol RTCAudioMixingDelegate <NSObject>
@optional
- (void)rtcLocalAudioMixingDidFinish;
- (void)rtcLocalAudioMixingStateDidChanged:(AgoraAudioMixingStateCode)state errorCode:(AgoraAudioMixingErrorCode)errorCode;
- (void)rtcRemoteAudioMixingDidStart;
- (void)rtcRemoteAudioMixingDidFinish;
@end

@protocol RTCSpeakerReportDelegate <NSObject>
@optional
- (void)rtcReportAudioVolumeIndicationOfLocalSpeaker:(AgoraRtcAudioVolumeInfo *)speaker;
- (void)rtcReportAudioVolumeIndicationOfRemoteSpeaker:(AgoraRtcAudioVolumeInfo *)speaker;
@end

@protocol RTCStatisticsReportDelegate <NSObject>
@optional
- (void)rtcReportRtcStats:(AgoraChannelStats *)stats;
- (void)rtcVideoSizeChangedOfUid:(NSUInteger)uid size:(CGSize)size rotation:(NSInteger)rotation;
@end

@protocol RTCStreamStateDelegate <NSObject>
- (void)rtcRemoteVideoStateChangedOfUid:(NSUInteger)uid
             state:(AgoraVideoRemoteState)state
            reason:(AgoraVideoRemoteStateReason)reason
           elapsed:(NSInteger)elapsed;

- (void)rtcRemoteAudioStateChangedOfUid:(NSUInteger)uid
             state:(AgoraAudioRemoteState)state
            reason:(AgoraAudioRemoteStateReason)reason
           elapsed:(NSInteger)elapsed;

- (void)rtcLocalVideoStateChange:(AgoraLocalVideoStreamState)state
                           error:(AgoraLocalVideoStreamError)error;

- (void)rtcLocalAudioStateChange:(AgoraAudioLocalState)state
                           error:(AgoraAudioLocalError)error;
@end


NS_ASSUME_NONNULL_END
