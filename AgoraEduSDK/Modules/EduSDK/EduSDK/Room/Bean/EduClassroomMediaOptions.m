//
//  EduClassroomSubscribeOption.m
//  EduSDK
//
//  Created by SRS on 2020/7/3.
//  Copyright © 2020 agora. All rights reserved.
//

#import "EduClassroomMediaOptions.h"

@implementation EduClassroomMediaOptions
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.autoSubscribe = YES;
        self.autoPublish = YES;
        self.primaryStreamId = 0;
    }
    return self;
}
@end
