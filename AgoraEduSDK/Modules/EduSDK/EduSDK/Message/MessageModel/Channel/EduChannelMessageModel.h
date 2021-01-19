//
//  EduMessageModel.h
//  EduSDK
//
//  Created by SRS on 2020/7/22.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ChannelMessageCmd) {
    ChannelMessageCmdRoomCourseState        = 1,
    ChannelMessageCmdRoomMuteState          = 2,
    ChannelMessageCmdChat                   = 3,
    ChannelMessageCmdRoomProperty           = 4,
    ChannelMessageCmdRoomProperties         = 5,
    
    ChannelMessageCmdUserInOut              = 20,
    ChannelMessageCmdUserInfo               = 21,
    ChannelMessageCmdUserProperties         = 22,
    ChannelMessageCmdStreamInOut            = 40,
    ChannelMessageCmdStreamsInOut           = 41,
    ChannelMessageCmdMessageExtention       = 99,
};

NS_ASSUME_NONNULL_BEGIN

@interface EduChannelMessageModel : NSObject

@property (nonatomic, assign) ChannelMessageCmd cmd;
@property (nonatomic, assign) NSInteger version;
@property (nonatomic, assign) NSInteger ts;
@property (nonatomic, assign) NSInteger sequence;
@property (nonatomic, strong) NSDictionary *data;

@end

NS_ASSUME_NONNULL_END
