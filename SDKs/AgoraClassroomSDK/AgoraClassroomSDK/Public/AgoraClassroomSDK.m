//
//  AgoraClassroomSDK.m
//  AgoraClassroomSDK
//
//  Created by SRS on 2021/1/5.
//

#import <AgoraEduCore/AgoraEduCore-Swift.h>
#import <AgoraEduUI/AgoraEduUI-Swift.h>
#import <AgoraEduContext/AgoraEduContext-Swift.h>
#import <AgoraWidgets/AgoraWidgets-Swift.h>
#import "AgoraBaseViewController.h"
#import "AgoraEduTopVC.h"
#import "AgoraClassroomSDK.h"
#import "AgoraInternalClassroom.h"

@interface AgoraClassroomSDK () <AgoraEduCoreDelegate, AgoraDownloadDelegate>
@property (nonatomic, strong) AgoraClassroomSDKConfig *sdkConfig;
@property (nonatomic, strong) NSArray<AgoraExtAppConfiguration *> *apps;
@property (nonatomic, strong) NSArray<AgoraWidgetConfiguration *> *widgets;
@property (nonatomic, strong) AgoraEduCore *core;
@property (nonatomic, strong) AgoraEduUI *ui;
@property (nonatomic, strong) NSNumber *consoleState;
@property (nonatomic, strong) NSArray<AgoraEduCourseware *> *coursewares;
@property (nonatomic, strong) AgoraEduClassroom *room;
@property (nonatomic, weak) id<AgoraEduClassroomDelegate> roomDelegate;
@property (nonatomic, weak) id<AgoraEduCoursewareDelegate> coursewareDelegate;
@property (nonatomic, copy) NSString *baseURL;
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

+ (NSString *)version {
    return @"1.1.5";
}

+ (void)setBaseURL:(NSString *)baseURL {
    [AgoraClassroomSDK share].baseURL = baseURL;
}

+ (void)setLogConsoleState:(NSNumber *)state {
    [AgoraClassroomSDK share].consoleState = state;
}

#pragma mark - Public
+ (BOOL)setConfig:(AgoraClassroomSDKConfig *)config {
    if (config == nil) {
        return NO;
    }
    
    if (config.isLegal) {
        [AgoraClassroomSDK share].sdkConfig = config;
        return YES;
    } else {
        return NO;
    }
}

+ (AgoraEduClassroom * _Nullable)launch:(AgoraEduLaunchConfig *)config
                               delegate:(id<AgoraEduClassroomDelegate> _Nullable)delegate {
    if (config == nil) {
        return nil;
    }
    
    if (!config.isLegal) {
        return nil;
    }
    
    AgoraClassroomSDK *manager = [AgoraClassroomSDK share];
    
    AgoraEduCore *core = [[AgoraEduCore alloc] initWithDelegate:manager];
    
    // 切换 host
    NSString *host = [AgoraClassroomSDK share].baseURL;
    if (![host containsString:@"-dev"]) {
        host = [host stringByAppendingFormat:@"/%@",config.region.lowercaseString];
    }

    if (host.length > 0) {
        NSDictionary *dic = @{@"host": host};
        [core setParameters:dic];
    }
    
    NSArray *coursewares = nil;
    
    // 模型转换
    if (manager.coursewares.count > 0) {
        NSMutableArray *array = [NSMutableArray array];
        
        for (AgoraEduCourseware *courseware in manager.coursewares) {
            AgoraEduCoreCourseware *item = [[AgoraEduCoreCourseware alloc] initWithResourceName:courseware.resourceName
                                                                                   resourceUuid:courseware.resourceUuid
                                                                                      scenePath:courseware.scenePath
                                                                                    resourceURL:courseware.resourceUrl
                                                                                         scenes:courseware.scenes];
            [array addObject:item];
        }
        
        coursewares = array;
    }
    
    AgoraEduCoreVideoConfig *videoConfig;
    if (config.cameraEncoderConfiguration) {
        videoConfig = [[AgoraEduCoreVideoConfig alloc] initWithVideoDimensionWidth:config.cameraEncoderConfiguration.width
                                                             videoDimensionHeight:config.cameraEncoderConfiguration.height
                                                                        frameRate:config.cameraEncoderConfiguration.frameRate
                                                                          bitrate:config.cameraEncoderConfiguration.bitrate
                                                                        mirrorMode: config.cameraEncoderConfiguration.mirrorMode];
    }
    AgoraEduCoreMediaOptions *mediaOptions;
    if (config.mediaOptions) {
        AgoraEduCoreMediaEncryptionConfig * encryptionConfig = [[AgoraEduCoreMediaEncryptionConfig alloc] initWithKey:config.mediaOptions.encryptionConfig.key
                                                                                                                 mode:config.mediaOptions.encryptionConfig.mode];
        mediaOptions = [[AgoraEduCoreMediaOptions alloc] initWithEncryptionConfig:encryptionConfig];
    }
    AgoraEduCoreLaunchConfig *coreConfig = [[AgoraEduCoreLaunchConfig alloc] initWithUserName:config.userName
                                                                                     userUuid:config.userUuid
                                                                                     userRole:AgoraEduRoleTypeStudent
                                                                               userProperties:config.userProperties
                                                                                     roomName:config.roomName
                                                                                     roomUuid:config.roomUuid
                                                                                     roomType:config.roomType
                                                                                    startTime:config.startTime
                                                                                     duration:config.duration
                                                                                        appId:manager.sdkConfig.appId
                                                                                     rtmToken:config.token
                                                                                       region:config.region
                                                                                 mediaOptions:mediaOptions
                                                                                   videoState:config.videoState
                                                                                   audioState:config.audioState
                                                                                  coursewares:coursewares
                                                                                  videoConfig:videoConfig
                                                                                 latencyLevel:config.latencyLevel
                                                                                 boardFitMode:config.boardFitMode];
    
    manager.core = core;

    __weak AgoraClassroomSDK *weakManager = manager;
    __weak AgoraEduCore *weakCore = core;
    
    // 注册内部的 widget
    AgoraWidgetConfiguration *chat = [[AgoraWidgetConfiguration alloc] initWithClass:[AgoraChatWidget class]
                                                                            widgetId:@"AgoraChatWidget"];
    
    NSMutableDictionary *widgets = [NSMutableDictionary dictionary];
    widgets[chat.widgetId] = chat;
    
    for (AgoraWidgetConfiguration *item in manager.widgets) {
        widgets[item.widgetId] = item;
    }
    
    [core launchWithConfig:coreConfig
                   extApps:manager.apps
                   widgets:widgets.allValues
                   success:^(id<AgoraEduContextPool> _Nonnull pool) {
        AgoraEduContextRoomType roomType = AgoraEduContextRoomTypeOneToOne;

        switch (config.roomType) {
            case AgoraEduRoomTypeOneToOne:
                roomType = AgoraEduContextRoomTypeOneToOne;
                break;
            case AgoraEduRoomTypeSmall:
                roomType = AgoraEduContextRoomTypeSmall;
                break;
            case AgoraEduRoomTypeLecture:
                roomType = AgoraEduContextRoomTypeLecture;
                break;
            default:
                assert("Enum RoomType error");
                break;
        }

        AgoraEduUI *ui = [[AgoraEduUI alloc] initWithViewType:roomType
                                                  contextPool:pool
                                                       region:config.region];

        AgoraBaseViewController *vc = [[AgoraBaseViewController alloc] init];
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [vc.view addSubview:ui.appView];
        ui.appView.agora_x = 0;
        ui.appView.agora_y = 0;
        ui.appView.agora_right = 0;
        ui.appView.agora_bottom = 0;

        [AgoraEduTopVC.topVC presentViewController:vc
                                          animated:YES
                                        completion:^{
            [weakManager launchCompleteEvent:AgoraEduEventReady];
        }];
        
        weakManager.ui = ui;
    } fail:^(AgoraEduContextError * _Nonnull error) {
        if (error.code == 30403100) {
            [manager launchCompleteEvent:AgoraEduEventForbidden];
        } else {
            [manager launchCompleteEvent:AgoraEduEventFailed];
        }
    }];
    
    AgoraEduClassroom *room = [[AgoraEduClassroom alloc] init];
    manager.room = room;
    manager.roomDelegate = delegate;
    
    return room;
}

+ (void)configCoursewares:(NSArray<AgoraEduCourseware *> *)coursewares {
    [AgoraClassroomSDK share].coursewares = [coursewares mutableCopy];
}

+ (void)downloadCoursewares:(id<AgoraEduCoursewareDelegate> _Nullable)delegate {
    AgoraClassroomSDK *manager = [AgoraClassroomSDK share];
    AgoraEduCore *core = manager.core;
    NSArray *coursewares = manager.coursewares;
    
    // 下载公共课件
    NSString *directory = core.fileGroup.downloadFolder;
    NSString *url = core.urlGroup.netlessPublicCourseware;
    NSURL *publicCourseware = [NSURL URLWithString:url];
    
    [core.download downloadWithUrls:@[publicCourseware]
                      fileDirectory:directory
                                key:nil
                           delegate:nil];
    
    // 下载私有课件
    // 判断非空
    if (coursewares.count == 0) {
        return;
    }
    
    for (AgoraEduCourseware *courseware in coursewares) {
        if (courseware.resourceUrl.length == 0) {
            continue;;
        }
        
        NSURL *url = [NSURL URLWithString:courseware.resourceUrl];
        NSString *key = [NSString stringWithFormat:@"%lu", (unsigned long)courseware.resourceUrl.hash];
        [core.download downloadWithUrls:@[url]
                          fileDirectory:directory
                                    key:key
                               delegate:manager];
    }
    
    manager.coursewareDelegate = delegate;
}

+ (void)registerExtApps:(NSArray<AgoraExtAppConfiguration *> *)apps {
    [AgoraClassroomSDK share].apps = [NSArray arrayWithArray:apps];
}

+ (void)registerWidgets:(NSArray<AgoraWidgetConfiguration *> *)widgets {
    [AgoraClassroomSDK share].widgets = [NSArray arrayWithArray:widgets];
}

+ (void)setParameters:(NSDictionary *)parameters {
    if (parameters.count <= 0) {
        return;
    }
    
    NSNumber *destory = parameters[@"destory"];
    
    if ([destory integerValue]) {
        [[AgoraClassroomSDK share] destory];
    }
}

- (void)launchCompleteEvent:(AgoraEduEvent)event {
    if ([self.roomDelegate respondsToSelector:@selector(classroom:didReceivedEvent:)]) {
        [self.roomDelegate classroom:self.room
                    didReceivedEvent:event];
    }
}

- (void)destory {
    __weak AgoraClassroomSDK *weakself = self;
    
    if (![AgoraEduTopVC.topVC isKindOfClass:[AgoraBaseViewController class]]) {
        [self agoraRelease];
        return;
    }
    
    [AgoraEduTopVC.topVC dismissViewControllerAnimated:true
                                            completion:^{
        [weakself agoraRelease];
    }];
}

- (void)agoraRelease {
    self.core = nil;
    self.ui = nil;
    
    self.apps = nil;
    self.widgets = nil;
    self.coursewares = nil;
    self.room = nil;
    self.roomDelegate = nil;
    self.coursewareDelegate = nil;
    
    [self launchCompleteEvent:AgoraEduEventDestroyed];
}

#pragma mark - AgoraEduCoreDelegate
- (void)didExit {
    [self destory];
}

#pragma mark - AgoraDownloadDelegate
- (void)onProcessChanged:(NSString *)key
                     url:(NSURL *)url
                 process:(float)process {
    if (key.length == 0) {
        return;
    }

    if (![self.coursewareDelegate respondsToSelector:@selector(courseware:didProcessChanged:)]) {
        return;
    }

    for (AgoraEduCourseware *courseware in self.coursewares) {
        NSUInteger hash = courseware.resourceUrl.hash;
        NSString *hashKey = [NSString stringWithFormat:@"%lu", (unsigned long)hash];
        
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
    if (key.length == 0) {
        return;
    }

    if (![self.coursewareDelegate respondsToSelector:@selector(courseware:didCompleted:)]) {
        return;
    }

    for (AgoraEduCourseware *courseware in self.coursewares) {
        NSUInteger hash = courseware.resourceUrl.hash;
        NSString *hashKey = [NSString stringWithFormat:@"%lu", (unsigned long)hash];
        
        if ([key isEqualToString:hashKey]) {
            [self.coursewareDelegate courseware:courseware
                                   didCompleted:error];
            return;
        }
    }
}
@end
