//
//  EducationRoom.m
//  Demo
//
//  Created by SRS on 2020/6/17.
//  Copyright © 2020 agora. All rights reserved.
//

#import "AgoraRTEClassroom.h"
#import "AgoraRTEConstants.h"

@interface AgoraRTEClassroomInfo ()
@property (nonatomic, strong) NSString *roomUuid;
@end
@implementation AgoraRTEClassroomInfo
- (instancetype)initWithRoomUuid:(NSString *)roomUuid {
    self = [super init];
    if (self) {
        self.roomUuid = roomUuid;
    }
    return self;
}
@end

@interface AgoraRTEClassroomState ()
@end

@implementation AgoraRTEClassroomState
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.courseState = AgoraRTECourseStateStop;
    }
    return self;
}
@end

@interface AgoraRTEClassroom ()
@property (nonatomic, strong) AgoraRTEClassroomInfo *roomInfo;
@property (nonatomic, strong) AgoraRTEClassroomState *roomState;
@end

@implementation AgoraRTEClassroom
@end

