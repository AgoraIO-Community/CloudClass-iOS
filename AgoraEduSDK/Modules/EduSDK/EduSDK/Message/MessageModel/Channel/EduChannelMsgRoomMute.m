//
//  EduChannelMsgRoomMute.m
//  EduSDK
//
//  Created by SRS on 2020/7/23.
//  Copyright © 2020 agora. All rights reserved.
//

#import "EduChannelMsgRoomMute.h"
#import "RoomModel.h"

@implementation EduChannelMsgRoomMute
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"opr"  : @"operator"};
}
@end
