//
//  AgoraRTMManagerDelegate.h
//  AgoraEdu
//
//  Created by SRS on 2020/5/5.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AgoraRTMChannelDelegate <NSObject>
@optional
- (void)didReceivedSignal:(NSString *)signalText fromChannel: (AgoraRtmChannel *)channel;
@end

@protocol AgoraRTMPeerDelegate <NSObject>
@optional
- (void)didReceivedSignal:(NSString *)signalText fromPeer: (NSString *)peer;
@end

@protocol AgoraRTMConnectionDelegate <NSObject>
@optional
- (void)didReceivedConnectionStateChanged:(AgoraRtmConnectionState)state reason:(AgoraRtmConnectionChangeReason)reason;
@end

NS_ASSUME_NONNULL_END

