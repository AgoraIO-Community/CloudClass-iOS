//
//  EduClassroomJoinConfig.m
//  EduSDK
//
//  Created by SRS on 2020/7/3.
//  Copyright © 2020 agora. All rights reserved.
//

#import "EduClassroomJoinOptions.h"
#define NoNullString(x) ([x isKindOfClass:NSString.class] ? x : @"")

@implementation EduClassroomJoinOptions
- (instancetype)initWithUserName:(NSString *)userName role:(EduRoleType)role {
    
    if (self = [super init]) {
        EduClassroomMediaOptions *option = [EduClassroomMediaOptions new];
        self.userName = NoNullString(userName);
        self.role = role;
        self.mediaOption = option;
    }
    return self;
}

- (instancetype)initWithRole:(EduRoleType)role {
    if (self = [super init]) {
        EduClassroomMediaOptions *option = [EduClassroomMediaOptions new];
        self.role = role;
        self.mediaOption = option;
    }
    return self;
}

@end
