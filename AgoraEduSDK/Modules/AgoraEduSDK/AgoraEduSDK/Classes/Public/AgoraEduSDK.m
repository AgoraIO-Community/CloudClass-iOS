//
//  AgoraEduSDK.m
//  AgoraEduSDK
//
//  Created by SRS on 2021/1/5.
//

#import "AgoraEduSDK.h"
#import "AgoraEduManager.h"
#import "AgoraBaseViewController.h"
#import "Agora1V1ViewController.h"
#import "UIView+AgoraEduToast.h"
#import "AgoraEduTopVC.h"
#import "AgoraEyeCareModeUtil.h"
#import "AgoraEduKeyCenter.h"
#import "AgoraEduReplayConfiguration.h"
#import <YYModel/YYModel.h>

#import <AgoraEduSDK/AgoraEduSDK-Swift.h>

AgoraUserView *teaView;
AgoraUserView *stuView;

#define NoNullString(x) ([x isKindOfClass:NSString.class] ? x : @"")
#define NoNullObjectString(x) ((x == nil) ? @"" : @"NoNull")

@interface AgoraEduSDK ()
@end

@implementation AgoraEduSDK
+ (void)setBaseURL:(NSString *)baseURL {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    SEL sel = NSSelectorFromString(@"setBaseURL:");
    if ([AgoraRTEManager respondsToSelector:sel]) {
        [AgoraRTEManager performSelector:sel withObject:baseURL];
    }
#pragma clang diagnostic pop
    
    [AgoraHTTPManager setBaseURL:baseURL];
}
+ (void)setLogConsoleState:(NSNumber *)num {
    [AgoraEduManager.shareManager setLogConsoleState:num.boolValue];
}

+ (void)setConfig:(AgoraEduSDKConfig *)config {
    // 校验
    NSString *msg = [AgoraEduSDK validateEmptyMsg:@{@"config":NoNullObjectString(config),
                        @"appId":NoNullString([config appId])}];
    if(msg.length > 0){
        [AgoraEduSDK showToast:msg];
        return;
    }
    
    AgoraEduKeyCenter.agoraAppid = config.appId;
    [[AgoraEyeCareModeUtil sharedUtil] switchEyeCareMode:config.eyeCare];
}
+ (AgoraEduClassroom * _Nullable)launch:(AgoraEduLaunchConfig *)config delegate:(id<AgoraEduClassroomDelegate> _Nullable)delegate {
    
//    [AgoraEduSDK test];
//    return nil;
    
    // 校验
    if(NoNullString(AgoraEduKeyCenter.agoraAppid).length == 0) {
        NSString *msg = [NSString stringWithFormat:@"%@%@", AgoraEduLocalizedString(@"NeedCallText", nil), @"`setConfig:`"];
        [AgoraEduSDK showToast:msg];
        return nil;
    }

    NSString *msg = [AgoraEduSDK validateEmptyMsg:@{@"config":NoNullObjectString(config),
                        @"userName":NoNullString([config userName]),
                        @"userUuid":NoNullString([config userUuid]),
                        @"roomName":NoNullString([config roomName]),
                        @"roomName":NoNullString([config roomUuid])}];
    if(msg.length > 0){
        [AgoraEduSDK showToast:msg];
        return nil;
    }
    
    if (config.roomType != AgoraEduRoomType1V1 &&
        config.roomType != AgoraEduRoomTypeSmall &&
        config.roomType != AgoraEduRoomTypeBig) {
        NSString *msg = [NSString stringWithFormat:@"%@%@", @"roomType", AgoraEduLocalizedString(@"ParamErrorText", nil)];
        [AgoraEduSDK showToast:msg];
        return nil;
    }
    
    // 只能调用一次
    if (AgoraEduManager.shareManager.classroom != nil) {
        [AgoraEduSDK showToast:AgoraEduLocalizedString(@"DuplicateLaunchText", nil)];
        return nil;
    }
    AgoraEduManager.shareManager.classroom = [AgoraEduClassroom new];
    AgoraEduManager.shareManager.classroomDelegate = delegate;
    AgoraEduManager.shareManager.token = NoNullString(config.token);
    
    AgoraRoomConfiguration *roomConfig = [AgoraRoomConfiguration new];
    roomConfig.appId = AgoraEduKeyCenter.agoraAppid;
    roomConfig.userUuid = config.userUuid;
    roomConfig.token = config.token;
    [AgoraHTTPManager getConfig:roomConfig success:^(AgoraConfigModel * _Nonnull model) {

        AgoraEduKeyCenter.boardAppid = model.data.netless.appId;
        [AgoraEduSDK joinSDKWithConfig:config appConfigModel:model];

    } failure:^(NSError * _Nonnull error, NSInteger statusCode) {
        [AgoraEduManager releaseResource];
        [AgoraEduSDK showToast:error.localizedDescription];
    }];
    
    return AgoraEduManager.shareManager.classroom;
}

+ (AgoraEduReplay * _Nullable)replay:(AgoraEduReplayConfig *)config delegate:(id<AgoraEduReplayDelegate> _Nullable)delegate {
    
    Class class = Agora_Replay_Class;
    if (class == nil) {
        return nil;
    }
    

    NSString *msg = [AgoraEduSDK validateEmptyMsg:@{@"config":NoNullObjectString(config),
                        @"whiteBoardAppId":NoNullString([config whiteBoardAppId]),
                        @"whiteBoardId":NoNullString([config whiteBoardId]),
                        @"whiteBoardToken":NoNullString([config whiteBoardToken]),
                        @"videoUrl":NoNullString([config videoUrl])}];
    if(msg.length > 0){
        [AgoraEduSDK showToast:msg];
        return nil;
    }
    if (@(config.beginTime).stringValue.length != 13) {
        NSString *msg = [NSString stringWithFormat:@"%@%@", @"beginTime", AgoraEduLocalizedString(@"ParamErrorText", nil)];
        [AgoraEduSDK showToast:msg];
        return nil;
    }
    if (@(config.endTime).stringValue.length != 13) {
        NSString *msg = [NSString stringWithFormat:@"%@%@", @"endTime", AgoraEduLocalizedString(@"ParamErrorText", nil)];
        [AgoraEduSDK showToast:msg];
        return nil;
    }
    
    // 只能调用一次
    if (AgoraEduManager.shareManager.replay != nil) {
        [AgoraEduSDK showToast:AgoraEduLocalizedString(@"DuplicateLaunchText", nil)];
        return nil;
    }
    AgoraEduManager.shareManager.replay = [AgoraEduReplay new];
    AgoraEduManager.shareManager.replayDelegate = delegate;

    /// ReplayConfiguration
    AgoraEduBoardConfiguration *boardConfig = [AgoraEduBoardConfiguration new];
    boardConfig.boardId = config.whiteBoardId;
    boardConfig.boardToken = config.whiteBoardToken;
    boardConfig.boardAppid = config.whiteBoardAppId;

    AgoraEduVideoConfiguration *videoConfig = [AgoraEduVideoConfiguration new];
    videoConfig.urlString = config.videoUrl;
    
    AgoraEduReplayConfiguration *replayConfig = [AgoraEduReplayConfiguration new];
    replayConfig.boardConfig = boardConfig;
    replayConfig.videoConfig = videoConfig;
    replayConfig.startTime = @(config.beginTime).stringValue;
    replayConfig.endTime = @(config.endTime).stringValue;
    
    NSBundle *replayBundle = [NSBundle bundleForClass:class];
    UIViewController *vc = [[class alloc] initWithNibName:@"ReplayViewController" bundle:replayBundle];
    id obj = [replayConfig yy_modelToJSONObject];
    [vc setValue:obj forKey:@"configParams"];
    [vc setValue:AgoraEduManager.shareManager.replay forKey:@"replayDelegate"];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;

    [AgoraEduTopVC.topVC presentViewController:vc animated:YES completion:^{
        
        if ([AgoraEduManager.shareManager.replayDelegate respondsToSelector:@selector(replay:didReceivedEvent:)]) {
            [AgoraEduManager.shareManager.replayDelegate replay:AgoraEduManager.shareManager.replay didReceivedEvent:AgoraEduEventReady];
        }
    }];
    return AgoraEduManager.shareManager.replay;
}

+ (NSString *)version {
    return @"1.0.0";
}

#pragma mark joinSDKWithConfig
+ (void)joinSDKWithConfig:(AgoraEduLaunchConfig *)config appConfigModel:(AgoraConfigModel *)model {
    
    NSString *roomUuid = config.roomUuid;
    NSString *roomName = config.roomName;
    NSString *userUuid = config.userUuid;
    NSString *userName = config.userName;
    AgoraRTESceneType sceneType = (AgoraRTESceneType)config.roomType;
    
    AgoraRoomStateConfiguration *roomStateConfig = [AgoraRoomStateConfiguration new];
    roomStateConfig.appId = AgoraEduKeyCenter.agoraAppid;
    
    roomStateConfig.roomName = roomName;
    roomStateConfig.roomUuid = roomUuid;
    roomStateConfig.roomType = sceneType;
    roomStateConfig.role = config.roleType;
    roomStateConfig.userUuid = userUuid;
    roomStateConfig.token = AgoraEduManager.shareManager.token;

    [AgoraEduManager.shareManager initWithUserUuid:userUuid userName:userName tag:sceneType success:^{
        
        [AgoraEduManager.shareManager queryRoomStateWithConfig:roomStateConfig success:^{
        
            if(sceneType == AgoraRTESceneType1V1) {
                if(IsPad){
                    [AgoraEduSDK joinRoomWithIdentifier:@"oneToOneRoom-iPad" config:config appConfigModel:model];
                } else {
                    [AgoraEduSDK joinRoomWithIdentifier:@"oneToOneRoom" config:config appConfigModel:model];
                }
            } else if(sceneType == AgoraRTESceneTypeSmall) {
                if(IsPad){
                    [AgoraEduSDK joinRoomWithIdentifier:@"smallRoom-iPad" config:config appConfigModel:model];
                } else {
                    [AgoraEduSDK joinRoomWithIdentifier:@"smallRoom" config:config appConfigModel:model];
                }
            } else if(sceneType == AgoraRTESceneTypeBig) {
                if(IsPad){
                    [AgoraEduSDK joinRoomWithIdentifier:@"bigRoom-iPad" config:config appConfigModel:model];
                } else {
                    [AgoraEduSDK joinRoomWithIdentifier:@"bigRoom" config:config appConfigModel:model];
                }
            } else if(sceneType == AgoraRTESceneTypeBreakout) {
                if(IsPad){
                   [AgoraEduSDK joinRoomWithIdentifier:@"boRoom-iPad" config:config appConfigModel:model];
                } else {
                   [AgoraEduSDK joinRoomWithIdentifier:@"boRoom" config:config appConfigModel:model];
                }
            } else if(sceneType == AgoraRTESceneTypeMedium) {
                [AgoraEduSDK joinRoomWithIdentifier:@"groupRoom" config:config appConfigModel:model];
            }

        } failure:^(NSString * _Nonnull errorMsg) {
            [AgoraEduManager releaseResource];
            [AgoraEduSDK showToast:errorMsg];
        }];
    
    } failure:^(NSString * _Nonnull errorMsg) {
        [AgoraEduManager releaseResource];
        [AgoraEduSDK showToast:errorMsg];
    }];
}

+ (void)joinRoomWithIdentifier:(NSString*)identifier config:(AgoraEduLaunchConfig *)config appConfigModel:(AgoraConfigModel *)model {

    NSString *roomUuid = config.roomUuid;
    NSString *roomName = config.roomName;
    NSString *userUuid = config.userUuid;
    NSString *userName = config.userName;
    AgoraRTESceneType sceneType = (AgoraRTESceneType)config.roomType;
    
    Agora1V1ViewController *vc = [[Agora1V1ViewController alloc] init];
//    NSBundle *bundle = AgoraEduBundle;
//    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Room" bundle:bundle];
//    AgoraBaseViewController *vc = [story instantiateViewControllerWithIdentifier:identifier];
    vc.sceneType = sceneType;
    vc.className = roomName;
    vc.roomUuid = roomUuid;
    vc.userUuid = userUuid;
    vc.userName = userName;
    vc.boardId = model.data.netless.appId;
    vc.boardToken = model.data.netless.token;
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    
    [AgoraEduTopVC.topVC presentViewController:vc animated:YES completion:^{
        
        if ([AgoraEduManager.shareManager.classroomDelegate respondsToSelector:@selector(classroom:didReceivedEvent:)]) {
            [AgoraEduManager.shareManager.classroomDelegate classroom:AgoraEduManager.shareManager.classroom didReceivedEvent:AgoraEduEventReady];
        }
    }];
}

#pragma mark Private
+ (NSString *)validateEmptyMsg:(NSDictionary<NSString *,NSString *> *)dictionary {
    for(NSString *key in dictionary.allKeys) {
        if(dictionary[key].length == 0) {
            NSString *msg = [NSString stringWithFormat:@"%@%@", key, AgoraEduLocalizedString(@"NoEmptyText", nil)];
            return msg;
        }
    }
    return @"";
}

+ (void)showToast:(NSString *)msg {
    [[UIApplication sharedApplication].windows.firstObject makeToast:msg];
}

+ (void)test {
    UIView *view = AgoraEduTopVC.topVC.view;
    
    MenuConfig *config1 = [MenuConfig new];
    config1.imageName = @"camera_switch";
    config1.touchBlock = ^{
        NSLog(@"camera_switch");
    };
    
    MenuConfig *config2 = [MenuConfig new];
    config2.imageName = @"cs";
    config2.touchBlock = ^{
        NSLog(@"cs");
    };
    
    AgoraToolView *toolView = [[AgoraToolView alloc] initWithMenuConfigs:@[config1, config2]];
    [view addSubview:toolView];
    toolView.safeX = 0;
    toolView.safeY = 0;
    toolView.safeRight = 0;
    toolView.height = IsPad ? 77 : 40;
    toolView.leftTouchBlock = ^{
        
    };
    
    CGFloat top = toolView.height + 5;
    CGFloat right = 5;
    CGFloat width = 180;
    CGFloat height = 128;
    CGFloat minGap = 8;
    CGFloat minRight = 15;
    CGFloat minBottom = 15;
    CGFloat minHeight = 27;
    CGFloat minWidth = 130;
    if(IsPad) {
        top = toolView.height + 9;
        right = 20;
        width = 319;
        height = 228;
        minGap = 12;
        minRight = 30;
        minBottom = 25;
        minHeight = 49;
        minWidth = 230;
    }
    
    AgoraUserView *vv = [[AgoraUserView alloc] init];
    [view addSubview:vv];
    teaView = vv;
    vv.safeY = top;
    vv.right = right;
    vv.width = width;
    vv.height = height;

    vv.audioTouchBlock = ^(BOOL mute) {
        NSLog(@"Srs audio mute:%d", mute);
    };
    vv.videoTouchBlock = ^(BOOL mute) {
        NSLog(@"Srs video mute:%d", mute);
    };
    WEAK(self);
    vv.scaleTouchBlock = ^(BOOL isMin) {

        if (isMin) {
            [vv clearConstraint];
            
            vv.bottom = stuView.isMin ? minGap + minHeight + minBottom : minBottom;
            vv.right = minRight;
            vv.width = minWidth;
            vv.height = minHeight;
            
        } else {
            [vv clearConstraint];
            vv.safeY = top;
            vv.right = right;
            vv.width = width;
            vv.height = height;
        }
        
        [UIView animateWithDuration:0.35 animations:^{
            [view layoutIfNeeded];
        }];
    };

    AgoraUserView *vvv = [[AgoraUserView alloc] init];
    [view addSubview:vvv];
    stuView = vvv;

    vvv.safeY = top + height + 10;
    vvv.right = right;
    vvv.width = width;
    vvv.height = height;
    
    vvv.audioTouchBlock = ^(BOOL mute) {
        NSLog(@"Srs audio mute:%d", mute);
    };
    vvv.videoTouchBlock = ^(BOOL mute) {
        NSLog(@"Srs video mute:%d", mute);
    };
 
    vvv.scaleTouchBlock = ^(BOOL isMin) {

        if (isMin) {
            [vvv clearConstraint];
            vvv.bottom = minBottom;
            vvv.right = minRight;
            vvv.width = minWidth;
            vvv.height = minHeight;
            
            if(teaView.isMin) {
                teaView.bottom = stuView.isMin ? minGap + minHeight + minBottom: minBottom;
            }
            
        } else {
            [vvv clearConstraint];
            vvv.safeY = top + 10 + height;
            vvv.right = right;
            vvv.width = width;
            vvv.height = height;
        }
        
        [UIView animateWithDuration:0.35 animations:^{
            [view layoutIfNeeded];
        }];
    };
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [vv updateView];
//        [vvv updateView];
        [toolView updateView];
    });
}

@end
