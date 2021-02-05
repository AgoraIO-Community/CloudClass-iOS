//
//  Agora1V1ViewController.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/10/30.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "Agora1V1ViewController.h"
#import "AgoraEENavigationView.h"
#import "AgoraEEChatTextFiled.h"
#import "AgoraEEMessageView.h"
#import "AgoraOTOTeacherView.h"
#import "AgoraOTOStudentView.h"
#import "UIView+AgoraEduToast.h"
#import "AgoraBoardTouchView.h"
#import "AgoraHTTPManager.h"
#import <YYModel/YYModel.h>
#import "AgoraRTEStream+StreamState.h"
#import <EduSDK/AgoraRTCManager.h>
#import "AgoraEduKeyCenter.h"

#import <AgoraEduSDK/AgoraEduSDK-Swift.h>

#define AgoraVideoPhoneWScale 0.29
#define AgoraVideoPhoneWHScale 1.46
#define AgoraVideoPhonePageWMax 228
#define AgoraVideoPhoneChatWScale 0.25

@interface Agora1V1ViewController ()<UITextFieldDelegate, AgoraRTEClassroomDelegate, AgoraRTEStudentDelegate, AgoraRTEMediaStreamDelegate, AgoraPageControlProtocol, WhiteManagerDelegate>

@property (weak, nonatomic) AgoraBaseUIImageView *bgView;
@property (weak, nonatomic) AgoraBaseView *contentView;
@property (weak, nonatomic) AgoraToolView *toolView;
@property (weak, nonatomic) AgoraUserView *teaView;
@property (weak, nonatomic) AgoraUserView *stuView;
@property (weak, nonatomic) AgoraBaseView *boardContentView;
@property (weak, nonatomic) AgoraPageControlView *boardPageControlView;
@property (weak, nonatomic) AgoraChatPanelView *chatPanelView;
@property (weak, nonatomic) AgoraBoardToolsView *boardToolsView;

// cache
@property (assign, nonatomic) CGFloat boardRight;
@property (assign, nonatomic) BOOL boardMax;


@property (nonatomic, weak) AgoraBoardTouchView *whiteBoardTouchView;

@end

@implementation Agora1V1ViewController
- (void)viewDidLoad {
    [super viewDidLoad];

    [self initView];
    [self initLayout];
    [self initData];
}

- (void)initData {

    AgoraEduManager.shareManager.studentService.mediaStreamDelegate = self;
    
    WEAK(self);
    [self.toolView updateClassID: self.roomUuid];
    self.toolView.leftTouchBlock = ^{
        [AgoraEduAlertViewUtil showAlertWithController:weakself title:AgoraEduLocalizedString(@"QuitClassroomText", nil) sureHandler:^(UIAlertAction * _Nullable action) {
 
            [AgoraEduManager releaseResource];
            [weakself dismissViewControllerAnimated:YES completion:nil];
        }];
    };
    
    self.stuView.audioTouchBlock = ^(BOOL mute) {
        
        AgoraRTEStream *stream = weakself.localUser.streams.firstObject;
        [weakself setLocalStreamVideo:stream.hasVideo audio:!mute streamState:LocalStreamStateUpdate];
    };
    self.stuView.videoTouchBlock = ^(BOOL mute) {
        AgoraRTEStream *stream = weakself.localUser.streams.firstObject;
        [weakself setLocalStreamVideo:!mute audio:stream.hasAudio streamState:LocalStreamStateUpdate];
    };
}

- (void)lockViewTransform:(BOOL)lock {
    
    [AgoraEduManager.shareManager.whiteBoardManager lockViewTransform:lock];
    
    self.whiteBoardTouchView.hidden = !lock;
}
- (void)initLayout {
    //-----
    self.bgView.agora_x = 0;
    self.bgView.agora_y = 0;
    self.bgView.agora_right = 0;
    self.bgView.agora_bottom = 0;
    
    // contentView
    self.contentView.agora_safe_x = 0;
    self.contentView.agora_safe_y = 0;
    self.contentView.agora_safe_right = 0;
    self.contentView.agora_safe_bottom = 0;
    
    // tool
    self.toolView.agora_x = 0;
    self.toolView.agora_y = 0;
    self.toolView.agora_right = 0;
    self.toolView.agora_height = IsPad ? 77 : 44;

    // teacher & student
    CGFloat top = self.toolView.agora_height + 10;
    CGFloat topGap = 5;
    CGFloat right = 10;
    CGFloat width = MAX(kScreenWidth, kScreenHeight) * AgoraVideoPhoneWScale;
    CGFloat height = width / AgoraVideoPhoneWHScale;
    CGFloat minGap = 8;
    CGFloat minRight = 15;
    CGFloat minBottom = 15;
    CGFloat minHeight = 31;
    CGFloat minWidth = 140;
    if(IsPad) {
        top = self.toolView.agora_height + 15;
        topGap = 10;
        right = 20;
        width = 319;
        height = 228;
        minGap = 12;
        minRight = 30;
        minBottom = 25;
        minHeight = 49;
        minWidth = 230;
    }
    
    CGFloat maxVideoHeight = (MIN(kScreenWidth, kScreenHeight) - 25 - topGap - top) * 0.5;
    if(height > maxVideoHeight) {
        height = maxVideoHeight;
        width = height * AgoraVideoPhoneWHScale;
    }
    
    WEAK(self);
    self.teaView.agora_y = top;
    self.teaView.agora_right = right;
    self.teaView.agora_width = width;
    self.teaView.agora_height = height;
    self.teaView.scaleTouchBlock = ^(BOOL isMin) {
        [weakself.teaView agora_clear_constraint];
        if (isMin) {
            weakself.teaView.agora_bottom = weakself.stuView.isMin ? minGap + minHeight + minBottom : minBottom;
            weakself.teaView.agora_right = minRight;
            weakself.teaView.agora_width = minWidth;
            weakself.teaView.agora_height = minHeight;

            // adjust stuview layout
            if (!weakself.stuView.isMin) {
                CGFloat differ = [weakself getStudentDiffer:minBottom];
                if (differ > 0) {
                    weakself.stuView.agora_y -= abs(differ);
                }
            }

        } else {
            weakself.teaView.agora_y = top;
            weakself.teaView.agora_right = right;
            weakself.teaView.agora_width = width;
            weakself.teaView.agora_height = height;

            if (!weakself.stuView.isMin) {
                CGFloat stuViewY = top + 10 + height;
                weakself.stuView.agora_y = stuViewY;
            }
        }
        [UIView animateWithDuration:0.35 animations:^{
            [weakself.view layoutIfNeeded];
        }];
    };

    self.stuView.agora_y = top + height + topGap;
    self.stuView.agora_right = right;
    self.stuView.agora_width = width;
    self.stuView.agora_height = height;
    self.stuView.scaleTouchBlock = ^(BOOL isMin) {
        [weakself.stuView agora_clear_constraint];
        if (isMin) {
            weakself.stuView.agora_bottom = minBottom;
            weakself.stuView.agora_right = minRight;
            weakself.stuView.agora_width = minWidth;
            weakself.stuView.agora_height = minHeight;
            if (weakself.teaView.isMin) {
                weakself.teaView.agora_bottom = weakself.stuView.isMin ? minGap + minHeight + minBottom: minBottom;
            }
        } else {
            if (weakself.teaView.isMin) {
                weakself.teaView.agora_bottom = weakself.stuView.isMin ? minGap + minHeight + minBottom : minBottom;
            }

            CGFloat stuViewY = top + 10 + height;
            weakself.stuView.agora_right = right;
            weakself.stuView.agora_width = width;
            weakself.stuView.agora_height = height;
            weakself.stuView.agora_y = top + height + topGap;
            
            // adjust stuview layout
            if (weakself.teaView.isMin) {
                CGFloat differ = [weakself getStudentDiffer:minBottom];
                if (differ > 0) {
                    weakself.stuView.agora_y -= abs(differ);
                }
            }
        }
        [UIView animateWithDuration:0.35 animations:^{
            [weakself.view layoutIfNeeded];
        }];
    };
    
    //board
    self.boardContentView.agora_x = 0;
    self.boardContentView.agora_right = IsPad ? right + width + 20 : right + width + 10;
    self.boardRight = self.boardContentView.agora_right;
    self.boardContentView.agora_y = self.teaView.agora_y;
    self.boardContentView.agora_bottom = 0;

    // boardView
    [self.boardView equalTo:self.boardContentView];

    // boardToolsView
    self.boardToolsView.agora_x = 10;
    self.boardToolsView.agora_y = self.toolView.agora_height;
    self.boardToolsView.agora_width = 100;
    
    // boardPageControlView
    self.boardPageControlView.agora_x = IsPad ? 20 : 10;
    self.boardPageControlView.agora_height = IsPad ? 42 : 27;
    self.boardPageControlView.agora_bottom = IsPad ? 20 : 10;
    self.boardPageControlView.agora_width = IsPad ? AgoraVideoPhonePageWMax + 50 : AgoraVideoPhonePageWMax;

    // chatPanelView
    CGFloat chatPanelViewMaxWidth = IsPad ? 246 : MAX(kScreenWidth, kScreenHeight) * AgoraVideoPhoneChatWScale;
    CGFloat chatPanelViewMinWidth = IsPad ? 44 : 28;
    CGFloat chatPanelViewMaxHeight = IsPad ? 362 : MIN(kScreenWidth, kScreenHeight) - top - 30;
    if (@available(iOS 11.0, *)) {
        UIEdgeInsets safeAreaInsets =  UIApplication.sharedApplication.keyWindow.safeAreaInsets;
        if (safeAreaInsets.left > 0.0 || safeAreaInsets.top > 0.0 || safeAreaInsets.right > 0.0 || safeAreaInsets.bottom > 0.0) {
            chatPanelViewMaxHeight -= 34;
        }
    }
    
    CGFloat chatPanelViewMinHeight = IsPad ? 44 : 28;

    self.chatPanelView.agora_width = chatPanelViewMaxWidth;
    self.chatPanelView.agora_height = chatPanelViewMaxHeight;
    self.chatPanelView.agora_bottom = self.boardPageControlView.agora_bottom;
    self.chatPanelView.agora_right = self.boardContentView.agora_right + 20;
    self.chatPanelView.scaleTouchBlock = ^(BOOL isMin) {
        weakself.chatPanelView.agora_width = isMin ? chatPanelViewMinWidth : chatPanelViewMaxWidth;
        weakself.chatPanelView.agora_height = isMin ? chatPanelViewMinHeight : chatPanelViewMaxHeight;
        [UIView animateWithDuration:0.35 animations:^{
            [weakself.view layoutIfNeeded];
        }];
    };
    
    // reset page controle
    CGFloat pageControlMaxWidth = MAX(kScreenWidth, kScreenHeight) - (self.chatPanelView.agora_right + self.chatPanelView.agora_width) - 20;
    if (pageControlMaxWidth < self.boardPageControlView.agora_width) {
        self.boardPageControlView.agora_width = pageControlMaxWidth;
    }
}

- (void)initView {
   
    UIImage *image = AgoraEduImageWithName(@"bg_1v1");
    AgoraBaseUIImageView *imgView = [[AgoraBaseUIImageView alloc] initWithImage:image];
    [self.view addSubview:imgView];
    self.bgView = imgView;
    
    // contentView
    AgoraBaseView *contentView = [[AgoraBaseView alloc] init];
    [self.view addSubview:contentView];
    self.contentView = contentView;

    // whitboard
    AgoraBaseView *boardContentView = [[AgoraBaseView alloc] init];
    boardContentView.clipsToBounds = YES;
    boardContentView.layer.cornerRadius = IsPad ? 15 : 10;
    boardContentView.layer.borderColor = [UIColor colorWithHex:0x75C0FF].CGColor;
    boardContentView.layer.borderWidth = IsPad ? 10 : 7;
    [self.contentView addSubview:boardContentView];
    self.boardContentView = boardContentView;

    WhiteBoardManager *whiteBoardManager = AgoraEduManager.shareManager.whiteBoardManager;
    UIView *boardView = [whiteBoardManager getBoardView];
    [self.boardContentView addSubview:boardView];
    self.boardView = boardView;

    // tool
    MenuConfig *cameraSwitch = [MenuConfig new];
    cameraSwitch.imageName = @"camera_switch";
    cameraSwitch.touchBlock = ^{
        [AgoraRTCManager.shareManager switchCamera];
    };
    MenuConfig *cs = [MenuConfig new];
    cs.imageName = @"cs";
    cs.touchBlock = ^{
        NSLog(@"cs");
    };
    AgoraToolView *toolView = [[AgoraToolView alloc] initWithMenuConfigs:@[cameraSwitch, cs]];
    [self.contentView addSubview:toolView];
    self.toolView = toolView;
    
    // teacher & student
    {
        AgoraUserView *teacherView = [[AgoraUserView alloc] init];
        [self.contentView addSubview:teacherView];
        self.teaView = teacherView;

        AgoraUserView *studentView = [[AgoraUserView alloc] init];
        [self.contentView addSubview:studentView];
        self.stuView = studentView;
    }

    // boardToolsView
    AgoraBoardToolsView *boardToolsView = [[AgoraBoardToolsView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:boardToolsView];
    self.boardToolsView = boardToolsView;
    
    // page control
    AgoraPageControlView *pageControlView = [[AgoraPageControlView alloc] initWithDelegate:self];
    pageControlView.hidden = YES;
    [self.contentView addSubview:pageControlView];
    self.boardPageControlView = pageControlView;
    
    // chat view
    AgoraHTTPConfig *config = [AgoraHTTPConfig new];
    config.appId = AgoraEduKeyCenter.agoraAppid;
    config.roomUuid = self.roomUuid;
    config.userToken = self.localUser.userToken;
    config.userUuid = self.userUuid;
    config.token = AgoraEduManager.shareManager.token;
    AgoraChatPanelView *chatPanelView = [[AgoraChatPanelView alloc] initWithHttpConfig:config];
    [self.contentView addSubview:chatPanelView];
    self.chatPanelView = chatPanelView;

//    self.tipLabel.layer.backgroundColor = [UIColor colorWithHexString:@"000000" alpha:0.7].CGColor;
//    self.tipLabel.layer.cornerRadius = 6;
}

- (void)setupWhiteBoard {
    
    WEAK(self);
    [self setupWhiteBoard:^{
        [AgoraEduManager.shareManager.whiteBoardManager allowTeachingaids:YES success:^{
            
            weakself.boardPageControlView.hidden = NO;
            
            BOOL lock = weakself.boardState.follow;
            [weakself lockViewTransform:lock];
             
        } failure:^(NSError * error) {
            [AgoraBaseViewController showToast:error.localizedDescription];
        }];
    }];
}

- (void)updateTimeState  {
    
}

- (void)updateChatViews {
//    [self updateChatViews:self.chatTextFiled];
}

- (void)updateRoleViews:(AgoraRTEUser *) user {
    if (user.role == AgoraRTERoleTypeTeacher) {
        self.teaView.userName = user.userName;
    } else if (user.role == AgoraRTERoleTypeStudent) {
        self.stuView.userName = user.userName;
    }
}
- (void)removeRoleViews:(AgoraRTEUser *) user {
    if (user.role == AgoraRTERoleTypeTeacher) {
        self.teaView.userName = @"";
    } else if (user.role == AgoraRTERoleTypeStudent) {
        self.stuView.userName = @"";
    }
}
- (void)updateRoleCanvas:(AgoraRTEStream *)stream {
    
    if(stream.userInfo.role == AgoraRTERoleTypeTeacher) {
        if(stream.sourceType == AgoraRTEVideoSourceTypeCamera) {
            [AgoraEduManager.shareManager.studentService setStreamView:(stream.hasVideo ? self.teaView.videoCanvas : nil) stream:stream];
            
            [self.teaView updateViewWithStream:stream cupNum:0];
        }
    } else if(stream.userInfo.role == AgoraRTERoleTypeStudent) {
        
        [AgoraEduManager.shareManager.studentService setStreamView:(stream.hasVideo ? self.stuView.videoCanvas : nil) stream:stream];
        
        [self.stuView updateViewWithStream:stream cupNum:234];
    }
}
- (void)removeRoleCanvas:(AgoraRTEStream *)stream {
    [AgoraEduManager.shareManager.studentService setStreamView:nil stream:stream];
    
    if (stream.userInfo.role == AgoraRTERoleTypeTeacher) {
        if (stream.sourceType == AgoraRTEVideoSourceTypeCamera) {
//            self.teacherView.defaultImageView.hidden = NO;
//            [self.teacherView updateSpeakerEnabled:NO];
        }
    } else {
//        [self.stuView updateVideoImageWithMuted:YES];
//        [self.studentView updateAudioImageWithMuted:YES];
    }
}

- (CGFloat)getStudentDiffer:(CGFloat)minBottom {
    CGFloat maxHeight = MIN(kScreenWidth, kScreenHeight) - self.teaView.agora_bottom - minBottom - 20;
    if (@available(iOS 11.0, *)) {
        UIEdgeInsets safeAreaInsets =  UIApplication.sharedApplication.keyWindow.safeAreaInsets;
        if (safeAreaInsets.left > 0.0 || safeAreaInsets.top > 0.0 || safeAreaInsets.right > 0.0 || safeAreaInsets.bottom > 0.0) {
            maxHeight -= 34;
        }
    }
    
    CGFloat differ = (self.stuView.agora_y + self.stuView.agora_height) - maxHeight;
    return differ;
}


#pragma mark AgoraRTEClassroomDelegate
- (void)classroom:(AgoraRTEClassroom * _Nonnull)classroom remoteUsersInit:(NSArray<AgoraRTEUser*> *)users {
    for (AgoraRTEUser *user in users) {
        [self updateRoleViews:user];
    }
}
- (void)classroom:(AgoraRTEClassroom * _Nonnull)classroom remoteUsersJoined:(NSArray<AgoraRTEUser*> *)users {
    for (AgoraRTEUser *user in users) {
        [self updateRoleViews:user];
        
        if (user.role == AgoraRTERoleTypeTeacher) {
            AgoraChatUserInfoModel *userModel = [AgoraChatUserInfoModel new];
            userModel.role = user.role;
            userModel.userName = user.userName;
            userModel.userUuid = user.userUuid;
            [self.chatPanelView inoutChatMessage:userModel left:NO];
        }
    }
}
- (void)classroom:(AgoraRTEClassroom * _Nonnull)classroom remoteUsersLeft:(NSArray<AgoraRTEUserEvent*> *)events leftType:(AgoraRTEUserLeftType)type {
    for (AgoraRTEUserEvent *event in events) {
        [self removeRoleViews:event.modifiedUser];
        
        AgoraRTEUser *user = event.modifiedUser;
        if (user.role == AgoraRTERoleTypeTeacher) {
            AgoraChatUserInfoModel *userModel = [AgoraChatUserInfoModel new];
            userModel.role = user.role;
            userModel.userName = user.userName;
            userModel.userUuid = user.userUuid;
            [self.chatPanelView inoutChatMessage:userModel left:YES];
        }
    }
}

// message
- (void)classroom:(AgoraRTEClassroom * _Nonnull)classroom roomChatMessageReceived:(AgoraRTETextMessage *)textMessage {
    AgoraChatUserInfoModel *userModel = [AgoraChatUserInfoModel new];
    userModel.role = textMessage.fromUser.role;
    userModel.userName = textMessage.fromUser.userName;
    userModel.userUuid = textMessage.fromUser.userUuid;
    
    AgoraChatMessageInfoModel *model = [AgoraChatMessageInfoModel new];
    model.message = textMessage.message;
    model.type = AgoraChatMessageTypeText;
    model.fromUser = userModel;
    model.sendTime = textMessage.timestamp;
    model.isSelf = NO;
    [self.chatPanelView receivedChatMessage:model];
}

// stream
- (void)classroom:(AgoraRTEClassroom * _Nonnull)classroom remoteStreamsInit:(NSArray<AgoraRTEStream*> *)streams {
    for (AgoraRTEStream *stream in streams) {
        [self updateRoleCanvas:stream];
    }
}
- (void)classroom:(AgoraRTEClassroom * _Nonnull)classroom remoteStreamsAdded:(NSArray<AgoraRTEStreamEvent*> *)events {
    for (AgoraRTEStreamEvent *event in events) {
        [self updateRoleCanvas:event.modifiedStream];
    }
}
- (void)classroom:(AgoraRTEClassroom *)classroom remoteStreamUpdated:(NSArray<AgoraRTEStreamEvent*> *)events {
    for (AgoraRTEStreamEvent *event in events) {
        [self updateRoleCanvas:event.modifiedStream];
    }
}
- (void)classroom:(AgoraRTEClassroom * _Nonnull)classroom remoteStreamsRemoved:(NSArray<AgoraRTEStreamEvent*> *)events  {
    for (AgoraRTEStreamEvent *event in events) {
        [self removeRoleCanvas:event.modifiedStream];
    }
}

- (void)classroom:(AgoraRTEClassroom * _Nonnull)classroom networkQualityChanged:(AgoraRTENetworkQuality)quality user:(AgoraRTEBaseUser *)user {
    [self.toolView updateSignal:quality];
}

#pragma mark AgoraRTEStudentDelegate
- (void)localStreamAdded:(AgoraRTEStreamEvent*)event {
    self.localUser.streams = @[event.modifiedStream];
    [self updateRoleCanvas:event.modifiedStream];
}
- (void)localStreamUpdated:(AgoraRTEStreamEvent*)event {
    self.localUser.streams = @[event.modifiedStream];
    [self updateRoleCanvas:event.modifiedStream];
}
- (void)localStreamRemoved:(AgoraRTEStreamEvent*)event {
    self.localUser.streams = @[];
    [self removeRoleCanvas:event.modifiedStream];
}
- (void)localUserStateUpdated:(AgoraRTEUserEvent*)event changeType:(AgoraRTEUserStateChangeType)changeType {
    [self updateChatViews];
}

#pragma mark onSyncSuccess
- (void)onSyncSuccess {
    [self setupWhiteBoard];
    [self updateTimeState];
    [self updateChatViews];
    [self updateRoleViews: self.localUser];
}

#pragma mark onReconnected
- (void)onReconnected {
    [self updateTimeState];
    [self updateChatViews];

    BOOL lock = self.boardState.follow;
    [self lockViewTransform:lock];

    WEAK(self);
    [AgoraEduManager.shareManager.roomManager getFullUserListWithSuccess:^(NSArray<AgoraRTEUser *> * _Nonnull users) {
        for(AgoraRTEUser *user in users){
            [weakself updateRoleViews:user];
        }
    } failure:^(NSError * error) {
        [AgoraBaseViewController showToast:error.localizedDescription];
    }];

    [AgoraEduManager.shareManager.roomManager getFullStreamListWithSuccess:^(NSArray<AgoraRTEStream *> * _Nonnull streams) {
        for(AgoraRTEStream *stream in streams){
            [weakself updateRoleCanvas:stream];
        }
    } failure:^(NSError * error) {
        [AgoraBaseViewController showToast:error.localizedDescription];
    }];
}

#pragma mark ClassRoom Update
- (void)onUpdateChatViews {
    [self updateChatViews];
}
- (void)onUpdateCourseState {
    [self updateTimeState];
}
- (void)onBoardFollowMode:(BOOL)enable {
    NSString *toastMessage;
    if(enable) {
        toastMessage = AgoraEduLocalizedString(@"LockBoardText", nil);
    } else {
        toastMessage = AgoraEduLocalizedString(@"UnlockBoardText", nil);
    }
    [AgoraBaseViewController showToast:toastMessage];
    [self lockViewTransform:enable];
}

#pragma mark AgoraRTEMediaStreamDelegate
//- (void)didChangeOfLocalAudioStream:(NSString *)streamId
//                          withState:(AgoraRTEStreamState)state {
//
//}

- (void)didChangeOfLocalVideoStream:(NSString *)streamId
                          withState:(AgoraRTEStreamState)state {
    
    return;
    WEAK(self);
    [AgoraEduManager.shareManager.roomManager getFullStreamListWithSuccess:^(NSArray<AgoraRTEStream *> * _Nonnull streams) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamUuid == %d", streamId];
        NSArray<AgoraRTEStream*> *filtes = [streams filteredArrayUsingPredicate:predicate];
        if (filtes.count == 0) {
            return;
        }
        AgoraRTEStream *stream = filtes.firstObject;
        if (state == AgoraRTEStreamStateStopped || state == AgoraRTEStreamStateFailed) {
            stream.audio = NO;
        } else {
            stream.audio = YES;
        }
        [weakself updateRoleCanvas:stream];
        
    } failure:^(NSError * _Nonnull error) {
        [AgoraBaseViewController showToast:error.localizedDescription];
    }];
}

//- (void)didChangeOfRemoteAudioStream:(NSString *)streamId
//                           withState:(AgoraRTEStreamState)state {
//
//}

- (void)didChangeOfRemoteVideoStream:(NSString *)streamId
                           withState:(AgoraRTEStreamState)state {
    
    return;
    WEAK(self);
    [AgoraEduManager.shareManager.roomManager getFullStreamListWithSuccess:^(NSArray<AgoraRTEStream *> * _Nonnull streams) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamUuid == %d", streamId];
        NSArray<AgoraRTEStream*> *filtes = [streams filteredArrayUsingPredicate:predicate];
        if (filtes.count == 0) {
            return;
        }
        AgoraRTEStream *stream = filtes.firstObject;
        if (state == AgoraRTEStreamStateStopped || state == AgoraRTEStreamStateFailed) {
            stream.video = NO;
        } else {
            stream.video = YES;
        }
        [weakself updateRoleCanvas:stream];
        
    } failure:^(NSError * _Nonnull error) {
        [AgoraBaseViewController showToast:error.localizedDescription];
    }];
}
- (void)audioVolumeIndicationOfLocalStream:(NSString *)streamId withVolume:(NSUInteger)volume {
    [self.stuView updateAudioWithEffect:volume];
}
- (void)audioVolumeIndicationOfRemoteStream:(NSString *)streamId withVolume:(NSUInteger)volume {
    [self.teaView updateAudioWithEffect:volume];
}

#pragma mark AgoraPageControlProtocol
- (void)onPageZoomEventWithComplete:(void (^)(void))complete {
    self.boardMax = !self.boardMax;
    if (self.boardMax) {
        self.boardContentView.agora_right = self.boardContentView.agora_x;
    } else {
        self.boardContentView.agora_right = self.boardRight;
    }
    [UIView animateWithDuration:0.35 animations:^{
        [self.view layoutIfNeeded];
    }];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        complete();
    });
}

#pragma mark WhiteManagerDelegate
- (void)onWhiteBoardPageChanged:(NSInteger)pageIndex pageCount:(NSInteger)pageCount {
    self.boardPageControlView.pageIndex = pageIndex + 1;
    self.boardPageControlView.pageCount = pageCount;
}
@end
