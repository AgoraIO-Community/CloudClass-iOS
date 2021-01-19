//
//  EduClassroomManager.h
//  Demo
//
//  Created by SRS on 2020/6/17.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EduBaseTypes.h"
#import "EduUserService.h"
#import "EduClassroomJoinOptions.h"
#import "EduClassroom.h"
#import "EduClassroomDelegate.h"
#import "EduStream.h"
#import "EduTeacherService.h"
#import "EduAssistantService.h"
#import "EduStudentService.h"
#import "EduClassroomConfig.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^OnJoinRoomSuccessBlock)(EduUserService *userService);
typedef void (^OnGetLocalUserSuccessBlock)(EduLocalUser *user);
typedef void (^OnGetClassroomInfoSuccessBlock)(EduClassroom *room);
typedef void (^OnGetUserCountSuccessBlock)(NSUInteger count);
typedef void (^OnGetUserListSuccessBlock)(NSArray<EduUser*> *users);
typedef void (^OnGetStreamListSuccessBlock)(NSArray<EduStream*> *streams);

@interface EduClassroomManager : NSObject

@property (nonatomic, weak) id<EduClassroomDelegate> delegate;

- (void)joinClassroom:(EduClassroomJoinOptions*)options success:(OnJoinRoomSuccessBlock)successBlock failure:(EduFailureBlock _Nullable)failureBlock;

- (void)getLocalUserWithSuccess:(OnGetLocalUserSuccessBlock)successBlock failure:(EduFailureBlock _Nullable)failureBlock;
 
- (void)getClassroomInfoWithSuccess:(OnGetClassroomInfoSuccessBlock)successBlock failure:(EduFailureBlock _Nullable)failureBlock;

- (void)getUserCountWithRole:(EduRoleType)role success:(OnGetUserCountSuccessBlock)successBlock failure:(EduFailureBlock _Nullable)failureBlock;
- (void)getUserListWithRole:(EduRoleType)role from:(NSUInteger)fromIndex to:(NSUInteger)endIndex success:(OnGetUserListSuccessBlock)successBlock failure:(EduFailureBlock _Nullable)failureBlock;
- (void)getFullUserListWithSuccess:(OnGetUserListSuccessBlock)successBlock failure:(EduFailureBlock _Nullable)failureBlock;

- (void)getFullStreamListWithSuccess:(OnGetStreamListSuccessBlock)successBlock failure:(EduFailureBlock _Nullable)failureBlock;

- (void)leaveClassroomWithSuccess:(EduSuccessBlock _Nullable)successBlock failure:(EduFailureBlock _Nullable)failureBlock;

- (void)destory;

#pragma mark Unavailable Initializers
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
