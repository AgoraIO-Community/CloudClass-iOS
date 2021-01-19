//
//  EduChannelMsgStreamInOut.m
//  EduSDK
//
//  Created by SRS on 2020/7/26.
//  Copyright © 2020 agora. All rights reserved.
//

#import "EduChannelMsgStreamInOut.h"

@implementation EduChannelMsgStreamInOut
@end

@implementation EduChannelMsgStreamsInOut
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
        @"streams" : [EduChannelMsgStreamInOut class]
    };
}
@end


