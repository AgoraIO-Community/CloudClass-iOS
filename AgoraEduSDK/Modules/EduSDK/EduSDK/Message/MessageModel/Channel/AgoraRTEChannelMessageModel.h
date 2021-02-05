//
//  EduMessageModel.h
//  EduSDK
//
//  Created by SRS on 2020/7/22.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, AgoraRTEChannelMessageCmd) {
    AgoraRTEChannelMessageCmdRoomCourseState        = 1,
    AgoraRTEChannelMessageCmdRoomMuteState          = 2,
    AgoraRTEChannelMessageCmdChat                   = 3,
    AgoraRTEChannelMessageCmdRoomProperty           = 4,
    AgoraRTEChannelMessageCmdRoomProperties         = 5,
    
    AgoraRTEChannelMessageCmdUserInOut              = 20,
    AgoraRTEChannelMessageCmdUserInfo               = 21,
    AgoraRTEChannelMessageCmdUserProperties         = 22,
    AgoraRTEChannelMessageCmdStreamInOut            = 40,
    AgoraRTEChannelMessageCmdStreamsInOut           = 41,
    AgoraRTEChannelMessageCmdMessageExtention       = 99,
};

NS_ASSUME_NONNULL_BEGIN

@interface AgoraRTEChannelMessageModel : NSObject

@property (nonatomic, assign) AgoraRTEChannelMessageCmd cmd;
@property (nonatomic, assign) NSInteger version;
@property (nonatomic, assign) NSInteger sequence;
@property (nonatomic, strong) NSDictionary *data;

@end

NS_ASSUME_NONNULL_END
