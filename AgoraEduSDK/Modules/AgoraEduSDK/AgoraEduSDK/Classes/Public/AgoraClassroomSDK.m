//
//  AgoraClassroomSDK.m
//  AgoraClassroomSDK
//
//  Created by SRS on 2021/1/5.
//

#import <AgoraWhiteBoard/AgoraWhiteURLSchemeHandler.h>
#import <AgoraReport/AgoraReport-Swift.h>
#import <AgoraEduSDK/AgoraEduSDK-Swift.h>
#import <YYModel/YYModel.h>
#import "AgoraClassroomSDK.h"
#import "AgoraEduManager.h"
#import "Agora1V1ViewController.h"
#import "AgoraSmallViewController.h"
#import "AgoraEduTopVC.h"
#import "AgoraEyeCareModeUtil.h"
#import "AgoraEduReplayConfiguration.h"
#import "AgoraManagerCache.h"
#import "AgoraHTTPManager.h"

#define NoNullString(x) ([x isKindOfClass:NSString.class] ? x : @"")
#define NoNullObjectString(x) ((x == nil) ? @"" : @"NoNull")

@interface AgoraClassroomSDK ()<AgoraDownloadProtocol>
@property (weak, nonatomic) id<AgoraEduCoursewareDelegate> coursewareDelegate;
@end

static AgoraClassroomSDK *manager = nil;

@implementation AgoraClassroomSDK
+ (instancetype)share {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[AgoraClassroomSDK alloc] init];
    });
    return manager;
}

+ (void)setBaseURL:(NSString *)baseURL {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    SEL sel = NSSelectorFromString(@"setBaseURL:");
    if ([AgoraRTEManager respondsToSelector:sel]) {
        [AgoraRTEManager performSelector:sel
                              withObject:baseURL];
    }
#pragma clang diagnostic pop

    [AgoraHTTPManager setBaseURL:baseURL];
}

+ (void)setLogConsoleState:(NSNumber *)num {
    [AgoraEduManager.shareManager setLogConsoleState:num.boolValue];
}

#pragma mark - Public
+ (void)setConfig:(AgoraEduSDKConfig *)config {
    // 校验
    NSString *msg = [AgoraClassroomSDK validateEmptyMsg:@{@"config": NoNullObjectString(config),
                                                          @"appId": NoNullString([config appId])}];
    if (msg.length > 0) {
        [AgoraClassroomSDK showToast:msg];
        return;
    }

    AgoraManagerCache.share.appId = config.appId;
    [[AgoraEyeCareModeUtil sharedUtil] switchEyeCareMode:config.eyeCare];
}

+ (AgoraEduClassroom * _Nullable)launch:(AgoraEduLaunchConfig *)config
                               delegate:(id<AgoraEduClassroomDelegate> _Nullable)delegate {    
    AgoraManagerCache.share.classroomDelegate = delegate;

    // 校验
    if (NoNullString(AgoraManagerCache.share.appId).length == 0) {
        NSString *msg = [NSString stringWithFormat:@"%@%@", AgoraLocalizedString(@"NeedCallText", nil), @"`setConfig:`"];
        [AgoraClassroomSDK showToast:msg];
        [AgoraClassroomSDK launchCompleteEvent:AgoraEduEventFailed];
        return nil;
    }

    NSString *msg = [AgoraClassroomSDK validateEmptyMsg:@{@"config": NoNullObjectString(config),
                                                          @"userName": NoNullString([config userName]),
                                                          @"userUuid": NoNullString([config userUuid]),
                                                          @"roomName": NoNullString([config roomName]),
                                                          @"roomName": NoNullString([config roomUuid])}];
    if (msg.length > 0) {
        [AgoraClassroomSDK showToast:msg];
        [AgoraClassroomSDK launchCompleteEvent:AgoraEduEventFailed];
        return nil;
    }

    if (config.roomType != AgoraEduRoomType1V1 &&
        config.roomType != AgoraEduRoomTypeSmall &&
        config.roomType != AgoraEduRoomTypeLecture) {
        NSString *msg = [NSString stringWithFormat:@"%@%@", @"roomType", AgoraLocalizedString(@"ParamErrorText", nil)];
        [AgoraClassroomSDK showToast:msg];
        [AgoraClassroomSDK launchCompleteEvent:AgoraEduEventFailed];
        return nil;
    }

    // 只能调用一次
    if (AgoraManagerCache.share.classroom != nil) {
        [AgoraClassroomSDK showToast:AgoraLocalizedString(@"DuplicateLaunchText", nil)];
        return nil;
    }

    AgoraManagerCache.share.classroom = [AgoraEduClassroom new];
    AgoraManagerCache.share.token = NoNullString(config.token);
    AgoraManagerCache.share.collectionStyle = config.collectionStyle;
    AgoraManagerCache.share.boardStyles = config.boardStyles;
    AgoraManagerCache.share.cameraEncoderConfiguration = config.cameraEncoderConfiguration;

    // Report
    NSString *hostV1 = @"https://api.agora.io";
    AgoraReportorContext *context = [[AgoraReportorContext alloc] initWithSource:@"apaas"
                                                                      clientType:@"flexible_class"
                                                                        platform:@"iOS"
                                                                           appId:AgoraManagerCache.share.appId
                                                                         version:AgoraClassroomSDK.version
                                                                           token:NoNullString(config.token)
                                                                        userUuid:NoNullString(config.userUuid)
                                                                            host:hostV1];
    
    [[ApaasReporterWrapper getApaasReportor] setWithContext:context];
    [ApaasReporterWrapper startJoinRoom];
    
    AgoraRoomConfiguration *roomConfig = [AgoraRoomConfiguration new];
    roomConfig.appId = AgoraManagerCache.share.appId;
    roomConfig.userUuid = config.userUuid;
    roomConfig.token = config.token;

    [AgoraHTTPManager getConfig:roomConfig
                        success:^(AgoraConfigModel * _Nonnull model) {
        // TODO: switch to release url
        NSString *hostV2 = @"https://rest-argus-ad.agoralab.co/v2/report";
        
        AgoraReportorContextV2 *contextV2 = [[AgoraReportorContextV2 alloc] initWithSource:@"apaas"
                                                                                      host:hostV2
                                                                                       vid:model.data.vid
                                                                                   version:[AgoraClassroomSDK version]
                                                                                  scenario:@"education"
                                                                                  userUuid:config.userUuid
                                                                                  userName:config.userName
                                                                                  userRole:@"student"
                                                                                streamUuid:@""
                                                                           streamSessionId:@""
                                                                                  roomUuid:config.roomUuid
                                                                                    rtmSid:@""
                                                                               roomCreatTs:0];
        
        [[ApaasReporterWrapper getApaasReportor] setV2WithContext:contextV2];
        
        AgoraManagerCache.share.boardAppId = model.data.netless.appId;
        [AgoraClassroomSDK joinSDKWithConfig:config
                              appConfigModel:model];
    } failure:^(NSError * _Nonnull error, NSInteger statusCode) {
        [AgoraClassroomSDK launchCompleteEvent:AgoraEduEventFailed];
        [AgoraEduManager releaseResource];
        [AgoraClassroomSDK showToast:error.localizedDescription];
    }];

    return AgoraManagerCache.share.classroom;
}

+ (void)configCoursewares:(NSArray<AgoraEduCourseware *> *)coursewares {
    AgoraManagerCache.share.coursewares = coursewares;
}

+ (void)downloadCoursewares:(id<AgoraEduCoursewareDelegate> _Nullable)delegate {
    NSString *directory = AgoraWhiteCoursewareDirectory;

    NSURL *publicURL = [NSURL URLWithString:@"https://convertcdn.netless.link/publicFiles.zip"];
    [AgoraDownloadManager.shared downloadWithUrls:@[publicURL]
                                    fileDirectory:directory
                                              key:nil
                                         delegate:nil];

    NSArray<AgoraEduCourseware *> *config = AgoraManagerCache.share.coursewares;

    if (config == nil || config.count == 0) {
        NSString *msg = [NSString stringWithFormat:@"%@%@", AgoraLocalizedString(@"NeedCallText", nil), @"`configCoursewares:`"];
        [AgoraClassroomSDK showToast:msg];
        return;
    }

    for (AgoraEduCourseware *courseware in config) {
        if (NoNullString(courseware.resourceUrl).length == 0) {
            continue;
        }
        NSURL *url = [NSURL URLWithString:courseware.resourceUrl];
        NSString *key = [NSString stringWithFormat:@"%lu", courseware.resourceUrl.hash];
        [AgoraDownloadManager.shared downloadWithUrls:@[url]
                                        fileDirectory:directory
                                                  key:key
                                             delegate:AgoraClassroomSDK.share];
    }

    AgoraClassroomSDK.share.coursewareDelegate = delegate;
    AgoraManagerCache.share.coursewares = config;
}

+ (void)registerExtApps:(NSArray<AgoraExtAppConfiguration *> *)apps {
    if ([AgoraEduTopVC.topVC isKindOfClass:[AgoraBaseViewController class]]) {
        AgoraBaseViewController *vc = (AgoraBaseViewController *)AgoraEduTopVC.topVC;
        [vc registerExtApps:apps];
    } else {
        AgoraManagerCache.share.extApps = apps;
    }
}

+ (void)registerWidgets:(NSArray<AgoraWidgetConfiguration *> *)widgets {
    if ([AgoraEduTopVC.topVC isKindOfClass:[AgoraBaseViewController class]]) {
        AgoraBaseViewController *vc = (AgoraBaseViewController *)AgoraEduTopVC.topVC;
        [vc registerWidgets:widgets];
    } else {
        AgoraManagerCache.share.components = widgets;
    }
}

+ (NSString *)version {
    return @"1.1.2";
}

#pragma mark - Private
#pragma mark joinSDKWithConfig
+ (void)joinSDKWithConfig:(AgoraEduLaunchConfig *)config
           appConfigModel:(AgoraConfigModel *)model {
    NSString *roomUuid = config.roomUuid;
    NSString *roomName = config.roomName;
    NSString *userUuid = config.userUuid;
    NSString *userName = config.userName;
    AgoraRTESceneType sceneType = (AgoraRTESceneType)config.roomType;

    AgoraRoomStateConfiguration *roomStateConfig = [AgoraRoomStateConfiguration new];
    roomStateConfig.appId = AgoraManagerCache.share.appId;

    roomStateConfig.roomName = roomName;
    roomStateConfig.roomUuid = roomUuid;
    roomStateConfig.roomType = sceneType;
    roomStateConfig.role = (AgoraRTERoleType)config.roleType;
    roomStateConfig.userUuid = userUuid;
    roomStateConfig.token = AgoraManagerCache.share.token;
    roomStateConfig.startTime = config.startTime;
    roomStateConfig.duration = config.duration;
    roomStateConfig.userName = config.userName;
    if (config.userProperties) {
        roomStateConfig.userProperties = config.userProperties;
    }
    
    AgoraRTEVideoConfig *videoConfig = [AgoraRTEVideoConfig defaultVideoConfig];
    videoConfig.bitrate = AgoraManagerCache.share.cameraEncoderConfiguration.bitrate;
    videoConfig.frameRate = AgoraManagerCache.share.cameraEncoderConfiguration.frameRate;
    videoConfig.videoDimensionWidth = AgoraManagerCache.share.cameraEncoderConfiguration.width;
    videoConfig.videoDimensionHeight = AgoraManagerCache.share.cameraEncoderConfiguration.height;

    // log rte
    [AgoraEduManager.shareManager initWithUserUuid:userUuid
                                          userName:userName
                                            roomId:roomUuid
                                               tag:sceneType
                                       videoConfig:videoConfig
                                           success:^{
        // Report
        NSString *subEvent = @"http-preflight";
        NSString *httpApi = @"preflight";
        [ApaasReporterWrapper startJoinRoomSubEventWithSubEvent:subEvent];
        
        // 预检
        [AgoraEduManager.shareManager queryRoomStateWithConfig:roomStateConfig
                                                       success:^{
            // Report
            [ApaasReporterWrapper endJoinRoomSubEventWithSubEvent:subEvent
                                                             type:AgoraReportEndCategoryHttp
                                                        errorCode:0
                                                         httpCode:200
                                                              api:httpApi];
            
            AgoraVMConfig *vmConfig = [AgoraVMConfig new];
            vmConfig.appId = AgoraManagerCache.share.appId;
            vmConfig.sceneType = config.roomType;
            vmConfig.roomUuid = config.roomUuid;
            vmConfig.className = config.roomName;
            vmConfig.userUuid = config.userUuid;
            vmConfig.userName = config.userName;
            vmConfig.token = AgoraManagerCache.share.token;
            vmConfig.baseURL = [AgoraHTTPManager getBaseURL];
            vmConfig.boardAutoFitMode = (config.boardFitMode == AgoraBoardFitModeAuto ? YES : NO);
            [AgoraClassroomSDK joinRoomWithConfig:vmConfig];

        } failure:^(NSError *error, NSInteger statusCode) {
            // Report
            [ApaasReporterWrapper endJoinRoomSubEventWithSubEvent:subEvent
                                                                         type:AgoraReportEndCategoryHttp
                                                                    errorCode:error.code
                                                                     httpCode:statusCode
                                                                          api:httpApi];

            [ApaasReporterWrapper endJoinRoomWithErrorCode:error.code
                                                              httpCode:statusCode];

            if (error.code == 30403100) {
                [AgoraClassroomSDK launchCompleteEvent:AgoraEduEventForbidden];
            } else {
                [AgoraClassroomSDK launchCompleteEvent:AgoraEduEventFailed];
                [AgoraClassroomSDK showToast:error.localizedDescription];
            }

            [AgoraEduManager releaseResource];
        }];

    } failure:^(NSError * error) {
        [AgoraClassroomSDK launchCompleteEvent:AgoraEduEventFailed];

        // Report
        [ApaasReporterWrapper endJoinRoomWithErrorCode:error.code
                                                          httpCode:0];

        [AgoraEduManager releaseResource];
        [AgoraClassroomSDK showToast:error.localizedDescription];
    }];
}

+ (void)joinRoomWithConfig:(AgoraVMConfig *)config  {
    AgoraBaseViewController *vc;
    if (config.sceneType == AgoraEduRoomType1V1) {
        vc = [[Agora1V1ViewController alloc] init];
    } else {
        vc = [[AgoraSmallViewController alloc] init];
    }
    vc.vmConfig = config;
    vc.host = [AgoraHTTPManager getBaseURL];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;

    [AgoraEduTopVC.topVC presentViewController:vc
                                      animated:YES
                                    completion:^{
        [AgoraClassroomSDK launchCompleteEvent:AgoraEduEventReady];
    }];
}

+ (void)launchCompleteEvent:(AgoraEduEvent)event {
    if ([AgoraManagerCache.share.classroomDelegate respondsToSelector:@selector(classroom:didReceivedEvent:)]) {
        [AgoraManagerCache.share.classroomDelegate classroom:AgoraManagerCache.share.classroom
                                            didReceivedEvent:event];
    }

    if (event == AgoraEduEventFailed || event == AgoraEduEventDestroyed || event == AgoraEduEventForbidden) {
        AgoraManagerCache.share.classroomDelegate = nil;
    }
}

+ (NSString *)validateEmptyMsg:(NSDictionary<NSString *,NSString *> *)dictionary {
    for (NSString *key in dictionary.allKeys) {
        if (dictionary[key].length == 0) {
            NSString *msg = [NSString stringWithFormat:@"%@%@", key, AgoraLocalizedString(@"NoEmptyText", nil)];
            return msg;
        }
    }
    return @"";
}

+ (void)showToast:(NSString *)msg {
    [AgoraUtils showToastWithMessage:msg];
}

#pragma mark AgoraDownloadProtocol
- (void)onProcessChanged:(NSString *)key
                     url:(NSURL *)url
                 process:(float)process {
    if (NoNullString(key).length == 0) {
        return;
    }

    if (![self.coursewareDelegate respondsToSelector:@selector(courseware:didProcessChanged:)]) {
        return;
    }

    for (AgoraEduCourseware *courseware in AgoraManagerCache.share.coursewares) {
        NSUInteger hash = courseware.resourceUrl.hash;
        NSString *hashKey = [NSString stringWithFormat:@"%lu", hash];
        if ([key isEqualToString:hashKey]) {
            [self.coursewareDelegate courseware:courseware
                              didProcessChanged:process];
            return;
        }
    }
}

- (void)onDownloadCompleted:(NSString *)key
                       urls:(NSArray<NSURL *> *)urls
                      error:(NSError *)error
                  errorCode:(NSInteger)errorCode {
    if (NoNullString(key).length == 0) {
        return;
    }

    if (![self.coursewareDelegate respondsToSelector:@selector(courseware:didCompleted:)]) {
        return;
    }

    for (AgoraEduCourseware *courseware in AgoraManagerCache.share.coursewares) {
        NSString *hashKey = [NSString stringWithFormat:@"%lu", (long)courseware.resourceUrl.hash];
        if ([key isEqualToString:hashKey]) {
            [self.coursewareDelegate courseware:courseware didCompleted:error];
            return;
        }
    }
}
@end
