//
//  EducationRoom.h
//  Demo
//
//  Created by SRS on 2020/6/17.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EduEnumerates.h"
#import "EduBaseTypes.h"

NS_ASSUME_NONNULL_BEGIN

@interface EduClassroomInfo : NSObject
@property (nonatomic, strong, readonly) NSString *roomUuid;
@property (nonatomic, strong) NSString *roomName;

- (instancetype)initWithRoomUuid:(NSString *)roomUuid;
@end

@interface EduClassroomState : NSObject
@property (nonatomic, assign) EduCourseState courseState;
@property (nonatomic, assign) NSUInteger startTime;
@property (nonatomic, assign) BOOL isStudentChatAllowed;
@property (nonatomic, assign) NSUInteger onlineUserCount;
@end

@interface EduClassroom : NSObject
@property (nonatomic, strong, readonly) EduClassroomInfo *roomInfo;
@property (nonatomic, strong, readonly) EduClassroomState *roomState;
@property (nonatomic, strong) NSDictionary *roomProperties;
@end

NS_ASSUME_NONNULL_END
