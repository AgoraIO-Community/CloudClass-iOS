//
//  AgoraEduManager.m
//  AgoraEducation
//
//  Created by SRS on 2020/7/27.
//  Copyright © 2020 Agora. All rights reserved.
//

#import "AgoraEduManager.h"
#import "AgoraHTTPManager.h"
#import <YYModel/YYModel.h>
#import <EduSDK/AgoraRTEConstants.h>
#import "AgoraManagerCache.h"

#define USER_PROPERTY_KEY_GROUP @"group"
#define ROOM_PROPERTY_KEY_BOARD @"board"

#define BREAKOUT_GROUP_MEMBER_LIMIT 4
#define MEDIUM_MEMBER_LIMIT 500

NSString * const kTeacherLimit = @"TeacherLimit";
NSString * const kAssistantLimit = @"AssistantLimit";
NSString * const kStudentLimit = @"StudentLimit";

static AgoraEduManager *manager = nil;

@interface AgoraEduManager()
@property (nonatomic, assign) AgoraLogLevelType logLevel;
@property (nonatomic, assign) AgoraLogConsoleState consoleState;
@property (nonatomic, strong) AgoraLogManager *logManager;
@property (nonatomic, strong) NSString *logDirectoryPath;

@property (nonatomic, strong) AgoraLogUploadOptions *logOptions;

@property (nonatomic, strong) NSString *roomName;
@property (nonatomic, assign) AgoraRTESceneType roomType;

@property (nonatomic, strong, nullable) AgoraRTEVideoConfig *videoConfig;
@end

@implementation AgoraEduManager
- (void)setLogConsoleState:(AgoraLogConsoleState)state {
    self.consoleState = state;
}

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[AgoraEduManager alloc] init];
        manager.logLevel = AgoraLogLevelTypeInfo;
        NSString *cachesPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                                   NSUserDomainMask,
                                                                   YES).firstObject;
        NSString *logFilePath = [cachesPath stringByAppendingPathComponent:@"/AgoraEducation"];
        manager.logDirectoryPath = logFilePath;
        manager.consoleState = AgoraLogConsoleStateClose;
    });
    
    return manager;
}

- (void)initWithUserUuid:(NSString *)userUuid
                userName:(NSString *)userName
                  roomId:(NSString *)roomId
                roomName:(NSString *)roomName
                  role:(AgoraEduRoleType)role
                     tag:(NSInteger)tag
             videoConfig:(AgoraRTEVideoConfig * _Nullable)videoConfig
                 success:(void (^) (void))successBlock
                 failure:(void (^) (NSError * _Nonnull error))failureBlock {
    AgoraRTEConfiguration *config = [[AgoraRTEConfiguration alloc] initWithAppId:AgoraManagerCache.share.appId
                                                                        userUuid:userUuid
                                                                           token:AgoraManagerCache.share.token
                                                                        userName:userName];
    config.logLevel = self.logLevel;
    config.logDirectoryPath = self.logDirectoryPath;
    config.tag = tag;
    config.logConsoleState = self.consoleState;
    
    self.logOptions.roomName = roomName;
    self.logOptions.roomType = [NSString stringWithFormat:@"%ld",tag];
    self.logOptions.userName = userName;
    self.logOptions.userUuid = userUuid;
    self.logOptions.role = [NSNumber numberWithInt:role];
    self.logOptions.roomUuid = roomId;
    
    self.videoConfig = videoConfig;
    self.eduManager = [[AgoraRTEManager alloc] initWithConfig:config
                                                      success:successBlock
                                                      failure:^(NSError * _Nonnull error) {
        failureBlock(error);
    }];
}

- (void)queryRoomStateWithConfig:(AgoraRoomStateConfiguration *)config
                         success:(void (^) (void))successBlock
                         failure:(void (^) ( NSError * _Nonnull error, NSInteger statusCode))failureBlock {
    AgoraWEAK(self);
    
    [AgoraHTTPManager roomStateWithConfig:config
                                  success:^(AgoraRoomStateModel * _Nonnull model) {
        if (model.data == nil) {
            NSError *error = [[NSError alloc] initWithDomain:@"AgoraEdu"
                                                        code:model.data.state
                                                    userInfo:nil];
            
            failureBlock(error, 200);
        } else {
            self.roomName = config.roomName ? config.roomName : @"";
            self.roomType = config.roomType;
            
            AgoraRTEClassroomConfig *classroomConfig = [AgoraRTEClassroomConfig new];
            classroomConfig.roomUuid = config.roomUuid;
            classroomConfig.sceneType = config.roomType;
            // 超小学生会加入2个房间： 老师的房间(大班课)和小组的房间（小班课）
            if (config.roomType == AgoraRTESceneTypeBreakout) {
                classroomConfig.sceneType = AgoraRTESceneTypeBig;
            }
            weakself.roomManager = [weakself.eduManager createClassroomWithConfig:classroomConfig];
            
            AgoraManagerCache.share.roomStateInfoModel = model.data;
            AgoraManagerCache.share.userUuid = config.userUuid;
            AgoraManagerCache.share.roomUuid = config.roomUuid;
            NSDate *datenow = [NSDate date];
            NSTimeInterval interval = [datenow timeIntervalSince1970];
            AgoraManagerCache.share.differTime = interval * 1000 - model.ts;
            
            successBlock();
        }
    } failure:^(NSError * _Nonnull error, NSInteger statusCode) {
        if (error.code == 20403001) {
            NSString *message = AgoraLocalizedString(@"UserFullText", nil);
            NSError *_err = [[NSError alloc] initWithDomain:error.domain
                                                       code:error.code
                                                   userInfo:@{NSLocalizedDescriptionKey: (message)}];
            
            failureBlock(_err, statusCode);
        } else {
            failureBlock(error, statusCode);
        }
    }];
}

- (void)joinClassroomWithSceneType:(AgoraRTESceneType)sceneType
                          userName:(NSString*)userName
                           success:(void (^) (UInt64 timestamp))successBlock
                           failure:(void (^) (NSError * _Nonnull error))failureBlock {
    
    AgoraWEAK(self);
    AgoraRTEClassroomJoinOptions *options = [[AgoraRTEClassroomJoinOptions alloc] initWithUserName:userName
                                                                                              role:AgoraRTERoleTypeStudent];
    // 大班课不自动发流
    if (sceneType == AgoraRTESceneTypeBig || sceneType == AgoraRTESceneTypeBreakout || sceneType == AgoraRTESceneTypeMedium) {
        options.mediaOption.autoPublish = NO;
    } else {
        options.mediaOption.autoPublish = YES;
    }
    
    options.videoConfig = self.videoConfig;
    
    [self.roomManager joinClassroom:options
                            success:^(AgoraRTEUserService * _Nonnull studentService, UInt64 timestamp) {
        weakself.studentService = (AgoraRTEStudentService*)studentService;
        successBlock(timestamp);
    } failure:^(NSError * error) {
        failureBlock(error);
    }];
}

- (void)logMessage:(NSString *)message
             level:(AgoraLogLevelType)level {
    if (self.eduManager != nil) {
        self.logManager = nil;
        [self.eduManager logMessage:message level:level];
    } else {
        if(self.logManager == nil) {
            [self getLogManager];
        }
        [self.logManager logMessage:message level:level];
    }
}

- (void)uploadDebugItemSuccess:(OnDebugItemUploadSuccessBlock)successBlock
                       failure:(AgoraRTEFailureBlock _Nullable)failureBlock {
    if (self.roomManager) {
        AgoraWEAK(self);
        [self.roomManager getLocalUserWithSuccess:^(AgoraRTELocalUser * _Nonnull user) {
            self.logOptions.userUuid = user.userUuid;
            self.logOptions.role = [NSString stringWithFormat:@"%ld",user.role];
            self.logOptions.userName = user.userName;
        } failure:failureBlock];
    }
    
    if (self.eduManager != nil) {
        AgoraRTEDebugItem item = AgoraRTEDebugItemLog;
        [self.eduManager uploadDebugItem:item
                                     options:self.logOptions
                                     success:successBlock
                                     failure:failureBlock];
    } else {
        if(self.logManager == nil) {
            [self getLogManager];
        }
        
        [self.logManager uploadLogWithOptions:self.logOptions
                                         progress:nil
                                          success:successBlock
                                          failure:failureBlock];
    }
}

- (void)checkLogZipToUploadWithUserName:(NSString *)userName
                               userUuid:(NSString *)userUuid {
    if(self.logManager == nil) {
        [self getLogManager];
    }
    self.logOptions.userName = userName;
    self.logOptions.userUuid = userUuid;
    
    __weak typeof(self)weakSelf = self;
    // logManager用完就释放， 防止内部的日志重复，导致2份日志
    [self.logManager checkLogZipToUpload:self.logOptions
                                 success:^(NSString * _Nonnull uploadSerialNumber) {
        weakSelf.logManager = nil;
    } fail:^(NSError * _Nonnull error) {
        weakSelf.logManager = nil;
    }];
}

- (AgoraLogManager *)getLogManager {
    if (_logManager == nil) {
        AgoraLogManager *manager = [AgoraLogManager new];

        AgoraLogConfiguration *config = [AgoraLogConfiguration new];
        config.consoleState = self.consoleState;
        config.logLevel = AgoraLogLevelTypeInfo;
        config.directoryPath = self.logDirectoryPath;
        [manager setupLog:config];
        
        _logManager = manager;
    }
    return _logManager;
}

- (AgoraLogUploadOptions *)logOptions {
    if (!_logOptions) {
        _logOptions = [[AgoraLogUploadOptions alloc] init];
        _logOptions.appId = AgoraManagerCache.share.appId;
        _logOptions.rtmToken = AgoraManagerCache.share.token;
    }
    return _logOptions;
}


#pragma mark PRIVATE
- (void)getGroupClassInfoWithSuccess:(void (^) (NSString *groupRoomUuid, NSString *groupRoomName))successBlock
                             failure:(void (^) (NSError *error))failureBlock {
    AgoraWEAK(self);
    
    [self.roomManager getLocalUserWithSuccess:^(AgoraRTELocalUser * _Nonnull user) {
        if (user.userProperties && user.userProperties[USER_PROPERTY_KEY_GROUP]) {
            AgoraAssignGroupDataModel *model = [AgoraAssignGroupDataModel yy_modelWithDictionary:user.userProperties[USER_PROPERTY_KEY_GROUP]];
            successBlock(model.roomUuid,
                         model.roomName);
        } else {
            [weakself.roomManager getClassroomInfoWithSuccess:^(AgoraRTEClassroom * _Nonnull room) {
                AgoraAssignGroupInfoConfiguration *assignConfig = [AgoraAssignGroupInfoConfiguration new];
                assignConfig.memberLimit = BREAKOUT_GROUP_MEMBER_LIMIT;
                assignConfig.appId = AgoraManagerCache.share.appId;
                assignConfig.userToken = user.userToken;
                assignConfig.userUuid = user.userUuid;
                assignConfig.token = AgoraManagerCache.share.token;
                assignConfig.roomUuid = room.roomInfo.roomUuid;
                
                // role config
                {
                    AgoraRoleConfiguration *host = [AgoraRoleConfiguration new];
                    host.limit = 1;
                    assignConfig.host = host;
                    
                    AgoraRoleConfiguration *assistant = [AgoraRoleConfiguration new];
                    assistant.limit = 1;
                    assignConfig.assistant = assistant;
                    
                    AgoraRoleConfiguration *broadcaster = [AgoraRoleConfiguration new];
                    broadcaster.limit = 4;
                    assignConfig.broadcaster = broadcaster;
                }
                
                [AgoraHTTPManager assignBreakOutGroupWithConfig:assignConfig
                                                        success:^(AgoraAssignGroupModel * _Nonnull assignGroupModel) {
                    AgoraAssignGroupDataModel *model = assignGroupModel.data;
                    model.memberLimit = BREAKOUT_GROUP_MEMBER_LIMIT;
                    successBlock(model.roomUuid, model.roomName);
                } failure:^(NSError * _Nonnull error, NSInteger statusCode) {
                    failureBlock(error);
                }];
            } failure:^(NSError *error) {
                failureBlock(error);
            }];
        }
    } failure:^(NSError *error) {
        failureBlock(error);
    }];
}

+ (void)releaseResource {
    dispatch_async(dispatch_queue_create(0, 0), ^{
        [AgoraEduManager.shareManager.eduManager destory];
        AgoraEduManager.shareManager.eduManager = nil;
        AgoraEduManager.shareManager.roomManager = nil;
        AgoraEduManager.shareManager.logManager = nil;

        AgoraEduManager.shareManager.studentService = nil;
        
        [AgoraManagerCache releaseResource];
    });
}
@end
