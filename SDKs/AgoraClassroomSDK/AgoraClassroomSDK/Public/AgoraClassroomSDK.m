//
//  AgoraClassroomSDK.m
//  AgoraClassroomSDK
//
//  Created by SRS on 2021/1/5.
//

#import <AgoraEduContext/AgoraEduContext-Swift.h>
#import <AgoraEduCorePuppet/AgoraEduCoreWrapper.h>
#import <AgoraWidgets/AgoraWidgets-Swift.h>
#import <AgoraEduUI/AgoraEduUI-Swift.h>
#import <AgoraWidget/AgoraWidget.h>
#import "AgoraBaseViewController.h"
#import "AgoraInternalClassroom.h"
#import "AgoraClassroomSDK.h"
#import "AgoraEduTopVC.h"

@interface AgoraClassroomSDK () <AgoraEduCorePuppetDelegate, AgoraEduCorePuppetDownloadProcess>
@property (nonatomic, strong) AgoraClassroomSDKConfig *sdkConfig;
@property (nonatomic, strong) NSArray<AgoraExtAppConfiguration *> *apps;
@property (nonatomic, strong) NSArray<AgoraWidgetConfiguration *> *widgets;
@property (nonatomic, strong) AgoraEduCorePuppet *core;
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
        manager.consoleState = [[NSNumber alloc] initWithInt:0];
    });
    return manager;
}

+ (NSString *)version {
    NSBundle *bundle = [NSBundle bundleForClass:[AgoraClassroomSDK class]];
    NSDictionary *dictionary = bundle.infoDictionary;
    NSString *version = dictionary[@"CFBundleShortVersionString"];
    
    if (version.length > 0) {
        return version;
    } else {
        return @"1.0.0";
    }
}

- (AgoraEduCorePuppet *)core {
    if (_core == nil) {
        _core = [[AgoraEduCorePuppet alloc] initWithDelegate:self];
    }
    
    return _core;
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
    AgoraEduCorePuppet *core = manager.core;
    
    // Switch host
    NSString *host = [AgoraClassroomSDK share].baseURL;

    if (host.length > 0) {
        NSDictionary *parameters = @{@"host": host};
        [core setParameters:parameters];
    }
    
    // Log console
    NSNumber *console = [AgoraClassroomSDK share].consoleState;
    if (console) {
        NSDictionary *parameters = @{@"console": console};
        [core setParameters:parameters];
    }
    
    // Board coursewares
    NSArray<AgoraEduCorePuppetCourseware *> *coursewares = [self getPuppetBoardModelCoursewares:manager.coursewares];
    
    // Media video encoder config
    AgoraEduCorePuppetVideoConfig *videoConfig = nil;
    if (config.cameraEncoderConfiguration) {
        videoConfig = [[AgoraEduCorePuppetVideoConfig alloc] initWithVideoDimensionWidth:config.cameraEncoderConfiguration.width
                                                                    videoDimensionHeight:config.cameraEncoderConfiguration.height
                                                                               frameRate:config.cameraEncoderConfiguration.frameRate
                                                                                 bitRate:config.cameraEncoderConfiguration.bitrate
                                                                              mirrorMode:config.cameraEncoderConfiguration.mirrorMode];
    }

    AgoraEduCorePuppetMediaOptions *mediaOptions = nil;
    if (config.mediaOptions) {
        NSString *key = config.mediaOptions.encryptionConfig.key;
        AgoraEduCorePuppetMediaEncryptionMode mode = config.mediaOptions.encryptionConfig.mode;
        AgoraEduCorePuppetMediaEncryptionConfig *encryptionConfig = [[AgoraEduCorePuppetMediaEncryptionConfig alloc] initWithKey:key
                                                                                                                            mode:mode];
        mediaOptions = [[AgoraEduCorePuppetMediaOptions alloc] initWithEncryptionConfig:encryptionConfig];
    }

    AgoraEduCorePuppetRoleType role = config.roleType;

    AgoraEduCorePuppetLaunchConfig *coreConfig = [[AgoraEduCorePuppetLaunchConfig alloc] initWithAppId:manager.sdkConfig.appId
                                                                                              rtmToken:config.token
                                                                                                region:config.region
                                                                                              userName:config.userName
                                                                                              userUuid:config.userUuid
                                                                                              userRole:role
                                                                                        userProperties:config.userProperties
                                                                                           videoConfig:videoConfig
                                                                                          mediaOptions:mediaOptions
                                                                                            videoState:config.videoState
                                                                                            audioState:config.audioState
                                                                                          latencyLevel:config.latencyLevel
                                                                                              roomName:config.roomName
                                                                                              roomUuid:config.roomUuid
                                                                                              roomType:config.roomType
                                                                                             startTime:config.startTime
                                                                                              duration:config.duration
                                                                                           coursewares:coursewares
                                                                                          boardFitMode:config.boardFitMode];

    __weak AgoraClassroomSDK *weakManager = manager;

    // Register widgets
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
            case AgoraEduRoomTypePaintingSmall:
                roomType = AgoraEduContextRoomTypePaintingSmall;
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
    } fail:^(NSError * _Nonnull error) {
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
    AgoraEduCorePuppet *core = manager.core;
    NSArray *coursewares = manager.coursewares;

    // 下载公共课件
    NSString *directory = [core getDownloadFolderPath];;
    NSString *url = [core getNetlessPublicCoursewareURL];;
    NSURL *publicCourseware = [NSURL URLWithString:url];

    core.downloadProcess = manager;
    
    [core downloadWithURL:publicCourseware
           downloadFolder:directory
                      key:nil];
    
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
        [core downloadWithURL:url
               downloadFolder:directory
                          key:key];
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

#pragma mark - AgoraEduCorePuppetDelegate
- (void)corePuppetDidExit {
    [self destory];
}

#pragma mark - AgoraEduCorePuppetDownloadProcess
- (void)corePuppet:(AgoraEduCorePuppet *)core
didProcessUpdatedWithURL:(NSURL *)url
           process:(float)process
               key:(NSString *)key {
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

- (void)corePuppet:(nonnull AgoraEduCorePuppet *)core
    didFishWithKey:(nonnull NSString *)key
              urls:(nonnull NSArray<NSURL *> *)urls
             error:(nonnull NSError *)error
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

#pragma mark - Model translation
+ (NSArray<AgoraEduCorePuppetCourseware *> * _Nullable)getPuppetBoardModelCoursewares:(NSArray<AgoraEduCourseware *> *)coursewares {
    if (coursewares.count <= 0) {
        return nil;
    }
    
    NSMutableArray<AgoraEduCorePuppetCourseware *> *puppetCoursewares = [NSMutableArray array];
    
    for (AgoraEduCourseware *courseware in coursewares) {
        NSMutableArray *puppetScenes = [NSMutableArray array];
        
        // board scene
        for (AgoraEduBoardScene *scene in courseware.scenes) {
            // board ppt
            AgoraEduPPTPage *ppt = scene.pptPage;
            AgoraEduCorePuppetPPTPage *puppetPPT = nil;
            
            if (ppt) {
                puppetPPT = [[AgoraEduCorePuppetPPTPage alloc] initWithSource:ppt.source
                                                                   previewURL:ppt.previewURL
                                                                         size:CGSizeMake(ppt.width,
                                                                                         ppt.height)];
            }
            
            AgoraEduCorePuppetBoardScene *puppetScene = [[AgoraEduCorePuppetBoardScene alloc] initWithName:scene.name
                                                                                                   pptPage:puppetPPT];
            
            [puppetScenes addObject:puppetScene];
        }
        
        AgoraEduCorePuppetCourseware *puppetCourseware = [[AgoraEduCorePuppetCourseware alloc] initWithResourceName:courseware.resourceName
                                                                                                       resourceUuid:courseware.resourceUuid
                                                                                                          scenePath:courseware.scenePath
                                                                                                        resourceURL:courseware.resourceUrl
                                                                                                             scenes:puppetScenes];
        [puppetCoursewares addObject:puppetCourseware];
    }
    
    return puppetCoursewares;
}
@end
