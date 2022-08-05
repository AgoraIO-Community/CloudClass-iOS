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
#import "AgoraInternalClassroom.h"
#import "AgoraClassroomSDK.h"

@interface AgoraClassroomSDK () <FcrUISceneDelegate>
@property (nonatomic, strong) AgoraEduCorePuppet *core;
@property (nonatomic, strong) FcrUIScene *scene;
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
    
    [core launch:coreConfig
         widgets:config.widgets.allValues
         success:^(id<AgoraEduContextPool> pool) {
        
        FcrUIScene *scene = nil;
        
        switch ([pool.room getRoomInfo].roomType) {
            case AgoraEduContextRoomTypeOneToOne:
                [FcrWidgetUIContext createWith:FcrWidgetUISceneTypeOneToOne];
                
                scene = [[FcrOneToOneUIScene alloc] initWithContextPool:pool
                                                               delegate:manager];
                break;
            case AgoraEduContextRoomTypeSmall:
                [FcrWidgetUIContext createWith:FcrWidgetUISceneTypeSmall];
                
                scene = [[FcrSmallUIScene alloc] initWithContextPool:pool
                                                            delegate:manager];
                break;
            case AgoraEduContextRoomTypeLecture:
                [FcrWidgetUIContext createWith:FcrWidgetUISceneTypeLecture];
                
                scene = [[FcrLectureUIScene alloc] initWithContextPool:pool
                                                              delegate:manager];
                break;
            default:
                NSCAssert(true,
                          @"room type error");
                break;
        }
        
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
    
    [core launch:coreConfig
         widgets:config.widgets.allValues
         success:^(id<AgoraEduContextPool> pool) {
        
        if ([pool.room getRoomInfo].roomType != AgoraEduContextRoomTypeLecture) {
            NSCAssert(true, @"vocational room type error");
            return;
        }
        
        FcrUIScene *scene = nil;
        
        if (serviceType == AgoraEduServiceTypeMixStreamCDN) {
            VcrMixStreamCDNUIScene *vc = [[VcrMixStreamCDNUIScene alloc] initWithContextPool:pool
                                                                                    delegate:manager];
            scene = vc;
        } else if (serviceType == AgoraEduServiceTypeHostingScene) {
            VcrHostingUIScene *vc = [[VcrHostingUIScene alloc] initWithContextPool:pool
                                                                          delegate:manager];
            scene = vc;
        } else {
            VocationalCDNType cdnType = VocationalCDNTypeLiveStandard;
            switch (serviceType) {
                case AgoraEduServiceTypeCDN:
                    cdnType = VocationalCDNTypeCDN;
                    break;
                case AgoraEduServiceTypeFusion:
                    cdnType = VocationalCDNTypeFusion;
                    break;
                default:
                    cdnType = VocationalCDNTypeLiveStandard;
                    break;
            }
            
            AgoraVocationalUIScene *vc = [[AgoraVocationalUIScene alloc] initWithContextPool:pool
                                                                                    delegate:manager];
            vc.cdnType = cdnType;
            scene = vc;
        }
        
        [FcrWidgetUIContext createWith:FcrWidgetUISceneTypeVocation];
        
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

+ (void)setDelegate:(id<AgoraEduClassroomSDKDelegate> _Nullable)delegate {
    manager.delegate = delegate;
}

+ (void)exit {
    [manager.core exit];
    
    __weak AgoraClassroomSDK *weakManager = manager;
    
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
    
    [FcrWidgetUIContext desctory];
}

#pragma mark - FcrUISceneDelegate
- (void)scene:(FcrUIScene *)scene
      didExit:(FcrUISceneExitReason)reason {
    AgoraEduExitReason sdkReason = AgoraEduExitReasonNormal;

    switch (reason) {
        case FcrUISceneExitReasonNormal:
            sdkReason = AgoraEduExitReasonNormal;
            break;
        case FcrUISceneExitReasonKickOut:
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
