//
//  RTMManager.h
//  AgoraEdu
//
//  Created by SRS on 2020/5/5.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AgoraRtmKit/AgoraRtmKit.h>
#import "RTMManagerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface RTMChannelDelegateConfig: NSObject
@property (nonatomic, weak) id<RTMChannelDelegate> channelDelegate;
@end

@interface RTMManager : NSObject

@property (nonatomic, weak) id<RTMPeerDelegate> peerDelegate;
@property (nonatomic, weak) id<RTMConnectionDelegate> connectDelegate;

+ (instancetype)shareManager;

- (void)initSignalWithAppid:(NSString *)appId appToken:(NSString *)appToken userId:(NSString *)uid completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSInteger errorCode))failBlock;

- (void)setLogFile:(NSString *)logDirPath;

- (void)joinSignalWithChannelName:(NSString *)channelName completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSInteger errorCode))failBlock;

- (void)setChannelDelegateWithConfig:(RTMChannelDelegateConfig *)config channelName:(NSString * _Nonnull)channelName;

- (void)sendMessageWithChannelName:(NSString *)channelName value:(NSString *)value completeSuccessBlock:(void (^) (void))successBlock completeFailBlock:(void (^) (NSInteger errorCode))failBlock;
    
- (void)destoryWithChannelId:(NSString *)channelId;
- (void)destory;

@end

NS_ASSUME_NONNULL_END
