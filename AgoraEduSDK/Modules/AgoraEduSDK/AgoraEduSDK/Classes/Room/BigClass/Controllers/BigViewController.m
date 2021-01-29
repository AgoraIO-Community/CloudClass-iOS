
//
//  BigClassViewController.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/10/22.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "BigViewController.h"
#import "BCSegmentedView.h"
#import "EEChatTextFiled.h"
#import "BCStudentVideoView.h"
#import "EETeacherVideoView.h"
#import "BCNavigationView.h"
#import "EEMessageView.h"
#import "UIView+AgoraEduToast.h"
#import "WhiteBoardTouchView.h"
#import "AppHTTPManager.h"
#import "HandsUpModel.h"
#import <YYModel/YYModel.h>
#import "AgoraEduKeyCenter.h"

@interface BigViewController ()<BCSegmentedDelegate, UITextFieldDelegate, RoomProtocol, EduClassroomDelegate, EduStudentDelegate, EduManagerDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatTextFiledRelativeTeacherViewLeftCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textFiledBottomConstraint;

@property (weak, nonatomic) IBOutlet EETeacherVideoView *teactherVideoView;
@property (weak, nonatomic) IBOutlet BCStudentVideoView *studentVideoView;
@property (weak, nonatomic) IBOutlet BCSegmentedView *segmentedView;
@property (weak, nonatomic) IBOutlet BCNavigationView *navigationView;
@property (weak, nonatomic) IBOutlet UIButton *handUpButton;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UIView *shareScreenView;
@property (weak, nonatomic) IBOutlet EEChatTextFiled *chatTextFiled;
@property (weak, nonatomic) IBOutlet EEMessageView *messageView;

// white
@property (weak, nonatomic) IBOutlet UIView *whiteboardView;

@property (nonatomic, assign) NSInteger segmentedIndex;
@property (nonatomic, assign) NSInteger unreadMessageCount;
@property (nonatomic, assign) SignalLinkState linkState;
@property (nonatomic, assign) BOOL isLandscape;
@property (nonatomic, assign) BOOL isRenderShare;

@end

@implementation BigViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
    [self initData];
    [self addNotification];
    
    [self handleDeviceOrientationChange];
}

- (void)initData {
    
    self.isRenderShare = NO;
    self.linkState = SignalLinkStateIdle;
    
    self.segmentedView.delegate = self;
    self.studentVideoView.delegate = self;
    self.navigationView.delegate = self;
    self.chatTextFiled.contentTextFiled.delegate = self;
    
    AgoraEduManager.shareManager.eduManager.delegate = self;

    [self.navigationView updateClassName: self.className];
}

- (void)lockViewTransform:(BOOL)lock {
    
    [AgoraEduManager.shareManager.whiteBoardManager  lockViewTransform:lock];
}
- (void)muteVideoStream:(BOOL)mute {
    [self setLocalStreamVideo:!mute audio:self.studentVideoView.hasAudio streamState:LocalStreamStateUpdate];
}
- (void)muteAudioStream:(BOOL)mute {
    [self setLocalStreamVideo:self.studentVideoView.hasVideo audio:!mute streamState:LocalStreamStateUpdate];
}
- (void)updateRoleViews:(EduUser *) user {
    
    if(user.role == EduRoleTypeTeacher){
        if (self.segmentedIndex == 0) {
            self.handUpButton.hidden = NO;
        }
        [self.teactherVideoView updateAndsetTeacherName: user.userName];
        
    } else if(user.role == EduRoleTypeStudent){
    }
}
- (void)removeRoleViews:(EduUser *) user {
    if (user.role == EduRoleTypeTeacher) {
        [self.teactherVideoView updateAndsetTeacherName: @""];
    }
}
- (void)updateRoleCanvas:(EduStream *)stream {
    
    if(stream.userInfo.role == EduRoleTypeTeacher) {
        if(stream.sourceType == EduVideoSourceTypeCamera) {
            [AgoraEduManager.shareManager.studentService setStreamView:(stream.hasVideo ? self.teactherVideoView.teacherRenderView : nil) stream:stream];
            
            self.teactherVideoView.defaultImageView.hidden = stream.hasVideo ? YES : NO;
            [self.teactherVideoView updateSpeakerImageWithMuted:!stream.hasAudio];
            
        } else if(stream.sourceType == EduVideoSourceTypeScreen) {
            EduRenderConfig *config = [EduRenderConfig new];
            config.renderMode = EduRenderModeFit;
            [AgoraEduManager.shareManager.studentService setStreamView:(stream.hasVideo ? self.shareScreenView : nil) stream:stream renderConfig:config];
            self.shareScreenView.hidden = NO;
            self.isRenderShare = YES;
        }
    } else if(stream.userInfo.role == EduRoleTypeStudent) {
        [AgoraEduManager.shareManager.studentService setStreamView:(stream.hasVideo ? self.studentVideoView.studentRenderView : nil) stream:stream];
        [self.studentVideoView updateVideoImageWithMuted:!stream.hasVideo];
        [self.studentVideoView updateAudioImageWithMuted:!stream.hasAudio];
        
        //
        self.studentVideoView.hidden = NO;
        [self.studentVideoView setButtonEnabled:YES];
        if(![self.localUser.userUuid isEqualToString: stream.userInfo.userUuid]) {
            [self.studentVideoView setButtonEnabled:NO];
        } else {
            self.linkState = SignalLinkStateTeaAccept;
        }
        
        [self.handUpButton setBackgroundImage:AgoraEduImageWithName(@"icon-handup-x") forState:(UIControlStateNormal)];
    }
}
- (void)removeRoleCanvas:(EduStream *)stream {
    [AgoraEduManager.shareManager.studentService setStreamView:nil stream:stream];
    
    if (stream.userInfo.role == EduRoleTypeTeacher) {
        if (stream.sourceType == EduVideoSourceTypeScreen) {
            self.shareScreenView.hidden = YES;
            self.isRenderShare = NO;
        } else if (stream.sourceType == EduVideoSourceTypeCamera) {
            self.teactherVideoView.defaultImageView.hidden = NO;
            [self.teactherVideoView updateSpeakerImageWithMuted:YES];
        }
    } else if (stream.userInfo.role == EduRoleTypeStudent) {
        
        [self.studentVideoView updateVideoImageWithMuted:YES];
        [self.studentVideoView updateAudioImageWithMuted:YES];
        
        self.studentVideoView.hidden = YES;
        [self.handUpButton setBackgroundImage:AgoraEduImageWithName(@"icon-handup") forState:(UIControlStateNormal)];
    }
}

- (void)updateChatViews {
    [self updateChatViews:self.chatTextFiled];
}

- (void)setupView {
    
    WhiteBoardManager *whiteBoardManager = AgoraEduManager.shareManager.whiteBoardManager;
    UIView *boardView = [whiteBoardManager getBoardView];
    [self.whiteboardView addSubview:boardView];
    self.boardView = boardView;
    [boardView equalTo:self.whiteboardView];
    
    [self.handUpButton setBackgroundImage:AgoraEduImageWithName(@"icon-handup") forState:UIControlStateNormal];
    self.handUpButton.layer.borderWidth = 1.f;
    self.handUpButton.layer.borderColor = [UIColor colorWithHexString:@"DBE2E5"].CGColor;
    self.handUpButton.layer.backgroundColor = [UIColor colorWithHexString:@"FFFFFF"].CGColor;
    self.handUpButton.layer.cornerRadius = 6;
    
    self.tipLabel.layer.backgroundColor = [UIColor colorWithHexString:@"000000" alpha:0.7].CGColor;
    self.tipLabel.layer.cornerRadius = 6;
    
    if(IsPad) {
        [self stateBarHidden:YES];
        self.chatTextFiled.hidden = NO;
        self.messageView.hidden = NO;
    }
}

- (void)handleDeviceOrientationChange {
    
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    switch (deviceOrientation) {
        case UIDeviceOrientationPortrait:
        {
            [self verticalScreenConstraints];
            [self.view layoutIfNeeded];
            [AgoraEduManager.shareManager.whiteBoardManager refreshViewSize];
        }
            break;
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight:
        {
            [self landscapeScreenConstraints];
            [self.view layoutIfNeeded];
            [AgoraEduManager.shareManager.whiteBoardManager refreshViewSize];
        }
            break;
        default:
            break;
    }
}

- (void)stateBarHidden:(BOOL)hidden {
    self.isLandscape = hidden;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (IBAction)handUpEvent:(UIButton *)sender {
    
    WEAK(self);
    [AgoraEduManager.shareManager.roomManager getFullStreamListWithSuccess:^(NSArray<EduStream *> * _Nonnull streams) {
        
        for(EduStream *stream in streams) {
            if(stream.userInfo.role == EduRoleTypeStudent && ![stream.userInfo.userUuid isEqualToString:weakself.localUser.userUuid]) {
                
                return;
            }
        }
        
        switch (weakself.linkState) {
            case SignalLinkStateIdle:
            case SignalLinkStateTeaReject:
            case SignalLinkStateStuCancel:
            case SignalLinkStateStuClose:
            case SignalLinkStateTeaClose:
                [weakself coVideoStateChanged: SignalLinkStateApply];
                break;
            case SignalLinkStateApply:
                [weakself coVideoStateChanged: SignalLinkStateStuCancel];
                break;
            case SignalLinkStateTeaAccept:
                [weakself coVideoStateChanged: SignalLinkStateStuClose];
                break;
            default:
                break;
        }
    } failure:^(NSError * error) {
        [AgoraBaseViewController showToast:error.localizedDescription];
    }];
}

- (void)coVideoStateChanged:(SignalLinkState) linkState {
    switch (linkState) {
        case SignalLinkStateApply:
        case SignalLinkStateStuCancel:
        case SignalLinkStateStuClose: {
            WEAK(self);
            // find teacher
            [AgoraEduManager.shareManager.roomManager getFullUserListWithSuccess:^(NSArray<EduUser *> * _Nonnull users) {
                
                EduUser *teacher;
                for(EduUser *user in users) {
                    if(user.role == EduRoleTypeTeacher){
                        teacher = user;
                        break;
                    }
                }

                weakself.linkState = linkState;
                if(linkState == SignalLinkStateStuClose) {
                    [weakself setLocalStreamVideo:NO audio:NO streamState:LocalStreamStateRemove];
                }
                
                if(teacher != nil){
                    [weakself sendUserMessage:linkState toUser:teacher];
                }
                
            } failure:^(NSError * error) {
                [AgoraBaseViewController showToast:error.localizedDescription];
            }];

            if (linkState == SignalLinkStateStuCancel) {
                weakself.linkState = linkState;
                
                [weakself.handUpButton setBackgroundImage:AgoraEduImageWithName(@"icon-handup") forState:(UIControlStateNormal)];
            } else if (linkState == SignalLinkStateStuClose) {
                weakself.linkState = linkState;
                [AgoraEduManager.shareManager.roomManager getFullStreamListWithSuccess:^(NSArray<EduStream *> * _Nonnull streams) {
                    
                    for(EduStream *stream in streams) {
                        if([stream.userInfo.userUuid isEqualToString:weakself.localUser.userUuid]) {
                            [weakself removeRoleCanvas:stream];
                            break;
                        }
                    }
                    
                } failure:^(NSError * error) {
                    [AgoraBaseViewController showToast:error.localizedDescription];
                }];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)sendUserMessage:(SignalLinkState)linkState toUser:(EduUser*)teacher {
    
    HandsUpDataModel *dataModel = [HandsUpDataModel new];
    dataModel.userId = self.localUser.userUuid;
    dataModel.userName = self.localUser.userName;
    dataModel.type = linkState;
    HandsUpModel *model = [HandsUpModel new];
    model.cmd = CMD_SIGNAL_LINK_STATE;
    model.data = dataModel;
    NSString *text = [model yy_modelToJSONString];
    
    HandUpConfiguration *config = [HandUpConfiguration new];
    config.appId = AgoraEduKeyCenter.agoraAppid;
    config.toUserUuid = teacher.userUuid;
    config.roomUuid = self.roomUuid;
    config.userToken = self.localUser.userToken;
    config.payload = text;
    config.userUuid = self.localUser.userUuid;
    config.token = AgoraEduManager.shareManager.token;
    [AppHTTPManager handUpWithConfig:config success:^(AppHandUpModel * _Nonnull model) {
            
        if (model.data == 0) {
            //1.举手成功 0.对端不在线，举手失败
            [AgoraBaseViewController showToast:AgoraEduLocalizedString(@"HandsUpFailureText", nil)];
        } else {
            [AgoraBaseViewController showToast:AgoraEduLocalizedString(@"HandsUpSuccessText", nil)];
        }
        
    } failure:^(NSError * _Nonnull error, NSInteger statusCode) {
        [AgoraBaseViewController showToast:error.localizedDescription];
    }];

}

- (void)landscapeScreenConstraints {
    if(!IsPad) {
        [self stateBarHidden:YES];
        self.chatTextFiled.hidden = NO;
        self.messageView.hidden = NO;
        self.handUpButton.hidden = NO;
//        [self resetHandUp];
    }
}

- (void)resetHandUp {
    
//    self.handUpButton.hidden = YES;
//
//    WEAK(self);
//    [AgoraEduManager.shareManager.roomManager getFullUserListWithSuccess:^(NSArray<EduUser *> * _Nonnull users) {
//
//        for(EduUser *user in users) {
//            if(user.role == EduRoleTypeTeacher){
//                weakself.handUpButton.hidden = NO;
//                break;
//            }
//        }
//
//    } failure:^(NSError * _Nullable error) {
//        [AgoraBaseViewController showToast:error.localizedDescription];
//    }];
}
- (void)verticalScreenConstraints {
    if(!IsPad) {
        [self stateBarHidden:NO];
        self.chatTextFiled.hidden = self.segmentedIndex == 0 ? YES : NO;
        self.messageView.hidden = self.segmentedIndex == 0 ? YES : NO;
//        [self resetHandUp];
        self.handUpButton.hidden = self.segmentedIndex == 0 ? NO: YES;
     
        if(self.isRenderShare) {
            self.shareScreenView.hidden = NO;
        }
    }
}

#pragma mark Notification
- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleDeviceOrientationChange) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)keyboardWasShow:(NSNotification *)notification {
    if (self.isChatTextFieldKeyboard) {
        self.chatTextFiledRelativeTeacherViewLeftCon.active = NO;
        
        CGRect frame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        float bottom = frame.size.height;
        self.textFiledBottomConstraint.constant = bottom;
    }
}

- (void)keyboardWillHidden:(NSNotification *)notification {
    self.chatTextFiledRelativeTeacherViewLeftCon.active = YES;
    self.textFiledBottomConstraint.constant = 0;
}

- (void)setupWhiteBoard {
    
    WEAK(self);
    [self setupWhiteBoard:^{
        BOOL lock = weakself.boardState.follow;
        [weakself lockViewTransform:lock];
    }];
}

#pragma mark BCSegmentedDelegate
- (void)selectedItemIndex:(NSInteger)index {
    
    if (index == 0) {
        self.segmentedIndex = 0;
        self.messageView.hidden = YES;
        self.chatTextFiled.hidden = YES;
        self.handUpButton.hidden = NO;
//        [self resetHandUp];
        if(self.isRenderShare) {
            self.shareScreenView.hidden = NO;
        }
    } else {
        self.segmentedIndex = 1;
        self.messageView.hidden = NO;
        self.chatTextFiled.hidden = NO;
        self.handUpButton.hidden = YES;
        self.unreadMessageCount = 0;
        [self.segmentedView hiddeBadge];
        self.shareScreenView.hidden = YES;
    }
}

#pragma mark RoomProtocol
- (void)closeRoom {
    WEAK(self);
    [AgoraEduAlertViewUtil showAlertWithController:self title:AgoraEduLocalizedString(@"QuitClassroomText", nil) sureHandler:^(UIAlertAction * _Nullable action) {
        [AgoraEduManager releaseResource];
        [weakself dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (BOOL)prefersStatusBarHidden {
    return self.isLandscape;
}
- (BOOL)shouldAutorotate {
    return YES;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
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
    [self.messageView addMessageModel:message];
    
    if (self.messageView.hidden) {
        self.unreadMessageCount = self.unreadMessageCount + 1;
        [self.segmentedView showBadgeWithCount:(self.unreadMessageCount)];
    }
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
    
- (void)classroom:(EduClassroom * _Nonnull)classroom remoteStreamsRemoved:(NSArray<EduStreamEvent*> *)events {
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
- (void)localUserStateUpdated:(EduUserEvent*)event changeType:(EduUserStateChangeType)changeType {
    [self updateChatViews];
}
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
- (void)userMessageReceived:(EduTextMessage*)textMessage {
    
    HandsUpModel *model = [HandsUpModel yy_modelWithJSON:textMessage.message];
    if(model.cmd != CMD_SIGNAL_LINK_STATE) {
        return;
    }
    HandsUpDataModel *dataModel = model.data;
    
    NSString *localString = @"";
    if (dataModel.type == SignalLinkStateTeaReject) {
        localString = AgoraEduLocalizedString(@"RejectRequestText", nil);
        
    } else if (dataModel.type == SignalLinkStateTeaAccept) {
        localString = AgoraEduLocalizedString(@"AcceptRequestText", nil);
        
    } else if (dataModel.type == SignalLinkStateTeaClose) {
        localString = AgoraEduLocalizedString(@"TeaCloseCoVideoText", nil);
    }
    if (localString.length > 0) {
        [AgoraBaseViewController showToast:localString];
    }
    
    self.linkState = dataModel.type;
}

#pragma mark UITextFieldDelegate
- (void)onSendMessage:(EETextMessage *)message {
    [self.messageView addMessageModel:message];
}

#pragma mark onSyncSuccess
- (void)onSyncSuccess {
    [self setupWhiteBoard];
    [self updateChatViews];
}

#pragma mark onReconnected
- (void)onReconnected {
    
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
    [self.messageView addMessageModel:textMsg];
    
    if (self.messageView.hidden) {
        self.unreadMessageCount = self.unreadMessageCount + 1;
        [self.segmentedView showBadgeWithCount:(self.unreadMessageCount)];
    }
}
@end
