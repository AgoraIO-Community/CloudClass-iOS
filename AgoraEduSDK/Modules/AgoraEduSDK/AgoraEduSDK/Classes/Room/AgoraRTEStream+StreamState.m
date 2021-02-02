//
//  AgoraRTEStream+StreamState.m
//  AgoraEduSDK
//
//  Created by SRS on 2021/1/9.
//

#import "AgoraRTEStream+StreamState.h"
#import <objc/runtime.h>

static const void *EduRtcStreamStateVideo;
static const void *EduRtcStreamStateAudio;

@implementation AgoraRTEStream (AgoraStreamState)

- (void)setVideo:(EduRtcStreamState)state {
    objc_setAssociatedObject(self, &EduRtcStreamStateVideo, @(state), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (EduRtcStreamState)video {
    NSNumber *num = objc_getAssociatedObject(self, &EduRtcStreamStateVideo);
    return num.intValue;
}

- (void)setAudio:(EduRtcStreamState)state {
    objc_setAssociatedObject(self, &EduRtcStreamStateAudio, @(state), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (EduRtcStreamState)audio {
    NSNumber *num = objc_getAssociatedObject(self, &EduRtcStreamStateAudio);
    return num.intValue;
}

@end
