//
//  AgoraRTMManager.m
//  AgoraEdu
//
//  Created by SRS on 2020/5/5.
//  Copyright © 2020 agora. All rights reserved.
//

#import "AgoraRTMManager.h"
#import <AgoraLog/AgoraLog.h>
#import "AgoraRTELogService.h"
#import "RtmPrivateKit.h"

#define AgoraRTMNoNullString(x) ([x isKindOfClass:NSString.class] ? x : @"")

@implementation AgoraRTMChannelDelegateConfig
@end

@interface RTMChannelInfo: NSObject
@property (nonatomic, strong) AgoraRtmChannel *agoraRtmChannel;
@property (nonatomic, strong) NSString *channelName;
@property (nonatomic, strong) AgoraRTMChannelDelegateConfig *config;
@end
@implementation RTMChannelInfo
@end

@interface AgoraRTMManager()<AgoraRtmDelegate, AgoraRtmChannelDelegate>
@property (nonatomic, strong) AgoraRtmKit *agoraRtmKit;
@property (nonatomic, strong) NSString * _Nullable uid;
@property (nonatomic, strong) NSMutableArray<RTMChannelInfo *> * rtmChannelInfos;
@end

static AgoraRTMManager *manager = nil;

@implementation AgoraRTMManager
+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
        manager.rtmChannelInfos = [NSMutableArray array];
    });
    return manager;
}

- (void)initSignalWithAppid:(NSString *)appId appToken:(NSString *)appToken userId:(NSString *)uid completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSInteger errorCode))failBlock {
 
    NSString *logStr = [NSString stringWithFormat:@"init signal appid:%@ apptoken:%@ uid:%@", AgoraRTMNoNullString(appId), AgoraRTMNoNullString(appToken), AgoraRTMNoNullString(uid)];
    [AgoraRTELogService logMessage:logStr level:AgoraLogLevelInfo];
    
    self.uid = AgoraRTMNoNullString(uid);

    self.agoraRtmKit = [[AgoraRtmKit alloc] initWithAppId:appId delegate:self];
    [self.agoraRtmKit loginByToken:appToken user:uid completion:^(AgoraRtmLoginErrorCode errorCode) {
        if (errorCode == AgoraRtmLoginErrorOk) {
            [AgoraRTELogService logMessageWithDescribe:@"rtm login success:" message:@{@"appId":AgoraRTMNoNullString(appId), @"appToken":AgoraRTMNoNullString(appToken), @"uid":AgoraRTMNoNullString(uid)}];

            if (successBlock != nil) {
                successBlock();
            }
        } else {
            [AgoraRTELogService logErrMessageWithDescribe:@"rtm login failure:" message:@{@"errorCode":@(errorCode), @"appId":AgoraRTMNoNullString(appId), @"appToken":AgoraRTMNoNullString(appToken), @"uid":AgoraRTMNoNullString(uid)}];

            if(failBlock != nil){
                failBlock(errorCode);
            }
        }
    }];
}

- (NSString *)getSessionId {
    return [RtmPrivateKit GetSessionId:self.agoraRtmKit];
}

- (void)setLogFile:(NSString *)logDirPath {
    NSString *logFilePath = @"";
    if([[logDirPath substringFromIndex:logDirPath.length-1] isEqualToString:@"/"]) {
        logFilePath = [logDirPath stringByAppendingString:@"agoraRTM.log"];
    } else {
        logFilePath = [logDirPath stringByAppendingString:@"/agoraRTM.log"];
    }

    [self.agoraRtmKit setLogFile:logFilePath];
    [self.agoraRtmKit setLogFileSize:512];
    [self.agoraRtmKit setLogFilters:AgoraRtmLogFilterInfo];
}

- (void)joinSignalWithChannelName:(NSString *)channelName completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSInteger errorCode))failBlock {
    
    [AgoraRTELogService logMessageWithDescribe:@"join signal:" message:@{@"roomUuid":AgoraRTMNoNullString(channelName)}];

    AgoraRtmChannel *agoraRtmChannel = [self.agoraRtmKit createChannelWithId:channelName delegate:self];
    
    BOOL isExsit = NO;
    for (RTMChannelInfo *channelInfo in self.rtmChannelInfos) {
        if ([channelInfo.channelName isEqualToString:channelName]) {
            isExsit = YES;
            channelInfo.agoraRtmChannel = agoraRtmChannel;
        }
    }
    if (!isExsit) {
        RTMChannelInfo *channelInfo = [RTMChannelInfo new];
        channelInfo.agoraRtmChannel = agoraRtmChannel;
        channelInfo.channelName = channelName;;
        [self.rtmChannelInfos addObject:channelInfo];
    }

    [agoraRtmChannel joinWithCompletion:^(AgoraRtmJoinChannelErrorCode errorCode) {
        
        if(errorCode == AgoraRtmJoinChannelErrorOk || errorCode == AgoraRtmJoinChannelErrorAlreadyJoined) {
            
            [AgoraRTELogService logErrMessageWithDescribe:@"rtm join channel success:" message:@{@"roomUuid":AgoraRTMNoNullString(channelName)}];
            if(successBlock != nil) {
                successBlock();
            }
        } else {
            [AgoraRTELogService logErrMessageWithDescribe:@"rtm join channel failure:" message:@{@"roomUuid":AgoraRTMNoNullString(channelName), @"errorCode":@(errorCode)}];
            if(failBlock != nil){
                failBlock(errorCode);
            }
        }
    }];
}

- (void)setChannelDelegateWithConfig:(AgoraRTMChannelDelegateConfig *)config channelName:(NSString * _Nonnull)channelName {
    
    for (RTMChannelInfo *channelInfo in self.rtmChannelInfos) {
        if([channelInfo.channelName isEqualToString:channelName]) {
            if (channelInfo.config == nil) {
               channelInfo.config = config;
            } else {
                if (config.channelDelegate != nil) {
                    channelInfo.config.channelDelegate = config.channelDelegate;
                }
            }
            
            return;
        }
    }
    
    RTMChannelInfo *channelInfo = [RTMChannelInfo new];
    channelInfo.channelName = channelName;
    channelInfo.config = config;
    [self.rtmChannelInfos addObject:channelInfo];
}

- (void)sendMessageWithChannelName:(NSString *)channelName value:(NSString *)value completeSuccessBlock:(void (^) (void))successBlock completeFailBlock:(void (^) (NSInteger errorCode))failBlock {
    
    AgoraRtmMessage *rtmMessage = [[AgoraRtmMessage alloc] initWithText:value];
    
    for (RTMChannelInfo *channelInfo in self.rtmChannelInfos) {
        if (channelInfo.agoraRtmChannel && [channelInfo.channelName isEqualToString:channelName]) {
            [channelInfo.agoraRtmChannel sendMessage:rtmMessage completion:^(AgoraRtmSendChannelMessageErrorCode errorCode) {
                if (errorCode == AgoraRtmSendChannelMessageErrorOk) {
                    if(successBlock != nil){
                        successBlock();
                    }
                } else {
                    if(failBlock != nil){
                        failBlock(errorCode);
                    }
                }
            }];
        }
    }
}

#pragma mark Release
- (void)destoryWithChannelId:(NSString *)channelId {
    [AgoraRTELogService logMessageWithDescribe:@"desotry rtm:" message:@{@"roomUuid": AgoraRTMNoNullString(channelId)}];
    
    RTMChannelInfo *rmvChannelInfo;
    for (RTMChannelInfo *channelInfo in self.rtmChannelInfos) {
        if (channelInfo.agoraRtmChannel) {
            NSString *_channelId = AgoraRTMNoNullString(channelInfo.channelName);
            if ([_channelId isEqualToString:AgoraRTMNoNullString(channelId)]) {
                rmvChannelInfo = channelInfo;
                
                if(AgoraRTMNoNullString(channelInfo.channelName).length > 0) {
                    AgoraRtmChannelAttributeOptions *options = [[AgoraRtmChannelAttributeOptions alloc] init];
                    options.enableNotificationToChannelMembers = YES;
                    [self.agoraRtmKit deleteChannel:AgoraRTMNoNullString(channelInfo.channelName) AttributesByKeys:@[self.uid] Options:options completion:nil];
                }
                [channelInfo.agoraRtmChannel leaveWithCompletion:nil];
            }
        }
    }
    if (rmvChannelInfo != nil) {
        [self.rtmChannelInfos removeObject:rmvChannelInfo];
    }
}

- (void)leaveChannel {
    
    for (RTMChannelInfo *channelInfo in self.rtmChannelInfos) {
        
        if (channelInfo.agoraRtmChannel != nil && channelInfo.channelName != nil) {
            AgoraRtmChannelAttributeOptions *options = [[AgoraRtmChannelAttributeOptions alloc] init];
            options.enableNotificationToChannelMembers = YES;
            [self.agoraRtmKit deleteChannel:channelInfo.channelName AttributesByKeys:@[self.uid] Options:options completion:nil];
            
            [channelInfo.agoraRtmChannel leaveWithCompletion:nil];
        }
        channelInfo.config.channelDelegate = nil;
    }
    [self.rtmChannelInfos removeAllObjects];
}

- (void)destory {
    [AgoraRTELogService logMessageWithDescribe:@"desotry rtm" message:nil];
    [self leaveChannel];
    [self.agoraRtmKit logoutWithCompletion:nil];
    self.agoraRtmKit = nil;
    self.peerDelegate = nil;
    self.uid = nil;
}

- (void)dealloc {
    [self destory];
}

#pragma mark SignalManagerDelegate
- (void)rtmKit:(AgoraRtmKit * _Nonnull)kit connectionStateChanged:(AgoraRtmConnectionState)state reason:(AgoraRtmConnectionChangeReason)reason {
    
    [AgoraRTELogService logMessageWithDescribe:@"rtm connectionStateChanged:" message:@{@"state":@(state), @"reason":@(reason)}];
    
    if([self.connectDelegate respondsToSelector:@selector(didReceivedConnectionStateChanged:reason:)]) {
        [self.connectDelegate didReceivedConnectionStateChanged:state reason:reason];
    }
}

- (void)rtmKit:(AgoraRtmKit * _Nonnull)kit messageReceived:(AgoraRtmMessage * _Nonnull)message fromPeer:(NSString * _Nonnull)peerId {
    
    [AgoraRTELogService logMessageWithDescribe:@"rtm messageReceived:" message:@{@"message":AgoraRTMNoNullString(message.text), @"peerId":AgoraRTMNoNullString(peerId)}];

    if([self.peerDelegate respondsToSelector:@selector(didReceivedSignal:fromPeer:)]) {
        [self.peerDelegate didReceivedSignal:AgoraRTMNoNullString(message.text) fromPeer:AgoraRTMNoNullString(peerId)];
    }
}

- (void)channel:(AgoraRtmChannel * _Nonnull)channel messageReceived:(AgoraRtmMessage * _Nonnull)message fromMember:(AgoraRtmMember * _Nonnull)member {
    
    for (RTMChannelInfo *channelInfo in self.rtmChannelInfos) {
        if (channelInfo.agoraRtmChannel == channel) {
            NSString *logStr = [NSString stringWithFormat:@"roomUuid:%@ messageReceived:%@", AgoraRTMNoNullString(channelInfo.channelName), AgoraRTMNoNullString(message.text)];
            [AgoraRTELogService logMessage:logStr level:AgoraLogLevelInfo];

            if([channelInfo.config.channelDelegate respondsToSelector:@selector(didReceivedSignal:fromChannel:)]) {
               [channelInfo.config.channelDelegate didReceivedSignal:message.text fromChannel:channel];
            }
            break;
        }
    }
}
@end
