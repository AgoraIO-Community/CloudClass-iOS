//
//  AgoraEduManager.h
//  AgoraEducation
//
//  Created by SRS on 2020/7/27.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AgoraWhiteBoard/AgoraWhiteBoard.h>
#import <EduSDK/EduSDK.h>
#import "EduConfiguration.h"
#import "HTTPConfiguration.h"
#import <AgoraLog/AgoraLog.h>
#import "AgoraEduSDK.h"

NS_ASSUME_NONNULL_BEGIN

@interface AgoraEduManager : NSObject
#pragma mark APP
@property (nonatomic, assign) BOOL sdkReady;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *boardId;
@property (nonatomic, copy) NSString *boardToken;
@property (nonatomic, strong, nullable) AgoraEduClassroom *classroom;
@property (nonatomic, strong, nullable) AgoraEduReplay *replay;
@property (nonatomic, weak, nullable) id<AgoraEduClassroomDelegate> classroomDelegate;
@property (nonatomic, weak, nullable) id<AgoraEduReplayDelegate> replayDelegate;

#pragma mark --
@property (nonatomic, strong) EduManager *eduManager;
@property (nonatomic, strong) WhiteBoardManager *whiteBoardManager;

@property (nonatomic, strong) EduClassroomManager * _Nullable roomManager;
@property (nonatomic, strong) EduStudentService * _Nullable studentService;

// 用于超小的组频道
@property (nonatomic, strong) EduClassroomManager * _Nullable groupRoomManager;
@property (nonatomic, strong) EduStudentService * _Nullable groupStudentService;

+ (instancetype)shareManager;

- (void)setLogConsoleState:(AgoraLogConsoleState)state;

- (void)initWithUserUuid:(NSString *)userUuid userName:(NSString *)userName tag:(NSInteger)tag success:(void (^) (void))successBlock failure:(void (^) (NSString *errorMsg))failureBlock;

- (void)queryRoomStateWithConfig:(RoomStateConfiguration *)config success:(void (^) (void))successBlock failure:(void (^) (NSString * _Nonnull errorMsg))failureBlock;

- (void)joinClassroomWithSceneType:(EduSceneType)sceneType userName:(NSString*)userName success:(void (^) (void))successBlock failure:(void (^) (NSString * _Nonnull errorMsg))failureBlock;

- (void)getWhiteBoardInfoWithSuccess:(void (^) (NSString *boardId, NSString *boardToken))successBlock failure:(void (^) (NSString *errorMsg))failureBlock;

- (void)logMessage:(NSString *)message level:(EduLogLevel)level;
- (void)uploadDebugItemSuccess:(OnDebugItemUploadSuccessBlock) successBlock failure:(EduFailureBlock _Nullable)failureBlock;

+ (void)releaseResource;

@end

NS_ASSUME_NONNULL_END
