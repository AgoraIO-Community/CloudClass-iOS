//
//  Agora1V1ViewController.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/10/30.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "Agora1V1ViewController.h"
#import "EENavigationView.h"
#import "EEChatTextFiled.h"
#import "EEMessageView.h"
#import "OTOTeacherView.h"
#import "OTOStudentView.h"
#import "UIView+AgoraEduToast.h"
#import "WhiteBoardTouchView.h"
#import "AppHTTPManager.h"
#import <YYModel/YYModel.h>
#import "EduStream+StreamState.h"

#import <AgoraEduSDK/AgoraEduSDK-Swift.h>

@interface Agora1V1ViewController ()<UITextFieldDelegate, RoomProtocol, EduClassroomDelegate, EduStudentDelegate, EduMediaStreamDelegate>

@property (weak, nonatomic) AgoraBaseImageView *bgView;
@property (weak, nonatomic) AgoraBaseView *contentView;
@property (weak, nonatomic) AgoraToolView *toolView;
@property (weak, nonatomic) AgoraUserView *teaView;
@property (weak, nonatomic) AgoraUserView *stuView;
@property (weak, nonatomic) AgoraBaseView *boardContentView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatRoomViewWidthCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatRoomViewRightCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textFiledRightCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textFiledWidthCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textFiledBottomCon;

@property (weak, nonatomic) IBOutlet EENavigationView *navigationView;
@property (weak, nonatomic) IBOutlet UIView *chatRoomView;
@property (weak, nonatomic) IBOutlet UILabel *chatRoomLabel;
@property (weak, nonatomic) IBOutlet UIButton *uiContorlBtn;

@property (weak, nonatomic) IBOutlet OTOTeacherView *teacherView;
@property (weak, nonatomic) IBOutlet OTOStudentView *studentView;
@property (weak, nonatomic) IBOutlet EEChatTextFiled *chatTextFiled;
@property (weak, nonatomic) IBOutlet EEMessageView *messageListView;
@property (weak, nonatomic) IBOutlet UIView *shareScreenView;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

@property (weak, nonatomic) IBOutlet UIView *whiteboardBaseView;

@property (nonatomic, weak) WhiteBoardTouchView *whiteBoardTouchView;

@end

@implementation Agora1V1ViewController
- (void)viewDidLoad {
    [super viewDidLoad];

    [self initView];
    [self initLayout];
    [self initData];
    [self addNotification];
}

- (void)initData {
    
//    self.studentView.delegate = self;
//    self.navigationView.delegate = self;
//    self.chatTextFiled.contentTextFiled.delegate = self;
//
//    [self.navigationView updateClassName:self.className];
    
//    AgoraEduManager.shareManager.studentService.mediaStreamDelegate = self;
    
    self.toolView.leftTouchBlock = ^{
        
    };
    
    self.teaView.audioTouchBlock = ^(BOOL mute) {
        NSLog(@"Srs audio mute:%d", mute);
    };
    self.teaView.videoTouchBlock = ^(BOOL mute) {
        NSLog(@"Srs video mute:%d", mute);
    };
    self.stuView.audioTouchBlock = ^(BOOL mute) {
        NSLog(@"Srs audio mute:%d", mute);
    };
    self.stuView.videoTouchBlock = ^(BOOL mute) {
        NSLog(@"Srs video mute:%d", mute);
    };
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.teaView updateView];
        [self.stuView updateView];
        [self.toolView updateView];
    });

}

- (void)lockViewTransform:(BOOL)lock {
    
    [AgoraEduManager.shareManager.whiteBoardManager lockViewTransform:lock];
    
    self.whiteBoardTouchView.hidden = !lock;
}
- (void)initLayout {
    
    //-----
    self.bgView.x = 0;
    self.bgView.y = 0;
    self.bgView.right = 0;
    self.bgView.bottom = 0;
    
    // contentView
    self.contentView.safeX = 0;
    self.contentView.safeY = 0;
    self.contentView.safeRight = 0;
    self.contentView.safeBottom = 0;
    
    // tool
    self.toolView.x = 0;
    self.toolView.y = 0;
    self.toolView.right = 0;
    self.toolView.height = IsPad ? 77 : 40;

    // teacher & student
    CGFloat top = self.toolView.height + 5;
    CGFloat right = 5;
    CGFloat width = 180;
    CGFloat height = 128;
    CGFloat minGap = 8;
    CGFloat minRight = 15;
    CGFloat minBottom = 15;
    CGFloat minHeight = 27;
    CGFloat minWidth = 130;
    if(IsPad) {
        top = self.toolView.height + 9;
        right = 20;
        width = 319;
        height = 228;
        minGap = 12;
        minRight = 30;
        minBottom = 25;
        minHeight = 49;
        minWidth = 230;
    }
    
    WEAK(self);
    self.teaView.y = top;
    self.teaView.right = right;
    self.teaView.width = width;
    self.teaView.height = height;
    self.teaView.scaleTouchBlock = ^(BOOL isMin) {
        [weakself.teaView clearConstraint];
        if (isMin) {
            weakself.teaView.bottom = self.stuView.isMin ? minGap + minHeight + minBottom : minBottom;
            weakself.teaView.right = minRight;
            weakself.teaView.width = minWidth;
            weakself.teaView.height = minHeight;
            
        } else {
            weakself.teaView.y = top;
            weakself.teaView.right = right;
            weakself.teaView.width = width;
            weakself.teaView.height = height;
        }
        [UIView animateWithDuration:0.35 animations:^{
            [weakself.view layoutIfNeeded];
        }];
    };
    
    self.stuView.y = top + height + 10;
    self.stuView.right = right;
    self.stuView.width = width;
    self.stuView.height = height;
    self.stuView.scaleTouchBlock = ^(BOOL isMin) {
        [weakself.stuView clearConstraint];
        if (isMin) {
            weakself.stuView.bottom = minBottom;
            weakself.stuView.right = minRight;
            weakself.stuView.width = minWidth;
            weakself.stuView.height = minHeight;
            if(weakself.teaView.isMin) {
                weakself.teaView.bottom = weakself.stuView.isMin ? minGap + minHeight + minBottom: minBottom;
            }
            
        } else {
            weakself.stuView.y = top + 10 + height;
            weakself.stuView.right = right;
            weakself.stuView.width = width;
            weakself.stuView.height = height;
        }
        [UIView animateWithDuration:0.35 animations:^{
            [weakself.view layoutIfNeeded];
        }];
    };
    
    //board
    self.boardContentView.x = right;
    self.boardContentView.right = IsPad ? right + width + 25 : right + width + 25;
    self.boardContentView.y = top;
    self.boardContentView.bottom = 0;
    
    // boardView
    [self.boardView equalTo:self.boardContentView];
}

- (void)initView {
    
    UIImage *image = AgoraEduImageWithName(@"bg_1v1");
    AgoraBaseImageView *imgView = [[AgoraBaseImageView alloc] initWithImage:image];
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
        NSLog(@"camera_switch");
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

//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [vv updateView];
//        [vvv updateView];
//    });
    

//    self.chatRoomLabel.text = AgoraEduLocalizedString(@"ChatroomText", nil);
//    [self.uiContorlBtn setImage:AgoraEduImageWithName(@"view-close") forState:UIControlStateNormal];
//
//    WhiteBoardManager *whiteBoardManager = AgoraEduManager.shareManager.whiteBoardManager;
//    UIView *boardView = [whiteBoardManager getBoardView];
//    [self.whiteboardBaseView addSubview:boardView];
//    self.boardView = boardView;
//    [boardView equalTo:self.whiteboardBaseView];
//    self.whiteboardBaseView.backgroundColor = UIColor.whiteColor;
//
//    self.tipLabel.layer.backgroundColor = [UIColor colorWithHexString:@"000000" alpha:0.7].CGColor;
//    self.tipLabel.layer.cornerRadius = 6;
//
//    WhiteBoardTouchView *whiteBoardTouchView = [WhiteBoardTouchView new];
//    [whiteBoardTouchView setupInView:boardView onTouchBlock:^{
//        NSString *toastMessage = AgoraEduLocalizedString(@"LockBoardTouchText", nil);
//        [AgoraBaseViewController showToast:toastMessage];
//    }];
//    self.whiteBoardTouchView = whiteBoardTouchView;
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardDidShow:(NSNotification *)notification {
    if (self.isChatTextFieldKeyboard) {
        CGRect frame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        float bottom = frame.size.height;
        if(IsPad){
            self.textFiledWidthCon.constant = kScreenWidth;
        } else {
            BOOL isIphoneX = (MAX(kScreenHeight, kScreenWidth) / MIN(kScreenHeight, kScreenWidth) > 1.78) ? YES : NO;
            self.textFiledWidthCon.constant = isIphoneX ? kScreenWidth - 44 : kScreenWidth;
        }
        self.textFiledBottomCon.constant = bottom;
    }
}

- (void)keyboardWillHidden:(NSNotification *)notification {
    if(IsPad){
        self.textFiledWidthCon.constant = 292;
    } else {
        self.textFiledWidthCon.constant = 222;
    }
    self.textFiledBottomCon.constant = 0;
}

- (void)setupWhiteBoard {
    
    WEAK(self);
    [self setupWhiteBoard:^{
        [AgoraEduManager.shareManager.whiteBoardManager allowTeachingaids:YES success:^{
            
            BOOL lock = weakself.boardState.follow;
            [weakself lockViewTransform:lock];
             
        } failure:^(NSError * error) {
            [AgoraBaseViewController showToast:error.localizedDescription];
        }];
    }];
}

- (void)updateTimeState  {
    [self updateTimeState:self.navigationView];
}

- (void)updateChatViews {
    [self updateChatViews:self.chatTextFiled];
}

- (IBAction)chatRoomViewShowAndHide:(UIButton *)sender {
    self.chatRoomViewRightCon.constant = sender.isSelected ? 0.f : 222.f;
    self.textFiledRightCon.constant = sender.isSelected ? 0.f : 222.f;
    self.chatRoomView.hidden = sender.isSelected ? NO : YES;
    self.chatTextFiled.hidden = sender.isSelected ? NO : YES;
    NSString *imageName = sender.isSelected ? @"view-close" : @"view-open";
    [sender setImage:AgoraEduImageWithName(imageName) forState:(UIControlStateNormal)];
    sender.selected = !sender.selected;
    
    [self.boardView layoutIfNeeded];
    [AgoraEduManager.shareManager.whiteBoardManager refreshViewSize];
}

- (void)updateRoleViews:(EduUser *) user {
    if(user.role == EduRoleTypeTeacher){
        [self.teacherView updateUserName:user.userName];
        
    } else if(user.role == EduRoleTypeStudent){
        [self.studentView updateUserName:user.userName];
    }
}
- (void)removeRoleViews:(EduUser *) user {
    if (user.role == EduRoleTypeTeacher) {
        [self.teacherView updateUserName:@""];
        
    } else if(user.role == EduRoleTypeStudent) {
        [self.studentView updateUserName:@""];
    }
}
- (void)updateRoleCanvas:(EduStream *)stream {
    
    if(stream.userInfo.role == EduRoleTypeTeacher) {
        if(stream.sourceType == EduVideoSourceTypeCamera) {
            
            [AgoraEduManager.shareManager.studentService setStreamView:(stream.hasVideo ? self.teacherView.videoRenderView : nil) stream:stream];
            
            self.teacherView.defaultImageView.hidden = stream.hasVideo ? YES : NO;
            [self.teacherView updateSpeakerEnabled:stream.hasAudio];
            
        } else if(stream.sourceType == EduVideoSourceTypeScreen) {
            EduRenderConfig *config = [EduRenderConfig new];
            config.renderMode = EduRenderModeFit;
            [AgoraEduManager.shareManager.studentService setStreamView:(stream.hasVideo ? self.shareScreenView : nil) stream:stream renderConfig:config];
            self.shareScreenView.hidden = NO;
        }
    } else if(stream.userInfo.role == EduRoleTypeStudent) {
        
        [AgoraEduManager.shareManager.studentService setStreamView:(stream.hasVideo ? self.studentView.videoRenderView : nil) stream:stream];
        [self.studentView updateVideoImageWithMuted:!stream.hasVideo];
        [self.studentView updateAudioImageWithMuted:!stream.hasAudio];
    }
}
- (void)removeRoleCanvas:(EduStream *)stream {
    [AgoraEduManager.shareManager.studentService setStreamView:nil stream:stream];
    
    if (stream.userInfo.role == EduRoleTypeTeacher) {
        if (stream.sourceType == EduVideoSourceTypeScreen) {
            self.shareScreenView.hidden = YES;
        } else if (stream.sourceType == EduVideoSourceTypeCamera) {
            self.teacherView.defaultImageView.hidden = NO;
            [self.teacherView updateSpeakerEnabled:NO];
        }
    } else {
        [self.studentView updateVideoImageWithMuted:YES];
        [self.studentView updateAudioImageWithMuted:YES];
    }
}

#pragma mark RoomProtocol
- (void)closeRoom {

    WEAK(self);
    [AgoraEduAlertViewUtil showAlertWithController:self title:AgoraEduLocalizedString(@"QuitClassroomText", nil) sureHandler:^(UIAlertAction * _Nullable action) {

        [weakself.navigationView stopTimer];
        [AgoraEduManager releaseResource];
        [weakself dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)muteVideoStream:(BOOL)mute {
    [self setLocalStreamVideo:!mute audio:self.studentView.hasAudio streamState:LocalStreamStateUpdate];
}

- (void)muteAudioStream:(BOOL)mute {
    [self setLocalStreamVideo:self.studentView.hasVideo audio:!mute streamState:LocalStreamStateUpdate];
}

#pragma mark EduClassroomDelegate
// User in or out
- (void)classroom:(EduClassroom * _Nonnull)classroom remoteUsersInit:(NSArray<EduUser*> *)users {
    for (EduUser *user in users) {
        [self updateRoleViews:user];
    }
}
- (void)classroom:(EduClassroom * _Nonnull)classroom remoteUsersJoined:(NSArray<EduUser*> *)users {
    for (EduUser *user in users) {
        [self updateRoleViews:user];
    }
}
- (void)classroom:(EduClassroom * _Nonnull)classroom remoteUsersLeft:(NSArray<EduUserEvent*> *)events leftType:(EduUserLeftType)type {
    for (EduUserEvent *event in events) {
        [self removeRoleViews:event.modifiedUser];
    }
}

// message
- (void)classroom:(EduClassroom * _Nonnull)classroom roomChatMessageReceived:(EduTextMessage *)textMessage {
    EETextMessage *message = [EETextMessage new];
    message.fromUser = textMessage.fromUser;
    message.message = textMessage.message;
    message.timestamp = textMessage.timestamp;

    [self.messageListView addMessageModel:message];
}

// stream
- (void)classroom:(EduClassroom * _Nonnull)classroom remoteStreamsInit:(NSArray<EduStream*> *)streams {
    for (EduStream *stream in streams) {
        [self updateRoleCanvas:stream];
    }
}
- (void)classroom:(EduClassroom * _Nonnull)classroom remoteStreamsAdded:(NSArray<EduStreamEvent*> *)events {
    for (EduStreamEvent *event in events) {
        [self updateRoleCanvas:event.modifiedStream];
    }
}
- (void)classroom:(EduClassroom *)classroom remoteStreamUpdated:(NSArray<EduStreamEvent*> *)events {
    for (EduStreamEvent *event in events) {
        [self updateRoleCanvas:event.modifiedStream];
    }
}
- (void)classroom:(EduClassroom * _Nonnull)classroom remoteStreamsRemoved:(NSArray<EduStreamEvent*> *)events  {
    for (EduStreamEvent *event in events) {
        [self removeRoleCanvas:event.modifiedStream];
    }
}

- (void)classroom:(EduClassroom * _Nonnull)classroom networkQualityChanged:(NetworkQuality)quality user:(EduBaseUser *)user {
    
    if([self.localUser.userUuid isEqualToString:user.userUuid]) {
        switch (quality) {
            case NetworkQualityHigh:
                [self.navigationView updateSignalImageName:@"icon-signal3"];
                break;
            case NetworkQualityMiddle:
                [self.navigationView updateSignalImageName:@"icon-signal2"];
                break;
            case NetworkQualityLow:
                [self.navigationView updateSignalImageName:@"icon-signal1"];
                break;
            default:
                break;
        }
    }
}

#pragma mark EduStudentDelegate
- (void)localStreamAdded:(EduStreamEvent*)event {
    self.localUser.streams = @[event.modifiedStream];
    [self updateRoleCanvas:event.modifiedStream];
}
- (void)localStreamUpdated:(EduStreamEvent*)event {
    self.localUser.streams = @[event.modifiedStream];
    [self updateRoleCanvas:event.modifiedStream];
}
- (void)localStreamRemoved:(EduStreamEvent*)event {
    self.localUser.streams = @[];
    [self removeRoleCanvas:event.modifiedStream];
}
- (void)localUserStateUpdated:(EduUserEvent*)event changeType:(EduUserStateChangeType)changeType {
    [self updateChatViews];
}

#pragma mark UITextFieldDelegate
- (void)onSendMessage:(EETextMessage *)message {
    [self.messageListView addMessageModel:message];
}

#pragma mark onSyncSuccess
- (void)onSyncSuccess {
    [self setupWhiteBoard];
//    [self updateTimeState];
//    [self updateChatViews];
//    [self updateRoleViews: self.localUser];
}

#pragma mark onReconnected
- (void)onReconnected {
    [self updateTimeState];
    [self updateChatViews];
    
    BOOL lock = self.boardState.follow;
    [self lockViewTransform:lock];
    
    WEAK(self);
    [AgoraEduManager.shareManager.roomManager getFullUserListWithSuccess:^(NSArray<EduUser *> * _Nonnull users) {
        for(EduUser *user in users){
            [weakself updateRoleViews:user];
        }
    } failure:^(NSError * error) {
        [AgoraBaseViewController showToast:error.localizedDescription];
    }];
    
    [AgoraEduManager.shareManager.roomManager getFullStreamListWithSuccess:^(NSArray<EduStream *> * _Nonnull streams) {
        for(EduStream *stream in streams){
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
- (void)onEndRecord {
    EETextMessage *textMsg = [EETextMessage new];
    EduUser *fromUser = [EduUser new];
    [fromUser setValue:@"system" forKey:@"userName"];
    textMsg.fromUser = fromUser;
    textMsg.message = AgoraEduLocalizedString(@"ReplayRecordingText", nil);
    textMsg.recordRoomUuid = self.roomUuid;
    [self.messageListView addMessageModel:textMsg];
}

#pragma mark EduMediaStreamDelegate
//- (void)didChangeOfLocalAudioStream:(NSString *)streamId
//                          withState:(EduStreamState)state {
//
//}

- (void)didChangeOfLocalVideoStream:(NSString *)streamId
                          withState:(EduStreamState)state {
    
    WEAK(self);
    [AgoraEduManager.shareManager.roomManager getFullStreamListWithSuccess:^(NSArray<EduStream *> * _Nonnull streams) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamUuid == %d", streamId];
        NSArray<EduStream*> *filtes = [streams filteredArrayUsingPredicate:predicate];
        if (filtes.count == 0) {
            return;
        }
        EduStream *stream = filtes.firstObject;
        if (state == EduStreamStateStopped || state == EduStreamStateFailed) {
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
//                           withState:(EduStreamState)state {
//
//}

- (void)didChangeOfRemoteVideoStream:(NSString *)streamId
                           withState:(EduStreamState)state {
    
    WEAK(self);
    [AgoraEduManager.shareManager.roomManager getFullStreamListWithSuccess:^(NSArray<EduStream *> * _Nonnull streams) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamUuid == %d", streamId];
        NSArray<EduStream*> *filtes = [streams filteredArrayUsingPredicate:predicate];
        if (filtes.count == 0) {
            return;
        }
        EduStream *stream = filtes.firstObject;
        if (state == EduStreamStateStopped || state == EduStreamStateFailed) {
            stream.video = NO;
        } else {
            stream.video = YES;
        }
        [weakself updateRoleCanvas:stream];
        
    } failure:^(NSError * _Nonnull error) {
        [AgoraBaseViewController showToast:error.localizedDescription];
    }];
}

@end
