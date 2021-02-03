//
//  AgoraEduManager.m
//  AgoraEducation
//
//  Created by SRS on 2020/7/27.
//  Copyright © 2020 Agora. All rights reserved.
//

#import "AgoraEduManager.h"
#import "AgoraEduKeyCenter.h"
#import "AgoraHTTPManager.h"
#import <YYModel/YYModel.h>
#import <EduSDK/AgoraRTEConstants.h>
#import "UIView+AgoraEduToast.h"

#define USER_PROPERTY_KEY_GROUP @"group"
#define ROOM_PROPERTY_KEY_BOARD @"board"

#define BREAKOUT_GROUP_MEMBER_LIMIT 4
#define MEDIUM_MEMBER_LIMIT 100

NSString * const kTeacherLimit = @"TeacherLimit";
NSString * const kAssistantLimit = @"AssistantLimit";
NSString * const kStudentLimit = @"StudentLimit";

static AgoraEduManager *manager = nil;

@interface AgoraEduManager()
@property (nonatomic, assign) AgoraLogLevel logLevel;
@property (nonatomic, strong) NSString *logDirectoryPath;
@property (nonatomic, strong) AgoraLogManager *logManager;

@property (nonatomic, assign) AgoraLogConsoleState consoleState;

@end

@implementation AgoraEduManager
- (void)setLogConsoleState:(AgoraLogConsoleState)state {
    self.consoleState = state;
}

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[AgoraEduManager alloc] init];
        manager.logLevel = AgoraLogLevelInfo;
        
        NSString *logFilePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"/AgoraEducation"];
        manager.logDirectoryPath = logFilePath;
        
        manager.sdkReady = NO;

        manager.consoleState = AgoraLogConsoleStateClose;
    });
    
    return manager;
}

- (void)initWithUserUuid:(NSString *)userUuid userName:(NSString *)userName tag:(NSInteger)tag success:(void (^) (void))successBlock failure:(void (^) (NSString *errorMsg))failureBlock {
    
    AgoraRTEConfiguration *config = [[AgoraRTEConfiguration alloc] initWithAppId:AgoraEduKeyCenter.agoraAppid userUuid:userUuid token:AgoraEduManager.shareManager.token userName:userName];
    config.logLevel = self.logLevel;
    config.logDirectoryPath = self.logDirectoryPath;
    config.tag = tag;
    config.logConsoleState = self.consoleState;
    self.eduManager = [[AgoraRTEManager alloc] initWithConfig:config success:successBlock failure:^(NSError * _Nonnull error) {
        failureBlock(error.localizedDescription);
    }];
    
    self.whiteBoardManager = [WhiteBoardManager new];
}

- (void)queryRoomStateWithConfig:(AgoraRoomStateConfiguration *)config success:(void (^) (void))successBlock failure:(void (^) (NSString * _Nonnull errorMsg))failureBlock {
    
    WEAK(self);
    
    [AgoraHTTPManager roomStateWithConfig:config success:^(AgoraRoomStateModel * _Nonnull model) {
            
        if (model.data && model.data.state == 2) {// end
            failureBlock(AgoraEduLocalizedString(@"ClassroomEndText", nil));
        } else {
            AgoraRTEClassroomConfig *classroomConfig = [AgoraRTEClassroomConfig new];
            classroomConfig.roomUuid = config.roomUuid;
            classroomConfig.sceneType = config.roomType;
            // 超小学生会加入2个房间： 老师的房间(大班课)和小组的房间（小班课）
            if (config.roomType == AgoraRTESceneTypeBreakout) {
                classroomConfig.sceneType = AgoraRTESceneTypeBig;
            }
            weakself.roomManager = [weakself.eduManager createClassroomWithConfig:classroomConfig];
        
            weakself.boardId = model.data.board.boardId;
            weakself.boardToken = model.data.board.boardToken;
            
            successBlock();
        }
            
    } failure:^(NSError * _Nonnull error, NSInteger statusCode) {
        if (error.code ==  20403001) {
            failureBlock(AgoraEduLocalizedString(@"UserFullText", nil));
        } else {
            failureBlock(error.localizedDescription);
        }
    }];
}

- (void)joinClassroomWithSceneType:(AgoraRTESceneType)sceneType userName:(NSString*)userName success:(void (^) (void))successBlock failure:(void (^) (NSString * _Nonnull errorMsg))failureBlock {
    
    WEAK(self);
    AgoraRTEClassroomJoinOptions *options = [[AgoraRTEClassroomJoinOptions alloc] initWithUserName:userName role:AgoraRTERoleTypeStudent];
    // 大班课不自动发流
    if (sceneType == AgoraRTESceneTypeBig || sceneType == AgoraRTESceneTypeBreakout || sceneType == AgoraRTESceneTypeMedium) {
        options.mediaOption.autoPublish = NO;
    } else {
        options.mediaOption.autoPublish = YES;
    }
    [self.roomManager joinClassroom:options success:^(AgoraRTEUserService * _Nonnull studentService) {
        
        weakself.studentService = (AgoraRTEStudentService*)studentService;
        if(sceneType != AgoraRTESceneTypeBreakout) {
            successBlock();
            return;
        }

        // 超小学生会加入2个房间： 老师的房间(大班课)和小组的房间（小班课）
        [weakself getGroupClassInfoWithSuccess:^(NSString *roomUuid, NSString *roomName) {

            AgoraRTEClassroomConfig *classroomConfig = [AgoraRTEClassroomConfig new];
            classroomConfig.roomUuid = roomUuid;
            classroomConfig.sceneType = AgoraRTESceneTypeSmall;
            weakself.groupRoomManager = [weakself.eduManager createClassroomWithConfig:classroomConfig];
            
            AgoraRTEClassroomJoinOptions *options = [[AgoraRTEClassroomJoinOptions alloc] initWithUserName:userName role:AgoraRTERoleTypeStudent];
            [weakself.groupRoomManager joinClassroom:options success:^(AgoraRTEUserService * _Nonnull userService) {
                weakself.groupStudentService = (AgoraRTEStudentService*)userService;
                successBlock();
            } failure:^(NSError * error) {
                failureBlock(error.localizedDescription);
            }];
            
        } failure:failureBlock];
        
    } failure:^(NSError * error) {
        failureBlock(error.localizedDescription);
    }];
}

- (void)getWhiteBoardInfoWithSuccess:(void (^) (NSString *boardId, NSString *boardToken))successBlock failure:(void (^) (NSString *errorMsg))failureBlock {
    
    WEAK(self);
    [self.roomManager getClassroomInfoWithSuccess:^(AgoraRTEClassroom * _Nonnull room) {
        
        if(room.roomProperties && room.roomProperties[ROOM_PROPERTY_KEY_BOARD]) {
            
            AgoraBoardDataModel *boardDataModel =
            [AgoraBoardDataModel yy_modelWithDictionary:room.roomProperties[ROOM_PROPERTY_KEY_BOARD]];
            
            successBlock(boardDataModel.info.boardId, boardDataModel.info.boardToken);
            return;
            
        } else {
            [weakself.roomManager getLocalUserWithSuccess:^(AgoraRTELocalUser * _Nonnull user) {
                
                AgoraBoardInfoConfiguration *config = [AgoraBoardInfoConfiguration new];
                config.appId = AgoraEduKeyCenter.agoraAppid;
                config.roomUuid = room.roomInfo.roomUuid;
                config.userToken = user.userToken;
                config.userUuid = user.userUuid;
                config.token = AgoraEduManager.shareManager.token;
                
                [AgoraHTTPManager getBoardInfoWithConfig:config success:^(AgoraBoardModel * _Nonnull boardModel) {
                    
                    AgoraBoardInfoModel *boardInfoModel = boardModel.data.info;
                    successBlock(boardInfoModel.boardId, boardInfoModel.boardToken);
                    
                } failure:^(NSError * _Nonnull error, NSInteger statusCode) {
                    failureBlock(error.localizedDescription);
                }];
                
            } failure:^(NSError * error) {
                failureBlock(error.localizedDescription);
            }];
        }
        
    } failure:^(NSError * error) {
        failureBlock(error.localizedDescription);
    }];
}

- (void)logMessage:(NSString *)message level:(AgoraLogLevel)level {
    
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

- (void)uploadDebugItemSuccess:(OnDebugItemUploadSuccessBlock)successBlock failure:(AgoraRTEFailureBlock _Nullable)failureBlock {
    
    WEAK(self);
    [self.roomManager getLocalUserWithSuccess:^(AgoraRTELocalUser * _Nonnull user) {
       
        if (weakself.eduManager != nil) {
            AgoraRTEDebugItem item = AgoraRTEDebugItemLog;
            [weakself.eduManager uploadDebugItem:item uid:user.userUuid token:weakself.token success:successBlock failure:failureBlock];
            
        } else {
            if(weakself.logManager == nil) {
                [weakself getLogManager];
            }
            AgoraLogUploadOptions *options = [AgoraLogUploadOptions new];
            options.appId = AgoraEduKeyCenter.agoraAppid;
            options.uid = user.userUuid;
            options.rtmToken = weakself.token;
        
            [weakself.logManager uploadLogWithOptions:options progress:nil success:successBlock failure:failureBlock];
        }
            
    } failure:failureBlock];
}

- (AgoraLogManager *)getLogManager {
    if(_logManager == nil) {
        AgoraLogManager *manager = [AgoraLogManager new];

        AgoraLogConfiguration *config = [AgoraLogConfiguration new];
        config.consoleState = self.consoleState;
        config.logLevel = AgoraLogLevelInfo;
        config.directoryPath = self.logDirectoryPath;
        [manager setupLog:config];
        
        _logManager = manager;
    }
    return _logManager;
}

#pragma mark PRIVATE
- (void)getGroupClassInfoWithSuccess:(void (^) (NSString *groupRoomUuid, NSString *groupRoomName))successBlock failure:(void (^) (NSString *errorMsg))failureBlock {
    
    WEAK(self);
    [self.roomManager getLocalUserWithSuccess:^(AgoraRTELocalUser * _Nonnull user) {
        
        if(user.userProperties && user.userProperties[USER_PROPERTY_KEY_GROUP]) {
            AgoraAssignGroupDataModel *model =
            [AgoraAssignGroupDataModel yy_modelWithDictionary:user.userProperties[USER_PROPERTY_KEY_GROUP]];
            successBlock(model.roomUuid, model.roomName);
            
        } else {
            
            [weakself.roomManager getClassroomInfoWithSuccess:^(AgoraRTEClassroom * _Nonnull room) {
                
                AgoraAssignGroupInfoConfiguration *assignConfig = [AgoraAssignGroupInfoConfiguration new];
                assignConfig.memberLimit = BREAKOUT_GROUP_MEMBER_LIMIT;
                assignConfig.appId = AgoraEduKeyCenter.agoraAppid;
                assignConfig.userToken = user.userToken;
                assignConfig.userUuid = user.userUuid;
                assignConfig.token = AgoraEduManager.shareManager.token;
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
                
                [AgoraHTTPManager assignBreakOutGroupWithConfig:assignConfig success:^(AgoraAssignGroupModel * _Nonnull assignGroupModel) {

                    AgoraAssignGroupDataModel *model = assignGroupModel.data;
                    model.memberLimit = BREAKOUT_GROUP_MEMBER_LIMIT;
                    successBlock(model.roomUuid, model.roomName);
                    
                } failure:^(NSError * _Nonnull error, NSInteger statusCode) {
                    failureBlock(error.localizedDescription);
                }];
                
            } failure:^(NSError * error) {
                failureBlock(error.localizedDescription);
            }];
        }
        
    } failure:^(NSError * error) {
        failureBlock(error.localizedDescription);
    }];
}

+ (void)showToast:(NSString *)msg {
    [UIApplication.sharedApplication.keyWindow makeToast:msg];
}

+ (void)releaseResource {
    
    [AgoraEduManager.shareManager.eduManager destory];
    AgoraEduManager.shareManager.eduManager = nil;
    AgoraEduManager.shareManager.roomManager = nil;
    AgoraEduManager.shareManager.groupRoomManager = nil;

    AgoraEduManager.shareManager.studentService = nil;
    AgoraEduManager.shareManager.groupStudentService = nil;
    
    [AgoraEduManager.shareManager.whiteBoardManager leaveBoardWithSuccess:nil failure:nil];
    
    AgoraEduManager.shareManager.classroom = nil;
    AgoraEduManager.shareManager.replay = nil;
    AgoraEduManager.shareManager.classroomDelegate = nil;
    AgoraEduManager.shareManager.replayDelegate = nil;
    
    AgoraEduManager.shareManager.sdkReady = NO;
}

@end
