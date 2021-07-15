//
//  AgoraRTEMediaControl.m
//  AgoraEduSDK
//
//  Created by SRS on 2021/6/1.
//

#import "AgoraRTEMediaControl.h"

@interface AgoraRTEMediaControl ()
@property (nonatomic, strong) AgoraRTECameraVideoTrack *camera;
@property (nonatomic, strong) AgoraRTEMicrophoneAudioTrack *mic;
@end

@implementation AgoraRTEMediaControl
- (AgoraRTECameraVideoTrack *)createCameraVideoTrack {
    if (self.camera == nil) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        self.camera = [[AgoraRTECameraVideoTrack alloc] performSelector:NSSelectorFromString(@"init")];
#pragma clang diagnostic pop
    }
    return self.camera;
}
- (AgoraRTEMicrophoneAudioTrack *)createMicphoneAudioTrack {
    if (self.mic == nil) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        self.mic = [[AgoraRTEMicrophoneAudioTrack alloc] performSelector:NSSelectorFromString(@"init")];
#pragma clang diagnostic pop
    }
    return self.mic;
}
@end
