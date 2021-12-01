//
//  AgoraClassroomSDK.m
//  AgoraClassroomSDK
//
//  Created by SRS on 2021/1/5.
//

#if __has_include(<AgoraEduCorePuppet/AgoraEduCoreWrapper.h>)
#import <AgoraEduCorePuppet/AgoraEduCoreWrapper.h>
#elif __has_include(<AgoraEduCore/AgoraEduCoreWrapper.h>)
#import <AgoraEduCore/AgoraEduCoreWrapper.h>
#else
# error "Invalid import"
#endif

#import <AgoraEduContext/AgoraEduContext-Swift.h>
#import <AgoraWidgets/AgoraWidgets-Swift.h>
#import <AgoraEduUI/AgoraEduUI-Swift.h>
#import <AgoraWidget/AgoraWidget.h>
#import "AgoraInternalClassroom.h"
#import "AgoraClassroomSDK.h"

@interface AgoraClassroomSDK () <AgoraEduUIDelegate>
@property (nonatomic, strong) AgoraEduCorePuppet *core;
@property (nonatomic, strong) AgoraEduUI *ui;

@property (nonatomic, strong) AgoraClassroomSDKConfig *sdkConfig;
@property (nonatomic, strong) NSArray<AgoraExtAppConfiguration *> *apps;
@property (nonatomic, strong) NSArray<AgoraWidgetConfig *> *widgets;
@property (nonatomic, strong) NSArray<AgoraEduCourseware *> *coursewares;

@property (nonatomic, strong) NSNumber *consoleState;
@property (nonatomic, strong) NSNumber *environment;

@property (nonatomic, weak) id<AgoraEduClassroomSDKDelegate> delegate;
@property (nonatomic, weak) id<AgoraEduCoursewareProcess> coursewareDelegate;
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
        _core = [[AgoraEduCorePuppet alloc] init];
    }
    
    return _core;
}

+ (void)setEnvironment:(NSNumber *)environment {
    [AgoraClassroomSDK share].environment = environment;
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

+ (void)launch:(AgoraEduLaunchConfig *)config
      delegate:(id<AgoraEduClassroomSDKDelegate> _Nullable)delegate
       success:(void (^)(void))success
          fail:(void (^)(NSError *))fail {
    if (config == nil || !config.isLegal) {
        if (fail) {
            NSError *error = [[NSError alloc] initWithDomain:@"config illegal"
                                                        code:-1
                                                    userInfo:nil];
            fail(error);
        }
        
        return;
    }
    
    AgoraClassroomSDK *manager = [AgoraClassroomSDK share];
    AgoraEduCorePuppet *core = manager.core;
    
    // Log console
    NSNumber *console = manager.consoleState;
    if (console) {
        NSDictionary *parameters = @{@"console": console};
        [core setParameters:parameters];
    }
    
    // Environment
    NSNumber *environment = manager.environment;
    if (environment) {
        NSDictionary *parameters = @{@"environment": environment};
        [core setParameters:parameters];
    }
    
    // Board coursewares
    NSArray<AgoraEduCorePuppetCourseware *> *coursewares = [self getPuppetBoardModelCoursewares:manager.coursewares];
    
    // Media video encoder config
    AgoraEduCorePuppetMediaOptions *mediaOptions = [self getPuppetMediaOptions:config.mediaOptions];
    
    AgoraEduCorePuppetRoleType role = config.roleType;

    AgoraEduCorePuppetLaunchConfig *coreConfig = [[AgoraEduCorePuppetLaunchConfig alloc] initWithAppId:manager.sdkConfig.appId
                                                                                              rtmToken:config.token
                                                                                                region:config.region
                                                                                              userName:config.userName
                                                                                              userUuid:config.userUuid
                                                                                              userRole:role
                                                                                        userProperties:config.userProperties
                                                                                          mediaOptions:mediaOptions
                                                                                              roomName:config.roomName
                                                                                              roomUuid:config.roomUuid
                                                                                              roomType:config.roomType
                                                                                             startTime:config.startTime
                                                                                              duration:config.duration
                                                                                           coursewares:coursewares
                                                                                          boardFitMode:config.boardFitMode];
    
    __weak AgoraClassroomSDK *weakManager = manager;

    // Register widgets
    NSMutableDictionary *widgets = [NSMutableDictionary dictionary];
    // chat
    AgoraWidgetConfig *chat = [[AgoraWidgetConfig alloc] initWithClass:[AgoraChatWidget class]
                                                                            widgetId:@"AgoraChatWidget"];
    
    widgets[chat.widgetId] = chat;
    
    // AgoraSpreadRenderWidget
    AgoraWidgetConfig *spreadRender = [[AgoraWidgetConfig alloc] initWithClass:[AgoraSpreadRenderWidget class]
                                                                                    widgetId:@"big-window"];
    widgets[spreadRender.widgetId] = spreadRender;
    
    // AgoraCloudWidget
    AgoraWidgetConfig *cloudWidgetConfig = [[AgoraWidgetConfig alloc] initWithClass:[AgoraCloudWidget class]
                                                                                         widgetId:@"AgoraCloudWidget"];
    widgets[cloudWidgetConfig.widgetId] = cloudWidgetConfig;
    
    for (AgoraWidgetConfig *item in manager.widgets) {
        widgets[item.widgetId] = item;
    }

    [core launchWithConfig:coreConfig
                   extApps:manager.apps
                   widgets:widgets.allValues
                   success:^(id<AgoraEduContextPool> pool) {
        AgoraEduUI *eduUI = [[AgoraEduUI alloc] init];
        eduUI.delegate = weakManager;
        
        [eduUI launchWithContextPool:pool
                          completion:^{
            if (success) {
                success();
            }
        }];
        
        weakManager.ui = eduUI;
    } fail:fail];
}

+ (void)registerExtApps:(NSArray<AgoraExtAppConfiguration *> *)apps {
    [AgoraClassroomSDK share].apps = [NSArray arrayWithArray:apps];
}

+ (void)registerWidgets:(NSArray<AgoraWidgetConfig *> *)widgets {
    [AgoraClassroomSDK share].widgets = [NSArray arrayWithArray:widgets];
}

- (void)agoraRelease {
    self.core = nil;
    self.ui = nil;
    
    self.apps = nil;
    self.widgets = nil;
    self.coursewares = nil;
    self.delegate = nil;
    self.coursewareDelegate = nil;
}

#pragma mark - AgoraEduUIDelegate
- (void)eduUI:(AgoraEduUI *)eduUI
   didExited:(enum AgoraEduUIExitReason)reason {
    [self agoraRelease];
    
    if (![self.delegate respondsToSelector:@selector(classroomSDK:didExited:)]) {
        return;
    }
    
    AgoraEduExitReason sdkReason;
    
    switch (reason) {
        case AgoraEduUIExitReasonNormal:
            sdkReason = AgoraEduExitReasonNormal;
            break;
        case AgoraEduExitReasonKickOut:
            sdkReason = AgoraEduExitReasonKickOut;
        default:
            break;
    }
    
    [self.delegate classroomSDK:self
                      didExited:sdkReason];
}
@end
