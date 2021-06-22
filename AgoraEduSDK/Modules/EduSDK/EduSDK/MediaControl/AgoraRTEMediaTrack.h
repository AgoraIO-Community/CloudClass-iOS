//
//  AgoraRTEMediaTrack.h
//  AgoraEduSDK
//
//  Created by SRS on 2021/6/1.
//

#import <UIKit/UIKit.h>
#import "AgoraRTEObjects.h"

NS_ASSUME_NONNULL_BEGIN

@interface AgoraRTEMediaTrack : NSObject

- (NSInteger)start;
- (NSInteger)stop;

@end

__attribute__((visibility("default")))
@interface AgoraRTECameraVideoTrack : AgoraRTEMediaTrack

- (NSInteger)switchCamera;
- (NSInteger)setView:(UIView * _Nullable)view;
- (NSInteger)setRenderConfig:(AgoraRTERenderConfig *)config;
- (NSInteger)setVideoEncoderConfig:(AgoraRTEVideoConfig *)config;

#pragma mark Unavailable Initializers
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
@end

__attribute__((visibility("default")))
@interface AgoraRTEMicrophoneAudioTrack : AgoraRTEMediaTrack

#pragma mark Unavailable Initializers
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
@end


NS_ASSUME_NONNULL_END
