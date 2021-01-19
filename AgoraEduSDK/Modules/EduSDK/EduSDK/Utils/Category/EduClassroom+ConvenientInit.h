//
//  EduClassroom+ConvenientInit.h
//  EduSDK
//
//  Created by SRS on 2020/7/21.
//  Copyright © 2020 agora. All rights reserved.
//

#import "EduClassroom.h"

NS_ASSUME_NONNULL_BEGIN

@interface EduClassroomInfo (ConvenientInit)
- (instancetype)initWithRoomUuid:(NSString *)roomUuid roomName:(NSString *)roomName;
@end

@interface EduClassroomState (ConvenientInit)
- (instancetype)initWithCourseState:(EduCourseState)courseState startTime:(NSInteger)startTime chatAllowed:(BOOL)isStudentChatAllowed count:(NSUInteger)onlineUserCount;
- (void)updateWithCourseState:(EduCourseState)courseState startTime:(NSInteger)startTime chatAllowed:(BOOL)isStudentChatAllowed count:(NSUInteger)onlineUserCount;
- (void)updateOnlineUsersCount:(NSUInteger)count;
@end

@interface EduClassroom (ConvenientInit)
- (instancetype)initWithRoomInfo:(EduClassroomInfo *)roomInfo roomState:(EduClassroomState *)roomState roomProperties:(NSDictionary *)roomProperties;
- (void)updateRoomProperties:(NSDictionary*)roomProperties;

@end

NS_ASSUME_NONNULL_END
