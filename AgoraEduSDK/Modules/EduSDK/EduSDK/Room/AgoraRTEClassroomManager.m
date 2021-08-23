//
//  AgoraRTEClassroomManager.m
//  Demo
//
//  Created by SRS on 2020/6/17.
//  Copyright © 2020 agora. All rights reserved.
//

#import "AgoraRTEClassroomManager.h"
#import "AgoraRTEHttpManager.h"
#import "AgoraRTCManager.h"
#import "AgoraRTMManager.h"
#import "AgoraRTEStream.h"
#import "AgoraRTEConstants.h"
#import "AgoraRTEMessageHandle.h"

#import "AgoraRTEUser+ConvenientInit.h"
#import "AgoraRTEClassroom+ConvenientInit.h"

#import "AgoraRTEJoinRoomModel.h"
#import "AgoraRTERoomModel.h"
#import "AgoraRTECommonModel.h"

#import "AgoraRTELogService.h"

#import "AgoraRTEChannelMessageHandle.h"

#import "AgoraRTESyncUserModel.h"
#import "AgoraRTESyncStreamModel.h"
#import "AgoraRTESyncRoomModel.h"

#import "AgoraRTESyncIncreaseModel.h"

#import "AgoraRTELogService.h"
#import "AgoraRTEErrorManager.h"

#import "AgoraRTEKVCClassroomConfig.h"
#import "AgoraRTEKVCUserConfig.h"
#import "AgoraRTEManager.h"

#import <EduSDK/EduSDK-Swift.h>
#import <AgoraReport/AgoraReport-Swift.h>

#define AgoraRTE_NOTICE_KEY_ROOM_DESTORY @"AgoraRTE_NOTICE_KEY_ROOM_DESTORY"

typedef void (^OnJoinRoomSuccessBlock)(AgoraRTEUserService *userService, UInt64 timestamp);

@interface AgoraRTEClassroomManager() <AgoraRTMChannelDelegate, AgoraRTCManagerDelegate>
@property (nonatomic, strong) NSString *appId;
@property (nonatomic, strong) NSString *roomUuid;
@property (nonatomic, strong) NSString *defaultUserName;
@property (nonatomic, strong) NSString *userToken;
@property (nonatomic, assign) AgoraRTESceneType sceneType;
@property (nonatomic, strong) AgoraRTEClassroomMediaOptions *mediaOption;

@property (nonatomic, strong) AgoraRTEUserService *userService;

@property (nonatomic, strong) AgoraRTEChannelMessageHandle *messageHandle;
@property (nonatomic, strong) AgoraRTESyncRoomSession *syncRoomSession;

@property (nonatomic, copy) AgoraRTESuccessBlock joinRTCSuccessBlock;

// state
@property (nonatomic, assign) BOOL increaseSyncing;
@end

@implementation AgoraRTEClassroomManager
- (instancetype)initWithConfig:(AgoraRTEKVCClassroomConfig *)config {
    if (self = [super init]) {
        self.increaseSyncing = NO;
        
        HttpManagerConfig *httpConfig = [AgoraRTEHttpManager getHttpManagerConfig];
        self.appId = httpConfig.appid;
        self.roomUuid = config.roomUuid;
        self.defaultUserName = config.dafaultUserName;
        self.sceneType = config.sceneType;
        
        self.syncRoomSession = [[AgoraRTESyncRoomSession alloc] initWithUserUuid:httpConfig.userUuid
                                                                       roomClass:AgoraRTESyncRoomModel.class
                                                                        useClass:AgoraRTESyncUserModel.class
                                                                     streamClass:AgoraRTESyncStreamModel.class];
        AgoraRTEWEAK(self);
        self.syncRoomSession.fetchMessageList = ^(NSInteger nextId, NSInteger count) {
            [weakself syncIncreaseWithStartIndex:nextId
                                           count:count
                                         success:nil];
        };
        self.messageHandle = [[AgoraRTEChannelMessageHandle alloc] initWithSyncSession:self.syncRoomSession];
        self.messageHandle.roomUuid = self.roomUuid;
        
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(onReconnecting)
                                                   name:NOTICE_KEY_START_RECONNECT
                                                 object:nil];
    }

    return self;
}

- (void)onReconnecting {
    NSInteger nextId = self.syncRoomSession.currentMaxSeq + 1;
    [self syncIncreaseWithStartIndex:nextId
                               count:0
                             success:^{
    }];
    [NSNotificationCenter.defaultCenter postNotificationName:NOTICE_KEY_END_RECONNECT
                                                      object:nil];
}

- (void)joinClassroom:(AgoraRTEClassroomJoinOptions*)options
              success:(OnJoinRoomSuccessBlock)successBlock
              failure:(AgoraRTEFailureBlock _Nullable)failureBlock {
    NSString *userName = self.defaultUserName;
    
    if ([options isKindOfClass:AgoraRTEClassroomJoinOptions.class] && options.userName != nil) {
        userName = options.userName;
    }

    NSAssert(AgoraRTENoNullString(userName).length > 0, @"userName must not null");
    
    NSError *error;
    if (![options isKindOfClass:AgoraRTEClassroomJoinOptions.class]) {
        error = [AgoraRTEErrorManager paramterInvalid:@"options"
                                                 code:1];
    } else {
        error = [AgoraRTEErrorManager paramterEmptyError:@"userName"
                                                   value:userName
                                                    code:1];
    }

    if (error == nil) {
        if (options.role != AgoraRTERoleTypeStudent && options.role != AgoraRTERoleTypeTeacher && options.role != AgoraRTERoleTypeAssistant) {
            error = [AgoraRTEErrorManager paramterInvalid:@"role"
                                                     code:1];
        }
    }
    if (error != nil) {
        if(failureBlock != nil){
            failureBlock(error);
        }
        return;
    }
    
    self.mediaOption = options.mediaOption;

    AgoraRTEWEAK(self);
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"userName"] = AgoraRTENoNullString(userName);
    if (options.role == AgoraRTERoleTypeTeacher) {
        params[@"role"] = kAgoraRTEServiceRoleHost;
        
    } else if(options.role == AgoraRTERoleTypeAssistant){
        params[@"role"] = kAgoraRTEServiceRoleAudience;
        
    } else if(options.role == AgoraRTERoleTypeStudent) {
        if(self.sceneType == AgoraRTESceneTypeBig
           || self.sceneType == AgoraRTESceneTypeMedium
           || self.sceneType == AgoraRTESceneTypeBreakout) {
            params[@"role"] = kAgoraRTEServiceRoleAudience;
        } else {
            params[@"role"] = kAgoraRTEServiceRoleBroadcaster;
        }
    }
    params[@"streamUuid"] = @(options.mediaOption.primaryStreamId);
    if (options.mediaOption.autoPublish){
        params[@"publishType"] = @(1);
    }

    __block NSString *userId;
    
    [self getLocalUserWithSuccess:^(AgoraRTELocalUser * _Nonnull user) {
        userId = user.userUuid;
    } failure:nil];
    
    // Report
    HttpManagerConfig *httpConfig = [AgoraRTEHttpManager getHttpManagerConfig];
    NSString *host = [AgoraRteReportorWrapper getRteReporter].context.host;
    AgoraReportorContext *context = [[AgoraReportorContext alloc] initWithSource:@"rte"
                                                                      clientType:@"flexibleClass"
                                                                        platform:@"iOS"
                                                                           appId:self.appId
                                                                         version:AgoraRTEManager.version
                                                                           token:httpConfig.token
                                                                        userUuid:httpConfig.userUuid
                                                                            host:host];
    
    [[AgoraRteReportorWrapper getRteReporter] setWithContext:context];
    [AgoraRteReportorWrapper startJoinRoom];;
    
    NSString *subEvent = @"http-entry";
    NSString *httpApi = @"entry";
    [AgoraRteReportorWrapper startJoinRoomSubEventWithSubEvent:subEvent];
    
    // entry-》初始化RTM&RTC => sync => auto
    [AgoraRTEHttpManager joinRoomWithRoomUuid:self.roomUuid
                                        param:params
                                   apiVersion:APIVersion1
                                analysisClass:AgoraRTEJoinRoomModel.class
                                      success:^(id<AgoraRTEBaseModel> objModel) {
        // Report
        [AgoraRteReportorWrapper endJoinRoomSubEventWithSubEvent:subEvent
                                                            type:AgoraReportEndCategoryHttp
                                                       errorCode:0
                                                        httpCode:200
                                                             api:httpApi];
         
        AgoraRTEJoinRoomInfoModel *model = ((AgoraRTEJoinRoomModel*)objModel).data;
        weakself.userToken = model.user.userToken;
        
        AgoraRTEUserService *userService;
        SEL action = NSSelectorFromString(@"initWithConfig:");
 
        AgoraRTEKVCUserConfig *kvcConfig = [AgoraRTEKVCUserConfig new];
        kvcConfig.roomUuid = weakself.roomUuid;
        kvcConfig.messageHandle = weakself.messageHandle;
        kvcConfig.mediaOption = options.mediaOption;
        kvcConfig.userToken = model.user.userToken;
        
        if (options.role == AgoraRTERoleTypeTeacher) {
            userService = [AgoraRTETeacherService alloc];
        } else if (options.role == AgoraRTERoleTypeStudent) {
            userService = [AgoraRTEStudentService alloc];
        } else if (options.role == AgoraRTERoleTypeAssistant) {
            userService = [AgoraRTEAssistantService alloc];
        }
        if ([userService respondsToSelector:action]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [userService performSelector:action withObject:kvcConfig];
#pragma clang diagnostic pop
        }

        // local
        id userObj = [model.user yy_modelToJSONObject];
        weakself.syncRoomSession.localUser = [AgoraRTESyncUserModel new];
        [weakself.syncRoomSession.localUser yy_modelSetWithJSON:userObj];
        weakself.syncRoomSession.localUser.state = 1;
        
        [AgoraRTELogService logMessageWithDescribe:@"classroom:"
                                           message:@{@"roomUuid":AgoraRTENoNullString(weakself.roomUuid),
                                                     @"localuser":weakself.syncRoomSession.localUser}];
        // media
        weakself.userService = userService;
        
        // set videoConfig before join room
        [weakself setVideoConfig:options.videoConfig];
        
        [weakself initMediaDispatchGroup:model
                                 success:^{
            [AgoraRTELogService logMessageWithDescribe:@"classroom initMedia success:"
                                               message:@{@"roomUuid":AgoraRTENoNullString(weakself.roomUuid)}];
            
            [weakself syncTotalSuccess:^{
                [AgoraRTELogService logMessageWithDescribe:@"classroom initMedia success:"
                                                   message:@{@"roomUuid": AgoraRTENoNullString(weakself.roomUuid),
                                                             @"users": weakself.syncRoomSession.users,
                                                             @"streams": weakself.syncRoomSession.streams}];
                
                // auto
                [weakself setupPublishOptionsSuccess:^{
                    // Report
                    [AgoraRteReportorWrapper endJoinRoomWithErrorCode:0
                                                             httpCode:200];
                    [AgoraRteReportorWrapper startTimerOnline];
                    
                    if(successBlock){
                        successBlock(userService, model.room.roomState.createTime);
                    }
                } failure:^(NSError * error) {
                    // Report
                    [AgoraRteReportorWrapper endJoinRoomWithErrorCode:error.code
                                                             httpCode:nil];

                    [weakself releaseResource];
                    NSError *eduError = [AgoraRTEErrorManager internalError:@""
                                                                       code:2];
                    if(failureBlock != nil) {
                        failureBlock(eduError);
                    }
                }];
            }];
        } failure:^(NSError * error) {
            [weakself releaseResource];
            if(failureBlock){
                failureBlock(error);
            }
            
            // Report
            [AgoraRteReportorWrapper endJoinRoomWithErrorCode:error.code
                                                     httpCode:nil];
        }];
        
    } failure:^(NSError * error, NSInteger statusCode) {
        NSError *eduError = [AgoraRTEErrorManager networkError:error.code
                                                       codeMsg:error.localizedDescription
                                                          code:301];
        if (failureBlock != nil) {
            failureBlock(eduError);
        }
        
        // Report
        [AgoraRteReportorWrapper endJoinRoomSubEventWithSubEvent:subEvent
                                                            type:AgoraReportEndCategoryHttp
                                                       errorCode:error.code
                                                        httpCode:statusCode
                                                             api:httpApi];
        
        [AgoraRteReportorWrapper endJoinRoomWithErrorCode:error.code
                                                 httpCode:statusCode];
    }];
}

- (void)getLocalUserWithSuccess:(OnGetLocalUserSuccessBlock)successBlock
                        failure:(AgoraRTEFailureBlock)failureBlock {
    if (self.syncRoomSession.localUser != nil) {
        if (successBlock) {
            AgoraRTELocalUser *localUser = [self.syncRoomSession.localUser mapAgoraRTELocalUser];
            successBlock(localUser);
        }
    } else {
        NSError *error = [AgoraRTEErrorManager internalError:@"you haven't joined the room"
                                                        code:1];
        
        [AgoraRTELogService logErrMessageWithDescribe:@"classroom getLocalUser error:"
                                              message:@{@"roomUuid": AgoraRTENoNullString(self.roomUuid),
                                                        @"errMsg": error.localizedDescription}];
        
        if(failureBlock != nil) {
            failureBlock(error);
        }
    }
}

- (void)getClassroomInfoWithSuccess:(OnGetClassroomInfoSuccessBlock)successBlock
                            failure:(AgoraRTEFailureBlock)failureBlock {
    if (self.syncRoomSession.room != nil) {
        AgoraRTEWEAK(self);
        [self.syncRoomSession getRoomInQueue:^(AgoraRTEBaseSnapshotRoomModel *room) {
            AgoraRTESyncRoomModel *model = room;
            
            NSInteger count = weakself.syncRoomSession.users.count;
            AgoraRTEClassroom *classroom = [model mapAgoraRTEClassroom:count];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (successBlock) {
                    successBlock(classroom);
                }
            });
        }];
    } else {
        NSError *error = [AgoraRTEErrorManager internalError:@"you haven't joined the room"
                                                        code:1];

        [AgoraRTELogService logErrMessageWithDescribe:@"classroom getClassroomInfo error:"
                                              message:@{@"roomUuid":AgoraRTENoNullString(self.roomUuid),
                                                        @"errMsg":error.localizedDescription}];
        
        if (failureBlock) {
            failureBlock(error);
        }
    }
}

- (void)getUserCountWithRole:(AgoraRTERoleType)role
                     success:(OnGetUserCountSuccessBlock)successBlock
                     failure:(AgoraRTEFailureBlock _Nullable)failureBlock {
    if (self.syncRoomSession.localUser == nil) {
        NSError *error = [AgoraRTEErrorManager internalError:@"you haven't joined the room"
                                                        code:1];
        if(failureBlock != nil) {
            failureBlock(error);
        }
        return;
    }
    
    if (role != AgoraRTERoleTypeStudent && role != AgoraRTERoleTypeTeacher && role != AgoraRTERoleTypeAssistant) {
        NSError *error = [AgoraRTEErrorManager paramterInvalid:@"role"
                                                          code:2];
        if(failureBlock != nil) {
            failureBlock(error);
        }
        return;
    }

    [self.syncRoomSession getUsersInQueue:^(NSArray<AgoraRTESyncUserModel *> *users) {
        NSInteger count = 0;
        for (AgoraRTESyncUserModel *user in users) {
            if([user mapAgoraRTEUser].role == role) {
                count++;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (successBlock) {
                successBlock(count);
            }
        });
    }];
}

- (void)getUserListWithRole:(AgoraRTERoleType)role
                       from:(NSUInteger)fromIndex
                         to:(NSUInteger)endIndex
                    success:(OnGetUserListSuccessBlock)successBlock
                    failure:(AgoraRTEFailureBlock _Nullable)failureBlock {
    if (self.syncRoomSession.localUser == nil) {
        NSError *error = [AgoraRTEErrorManager internalError:@"you haven't joined the room"
                                                        code:1];
        if(failureBlock != nil) {
            failureBlock(error);
        }
        return;
    }
    
    if (fromIndex > endIndex) {
        NSError *error = [AgoraRTEErrorManager paramterInvalid:@"fromIndex or endIndex"
                                                          code:2];

        [AgoraRTELogService logErrMessageWithDescribe:@"classroom getUserList error:"
                                              message:@{@"roomUuid": AgoraRTENoNullString(self.roomUuid),
                                                        @"errMsg": @"endIndex must big then fromIndex"}];
        
        if (failureBlock) {
            failureBlock(error);
        }
        return;
    }

    [self.syncRoomSession getUsersInQueue:^(NSArray<AgoraRTESyncUserModel *> *users) {
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:users.count];
        for (AgoraRTESyncUserModel *user in users) {
            AgoraRTEUser *userModel = [user mapAgoraRTEUser];
            if (userModel.role == role) {
                [array addObject:userModel];
            }
        }
        
        if (endIndex > array.count) {
            NSError *error = [AgoraRTEErrorManager paramterInvalid:@"endIndex"
                                                              code:2];
        
            [AgoraRTELogService logErrMessageWithDescribe:@"classroom getUserList error:"
                                                  message:@{@"roomUuid":AgoraRTENoNullString(self.roomUuid),
                                                            @"role":@(role),
                                                            @"fromIndex":@(fromIndex),
                                                            @"toIndex":@(endIndex),
                                                            @"errMsg":@"endIndex outsize the total number of current users"}];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failureBlock) {
                    failureBlock(error);
                }
            });
            
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (successBlock) {
                 NSRange range = NSMakeRange(fromIndex,
                                             endIndex - fromIndex);
                 successBlock([array subarrayWithRange:range]);
             }
        });
    }];
}

- (void)getFullUserListWithSuccess:(OnGetUserListSuccessBlock)successBlock
                           failure:(AgoraRTEFailureBlock)failureBlock {
    if (self.syncRoomSession.localUser == nil) {
        NSError *error = [AgoraRTEErrorManager internalError:@"you haven't joined the room"
                                                        code:1];
        if(failureBlock != nil) {
            failureBlock(error);
        }
        return;
    }
    
    [self.syncRoomSession getUsersInQueue:^(NSArray<AgoraRTESyncUserModel *> *users) {
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:users.count];
        for (AgoraRTESyncUserModel *user in users) {
            AgoraRTEUser *userModel = [user mapAgoraRTEUser];
            [array addObject:userModel];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (successBlock) {
                successBlock(array);
            }
        });
    }];
}

- (void)getFullStreamListWithSuccess:(OnGetStreamListSuccessBlock)successBlock
                             failure:(AgoraRTEFailureBlock)failureBlock {
    if (self.syncRoomSession.localUser == nil) {
        NSError *error = [AgoraRTEErrorManager internalError:@"you haven't joined the room" code:1];
        if(failureBlock != nil) {
            failureBlock(error);
        }
        return;
    }
    
    [self.syncRoomSession getStreamsInQueue:^(NSArray<AgoraRTESyncStreamModel *> *streams) {
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:streams.count];
        for (AgoraRTESyncStreamModel *stream in streams) {
            AgoraRTEStream *streamModel = [stream mapAgoraRTEStream];
            [array addObject:streamModel];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (successBlock) {
                successBlock(array);
            }
        });
    }];
}

- (void)leaveClassroomWithSuccess:(AgoraRTESuccessBlock)successBlock
                          failure:(AgoraRTEFailureBlock)failureBlock {
    // Report
    [AgoraRteReportorWrapper stopTimerOnline];
    
    [self releaseResource];
    if (successBlock) {
        successBlock();
    }
}

- (void)setVideoConfig:(AgoraRTEVideoConfig *_Nullable)videoConfig {
    AgoraRTEVideoConfig *cameraEncodeConfig = videoConfig;
    if (!cameraEncodeConfig) {
        cameraEncodeConfig= [AgoraRTEVideoConfig defaultVideoConfig];
    }
    [self.userService setVideoConfig: videoConfig];
}


- (void)destory {
    [self releaseResource];
}

#pragma mark Private
- (void)setupPublishOptionsSuccess:(AgoraRTESuccessBlock)successBlock
                           failure:(AgoraRTEFailureBlock)failureBlock {
    if (self.mediaOption.autoPublish) {
        AgoraRTESyncUserModel *userModel = self.syncRoomSession.localUser;
        AgoraRTEStreamConfig *config = [[AgoraRTEStreamConfig alloc] initWithStreamUuid:userModel.streamUuid];

        [self.userService startOrUpdateLocalStream:config
                                           success:^(AgoraRTEStream * _Nonnull stream) {
            if(successBlock) {
                successBlock();
            }
        } failure:failureBlock];
    } else if(successBlock) {
        successBlock();
    }
}

#pragma mark Private
- (void)setDelegate:(id<AgoraRTEClassroomDelegate>)delegate {
    _delegate = delegate;
    self.messageHandle.roomDelegate = delegate;
}

- (void)syncTotalSuccess:(AgoraRTESuccessBlock)successBlock {
    AgoraRTEWEAK(self);
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [AgoraRTEHttpManager syncTotalWithRoomUuid:self.roomUuid
                                     userToken:self.userToken
                                         param:params
                                    apiVersion:APIVersion1
                                 analysisClass:AgoraRTECommonModel.class
                                       success:^(id<AgoraRTEBaseModel>  _Nonnull objModel) {
        AgoraRTECommonModel *model = objModel;
        [weakself.syncRoomSession syncSnapshot:AgoraRTENoNullDictionary(model.data) complete:^{
            successBlock();
        }];
    } failure:^(NSError * _Nullable error, NSInteger statusCode) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                     (int64_t)(3 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
            [weakself syncTotalSuccess:successBlock];
        });
    }];
}

- (void)syncIncreaseWithStartIndex:(NSInteger)nextId
                             count:(NSInteger)count
                           success:(AgoraRTESuccessBlock)block {
    if (self.increaseSyncing) {
        return;
    }
    
    self.increaseSyncing = YES;
    
    AgoraRTEWEAK(self);
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"nextId"] = @(nextId);
    if(count > 0) {
        params[@"count"] = @(count);
    }
    [AgoraRTEHttpManager syncIncreaseWithRoomUuid:self.roomUuid
                                        userToken:self.userToken
                                            param:params
                                       apiVersion:APIVersion1
                                    analysisClass:AgoraRTESyncIncreaseModel.class
                                          success:^(id<AgoraRTEBaseModel>  _Nonnull objModel) {
        weakself.increaseSyncing = NO;
        if (block) {
            block();
        }
        
        AgoraRTESyncIncreaseModel *model = objModel;
        for (id obj in AgoraRTENoNullArray(model.data.list)) {
            [weakself.messageHandle didReceivedChannelMsg:obj];
        }
    } failure:^(NSError * _Nullable error, NSInteger statusCode) {
        [weakself syncTotalSuccess:^{
            weakself.increaseSyncing = NO;
        }];
    }];
}

- (void)releaseResource {
    [AgoraRTELogService logMessageWithDescribe:@"AgoraRTEClassroomManager destory:"
                                       message:@{@"roomUuid": AgoraRTENoNullString(self.roomUuid)}];
    
    [NSNotificationCenter.defaultCenter postNotificationName:AgoraRTE_NOTICE_KEY_ROOM_DESTORY
                                                      object:self.roomUuid];
    
    [self.userService destory];
    self.userService = nil;
    [AgoraRTCManager.shareManager destoryWithChannelId:self.roomUuid];
    [AgoraRTMManager.shareManager destoryWithChannelId:self.roomUuid];
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)dealloc {
    [self releaseResource];
}

- (void)initMediaDispatchGroup:(AgoraRTEJoinRoomInfoModel *)model
                       success:(AgoraRTESuccessBlock)successBlock
                       failure:(AgoraRTEFailureBlock)failureBlock {
    dispatch_group_t group = dispatch_group_create();
    __block NSError *groupError;

    // Report
    NSString *subRtcEvent = @"rtc-join-channel";
    NSString *rtcApi = @"joinChannel";
    [AgoraRteReportorWrapper startJoinRoomSubEventWithSubEvent:subRtcEvent];
    
    dispatch_group_enter(group);
    [self initRTCWithModel:model success:^{
        // Report
        [AgoraRteReportorWrapper endJoinRoomSubEventWithSubEvent:subRtcEvent
                                                            type:AgoraReportEndCategoryRtc
                                                       errorCode:0
                                                             api:rtcApi];
        
        dispatch_group_leave(group);
    } failure:^(NSError * error) {
        [AgoraRteReportorWrapper endJoinRoomSubEventWithSubEvent:subRtcEvent
                                                            type:AgoraReportEndCategoryHttp
                                                       errorCode:error.code
                                                             api:rtcApi];
        
        groupError = error;
        dispatch_group_leave(group);
    }];

    // Report
    NSString *subRtmEvent = @"rtm-join-channel";
    NSString *rtmApi = @"joinChannel";
    [AgoraRteReportorWrapper startJoinRoomSubEventWithSubEvent:subRtmEvent];
    
    dispatch_group_enter(group);
    [self initRTMWithModel:model success:^{
        // Report
        [AgoraRteReportorWrapper endJoinRoomSubEventWithSubEvent:subRtmEvent
                                                            type:AgoraReportEndCategoryRtm
                                                       errorCode:0
                                                             api:rtmApi];
        
        dispatch_group_leave(group);
    } failure:^(NSError * error) {
        // Report
        [AgoraRteReportorWrapper endJoinRoomSubEventWithSubEvent:subRtmEvent
                                                            type:AgoraReportEndCategoryHttp
                                                       errorCode:error.code
                                                             api:rtmApi];
        
        groupError = error;
        dispatch_group_leave(group);
    }];

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (groupError) {
            failureBlock(groupError);
        } else {
            successBlock();
        }
    });
}

- (void)initRTCWithModel:(AgoraRTEJoinRoomInfoModel *)model
                 success:(AgoraRTESuccessBlock)successBlock
                 failure:(AgoraRTEFailureBlock)failureBlock {
    if (successBlock != nil) {
        self.joinRTCSuccessBlock = successBlock;
    }
        
    [AgoraRTCManager.shareManager setChannelProfile:AgoraChannelProfileLiveBroadcasting];

    if (self.mediaOption.autoPublish) {
        [AgoraRTCManager.shareManager setClientRole:AgoraClientRoleBroadcaster
                                          channelId:self.roomUuid];
    }
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    
    NSString *version = [AgoraRTEManager version];
    NSDictionary *infoDic = [NSDictionary dictionary];
    NSInteger tag = AgoraRTEHttpManager.getHttpManagerConfig.tag;
    switch (tag) {
        case AgoraRTESceneType1V1:
            infoDic = @{@"demo_scenario":@"One to One Classroom", @"demo_ver": version};
            break;
        case AgoraRTESceneTypeSmall:
            infoDic = @{@"demo_scenario":@"Small Classroom", @"demo_ver": version};
            break;
        case AgoraRTESceneTypeBig:
            infoDic = @{@"demo_scenario":@"Lecture Hall", @"demo_ver": version};
            break;
        case AgoraRTESceneTypeBreakout:
            infoDic = @{@"demo_scenario":@"Breakout Classroom", @"demo_ver": version};
            break;
        default:
            break;
    }
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:infoDic
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    NSString *info = @"";
    if (jsonData) {
        info = [[NSString alloc] initWithData:jsonData
                                     encoding:NSUTF8StringEncoding];
    }
    
    NSString *rtcToken = model.user.rtcToken;
    NSString *roomUuid = model.room.roomInfo.roomUuid;
    NSInteger uid = model.user.streamUuid.longLongValue;
    int errorCode = [AgoraRTCManager.shareManager joinChannelByToken:rtcToken
                                                           channelId:roomUuid
                                                                info:info
                                                                 uid:uid
                                                  autoSubscribeAudio:self.mediaOption.autoSubscribe
                                                  autoSubscribeVideo:self.mediaOption.autoSubscribe];
    if (errorCode != 0) {
        if (failureBlock) {
            NSError *eduError = [AgoraRTEErrorManager mediaError:errorCode
                                                         codeMsg:[AgoraRTCManager getErrorDescription:errorCode]
                                                            code:201];
            failureBlock(eduError);
        }
    } else {
        AgoraRTCChannelDelegateConfig *config = [AgoraRTCChannelDelegateConfig new];
        config.delegate = self;
        [AgoraRTCManager.shareManager setChannelDelegateWithConfig:config
                                                         channelId:roomUuid];
    }
}
- (void)initRTMWithModel:(AgoraRTEJoinRoomInfoModel *)model
                 success:(AgoraRTESuccessBlock)successBlock
                 failure:(AgoraRTEFailureBlock)failureBlock {
    NSString *roomUuid = model.room.roomInfo.roomUuid;

    AgoraRTEWEAK(self);
    [AgoraRTMManager.shareManager joinSignalWithChannelName:roomUuid
                                       completeSuccessBlock:^{
        AgoraRTMChannelDelegateConfig *config = [AgoraRTMChannelDelegateConfig new];
        config.channelDelegate = weakself;
        [AgoraRTMManager.shareManager setChannelDelegateWithConfig:config
                                                       channelName:roomUuid];
        successBlock();
    } completeFailBlock:^(NSInteger errorCode) {
        NSError *eduError = [AgoraRTEErrorManager communicationError:errorCode
                                                                code:101];
        failureBlock(eduError);
    }];
}

#pragma mark AgoraRTMManagerDelegate
- (void)didReceivedSignal:(NSString *)signalText
              fromChannel:(AgoraRtmChannel *)channel {
    [self.messageHandle didReceivedChannelMsg:signalText];
}

#pragma mark AgoraRTCManagerDelegate
- (void)rtcChannelDidJoinChannel:(NSString *)channelId
                         withUid:(NSUInteger)uid {
    if ([channelId isEqualToString:self.roomUuid]) {
        if(self.joinRTCSuccessBlock != nil){
            self.joinRTCSuccessBlock();
        }
    }
}

- (void)rtcChannel:(NSString *)channelId
    didJoinedOfUid:(NSUInteger)uid {
    if([self.delegate respondsToSelector:@selector(classroom:remoteRTCJoinedOfStreamId:)]) {
        AgoraRTESyncRoomModel *room = self.syncRoomSession.room;
        [self.delegate classroom:room remoteRTCJoinedOfStreamId:@(uid).stringValue];
    }
}
- (void)rtcChannel:(NSString *)channelId
   didOfflineOfUid:(NSUInteger)uid {
    if([self.delegate respondsToSelector:@selector(classroom:remoteRTCOfflineOfStreamId:)]) {
        AgoraRTESyncRoomModel *room = self.syncRoomSession.room;
        [self.delegate classroom:room
      remoteRTCOfflineOfStreamId:@(uid).stringValue];
    }
}

- (void)rtcChannel:(NSString *)channelId
    networkQuality:(NSUInteger)uid
         txQuality:(AgoraNetworkQuality)txQuality
         rxQuality:(AgoraNetworkQuality)rxQuality {
    if (![self.delegate respondsToSelector:@selector(classroom:networkQualityChanged:user:)]) {
        return;
    }
    
    AgoraRTENetworkQuality grade = AgoraRTENetworkQualityUnknown;
     
    AgoraRTENetworkQuality quality = MAX(txQuality, rxQuality);
    switch (quality) {
        case AgoraNetworkQualityExcellent:
        case AgoraNetworkQualityGood:
            grade = AgoraRTENetworkQualityHigh;
            break;
        case AgoraNetworkQualityPoor:
        case AgoraNetworkQualityBad:
            grade = AgoraRTENetworkQualityMiddle;
            break;
        case AgoraNetworkQualityVBad:
        case AgoraNetworkQualityDown:
            grade = AgoraRTENetworkQualityLow;
            break;
        default:
            break;
    }
    
    AgoraRTEBaseUser *user = [AgoraRTEBaseUser new];
    
    if (uid == 0) {
        id obj = [self.syncRoomSession.localUser yy_modelToJSONObject];
        [user yy_modelSetWithJSON:obj];
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamUuid = %@", @(uid).stringValue];
        NSArray<AgoraRTESyncStreamModel*> *filters = [self.syncRoomSession.streams filteredArrayUsingPredicate:predicate];
        if (filters.count == 0) {
            return;
        }
        AgoraRTESyncStreamModel *streamModel = filters.firstObject;
        
        id obj = [streamModel.fromUser yy_modelToJSONObject];
        [user yy_modelSetWithJSON:obj];
    }
    
    AgoraRTESyncRoomModel *room = self.syncRoomSession.room;
    [self.delegate classroom:[room mapAgoraRTEClassroom:self.syncRoomSession.users.count]
       networkQualityChanged:grade
                        user:user];
}
@end

