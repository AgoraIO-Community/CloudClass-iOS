//
//  EduMessageHandle.h
//  EduSDK
//
//  Created by SRS on 2020/7/22.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EduManagerDelegate.h"
#import "EduClassroomDelegate.h"
#import "EduUserDelegate.h"
#import <YYModel/YYModel.h>
#import "EduMsgChat.h"

#import "SyncRoomSession.h"

#define NOTICE_KEY_START_RECONNECT @"NOTICE_KEY_START_RECONNECT"
#define NOTICE_KEY_END_RECONNECT @"NOTICE_KEY_END_RECONNECT"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, MessageHandleCode) {
    MessageHandleCodeDone,
    MessageHandleCodeVersionError,
    MessageHandleCodeCMDError,
};

#define EDU_MESSAGE_VERSION 1

@interface EduMessageHandle : NSObject

@property (nonatomic, copy) NSString * _Nullable roomUuid;

@end

NS_ASSUME_NONNULL_END
