//
//  AgoraEduClassroom.m
//  AgoraClassroomSDK
//
//  Created by SRS on 2021/1/9.
//

#import "AgoraClassroomSDK.h"
#import "AgoraEduTopVC.h"

@interface AgoraEduClassroom()

@end

@implementation AgoraEduClassroom

- (void)destroy {
    SEL func = NSSelectorFromString(@"setParameters:");
    NSDictionary *parameters = @{@"destory": @(1)};
    [AgoraClassroomSDK performSelector:func withObject:parameters];
}
@end
