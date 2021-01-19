//
//  RTMManagerDelegate.h
//  AgoraEdu
//
//  Created by SRS on 2020/5/5.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RTMChannelDelegate <NSObject>
@optional
- (void)didReceivedSignal:(NSString *)signalText fromChannel: (AgoraRtmChannel *)channel;
@end

@protocol RTMPeerDelegate <NSObject>
@optional
- (void)didReceivedSignal:(NSString *)signalText fromPeer: (NSString *)peer;
@end

@protocol RTMConnectionDelegate <NSObject>
@optional
- (void)didReceivedConnectionStateChanged:(AgoraRtmConnectionState)state reason:(AgoraRtmConnectionChangeReason)reason;
@end

NS_ASSUME_NONNULL_END

