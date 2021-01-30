//
//  AgoraRTEChannelMsgStreamInOut.m
//  EduSDK
//
//  Created by SRS on 2020/7/26.
//  Copyright © 2020 agora. All rights reserved.
//

#import "AgoraRTEChannelMsgStreamInOut.h"

@implementation AgoraRTEChannelMsgStreamInOut
@end

@implementation AgoraRTEChannelMsgStreamsInOut
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
        @"streams" : [AgoraRTEChannelMsgStreamInOut class]
    };
}
@end


