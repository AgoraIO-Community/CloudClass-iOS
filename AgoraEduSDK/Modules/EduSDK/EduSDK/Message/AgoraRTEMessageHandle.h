//
//  AgoraRTEMessageHandle.h
//  EduSDK
//
//  Created by SRS on 2020/7/22.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AgoraRTEManagerDelegate.h"
#import "AgoraRTEClassroomDelegate.h"
#import "AgoraRTEUserDelegate.h"
#import <YYModel/YYModel.h>
#import "AgoraRTEMsgChat.h"

#import "AgoraRTESyncRoomSession.h"

#define NOTICE_KEY_START_RECONNECT @"NOTICE_KEY_START_RECONNECT"
#define NOTICE_KEY_END_RECONNECT @"NOTICE_KEY_END_RECONNECT"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, AgoraRTEMessageHandleCode) {
    AgoraRTEMessageHandleCodeDone,
    AgoraRTEMessageHandleCodeVersionError,
    AgoraRTEMessageHandleCodeCMDError,
};

#define AGORA_RTE_MESSAGE_VERSION 1

@interface AgoraRTEMessageHandle : NSObject

@property (nonatomic, copy) NSString * _Nullable roomUuid;

@end

NS_ASSUME_NONNULL_END
