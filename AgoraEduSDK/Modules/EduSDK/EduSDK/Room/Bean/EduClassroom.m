//
//  EducationRoom.m
//  Demo
//
//  Created by SRS on 2020/6/17.
//  Copyright © 2020 agora. All rights reserved.
//

#import "EduClassroom.h"
#import "EduConstants.h"

@interface EduClassroomInfo ()
@property (nonatomic, strong) NSString *roomUuid;
@end
@implementation EduClassroomInfo
- (instancetype)initWithRoomUuid:(NSString *)roomUuid {
    self = [super init];
    if (self) {
        self.roomUuid = roomUuid;
    }
    return self;
}
@end

@interface EduClassroomState ()
@end

@implementation EduClassroomState
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.courseState = EduCourseStateStop;
    }
    return self;
}
@end

@interface EduClassroom ()
@property (nonatomic, strong) EduClassroomInfo *roomInfo;
@property (nonatomic, strong) EduClassroomState *roomState;
@end

@implementation EduClassroom
@end

