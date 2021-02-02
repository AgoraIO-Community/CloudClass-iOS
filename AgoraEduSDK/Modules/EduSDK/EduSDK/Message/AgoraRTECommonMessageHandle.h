//
//  AgoraRTECommonMessageHandle.h
//  EduSDK
//
//  Created by SRS on 2020/8/31.
//

#import <Foundation/Foundation.h>
#import "AgoraRTEMessageHandle.h"

NS_ASSUME_NONNULL_BEGIN

@interface AgoraRTECommonMessageHandle : AgoraRTEMessageHandle

@property (nonatomic, weak) id<AgoraRTEManagerDelegate> agoraDelegate;

- (AgoraRTEMessageHandleCode)didReceivedPeerMsg:(NSString *)text;
- (void)didReceivedConnectionStateChanged:(AgoraRTEConnectionState)state complete:(void (^) (AgoraRTEConnectionState state))block;

@end

NS_ASSUME_NONNULL_END
