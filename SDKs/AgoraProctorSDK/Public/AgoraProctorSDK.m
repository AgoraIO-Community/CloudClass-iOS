//
//  AgoraProctorSDK.m
//  AgoraProctorSDK
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
#import <AgoraProctorUI/AgoraProctorUI-Swift.h>
#import "AgoraInternalProctorSDK.h"
#import "AgoraProctorSDK.h"

@interface AgoraProctorSDK () <FcrProctorSceneDelegate>
@property (nonatomic, strong) AgoraEduCorePuppet *core;
@property (nonatomic, strong) FcrProctorScene *scene;
@property (nonatomic, strong) NSNumber *consoleState;
@property (nonatomic, strong) NSNumber *environment;
@property (nonatomic, strong) AgoraProctorLaunchConfig *config;
@property (nonatomic, weak) id<AgoraProctorSDKDelegate> delegate;
@end

static AgoraProctorSDK *manager = nil;

@implementation AgoraProctorSDK
+ (instancetype)share {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[AgoraProctorSDK alloc] init];
    });
    return manager;
}

+ (NSString *)version {
    NSBundle *bundle = [NSBundle bundleForClass:[AgoraProctorSDK class]];
    NSDictionary *dictionary = bundle.infoDictionary;
    NSString *version = dictionary[@"CFBundleShortVersionString"];
    
    if (version.length > 0) {
        return version;
    } else {
        return @"1.0.0";
    }
}

+ (void)setEnvironment:(NSNumber *)environment {
    [AgoraProctorSDK share].environment = environment;
}

+ (void)setLogConsoleState:(NSNumber *)state {
    [AgoraProctorSDK share].consoleState = state;
}

#pragma mark - FcrProctorSceneDelegate
- (void)onExitWithReason:(enum FcrUISceneExitReason)reason {
    AgoraProctorExitReason sdkReason = AgoraProctorExitReasonNormal;
    
    switch (reason) {
        case FcrUISceneExitReasonNormal:
            sdkReason = AgoraProctorExitReasonNormal;
            break;
        case FcrUISceneExitReasonKickOut:
            sdkReason = AgoraProctorExitReasonKickOut;
        default:
            break;
    }
    
    [self.delegate proctorSDK:self
                      didExit:sdkReason];
}

#pragma mark - Public
+ (void)launch:(AgoraProctorLaunchConfig *)config
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
    
    AgoraProctorSDK *manager = [AgoraProctorSDK share];
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
    AgoraEduCorePuppetLaunchConfig *coreConfig = [AgoraProctorSDK getPuppetLaunchConfig:config];
    
    [core launch:coreConfig
         widgets:config.widgets.allValues
         success:^(id<AgoraEduContextPool> pool) {
        FcrProctorScene *scene = [[FcrProctorScene alloc] initWithContextPool:pool
                                                                     delegate:manager];
        scene.modalPresentationStyle = UIModalPresentationFullScreen;
        manager.scene = scene;
        
        UIViewController *topVC = [UIViewController agora_top_view_controller];
        
        [topVC presentViewController:scene
                            animated:true
                          completion:^{
            if (success) {
                success();
            }
        }];
    } failure:failure];
}

+ (void)setDelegate:(id<AgoraProctorSDKDelegate> _Nullable)delegate {
    manager.delegate = delegate;
}

+ (void)exit {
    [manager.core exit];
    
    __weak AgoraProctorSDK *weakManager = manager;
    
    [manager.scene dismissViewControllerAnimated:YES
                                   completion:^{
        [weakManager agoraRelease];
    }];
}

#pragma mark - Private
- (void)agoraRelease {
    self.delegate = nil;
    self.scene = nil;
    self.core = nil;
}

- (AgoraEduCorePuppet *)core {
    if (_core == nil) {
        _core = [[AgoraEduCorePuppet alloc] init];
    }
    
    return _core;
}

@end
