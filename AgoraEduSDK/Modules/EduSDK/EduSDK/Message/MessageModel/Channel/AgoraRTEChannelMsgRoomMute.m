//
//  AgoraRTEChannelMsgRoomMute.m
//  EduSDK
//
//  Created by SRS on 2020/7/23.
//  Copyright © 2020 agora. All rights reserved.
//

#import "AgoraRTEChannelMsgRoomMute.h"
#import "AgoraRTERoomModel.h"

@implementation AgoraRTEChannelMsgRoomMute
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"opr"  : @"operator"};
}
@end
