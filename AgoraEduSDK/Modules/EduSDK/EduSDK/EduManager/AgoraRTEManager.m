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
#import <EduSDK/EduSDK-Swift.h>

static NSString *AGORA_EDU_BASE_URL = @"https://api.agora.io/scene";

#define AgoraRTE_APP_CODE @"edu-demo"
#define AgoraRTE_LOG_PATH @"/AgoraEducation/"

#define AgoraRTE_NOTICE_KEY_ROOM_DESTORY @"AgoraRTE_NOTICE_KEY_ROOM_DESTORY"

@interface AgoraRTEManager()<AgoraRTMPeerDelegate, AgoraRTMConnectionDelegate>

@property (nonatomic, strong) NSString *appId;
//@property (nonatomic, strong) NSString *authorization;
@property (nonatomic, strong) NSString *logDirectoryPath;

@property (nonatomic, strong) NSString *userUuid;
@property (nonatomic, strong) NSString *userName;

@property (nonatomic, strong) AgoraRTEMediaControl *mediaControl;

@property (nonatomic, strong) AgoraRTECommonMessageHandle *messageHandle;

@property (nonatomic, strong) NSMutableDictionary<NSString*, AgoraRTEClassroomManager *> *classrooms;

@end

@implementation AgoraRTEManager
+ (void)setBaseURL:(NSString *)baseURL {
    NSString *url = [NSString stringWithFormat:@"%@/scene", baseURL];
    AGORA_EDU_BASE_URL = url;
}

- (instancetype)initWithConfig:(AgoraRTEConfiguration *)config
                       success:(AgoraRTESuccessBlock)successBlock
                       failure:(AgoraRTEFailureBlock _Nullable)failureBlock {
    NSError *error;
    
    if (![config isKindOfClass:AgoraRTEConfiguration.class]) {
        error = [AgoraRTEErrorManager paramterInvalid:@"config"
                                                 code:1];
    } else {
        error = [AgoraRTEErrorManager paramterEmptyError:@"appId"
                                                   value:config.appId
                                                    code:1];
    }
    
    if (error == nil) {
        error = [AgoraRTEErrorManager paramterEmptyError:@"userUuid"
                                                   value:config.userUuid
                                                    code:1];
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
    NSString *logDirectoryPath = [logBaseDirectoryPath stringByAppendingPathComponent:AgoraRTE_LOG_PATH];
    logConfig.directoryPath = logDirectoryPath;
    if(AgoraRTENoNullString(config.logDirectoryPath).length > 0){
        logConfig.directoryPath = config.logDirectoryPath;
    }
    logConfig.consoleState = config.logConsoleState;
    [AgoraRTELogService setupLog:logConfig];

    // Report
    NSString *host = @"https://api.agora.io";
    
    if ([AGORA_EDU_BASE_URL containsString:@"dev"]) {
        host = @"http://api-test.agora.io";
    } else {
        host = @"https://api.agora.io";
    }
    
    AgoraReportorContext *context = [[AgoraReportorContext alloc] initWithSource:@"rte"
                                                                      clientType:@"flexibleClass"
                                                                        platform:@"iOS"
                                                                           appId:config.appId
                                                                         version:AgoraRTEManager.version
                                                                           token:config.token
                                                                        userUuid:config.userUuid
                                                                            host:host];
    [[AgoraRteReportorWrapper getRteReporter] setWithContext:context];
    
    if (self = [super init]) {
        self.appId = AgoraRTENoNullString(config.appId);
        self.logDirectoryPath = logConfig.directoryPath;
        self.classrooms = [NSMutableDictionary dictionary];
        
        HttpManagerConfig *httpConfig = [AgoraRTEHttpManager getHttpManagerConfig];
        httpConfig.baseURL = AGORA_EDU_BASE_URL;
        httpConfig.appCode = AgoraRTE_APP_CODE;
        httpConfig.appid = AgoraRTENoNullString(self.appId);
        httpConfig.token = config.token;
        httpConfig.logDirectoryPath = logConfig.directoryPath;
        [AgoraRTEHttpManager setupHttpManagerConfig:httpConfig];
    
        AgoraRTEWEAK(self);
        [self loginWithUserUuid:config.userUuid
                       userName:AgoraRTENoNullString(config.userName)
                            tag:config.tag
                        success:^{
                            [weakself initMedia];
                            successBlock();
                        }
                        failure:failureBlock];
    
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(onRoomDestory:)
                                                   name:AgoraRTE_NOTICE_KEY_ROOM_DESTORY
                                                 object:nil];
    }

    return self;
}

- (void)initMedia {
    
    // initRtc
    [AgoraRTCManager.shareManager initEngineKitWithAppid:self.appId];
    [AgoraRTCManager.shareManager setLogFile:self.logDirectoryPath];
    
    // initRtm
    [AgoraRTMManager.shareManager setLogFile:self.logDirectoryPath];
    
    // initMedia
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    self.mediaControl = [[AgoraRTEMediaControl alloc] performSelector:NSSelectorFromString(@"init")];
#pragma clang diagnostic pop
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
    
    [AgoraRTELogService logMessageWithDescribe:@"login:" message:@{@"userUuid":AgoraRTENoNullString(userUuid), @"userName":AgoraRTENoNullString(userName)}];

    HttpManagerConfig *httpConfig = [AgoraRTEHttpManager getHttpManagerConfig];
    httpConfig.userUuid = userUuid;
    httpConfig.tag = tag;

    NSString *rtmToken = httpConfig.token;
    AgoraRTMManager.shareManager.peerDelegate = self;
    AgoraRTMManager.shareManager.connectDelegate = self;
    
    // Report
    [AgoraRteReportorWrapper startLogin];
    
    AgoraRTEWEAK(self);
    [AgoraRTMManager.shareManager initSignalWithAppid:self.appId appToken:AgoraRTENoNullString(rtmToken) userId:userUuid completeSuccessBlock:^{
        
        weakself.messageHandle = [[AgoraRTECommonMessageHandle alloc] init];
        weakself.messageHandle.agoraDelegate = weakself.delegate;
        if (successBlock != nil) {
            successBlock();
        }
        
        // Report
        [AgoraRteReportorWrapper endLoginWithErrorCode:0];
    } completeFailBlock:^(NSInteger errorCode) {
        NSError *error = [AgoraRTEErrorManager communicationError:errorCode code:101];
        if (failureBlock != nil) {
            failureBlock(error);
        }
        
        // Report
        [AgoraRteReportorWrapper endLoginWithErrorCode:errorCode];
    }];
}

- (AgoraRTEMediaControl *)getAgoraMediaControl {
    return self.mediaControl;
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
    return @"1.0.0";
}

- (void)reportAppScenario:(NSInteger)appScenario
              serviceType:(NSInteger)serviceType
               appVersion:(NSString *)appVersion {
    NSDictionary *dic = @{
        @"rtc.report_app_scenario":@{
            @"appScenario":@(appScenario),
            @"serviceType":@(serviceType),
            @"appVersion":appVersion
        }
    };
    NSError *rtcError;
    NSData *jsonRtcData = [NSJSONSerialization dataWithJSONObject:dic
                                                          options:NSJSONWritingPrettyPrinted
                                                            error:&rtcError];
    if (jsonRtcData != nil) {
        NSString *jsonString = [[NSString alloc]initWithData:jsonRtcData
                                                    encoding:NSUTF8StringEncoding];
        [AgoraRTCManager.shareManager setParameters:jsonString];
    }
}

- (void)setDelegate:(id<AgoraRTEManagerDelegate>)delegate {
    _delegate = delegate;
    self.messageHandle.agoraDelegate = delegate;
}

- (NSError * _Nullable)logMessage:(NSString *)message level:(AgoraLogLevel)level {
    return [AgoraRTELogService logMessage:message level:level];
}

- (void)uploadDebugItem:(AgoraRTEDebugItem)item
                options:(AgoraLogUploadOptions *)options
                success:(OnDebugItemUploadSuccessBlock)successBlock
                failure:(AgoraRTEFailureBlock _Nullable)failureBlock {
    options.appId = self.appId;
    [AgoraRTELogService uploadDebugItem:item
                                options:options
                                success:successBlock
                                failure:failureBlock];
}

#pragma mark AgoraRTMPeerDelegate
- (void)didReceivedSignal:(NSString *)signalText fromPeer: (NSString *)peer {
    [self.messageHandle didReceivedPeerMsg:signalText];
}

- (void)didReceivedConnectionStateChanged:(AgoraRtmConnectionState)state reason:(AgoraRtmConnectionChangeReason)reason {
    
    AgoraRTEWEAK(self);
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




