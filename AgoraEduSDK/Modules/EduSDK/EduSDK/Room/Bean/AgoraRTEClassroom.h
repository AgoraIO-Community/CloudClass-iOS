//
//  EducationRoom.h
//  Demo
//
//  Created by SRS on 2020/6/17.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AgoraRTEEnumerates.h"
#import "AgoraRTEBaseTypes.h"

NS_ASSUME_NONNULL_BEGIN

@interface AgoraRTEClassroomInfo : NSObject
@property (nonatomic, strong, readonly) NSString *roomUuid;
@property (nonatomic, strong) NSString *roomName;

- (instancetype)initWithRoomUuid:(NSString *)roomUuid;
@end

@interface AgoraRTEClassroomState : NSObject
@property (nonatomic, assign) AgoraRTECourseState courseState;
@property (nonatomic, assign) NSUInteger startTime;
@property (nonatomic, assign) BOOL isStudentChatAllowed;
@property (nonatomic, assign) NSUInteger onlineUserCount;
@end

@interface AgoraRTEClassroom : NSObject
@property (nonatomic, strong, readonly) AgoraRTEClassroomInfo *roomInfo;
@property (nonatomic, strong, readonly) AgoraRTEClassroomState *roomState;
@property (nonatomic, strong) NSDictionary *roomProperties;
@end

NS_ASSUME_NONNULL_END
