/*
Use RtmPrivateKit shoud copy this file to AgoraRtmKit.framework/Headers
and add the following 2 lines in AgoraRtmKit.h and AgoraRtmKit_swift.h

#import "RtmPrivateKit.h"
@class RTmPrivateKit;

*/
#import <Foundation/Foundation.h>
@class AgoraRtmKit;
@class RtmPrivateKit;
__attribute__((visibility("default"))) @interface RtmPrivateKit: NSObject
+ (NSString*)GetSessionId:(AgoraRtmKit * _Nonnull) rtmClient;
@end
