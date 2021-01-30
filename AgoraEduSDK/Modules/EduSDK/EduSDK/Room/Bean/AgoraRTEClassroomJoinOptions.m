//
//  AgoraRTEClassroomJoinConfig.m
//  EduSDK
//
//  Created by SRS on 2020/7/3.
//  Copyright © 2020 agora. All rights reserved.
//

#import "AgoraRTEClassroomJoinOptions.h"
#define NoNullString(x) ([x isKindOfClass:NSString.class] ? x : @"")

@implementation AgoraRTEClassroomJoinOptions
- (instancetype)initWithUserName:(NSString *)userName role:(AgoraRTERoleType)role {
    
    if (self = [super init]) {
        AgoraRTEClassroomMediaOptions *option = [AgoraRTEClassroomMediaOptions new];
        self.userName = NoNullString(userName);
        self.role = role;
        self.mediaOption = option;
    }
    return self;
}

- (instancetype)initWithRole:(AgoraRTERoleType)role {
    if (self = [super init]) {
        AgoraRTEClassroomMediaOptions *option = [AgoraRTEClassroomMediaOptions new];
        self.role = role;
        self.mediaOption = option;
    }
    return self;
}

@end
