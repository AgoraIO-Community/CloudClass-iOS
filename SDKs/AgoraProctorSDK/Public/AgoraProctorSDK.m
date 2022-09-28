//
//  AgoraProctorSDK.m
//  AgoraProctorSDK
//
//  Created by SRS on 2021/1/5.
//

#import <AgoraProctorUI/AgoraProctorUI-Swift.h>
#import <AgoraEduCore/AgoraEduCore-Swift.h>
#import "AgoraInternalProctorSDK.h"
#import "AgoraProctorSDK.h"

@interface AgoraProctorSDK () <PtUISceneDelegate>
@property (nonatomic, strong) AgoraEduCoreEngine *core;
@property (nonatomic, strong) PtUIScene *scene;
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
        
        AgoraEduCoreLaunchConfig *coreConfig = [self getCoreLaunchConfig:self.config];
        self.core = [[AgoraEduCoreEngine alloc] initWithConfig:coreConfig
                                                       widgets:config.widgets.allValues];
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
    _environment = environment;
}

- (void)setLogConsoleState:(NSNumber *)state {
    _consoleState = state;
}

#pragma mark - FcrProctorSceneDelegate
- (void)onExitWithReason:(enum PtUISceneExitReason)reason {
    AgoraProctorExitReason sdkReason = AgoraProctorExitReasonNormal;
    
    switch (reason) {
        case PtUISceneExitReasonNormal:
            sdkReason = AgoraProctorExitReasonNormal;
            break;
        case PtUISceneExitReasonKickOut:
            sdkReason = AgoraProctorExitReasonKickOut;
        default:
            break;
    }
    
    [self.delegate proctorSDK:self
                      didExit:sdkReason];
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
    
    __weak AgoraProctorSDK *weakSelf = self;
    
    [self.core launchWithSuccess:^(id<AgoraEduContextPool> pool) {
        AgoraProctorSDK *strongSelf = weakSelf;
        
        if (!strongSelf) {
            return;
        }
        [PtUIContext create];
        PtUIScene *scene = [[PtUIScene alloc] initWithContextPool:pool
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

- (void)dealloc {
    [self.core exit];
    
    [self.scene dismissViewControllerAnimated:YES
                                   completion:nil];
}
@end
