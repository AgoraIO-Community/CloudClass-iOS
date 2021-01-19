//
//  EduChannelMsgUsersInOut.m
//  EduSDK
//
//  Created by SRS on 2020/7/22.
//  Copyright © 2020 agora. All rights reserved.
//

#import "EduChannelMsgUsersInOut.h"

@implementation EduChannelMsgUsersInOut
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
        @"onlineUsers" : [EduSyncUserModel class],
        @"offlineUsers" : [EduSyncUserModel class],
    };
}
@end

