//
//  AgoraRTEChannelMsgUserInfo.m
//  EduSDK
//
//  Created by SRS on 2020/7/26.
//  Copyright © 2020 agora. All rights reserved.
//

#import "AgoraRTEChannelMsgUserInfo.h"

@implementation AgoraRTEChannelMsgUserInfo
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"opr"  : @"operator"};
}
@end
