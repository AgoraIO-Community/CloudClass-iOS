//
//  AgoraRTEClassroom+ConvenientInit.h
//  EduSDK
//
//  Created by SRS on 2020/7/21.
//  Copyright © 2020 agora. All rights reserved.
//

#import "AgoraRTEClassroom.h"

NS_ASSUME_NONNULL_BEGIN

@interface AgoraRTEClassroomInfo (ConvenientInit)
- (instancetype)initWithRoomUuid:(NSString *)roomUuid roomName:(NSString *)roomName;
@end

@interface AgoraRTEClassroomState (ConvenientInit)
- (instancetype)initWithCourseState:(AgoraRTECourseState)courseState startTime:(NSInteger)startTime chatAllowed:(BOOL)isStudentChatAllowed count:(NSUInteger)onlineUserCount;
- (void)updateWithCourseState:(AgoraRTECourseState)courseState startTime:(NSInteger)startTime chatAllowed:(BOOL)isStudentChatAllowed count:(NSUInteger)onlineUserCount;
- (void)updateOnlineUsersCount:(NSUInteger)count;
@end

@interface AgoraRTEClassroom (ConvenientInit)
- (instancetype)initWithRoomInfo:(AgoraRTEClassroomInfo *)roomInfo roomState:(AgoraRTEClassroomState *)roomState roomProperties:(NSDictionary *)roomProperties;
- (void)updateRoomProperties:(NSDictionary*)roomProperties;

@end

NS_ASSUME_NONNULL_END
