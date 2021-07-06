//
//  AgoraRTEClassroomManager.h
//  Demo
//
//  Created by SRS on 2020/6/17.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AgoraRTEBaseTypes.h"
#import "AgoraRTEUserService.h"
#import "AgoraRTEClassroomJoinOptions.h"
#import "AgoraRTEClassroom.h"
#import "AgoraRTEClassroomDelegate.h"
#import "AgoraRTEStream.h"
#import "AgoraRTETeacherService.h"
#import "AgoraRTEAssistantService.h"
#import "AgoraRTEStudentService.h"
#import "AgoraRTEClassroomConfig.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^OnJoinRoomSuccessBlock)(AgoraRTEUserService *userService, UInt64 timestamp);
typedef void (^OnGetLocalUserSuccessBlock)(AgoraRTELocalUser *user);
typedef void (^OnGetClassroomInfoSuccessBlock)(AgoraRTEClassroom *room);
typedef void (^OnGetUserCountSuccessBlock)(NSUInteger count);
typedef void (^OnGetUserListSuccessBlock)(NSArray<AgoraRTEUser*> *users);
typedef void (^OnGetStreamListSuccessBlock)(NSArray<AgoraRTEStream*> *streams);

@interface AgoraRTEClassroomManager : NSObject

@property (nonatomic, weak) id<AgoraRTEClassroomDelegate> delegate;

- (void)joinClassroom:(AgoraRTEClassroomJoinOptions*)options
              success:(OnJoinRoomSuccessBlock)successBlock
              failure:(AgoraRTEFailureBlock _Nullable)failureBlock;

- (void)getLocalUserWithSuccess:(OnGetLocalUserSuccessBlock)successBlock
                        failure:(AgoraRTEFailureBlock _Nullable)failureBlock;
 
- (void)getClassroomInfoWithSuccess:(OnGetClassroomInfoSuccessBlock)successBlock
                            failure:(AgoraRTEFailureBlock _Nullable)failureBlock;

- (void)getUserCountWithRole:(AgoraRTERoleType)role
                     success:(OnGetUserCountSuccessBlock)successBlock
                     failure:(AgoraRTEFailureBlock _Nullable)failureBlock;

- (void)getUserListWithRole:(AgoraRTERoleType)role
                       from:(NSUInteger)fromIndex
                         to:(NSUInteger)endIndex
                    success:(OnGetUserListSuccessBlock)successBlock
                    failure:(AgoraRTEFailureBlock _Nullable)failureBlock;

- (void)getFullUserListWithSuccess:(OnGetUserListSuccessBlock)successBlock
                           failure:(AgoraRTEFailureBlock _Nullable)failureBlock;

- (void)getFullStreamListWithSuccess:(OnGetStreamListSuccessBlock)successBlock
                             failure:(AgoraRTEFailureBlock _Nullable)failureBlock;

- (void)leaveClassroomWithSuccess:(AgoraRTESuccessBlock _Nullable)successBlock
                          failure:(AgoraRTEFailureBlock _Nullable)failureBlock;

- (void)destory;

#pragma mark Unavailable Initializers
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
