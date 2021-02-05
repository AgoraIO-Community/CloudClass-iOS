//
//  AgoraRTEManager.m
//  Demo
//
//  Created by SRS on 2020/6/17.
//  Copyright © 2020 agora. All rights reserved.
//

#import "AgoraRTEManager.h"
#import "AgoraRTEHttpManager.h"
#import "AgoraRTEClassroomManager.h"
#import "AgoraRTEConstants.h"
#import "AgoraRTELogService.h"
#import "AgoraRTECommonModel.h"
#import "AgoraRTMManager.h"
#import "AgoraRTCManager.h"
#import "AgoraRTEErrorManager.h"
#import "AgoraRTECommonMessageHandle.h"
#import "AgoraRTELogService.h"
#import "AgoraRTEKVCClassroomConfig.h"
#import <objc/runtime.h>

static NSString *AGORA_EDU_BASE_URL = @"https://api.agora.io/scene";

#define APP_CODE @"edu-demo"
#define LOG_PATH @"/AgoraEducation/"

#define NOTICE_KEY_ROOM_DESTORY @"NOTICE_KEY_ROOM_DESTORY"

@interface AgoraRTEManager()<AgoraRTMPeerDelegate, AgoraRTMConnectionDelegate>

@property (nonatomic, strong) NSString *appId;
//@property (nonatomic, strong) NSString *authorization;
@property (nonatomic, strong) NSString *logDirectoryPath;

@property (nonatomic, strong) NSString *userUuid;
@property (nonatomic, strong) NSString *userName;

@property (nonatomic, strong) AgoraRTECommonMessageHandle *messageHandle;

@property (nonatomic, strong) NSMutableDictionary<NSString*, AgoraRTEClassroomManager *> *classrooms;

@end

@implementation AgoraRTEManager
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

- (instancetype)initWithConfig:(AgoraRTEConfiguration *)config success:(AgoraRTESuccessBlock)successBlock failure:(AgoraRTEFailureBlock _Nullable)failureBlock {
    
    NSError *error;
    if (![config isKindOfClass:AgoraRTEConfiguration.class]) {
        error = [AgoraRTEErrorManager paramterInvalid:@"config" code:1];
    } else {
        error = [AgoraRTEErrorManager paramterEmptyError:@"appId" value:config.appId code:1];
    }
    if (error == nil) {
        error = [AgoraRTEErrorManager paramterEmptyError:@"userUuid" value:config.userUuid code:1];
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
    [AgoraRTELogService setupLog:logConfig];

    if (self = [super init]) {
        self.appId = NoNullString(config.appId);
        self.logDirectoryPath = logConfig.directoryPath;
        self.classrooms = [NSMutableDictionary dictionary];
        
        HttpManagerConfig *httpConfig = [AgoraRTEHttpManager getHttpManagerConfig];
        httpConfig.baseURL = AGORA_EDU_BASE_URL;
        httpConfig.appCode = APP_CODE;
        httpConfig.appid = NoNullString(self.appId);
        httpConfig.token = config.token;
        httpConfig.logDirectoryPath = logConfig.directoryPath;
        [AgoraRTEHttpManager setupHttpManagerConfig:httpConfig];
        
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
    
    AgoraRTEClassroomManager *manager = self.classrooms[roomUuid];
    if(manager != nil) {
        [self.classrooms removeObjectForKey:roomUuid];
    }
}

// login
- (void)loginWithUserUuid:(NSString *)userUuid userName:(NSString *)userName tag:(NSInteger)tag success:(AgoraRTESuccessBlock)successBlock failure:(AgoraRTEFailureBlock _Nullable)failureBlock {
    
    self.userUuid = userUuid;
    self.userName = userName;
    
    [AgoraRTELogService logMessageWithDescribe:@"login:" message:@{@"userUuid":NoNullString(userUuid), @"userName":NoNullString(userName)}];

    HttpManagerConfig *httpConfig = [AgoraRTEHttpManager getHttpManagerConfig];
    httpConfig.userUuid = userUuid;
    httpConfig.tag = tag;

    NSString *rtmToken = httpConfig.token;
    AgoraRTMManager.shareManager.peerDelegate = self;
    AgoraRTMManager.shareManager.connectDelegate = self;
    
    WEAK(self);
    [AgoraRTMManager.shareManager initSignalWithAppid:self.appId appToken:NoNullString(rtmToken) userId:userUuid completeSuccessBlock:^{
        
        weakself.messageHandle = [[AgoraRTECommonMessageHandle alloc] init];
        weakself.messageHandle.agoraDelegate = weakself.delegate;
        if (successBlock != nil) {
            successBlock();
        }
              
    } completeFailBlock:^(NSInteger errorCode) {
        NSError *error = [AgoraRTEErrorManager communicationError:errorCode code:101];
        if (failureBlock != nil) {
            failureBlock(error);
        }
    }];
}

- (AgoraRTEClassroomManager *)createClassroomWithConfig:(AgoraRTEClassroomConfig *)config {
    
    NSString *roomUuid = @"";
    AgoraRTESceneType sceneType = config.sceneType;

    if ([config isKindOfClass:AgoraRTEClassroomConfig.class]) {
        if([config.roomUuid isKindOfClass:NSString.class]) {
            roomUuid = config.roomUuid;
        }
    }

    AgoraRTEClassroomManager *manager = [AgoraRTEClassroomManager alloc];
    AgoraRTEKVCClassroomConfig *kvcConfig = [AgoraRTEKVCClassroomConfig new];
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
    for (AgoraRTEClassroomManager *manager in self.classrooms.allValues) {
        [manager destory];
    }
    [self.classrooms removeAllObjects];
    
    [AgoraRTELogService destory];
    
    [AgoraRTMManager.shareManager destory];
    [AgoraRTCManager.shareManager destory];
}

+ (NSString *)version {
    NSString *string = [[AgoraRTCManager sdkVersion] stringByAppendingString:@".1"];
    return string;
}

- (void)setDelegate:(id<AgoraRTEManagerDelegate>)delegate {
    _delegate = delegate;
    self.messageHandle.agoraDelegate = delegate;
}

- (NSError * _Nullable)logMessage:(NSString *)message level:(AgoraLogLevel)level {
    return [AgoraRTELogService logMessage:message level:level];
}

- (void)uploadDebugItem:(AgoraRTEDebugItem)item uid:(NSString *)uid token:(NSString *)token success:(OnDebugItemUploadSuccessBlock) successBlock failure:(AgoraRTEFailureBlock _Nullable)failureBlock {
    
    [AgoraRTELogService uploadDebugItem:item appId:self.appId uid:uid token:token success:successBlock failure:failureBlock];
}

#pragma mark AgoraRTMPeerDelegate
- (void)didReceivedSignal:(NSString *)signalText fromPeer: (NSString *)peer {
    [self.messageHandle didReceivedPeerMsg:signalText];
}

- (void)didReceivedConnectionStateChanged:(AgoraRtmConnectionState)state reason:(AgoraRtmConnectionChangeReason)reason {
    
    WEAK(self);
    [self.messageHandle didReceivedConnectionStateChanged:(AgoraRTEConnectionState)state complete:^(AgoraRTEConnectionState state) {
        [weakself updateConnectionforEachRoom:state];
    }];
}

- (void)updateConnectionforEachRoom:(AgoraRTEConnectionState)state {

    for(AgoraRTEClassroomManager *manager in self.classrooms.allValues) {
        if ([manager.delegate respondsToSelector:@selector(classroom:connectionStateChanged:)]) {
            [manager getClassroomInfoWithSuccess:^(AgoraRTEClassroom * _Nonnull room) {
                
                [manager.delegate classroom:room connectionStateChanged:state];
                
            } failure:nil];
            
        }
    }
}

-(void)dealloc {
    [self destory];
}
@end




