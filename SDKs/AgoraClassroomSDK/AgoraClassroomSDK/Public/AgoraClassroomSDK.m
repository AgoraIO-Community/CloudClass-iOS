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

@interface AgoraClassroomSDK () <AgoraEduUIManagerCallBack>
@property (nonatomic, strong) AgoraClassroomSDKConfig *sdkConfig;
@property (nonatomic, strong) AgoraEduCorePuppet *core;
@property (nonatomic, strong) UIViewController *ui;
@property (nonatomic, strong) NSNumber *consoleState;
@property (nonatomic, strong) NSNumber *environment;
@property (nonatomic, weak) id<AgoraEduClassroomSDKDelegate> delegate;
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
       failure:(void (^)(NSError *))failure {
    if (config == nil || !config.isLegal) {
        if (failure) {
            NSError *error = [[NSError alloc] initWithDomain:@"config illegal"
                                                        code:-1
                                                    userInfo:nil];
            failure(error);
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
    
    // Media video encoder config
    AgoraEduCorePuppetMediaOptions *mediaOptions = [self getPuppetMediaOptions:config.mediaOptions];
    
    AgoraEduCorePuppetRoleType role = config.userRole;

    AgoraEduCorePuppetLaunchConfig *coreConfig = [[AgoraEduCorePuppetLaunchConfig alloc]
                                                  initWithAppId:manager.sdkConfig.appId
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
                                                  duration:config.duration];
    
    __weak AgoraClassroomSDK *weakManager = manager;

    [core launchWithConfig:coreConfig
                   extApps:config.extApps.allValues
                   widgets:config.widgets.allValues
                   success:^(id<AgoraEduContextPool> pool) {
        AgoraEduUIManager *eduVC = nil;
        switch ([pool.room getRoomInfo].roomType) {
            case AgoraEduContextRoomTypeOneToOne:
                eduVC = [[AgoraOneToOneUIManager alloc] initWithContextPool:pool
                                                                   delegate:manager];
                break;
            case AgoraEduContextRoomTypeSmall:
                eduVC = [[AgoraSmallUIManager alloc] initWithContextPool:pool
                                                                delegate:manager];
                break;
            case AgoraEduContextRoomTypeLecture:
                eduVC = [[AgoraLectureUIManager alloc] initWithContextPool:pool
                                                                  delegate:manager];
                break;
            case AgoraEduContextRoomTypePaintingSmall:
                eduVC = [[AgoraPaintingUIManager alloc] initWithContextPool:pool
                                                                   delegate:manager];
                break;
            default:
                NSCAssert(true,
                          @"未实现该教室类型");
                break;
        }
        eduVC.modalPresentationStyle = UIModalPresentationFullScreen;
        UIViewController *topVC = [UIViewController ag_topViewController];
        manager.ui = eduVC;
        [topVC presentViewController:eduVC
                            animated:true
                          completion:^{
            if (success) {
                success();
            }
        }];
    } failure:failure];
}

- (void)agoraRelease {
    self.core = nil;
    self.ui = nil;
    self.delegate = nil;
}

#pragma mark - AgoraEduUIManagerDelegate
- (void)manager:(AgoraEduUIManager *)manager
      didExited:(enum AgoraClassRoomExitReason)reason {
    AgoraEduExitReason sdkReason = nil;
    switch (reason) {
        case AgoraClassRoomExitReasonNormal:
            sdkReason = AgoraEduExitReasonNormal;
            break;
        case AgoraClassRoomExitReasonKickOut:
            sdkReason = AgoraEduExitReasonKickOut;
        default:
            break;
    }
    if ([_delegate respondsToSelector:@selector(classroomSDK:didExited:)]) {
        [self.delegate classroomSDK:self
                          didExited:sdkReason];
    }
    [self agoraRelease];
}
@end
