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

@implementation AgoraProctorSDK
- (instancetype)init:(AgoraProctorLaunchConfig *)config
            delegate:(id<AgoraProctorSDKDelegate>)delegate {
    self = [super init];
    
    if (self) {
        self.config = config;
        self.delegate = delegate;
        self.core = [[AgoraEduCorePuppet alloc] init];
    }
    
    return self;
}

- (NSString *)version {
    NSBundle *bundle = [NSBundle bundleForClass:[AgoraProctorSDK class]];
    NSDictionary *dictionary = bundle.infoDictionary;
    NSString *version = dictionary[@"CFBundleShortVersionString"];
    
    if (version.length > 0) {
        return version;
    } else {
        return @"1.0.0";
    }
}

- (void)setEnvironment:(NSNumber *)environment {
    self.environment = environment;
}

- (void)setLogConsoleState:(NSNumber *)state {
    self.consoleState = state;
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
    
    [self agoraRelease];
}

#pragma mark - Public
- (void)launch:(void (^)(void))success
       failure:(void (^)(NSError * _Nonnull))failure {
    if (self.config == nil || !self.config.isLegal) {
        if (failure) {
            NSError *error = [[NSError alloc] initWithDomain:@"config illegal"
                                                        code:-1
                                                    userInfo:nil];
            failure(error);
        }
        
        return;
    }
    
    // Log console
    NSNumber *console = self.consoleState;
    if (console) {
        NSDictionary *parameters = @{@"console": console};
        [self.core setParameters:parameters];
    }
    
    // Environment
    NSNumber *environment = self.environment;
    if (environment) {
        NSDictionary *parameters = @{@"environment": environment};
        [self.core setParameters:parameters];
    }
    
    AgoraEduCorePuppetLaunchConfig *coreConfig = [AgoraProctorSDK getPuppetLaunchConfig:self.config];
    
    __weak AgoraProctorSDK *weakSelf = self;
    
    [self.core launch:coreConfig
              widgets:self.config.widgets.allValues
              success:^(id<AgoraEduContextPool> pool) {
        AgoraProctorSDK *strongSelf = weakSelf;
        
        if (!strongSelf) {
            return;
        }
        FcrProctorScene *scene = [[FcrProctorScene alloc] initWithContextPool:pool
                                                                     delegate:strongSelf];
        scene.modalPresentationStyle = UIModalPresentationFullScreen;
        weakSelf.scene = scene;
        
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

- (void)exit {
    [self.core exit];
    
    __weak AgoraProctorSDK *weakSelf = self;
    
    [self.scene dismissViewControllerAnimated:YES
                                   completion:^{
        AgoraProctorSDK *strongSelf = weakSelf;
        
        if (!strongSelf) {
            return;
        }
        [strongSelf agoraRelease];
    }];
}

#pragma mark - Private
- (void)agoraRelease {
    self.delegate = nil;
    self.scene = nil;
    self.core = nil;
}
@end
