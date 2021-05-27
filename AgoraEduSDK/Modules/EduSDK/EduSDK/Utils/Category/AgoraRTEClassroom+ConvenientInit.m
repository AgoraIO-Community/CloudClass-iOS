//
//  AgoraRTEClassroom+ConvenientInit.m
//  EduSDK
//
//  Created by SRS on 2020/7/21.
//  Copyright © 2020 agora. All rights reserved.
//

#import "AgoraRTEClassroom+ConvenientInit.h"

@implementation AgoraRTEClassroomInfo (ConvenientInit)
- (instancetype)initWithRoomUuid:(NSString *)roomUuid roomName:(NSString *)roomName {
    
    self = [super init];
    if (self) {
        [self setValue:roomUuid forKey:@"roomUuid"];
        [self setValue:roomName forKey:@"roomName"];
    }
    return self;
}
@end

@implementation AgoraRTEClassroomState (ConvenientInit)
- (instancetype)initWithCourseState:(AgoraRTECourseState)courseState startTime:(NSInteger)startTime chatAllowed:(BOOL)isStudentChatAllowed count:(NSUInteger)onlineUserCount {
    
    self = [super init];
    if (self) {
        [self updateWithCourseState:courseState startTime:startTime chatAllowed:isStudentChatAllowed count:onlineUserCount];
    }
    return self;
}

- (void)updateWithCourseState:(AgoraRTECourseState)courseState startTime:(NSInteger)startTime chatAllowed:(BOOL)isStudentChatAllowed count:(NSUInteger)onlineUserCount {
    [self setValue:@(courseState) forKey:@"courseState"];
    [self setValue:@(startTime) forKey:@"startTime"];
    [self setValue:@(isStudentChatAllowed) forKey:@"isStudentChatAllowed"];
    [self setValue:@(onlineUserCount) forKey:@"onlineUserCount"];
}

- (void)updateOnlineUsersCount:(NSUInteger)count {
    [self setValue:@(count) forKey:@"onlineUserCount"];
}

@end

@implementation AgoraRTEClassroom (ConvenientInit)
- (instancetype)initWithRoomInfo:(AgoraRTEClassroomInfo *)roomInfo roomState:(AgoraRTEClassroomState *)roomState roomProperties:(NSDictionary *)roomProperties {

    self = [super init];
    if (self) {
        [self setValue:roomInfo forKey:@"roomInfo"];
        [self setValue:roomState forKey:@"roomState"];
        [self setValue:roomProperties forKey:@"roomProperties"];
    }
    return self;
}

- (void)updateRoomProperties:(NSDictionary *)roomProperties {
    [self setValue:roomProperties forKey:@"roomProperties"];
}
@end
