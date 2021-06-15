//
//  AgoraRTEClassroomJoinConfig.m
//  EduSDK
//
//  Created by SRS on 2020/7/3.
//  Copyright © 2020 agora. All rights reserved.
//

#import "AgoraRTEClassroomJoinOptions.h"

@implementation AgoraRTEClassroomJoinOptions
- (instancetype)initWithUserName:(NSString *)userName
                       urlRegion:(NSString *)urlRegion
                       rtcRegion:(NSString *)rtcRegion
                            role:(AgoraRTERoleType)role {
    
    if (self = [super init]) {
        AgoraRTEClassroomMediaOptions *option = [AgoraRTEClassroomMediaOptions new];
        self.userName = @"";
        if ([userName isKindOfClass:NSString.class]) {
            self.userName = userName;
        }
        self.role = role;
        self.mediaOption = option;
        self.urlRegion = urlRegion;
        self.rtcRegion = rtcRegion;
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
