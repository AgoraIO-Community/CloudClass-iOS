//
//  AgoraEduManager.h
//  AgoraEducation
//
//  Created by SRS on 2020/7/27.
//  Copyright © 2020 Agora. All rights reserved.
//

#import <AgoraWhiteBoard/AgoraWhiteBoard.h>
#import <AgoraLog/AgoraLog.h>
#import <EduSDK/EduSDK.h>
#import "AgoraHTTPConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@interface AgoraEduManager : NSObject
@property (nonatomic, strong) AgoraRTEManager *eduManager;
@property (nonatomic, strong) AgoraRTEClassroomManager * _Nullable roomManager;
@property (nonatomic, strong) AgoraRTEStudentService * _Nullable studentService;

+ (instancetype)shareManager;

- (void)setLogConsoleState:(AgoraLogConsoleState)state;

- (void)initWithUserUuid:(NSString *)userUuid
                userName:(NSString *)userName
                  roomId:(NSString *)roomId
                     tag:(NSInteger)tag
             videoConfig:(AgoraRTEVideoConfig * _Nullable)videoConfig
                 success:(void (^) (void))successBlock
                 failure:(void (^) (NSError * _Nonnull error))failureBlock;

- (void)queryRoomStateWithConfig:(AgoraRoomStateConfiguration *)config
                         success:(void (^) (void))successBlock
                         failure:(void (^) ( NSError * _Nonnull error, NSInteger statusCode))failureBlock;

- (void)joinClassroomWithSceneType:(AgoraRTESceneType)sceneType
                          userName:(NSString*)userName
                           success:(void (^) (UInt64 timestamp))successBlock
                           failure:(void (^) (NSError * _Nonnull error))failureBlock;

- (void)logMessage:(NSString *)message
             level:(AgoraRTELogLevel)level;

- (void)uploadDebugItemSuccess:(OnDebugItemUploadSuccessBlock)successBlock
                       failure:(AgoraRTEFailureBlock _Nullable)failureBlock;

+ (void)releaseResource;
@end

NS_ASSUME_NONNULL_END
