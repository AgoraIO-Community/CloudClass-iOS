//
//  EduManager.m
//  Demo
//
//  Created by SRS on 2020/6/17.
//  Copyright © 2020 agora. All rights reserved.
//

#import "EduManager.h"
#import "HttpManager.h"
#import "EduClassroomManager.h"
#import "EduConstants.h"
#import "AgoraLogService.h"
#import "CommonModel.h"
#import "RTMManager.h"
#import "RTCManager.h"
#import "EduErrorManager.h"
#import "EduCommonMessageHandle.h"
#import "AgoraLogService.h"
#import "EduKVCClassroomConfig.h"
#import <objc/runtime.h>

static NSString *AGORA_EDU_BASE_URL = @"https://api.agora.io/scene";

#define APP_CODE @"edu-demo"
#define LOG_PATH @"/AgoraEducation/"

#define NOTICE_KEY_ROOM_DESTORY @"NOTICE_KEY_ROOM_DESTORY"

@interface EduManager()<RTMPeerDelegate, RTMConnectionDelegate>

@property (nonatomic, strong) NSString *appId;
//@property (nonatomic, strong) NSString *authorization;
@property (nonatomic, strong) NSString *logDirectoryPath;

@property (nonatomic, strong) NSString *userUuid;
@property (nonatomic, strong) NSString *userName;

@property (nonatomic, strong) EduCommonMessageHandle *messageHandle;

@property (nonatomic, strong) NSMutableDictionary<NSString*, EduClassroomManager *> *classrooms;

@end

@implementation EduManager
+ (void)setBaseURL:(NSString *)baseURL {
    NSString *url = [NSString stringWithFormat:@"%@/scene", baseURL];
    AGORA_EDU_BASE_URL = url;
    
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
//    SEL sel = NSSelectorFromString(@"setBaseURL:");
//    if ([AgoraLogManager respondsToSelector:sel]) {
//        [AgoraLogManager performSelector:sel withObject:baseURL];
//    }
//#pragma clang diagnostic pop
}

- (instancetype)initWithConfig:(EduConfiguration *)config success:(EduSuccessBlock)successBlock failure:(EduFailureBlock _Nullable)failureBlock {
    
    NSError *error;
    if (![config isKindOfClass:EduConfiguration.class]) {
        error = [EduErrorManager paramterInvalid:@"config" code:1];
    } else {
        error = [EduErrorManager paramterEmptyError:@"appId" value:config.appId code:1];
    }
    if (error == nil) {
        error = [EduErrorManager paramterEmptyError:@"userUuid" value:config.userUuid code:1];
    }
    if (error != nil) {
        if(failureBlock != nil){
            failureBlock(error);
        }
        return self;
    }
     
    AgoraLogConfiguration *logConfig = [AgoraLogConfiguration new];
    logConfig.logLevel = AgoraLogLevelInfo;
    NSString *logBaseDirectoryPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    NSString *logDirectoryPath = [logBaseDirectoryPath stringByAppendingPathComponent:LOG_PATH];
    logConfig.directoryPath = logDirectoryPath;
    if(NoNullString(config.logDirectoryPath).length > 0){
        logConfig.directoryPath = config.logDirectoryPath;
    }
    logConfig.consoleState = config.logConsoleState;
    [AgoraLogService setupLog:logConfig];

    if (self = [super init]) {
        self.appId = NoNullString(config.appId);
        self.logDirectoryPath = logConfig.directoryPath;
        self.classrooms = [NSMutableDictionary dictionary];
        
        HttpManagerConfig *httpConfig = [HttpManager getHttpManagerConfig];
        httpConfig.baseURL = AGORA_EDU_BASE_URL;
        httpConfig.appCode = APP_CODE;
        httpConfig.appid = NoNullString(self.appId);
        httpConfig.token = config.token;
        httpConfig.logDirectoryPath = logConfig.directoryPath;
        [HttpManager setupHttpManagerConfig:httpConfig];
        
        [self loginWithUserUuid:config.userUuid userName:NoNullString(config.userName) tag:config.tag success:successBlock failure:failureBlock];
        
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onRoomDestory:) name:NOTICE_KEY_ROOM_DESTORY object:nil];
    }

    return self;
}

- (void)onRoomDestory:(NSNotification *)notification {
    NSString *roomUuid = notification.object;
    if (roomUuid == nil || roomUuid.length == 0) {
        return;
    }
    
    EduClassroomManager *manager = self.classrooms[roomUuid];
    if(manager != nil) {
        [self.classrooms removeObjectForKey:roomUuid];
    }
}

// login
- (void)loginWithUserUuid:(NSString *)userUuid userName:(NSString *)userName tag:(NSInteger)tag success:(EduSuccessBlock)successBlock failure:(EduFailureBlock _Nullable)failureBlock {
    
    self.userUuid = userUuid;
    self.userName = userName;
    
    [AgoraLogService logMessageWithDescribe:@"login:" message:@{@"userUuid":NoNullString(userUuid), @"userName":NoNullString(userName)}];

    HttpManagerConfig *httpConfig = [HttpManager getHttpManagerConfig];
    httpConfig.userUuid = userUuid;
    httpConfig.tag = tag;

    NSString *rtmToken = httpConfig.token;
    RTMManager.shareManager.peerDelegate = self;
    RTMManager.shareManager.connectDelegate = self;
    
    WEAK(self);
    [RTMManager.shareManager initSignalWithAppid:self.appId appToken:NoNullString(rtmToken) userId:userUuid completeSuccessBlock:^{
        
        weakself.messageHandle = [[EduCommonMessageHandle alloc] init];
        weakself.messageHandle.agoraDelegate = weakself.delegate;
        if (successBlock != nil) {
            successBlock();
        }
              
    } completeFailBlock:^(NSInteger errorCode) {
        NSError *error = [EduErrorManager communicationError:errorCode code:101];
        if (failureBlock != nil) {
            failureBlock(error);
        }
    }];
}

- (EduClassroomManager *)createClassroomWithConfig:(EduClassroomConfig *)config {
    
    NSString *roomUuid = @"";
    EduSceneType sceneType = config.sceneType;

    if ([config isKindOfClass:EduClassroomConfig.class]) {
        if([config.roomUuid isKindOfClass:NSString.class]) {
            roomUuid = config.roomUuid;
        }
    }

    EduClassroomManager *manager = [EduClassroomManager alloc];
    EduKVCClassroomConfig *kvcConfig = [EduKVCClassroomConfig new];
    kvcConfig.dafaultUserName = self.userName;
    kvcConfig.roomUuid = roomUuid;
    kvcConfig.sceneType = sceneType;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    SEL action = NSSelectorFromString(@"initWithConfig:");
    if ([manager respondsToSelector:action]) {
        [manager performSelector:action withObject:kvcConfig];
    }
#pragma clang diagnostic pop
    [self.classrooms setValue:manager forKey:roomUuid];
    return manager;
}

- (void)destory {
    for (EduClassroomManager *manager in self.classrooms.allValues) {
        [manager destory];
    }
    [self.classrooms removeAllObjects];
    
    [RTMManager.shareManager destory];
    [RTCManager.shareManager destory];
}

+ (NSString *)version {
    NSString *string = [[RTCManager sdkVersion] stringByAppendingString:@".1"];
    return string;
}

- (void)setDelegate:(id<EduManagerDelegate>)delegate {
    _delegate = delegate;
    self.messageHandle.agoraDelegate = delegate;
}

- (NSError * _Nullable)logMessage:(NSString *)message level:(AgoraLogLevel)level {
    return [AgoraLogService logMessage:message level:level];
}

- (void)uploadDebugItem:(EduDebugItem)item uid:(NSString *)uid token:(NSString *)token success:(OnDebugItemUploadSuccessBlock) successBlock failure:(EduFailureBlock _Nullable)failureBlock {
    
    [AgoraLogService uploadDebugItem:item appId:self.appId uid:uid token:token success:successBlock failure:failureBlock];
}

#pragma mark RTMPeerDelegate
- (void)didReceivedSignal:(NSString *)signalText fromPeer: (NSString *)peer {
    [self.messageHandle didReceivedPeerMsg:signalText];
}

- (void)didReceivedConnectionStateChanged:(AgoraRtmConnectionState)state reason:(AgoraRtmConnectionChangeReason)reason {
    
    WEAK(self);
    [self.messageHandle didReceivedConnectionStateChanged:(ConnectionState)state complete:^(ConnectionState state) {
        [weakself updateConnectionforEachRoom:state];
    }];
}

- (void)updateConnectionforEachRoom:(ConnectionState)state {

    for(EduClassroomManager *manager in self.classrooms.allValues) {
        if ([manager.delegate respondsToSelector:@selector(classroom:connectionStateChanged:)]) {
            [manager getClassroomInfoWithSuccess:^(EduClassroom * _Nonnull room) {
                
                [manager.delegate classroom:room connectionStateChanged:state];
                
            } failure:nil];
            
        }
    }
}

-(void)dealloc {
    [self destory];
}
@end




