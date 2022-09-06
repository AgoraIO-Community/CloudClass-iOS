//
//  AgoraInvigilatorSDK.m
//  AgoraInvigilatorSDK
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
#import <AgoraInvigilatorUI/AgoraInvigilatorUI-Swift.h>
#import "AgoraInternalInvigilator.h"
#import "AgoraInvigilatorSDK.h"

@interface AgoraInvigilatorSDK () <FcrInviligatorSceneDelegate>
@property (nonatomic, strong) AgoraEduCorePuppet *core;
@property (nonatomic, strong) FcrInviligatorScene *scene;
@property (nonatomic, strong) NSNumber *consoleState;
@property (nonatomic, strong) NSNumber *environment;
@property (nonatomic, strong) AgoraInvigilatorLaunchConfig *config;
@property (nonatomic, weak) id<AgoraInvigilatorSDKDelegate> delegate;
@end

static AgoraInvigilatorSDK *manager = nil;

@implementation AgoraInvigilatorSDK
+ (instancetype)share {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[AgoraInvigilatorSDK alloc] init];
    });
    return manager;
}

+ (NSString *)version {
    NSBundle *bundle = [NSBundle bundleForClass:[AgoraInvigilatorSDK class]];
    NSDictionary *dictionary = bundle.infoDictionary;
    NSString *version = dictionary[@"CFBundleShortVersionString"];
    
    if (version.length > 0) {
        return version;
    } else {
        return @"1.0.0";
    }
}

+ (void)setEnvironment:(NSNumber *)environment {
    [AgoraInvigilatorSDK share].environment = environment;
}

+ (void)setLogConsoleState:(NSNumber *)state {
    [AgoraInvigilatorSDK share].consoleState = state;
}

#pragma mark - FcrInviligatorSceneDelegate
- (void)onExitWithReason:(enum FcrUISceneExitReason)reason {
    UIViewController *topVC = [UIViewController agora_top_view_controller];
    [topVC dismissViewControllerAnimated:manager.scene
                              completion:^{
        
    }];
}

#pragma mark - Public
+ (void)launch:(AgoraInvigilatorLaunchConfig *)config
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
    
    AgoraInvigilatorSDK *manager = [AgoraInvigilatorSDK share];
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
    AgoraEduCorePuppetLaunchConfig *coreConfig = [AgoraInvigilatorSDK getPuppetLaunchConfig:config];
    
    [core launch:coreConfig
         widgets:config.widgets.allValues
         success:^(id<AgoraEduContextPool> pool) {
        FcrInviligatorScene *scene = [[FcrInviligatorScene alloc] initWithContextPool:pool
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

+ (void)setDelegate:(id<AgoraInvigilatorSDKDelegate> _Nullable)delegate {
    manager.delegate = delegate;
}

+ (void)exit {
    [manager.core exit];
    
    __weak AgoraInvigilatorSDK *weakManager = manager;
    
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
@end
