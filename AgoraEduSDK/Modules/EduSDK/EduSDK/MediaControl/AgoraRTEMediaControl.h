//
//  AgoraRTEMediaControl.h
//  AgoraEduSDK
//
//  Created by SRS on 2021/6/1.
//

#import <Foundation/Foundation.h>
#import "AgoraRTEMediaTrack.h"

NS_ASSUME_NONNULL_BEGIN

@interface AgoraRTEMediaControl : NSObject

- (AgoraRTECameraVideoTrack *)createCameraVideoTrack;
- (AgoraRTEMicrophoneAudioTrack *)createMicphoneAudioTrack;

#pragma mark Unavailable Initializers
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
