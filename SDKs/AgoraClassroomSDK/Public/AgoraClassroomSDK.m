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
#import "AgoraEduEnums.h"

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
    [self coreLaunchWithConfig:config
                       success:^(id<AgoraEduContextPool> pool) {
        FcrUIScene *scene = nil;
         
        switch (config.roomType) {
            case FcrUISceneTypeOneToOne:
                [FcrUIContext createWith:FcrUISceneTypeOneToOne];
                [FcrWidgetUIContext createWith:FcrWidgetUISceneTypeOneToOne];
                
                scene = [[FcrOneToOneUIScene alloc] initWithContextPool:pool
                                                               delegate:manager];
                break;
            case FcrUISceneTypeSmall:
                [FcrUIContext createWith:FcrUISceneTypeSmall];
                [FcrWidgetUIContext createWith:FcrWidgetUISceneTypeSmall];
                
                scene = [[FcrSmallUIScene alloc] initWithContextPool:pool
                                                            delegate:manager];
                break;
            case FcrUISceneTypeLecture:
                [FcrUIContext createWith:FcrUISceneTypeLecture];
                [FcrWidgetUIContext createWith:FcrWidgetUISceneTypeLecture];
                
                scene = [[FcrLectureUIScene alloc] initWithContextPool:pool
                                                              delegate:manager];
            default:
                NSCAssert(true,
                          @"room type error");
                break;
        }
        
        [self presentUIScene:scene
                     success:success];
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
+ (void)coreLaunchWithConfig:(AgoraEduLaunchConfig *)config
                     success:(void (^)(id<AgoraEduContextPool> pool))success
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
    
    if (manager.core) {
        if (failure) {
            NSError *error = [[NSError alloc] initWithDomain:@"last launch not finished"
                                                        code:-1
                                                    userInfo:nil];
            failure(error);
        }
        
        return;
    }
    
    AgoraClassroomSDK *manager = [AgoraClassroomSDK share];
    
    AgoraEduCorePuppetLaunchConfig *coreConfig = [self getPuppetLaunchConfig:config];
    AgoraEduCorePuppet *core = [[AgoraEduCorePuppet alloc] init:coreConfig
                                                        widgets:config.widgets.allValues];
    
    manager.core = core;
    
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
    
    __weak AgoraClassroomSDK *weakManager = manager;
    
    [core launch:success
         failure:^(NSError * _Nonnull error) {
            
        weakManager.core = nil;
        
        if (failure) {
            failure(error);
        }
    }];
}

+ (void)presentUIScene:(FcrUIScene *)scene
               success:(void (^)(void))success {
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
}

- (void)agoraRelease {
    self.delegate = nil;
    self.scene = nil;
    self.core = nil;
    
    [FcrUIContext destroy];
    [FcrWidgetUIContext destroy];
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
