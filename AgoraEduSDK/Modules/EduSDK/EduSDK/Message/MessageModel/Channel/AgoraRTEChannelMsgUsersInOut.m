//
//  AgoraRTEChannelMsgUsersInOut.m
//  EduSDK
//
//  Created by SRS on 2020/7/22.
//  Copyright © 2020 agora. All rights reserved.
//

#import "AgoraRTEChannelMsgUsersInOut.h"

@implementation AgoraRTEChannelMsgUsersInOut
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
        @"onlineUsers" : [AgoraRTESyncUserModel class],
        @"offlineUsers" : [AgoraRTESyncUserModel class],
    };
}
@end

