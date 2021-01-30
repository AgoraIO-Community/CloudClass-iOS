//
//  AgoraRTCManagerDelegate.h
//  AgoraEducation
//
//  Created by SRS on 2019/12/25.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AgoraRTCManagerDelegate <NSObject>
@optional
- (void)rtcChannelDidJoinChannel:(NSString *)channelId
                         withUid:(NSUInteger)uid;
- (void)rtcChannel:(NSString *)channelId didJoinedOfUid:(NSUInteger)uid;
- (void)rtcChannel:(NSString *)channelId didOfflineOfUid:(NSUInteger)uid;
- (void)rtcChannel:(NSString *)channelId networkQuality:(NSUInteger)uid txQuality:(AgoraNetworkQuality)txQuality rxQuality:(AgoraNetworkQuality)rxQuality;
@end

@protocol AgoraRTCRateDelegate <NSObject>
@optional
- (void)rtcLastmileQuality:(AgoraNetworkQuality)quality;
@end

@protocol AgoraRTCMediaDeviceDelegate <NSObject>
- (void)rtcDidAudioRouteChanged:(AgoraAudioOutputRouting)routing;
@end

@protocol AgoraRTCAudioMixingDelegate <NSObject>
@optional
- (void)rtcLocalAudioMixingDidFinish;
- (void)rtcLocalAudioMixingStateDidChanged:(AgoraAudioMixingStateCode)state errorCode:(AgoraAudioMixingErrorCode)errorCode;
- (void)rtcRemoteAudioMixingDidStart;
- (void)rtcRemoteAudioMixingDidFinish;
@end

@protocol AgoraRTCSpeakerReportDelegate <NSObject>
@optional
- (void)rtcReportAudioVolumeIndicationOfLocalSpeaker:(AgoraRtcAudioVolumeInfo *)speaker;
- (void)rtcReportAudioVolumeIndicationOfRemoteSpeaker:(AgoraRtcAudioVolumeInfo *)speaker;
@end

@protocol AgoraRTCStatisticsReportDelegate <NSObject>
@optional
- (void)rtcReportRtcStats:(AgoraChannelStats *)stats;
- (void)rtcVideoSizeChangedOfUid:(NSUInteger)uid size:(CGSize)size rotation:(NSInteger)rotation;
@end

@protocol AgoraRTCStreamStateDelegate <NSObject>
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
