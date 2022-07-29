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
#import <AgoraEduUI/AgoraEduUI-Swift.h>
#import "AgoraInternalClassroom.h"
#import "AgoraClassroomSDK.h"

@interface AgoraClassroomSDK () <AgoraEduUIManagerCallback>
@property (nonatomic, strong) AgoraEduCorePuppet *core;
@property (nonatomic, strong) AgoraEduUIManager *ui;
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
+ (void)launch:(AgoraEduLaunchConfig *)config
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
    
    // Core config
    AgoraEduCorePuppetLaunchConfig *coreConfig = [AgoraClassroomSDK getPuppetLaunchConfig:config];
    // 职教课处理
    [core launch:coreConfig
         widgets:config.widgets.allValues
         success:^(id<AgoraEduContextPool> pool) {
        AgoraEduUIManager *eduVC = nil;
        
        switch ([pool.room getRoomInfo].roomType) {
            case AgoraEduContextRoomTypeOneToOne:
                eduVC = [[AgoraOneToOneUIManager alloc] initWithContextPool:pool
                                                                   delegate:manager
                                                                     uiMode:config.uiMode
                                                                   language:config.language];
                break;
            case AgoraEduContextRoomTypeSmall:
                eduVC = [[AgoraSmallUIManager alloc] initWithContextPool:pool
                                                                delegate:manager
                                                                  uiMode:config.uiMode
                                                                language:config.language];
                break;
            case AgoraEduContextRoomTypeLecture:
                eduVC = [[AgoraLectureUIManager alloc] initWithContextPool:pool
                                                                  delegate:manager
                                                                    uiMode:config.uiMode
                                                                  language:config.language];
                break;
            default:
                NSCAssert(true,
                          @"room type error");
                break;
        }
        
        eduVC.modalPresentationStyle = UIModalPresentationFullScreen;
        UIViewController *topVC = [UIViewController agora_top_view_controller];
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

+ (void)vocationalLaunch:(AgoraEduLaunchConfig *)config
                 service:(AgoraEduServiceType)serviceType
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
    // Core config
    AgoraEduCorePuppetLaunchConfig *coreConfig = [AgoraClassroomSDK getPuppetLaunchConfig:config];
    coreConfig.roomType = AgoraEduRoomTypeLecture;
    
    [core launch:coreConfig
         widgets:config.widgets.allValues
         success:^(id<AgoraEduContextPool> pool) {
        if ([pool.room getRoomInfo].roomType != AgoraEduContextRoomTypeLecture) {
            NSCAssert(true, @"vocational room type error");
            return;
        }
        AgoraEduUIManager *eduVC = nil;
        if (serviceType == AgoraEduServiceTypeMixStreamCDN) {
            VcrMixStreamCDNUIManager *vc = [[VcrMixStreamCDNUIManager alloc] initWithContextPool:pool
                                                                                        delegate:manager
                                                                                          uiMode:config.uiMode
                                                                                        language:config.language];
            eduVC = vc;
        } else if (serviceType == AgoraEduServiceTypeHostingScene) {
            VcrHostingSceneUIManager *vc = [[VcrHostingSceneUIManager alloc] initWithContextPool:pool
                                                                                        delegate:manager
                                                                                          uiMode:config.uiMode
                                                                                        language:config.language];
            eduVC = vc;
        } else {
            VocationalCDNType cdnType = VocationalCDNTypeNoCDN;
            switch (serviceType) {
                case AgoraEduServiceTypeOnlyCDN:
                    cdnType = VocationalCDNTypeOnlyCDN;
                    break;
                case AgoraEduServiceTypeMixedCDN:
                    cdnType = VocationalCDNTypeMixedCDN;
                    break;
                default:
                    cdnType = VocationalCDNTypeNoCDN;
                    break;
            }
            AgoraVocationalUIManager *vc = [[AgoraVocationalUIManager alloc] initWithContextPool:pool
                                                                                        delegate:manager
                                                                                          uiMode:config.uiMode
                                                                                        language:config.language];
            vc.cdnType = cdnType;
            eduVC = vc;
        }
        eduVC.modalPresentationStyle = UIModalPresentationFullScreen;
        UIViewController *topVC = [UIViewController agora_top_view_controller];
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

+ (void)setDelegate:(id<AgoraEduClassroomSDKDelegate> _Nullable)delegate {
    manager.delegate = delegate;
}

+ (void)exit {
    [manager.core exit];
    
    __weak AgoraClassroomSDK *weakManager = manager;
    
    [manager.ui dismissViewControllerAnimated:YES
                                   completion:^{
        [weakManager agoraRelease];
    }];
}

#pragma mark - Private
- (void)agoraRelease {
    self.core = nil;
    self.delegate = nil;
    self.ui = nil;
}

#pragma mark - AgoraEduUIManagerDelegate
- (void)manager:(AgoraEduUIManager *)manager
        didExit:(AgoraClassRoomExitReason)reason {
    AgoraEduExitReason sdkReason = AgoraEduExitReasonNormal;
    
    switch (reason) {
        case AgoraClassRoomExitReasonNormal:
            sdkReason = AgoraEduExitReasonNormal;
            break;
        case AgoraClassRoomExitReasonKickOut:
            sdkReason = AgoraEduExitReasonKickOut;
        default:
            break;
    }
    
    if ([_delegate respondsToSelector:@selector(classroomSDK:didExit:)]) {
        [self.delegate classroomSDK:self
                            didExit:sdkReason];
    }
    
    [self agoraRelease];
}
@end
