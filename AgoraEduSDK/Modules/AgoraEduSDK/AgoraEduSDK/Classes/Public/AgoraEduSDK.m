//
//  AgoraEduSDK.m
//  AgoraEduSDK
//
//  Created by SRS on 2021/1/5.
//

#import "AgoraEduSDK.h"
#import "AgoraEduManager.h"
#import "AgoraBaseViewController.h"
#import "UIView+AgoraEduToast.h"
#import "AgoraEduTopVC.h"
#import "EyeCareModeUtil.h"
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
    if ([EduManager respondsToSelector:sel]) {
        [EduManager performSelector:sel withObject:baseURL];
    }
#pragma clang diagnostic pop
    
    [AppHTTPManager setBaseURL:baseURL];
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
    [[EyeCareModeUtil sharedUtil] switchEyeCareMode:config.eyeCare];
}
+ (AgoraEduClassroom * _Nullable)launch:(AgoraEduLaunchConfig *)config delegate:(id<AgoraEduClassroomDelegate> _Nullable)delegate {
    
    [AgoraEduSDK test];
    return nil;
    
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
    
    RoomConfiguration *roomConfig = [RoomConfiguration new];
    roomConfig.appId = AgoraEduKeyCenter.agoraAppid;
    roomConfig.userUuid = config.userUuid;
    roomConfig.token = config.token;
    [AppHTTPManager getConfig:roomConfig success:^(AppConfigModel * _Nonnull model) {

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
+ (void)joinSDKWithConfig:(AgoraEduLaunchConfig *)config appConfigModel:(AppConfigModel *)model {
    
    NSString *roomUuid = config.roomUuid;
    NSString *roomName = config.roomName;
    NSString *userUuid = config.userUuid;
    NSString *userName = config.userName;
    EduSceneType sceneType = (EduSceneType)config.roomType;
    
    RoomStateConfiguration *roomStateConfig = [RoomStateConfiguration new];
    roomStateConfig.appId = AgoraEduKeyCenter.agoraAppid;
    
    roomStateConfig.roomName = roomName;
    roomStateConfig.roomUuid = roomUuid;
    roomStateConfig.roomType = sceneType;
    roomStateConfig.role = config.roleType;
    roomStateConfig.userUuid = userUuid;
    roomStateConfig.token = AgoraEduManager.shareManager.token;

    [AgoraEduManager.shareManager initWithUserUuid:userUuid userName:userName tag:sceneType success:^{
        
        [AgoraEduManager.shareManager queryRoomStateWithConfig:roomStateConfig success:^{
        
            if(sceneType == EduSceneType1V1) {
                if(IsPad){
                    [AgoraEduSDK joinRoomWithIdentifier:@"oneToOneRoom-iPad" config:config appConfigModel:model];
                } else {
                    [AgoraEduSDK joinRoomWithIdentifier:@"oneToOneRoom" config:config appConfigModel:model];
                }
            } else if(sceneType == EduSceneTypeSmall) {
                if(IsPad){
                    [AgoraEduSDK joinRoomWithIdentifier:@"smallRoom-iPad" config:config appConfigModel:model];
                } else {
                    [AgoraEduSDK joinRoomWithIdentifier:@"smallRoom" config:config appConfigModel:model];
                }
            } else if(sceneType == EduSceneTypeBig) {
                if(IsPad){
                    [AgoraEduSDK joinRoomWithIdentifier:@"bigRoom-iPad" config:config appConfigModel:model];
                } else {
                    [AgoraEduSDK joinRoomWithIdentifier:@"bigRoom" config:config appConfigModel:model];
                }
            } else if(sceneType == EduSceneTypeBreakout) {
                if(IsPad){
                   [AgoraEduSDK joinRoomWithIdentifier:@"boRoom-iPad" config:config appConfigModel:model];
                } else {
                   [AgoraEduSDK joinRoomWithIdentifier:@"boRoom" config:config appConfigModel:model];
                }
            } else if(sceneType == EduSceneTypeMedium) {
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

+ (void)joinRoomWithIdentifier:(NSString*)identifier config:(AgoraEduLaunchConfig *)config appConfigModel:(AppConfigModel *)model {

    NSString *roomUuid = config.roomUuid;
    NSString *roomName = config.roomName;
    NSString *userUuid = config.userUuid;
    NSString *userName = config.userName;
    EduSceneType sceneType = (EduSceneType)config.roomType;
    NSBundle *bundle = AgoraEduBundle;
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Room" bundle:bundle];
    AgoraBaseViewController *vc = [story instantiateViewControllerWithIdentifier:identifier];
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
    
    AgoraUserView *vv = [[AgoraUserView alloc] init];
    [view addSubview:vv];
    teaView = vv;
    vv.y = 40;
    vv.right = 0;
    vv.width = 283;
    vv.height = 205;

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
            
            vv.bottom = stuView.isMin ? 20 + 45 + 20 : 20;
            vv.right = 30;
            vv.width = 152;
            vv.height = 45;

        } else {
            [vv clearConstraint];
            vv.y = 40;
            vv.right = 0;
            vv.width = 283;
            vv.height = 205;
        }
        
        [UIView animateWithDuration:0.35 animations:^{
            [view layoutIfNeeded];
        }];
    };

    AgoraUserView *vvv = [[AgoraUserView alloc] init];
    [view addSubview:vvv];
    stuView = vvv;
    vvv.y = 205 + 40 + 10;
    vvv.right = 0;
    vvv.width = 283;
    vvv.height = 205;

    vvv.audioTouchBlock = ^(BOOL mute) {
        NSLog(@"Srs audio mute:%d", mute);
    };
    vvv.videoTouchBlock = ^(BOOL mute) {
        NSLog(@"Srs video mute:%d", mute);
    };
 
    vvv.scaleTouchBlock = ^(BOOL isMin) {

        if (isMin) {
            [vvv clearConstraint];
            vvv.bottom = 20;
            vvv.right = 30;
            vvv.width = 152;
            vvv.height = 45;
            
            if(teaView.isMin) {
                teaView.bottom = stuView.isMin ? 20 + 45 + 20 : 20;
            }
            
        } else {
            [vvv clearConstraint];
            vvv.y = 205 + 40 + 10;
            vvv.right = 0;
            vvv.width = 283;
            vvv.height = 205;
        }
        
        [UIView animateWithDuration:0.35 animations:^{
            [view layoutIfNeeded];
        }];
    };
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [vv updateView];
        [vvv updateView];
    });
}


@end
