//
//  AgoraSmallViewController.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/15.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "AgoraBOViewController.h"
#import "AgoraEENavigationView.h"
#import "AgoraMCStudentVideoListView.h"
#import "AgoraMCTeacherVideoView.h"
#import "AgoraEEChatTextFiled.h"
#import "AgoraEEMessageView.h"
#import "AgoraMCStudentListView.h"
#import "AgoraMCSegmentedView.h"
#import "AgoraMCStudentVideoCell.h"
#import "UIView+AgoraEduToast.h"
#import "AgoraBoardTouchView.h"
#import "AgoraHTTPManager.h"
#import <YYModel/YYModel.h>
#import "AgoraTextMessageModel.h"

@interface AgoraBOViewController ()<UITextFieldDelegate, AgoraRoomProtocol, AgoraRTEClassroomDelegate, AgoraRTEStudentDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoManagerViewRightCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatTextFiledBottomCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatTextFiledWidthCon;

@property (weak, nonatomic) IBOutlet AgoraEENavigationView *navigationView;
@property (weak, nonatomic) IBOutlet AgoraMCStudentVideoListView *studentVideoListView;
@property (weak, nonatomic) IBOutlet AgoraMCTeacherVideoView *teacherVideoView;
@property (weak, nonatomic) IBOutlet UIView *roomManagerView;
@property (weak, nonatomic) IBOutlet UIView *shareScreenView;
@property (weak, nonatomic) IBOutlet AgoraEEChatTextFiled *chatTextFiled;
@property (weak, nonatomic) IBOutlet AgoraEEMessageView *messageView;
@property (weak, nonatomic) IBOutlet AgoraMCStudentListView *studentListView;
@property (weak, nonatomic) IBOutlet AgoraMCSegmentedView *segmentedView;
@property (weak, nonatomic) IBOutlet UIButton *uiContorlBtn;

@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

@property (weak, nonatomic) IBOutlet UIView *whiteboardBaseView;

@property (assign, nonatomic) BOOL hasVideo;
@property (assign, nonatomic) BOOL hasAudio;
@end

@implementation AgoraBOViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
    [self initData];
    [self addNotification];
}

- (void)initData {
    self.hasVideo = YES;
    self.hasAudio = YES;

    self.chatTextFiled.contentTextFiled.delegate = self;
    self.studentListView.delegate = self;
    self.navigationView.delegate = self;

    [self initSelectSegmentBlock];
    [self initStudentRenderBlock];
}

- (void)lockViewTransform:(BOOL)lock {
    [AgoraEduManager.shareManager.whiteBoardManager lockViewTransform:lock];
}

- (void)setupWhiteBoard {
    
    WEAK(self);
    [self setupWhiteBoard:^{
        BOOL lock = weakself.boardState.follow;
        [weakself lockViewTransform:lock];
    }];
}

- (void)updateTimeState {
    [self updateTimeState:self.navigationView];
}

- (void)updateChatViews {
    [self updateChatViews:self.chatTextFiled];
}

- (void)setupView {
    [self.uiContorlBtn setImage:AgoraEduImageWithName(@"view-close") forState:UIControlStateNormal];
    
    WhiteBoardManager *whiteBoardManager = AgoraEduManager.shareManager.whiteBoardManager;
    UIView *boardView = [whiteBoardManager getBoardView];
    [self.whiteboardBaseView addSubview:boardView];
    self.boardView = boardView;
    [boardView equalTo:self.whiteboardBaseView];

    self.roomManagerView.layer.borderWidth = 1.f;
    self.roomManagerView.layer.borderColor = [UIColor colorWithHexString:@"DBE2E5"].CGColor;

    self.tipLabel.layer.backgroundColor = [UIColor colorWithHexString:@"000000" alpha:0.7].CGColor;
    self.tipLabel.layer.cornerRadius = 6;
}

- (void)initStudentRenderBlock {
    WEAK(self);
    [self.studentVideoListView setStudentVideoList:^(AgoraMCStudentVideoCell * _Nonnull cell, AgoraRTEStream *stream) {

        [AgoraEduManager.shareManager.groupStudentService setStreamView:cell.videoCanvasView stream:stream];
        if([stream.userInfo.userUuid isEqualToString:weakself.localUser.userUuid]) {
            weakself.hasVideo = stream.hasVideo;
            weakself.hasAudio = stream.hasAudio;
        }
    }];
}

- (void)initSelectSegmentBlock {
    WEAK(self);
    [self.segmentedView setSelectIndex:^(NSInteger index) {
        if (index == 0) {
            weakself.messageView.hidden = NO;
            weakself.chatTextFiled.hidden = NO;
            weakself.studentListView.hidden = YES;
        }else {
            weakself.messageView.hidden = YES;
            weakself.chatTextFiled.hidden = YES;
            weakself.studentListView.hidden = NO;
        }
    }];
}

#pragma mark ---------------------------- Notification ---------------------
- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardDidShow:(NSNotification *)notification {
    if (self.isChatTextFieldKeyboard) {
        CGRect frame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        float bottom = frame.size.height;
        self.chatTextFiledBottomCon.constant = bottom;
        BOOL isIphoneX = (MAX(kScreenHeight, kScreenWidth) / MIN(kScreenHeight, kScreenWidth) > 1.78) ? YES : NO;
        self.chatTextFiledWidthCon.constant = isIphoneX ? kScreenWidth - 44 : kScreenWidth;
    }
}

- (void)keyboardWillHidden:(NSNotification *)notification {
    self.chatTextFiledBottomCon.constant = 0;
    self.chatTextFiledWidthCon.constant = 222;
}

- (IBAction)messageViewshowAndHide:(UIButton *)sender {
    self.infoManagerViewRightCon.constant = sender.isSelected ? 0.f : 222.f;
    self.roomManagerView.hidden = sender.isSelected ? NO : YES;
    self.chatTextFiled.hidden = sender.isSelected ? NO : YES;
    NSString *imageName = sender.isSelected ? @"view-close" : @"view-open";
    [sender setImage:AgoraEduImageWithName(imageName) forState:(UIControlStateNormal)];
    sender.selected = !sender.selected;
    
    [self.view layoutIfNeeded];
    [AgoraEduManager.shareManager.whiteBoardManager refreshViewSize];
}

#pragma mark UPDATE
- (void)updateRoleViews:(NSArray<id> *)objModels {
    if (objModels.count == 0) {
        return;
    }
    
    if([objModels.firstObject isKindOfClass:AgoraRTEUserEvent.class]) {
        for (AgoraRTEUserEvent *event in objModels) {
            if(event.modifiedUser.role == AgoraRTERoleTypeTeacher){
                [self updateTeacherViews:event.modifiedUser];
            } else if(event.modifiedUser.role == AgoraRTERoleTypeStudent) {

            }
        }
    } else if([objModels.firstObject isKindOfClass:AgoraRTEUser.class]) {
        for (AgoraRTEUser *user in objModels) {
            if(user.role == AgoraRTERoleTypeTeacher){
                [self updateTeacherViews:user];
            } else if(user.role == AgoraRTERoleTypeStudent) {

            }
        }
    }
    
    [self reloadStudentViews];
}
- (void)updateTeacherViews:(AgoraRTEUser *)user {
    [self.teacherVideoView updateUserName:user.userName];
}
- (void)removeTeacherViews:(AgoraRTEUser *)user {
    [self.teacherVideoView updateUserName:@""];
}
- (void)updateRoleCanvas:(NSArray<id> *)objModels {
    if (objModels.count == 0){
        return;
    }
    
    BOOL hasStudent = NO;
    if([objModels.firstObject isKindOfClass:AgoraRTEStreamEvent.class]) {
        for (AgoraRTEStreamEvent *event in objModels) {
            if(event.modifiedStream.userInfo.role == AgoraRTERoleTypeTeacher){
                [self updateTeacherCanvas:event.modifiedStream];
                
            } else if(event.modifiedStream.userInfo.role == AgoraRTERoleTypeStudent) {
                hasStudent = YES;
            }
        }
    } else if([objModels.firstObject isKindOfClass:AgoraRTEStream.class]) {
        for (AgoraRTEStream *stream in objModels) {
            if(stream.userInfo.role == AgoraRTERoleTypeTeacher){
                [self updateTeacherCanvas:stream];
                
            } else if(stream.userInfo.role == AgoraRTERoleTypeStudent) {
                hasStudent = YES;
            }
        }
    }
    
    if(hasStudent) {
        [self reloadStudentViews];
    }
}
- (void)updateTeacherCanvas:(AgoraRTEStream *)stream {
    if(stream.sourceType == AgoraRTEVideoSourceTypeCamera) {
        [AgoraEduManager.shareManager.studentService  setStreamView:(stream.hasVideo ? self.teacherVideoView.videoRenderView : nil) stream:stream];
        
        self.teacherVideoView.defaultImageView.hidden = stream.hasVideo ? YES : NO;
        
        NSString *imageName = stream.hasAudio ? @"icon-speaker" : @"icon-speakeroff-white";
        [self.teacherVideoView updateSpeakerImageName: imageName];
        
    } else if(stream.sourceType == AgoraRTEVideoSourceTypeScreen) {
        AgoraRTERenderConfig *config = [AgoraRTERenderConfig new];
        config.renderMode = AgoraRTERenderModeFit;
        [AgoraEduManager.shareManager.studentService setStreamView:(stream.hasVideo ? self.shareScreenView : nil) stream:stream renderConfig:config];
        self.shareScreenView.hidden = NO;
    }
}
- (void)removeTeacherCanvas:(AgoraRTEStream *)stream {
    [AgoraEduManager.shareManager.studentService setStreamView:nil stream:stream];
    if (stream.sourceType == AgoraRTEVideoSourceTypeScreen) {
        self.shareScreenView.hidden = YES;
    } else if (stream.sourceType == AgoraRTEVideoSourceTypeCamera) {
        self.teacherVideoView.defaultImageView.hidden = NO;
        [self.teacherVideoView updateSpeakerImageName: @"icon-speakeroff-white"];
    }
}
- (void)removeStudentCanvas:(NSArray<AgoraRTEStream*> *)streams {
    if(streams.count == 0){
        return;
    }
    for(AgoraRTEStream *stream in streams){
        [AgoraEduManager.shareManager.groupStudentService setStreamView:nil stream:stream];
    }
    
    [self reloadStudentViews];
}

#pragma mark AgoraRoomProtocol
- (void)closeRoom {
    WEAK(self);
    [AgoraEduAlertViewUtil showAlertWithController:self title:AgoraEduLocalizedString(@"QuitClassroomText", nil) sureHandler:^(UIAlertAction * _Nullable action) {

        [weakself.navigationView stopTimer];
        [AgoraEduManager releaseResource];
        [weakself dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)muteVideoStream:(BOOL)mute {
    [self setLocalStreamVideo:!mute audio:self.hasAudio streamState:LocalStreamStateUpdate];
}

- (void)muteAudioStream:(BOOL)mute {
    [self setLocalStreamVideo:self.hasVideo audio:!mute streamState:LocalStreamStateUpdate];
}

#pragma mark  --------  Mandatory landscape -------
- (UIStatusBarStyle)preferredStatusBarStyle
{
  return UIStatusBarStyleLightContent;
}

- (void)reloadStudentViews {
    self.studentListView.userUuid = self.localUser.userUuid;
    
    WEAK(self);
    [AgoraEduManager.shareManager.groupRoomManager getFullStreamListWithSuccess:^(NSArray<AgoraRTEStream *> * _Nonnull streams) {
        
        [weakself.studentVideoListView updateStudentArray:streams];
        [weakself.studentListView updateStudentArray:streams];
        
    } failure:^(NSError * error) {
        [AgoraBaseViewController showToast:error.localizedDescription];
    }];
}

- (void)showTipWithMessage:(NSString *)toastMessage {

    self.tipLabel.hidden = NO;
    [self.tipLabel setText: toastMessage];

    WEAK(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
       weakself.tipLabel.hidden = YES;
    });
}


#pragma mark AgoraRTEClassroomDelegate
// User in or out
- (void)classroom:(AgoraRTEClassroom * _Nonnull)classroom remoteUsersInit:(NSArray<AgoraRTEUser*> *)users {
    [self updateRoleViews:users];
}
- (void)classroom:(AgoraRTEClassroom * _Nonnull)classroom remoteUsersJoined:(NSArray<AgoraRTEUser*> *)users {
    [self updateRoleViews:users];
}
- (void)classroom:(AgoraRTEClassroom * _Nonnull)classroom remoteUsersLeft:(NSArray<AgoraRTEUserEvent*> *)events leftType:(AgoraRTEUserLeftType)type {
    
    for (AgoraRTEUserEvent *event in events) {
        if(event.modifiedUser.role == AgoraRTERoleTypeTeacher){
            [self removeTeacherViews:event.modifiedUser];
        } else if(event.modifiedUser.role == AgoraRTERoleTypeStudent) {
            
        }
    }
    [self reloadStudentViews];
}

// message
- (void)classroom:(AgoraRTEClassroom * _Nonnull)classroom roomChatMessageReceived:(AgoraRTETextMessage *)textMessage {

    if (textMessage.message == nil || textMessage.message.length == 0) {
        return;
    }
    
    AgoraTextMessageModel *model = [AgoraTextMessageModel.class yy_modelWithJSON:textMessage.message];
    
    WEAK(self);
    [AgoraEduManager.shareManager.groupRoomManager getClassroomInfoWithSuccess:^(AgoraRTEClassroom * _Nonnull room) {
        
        // teacher message
        if(model.role == AgoraRTERoleTypeTeacher) {
            if(model.fromRoomUuid.length == 0 || [model.fromRoomUuid isEqualToString:room.roomInfo.roomUuid]) {
                AgoraEETextMessage *message = [AgoraEETextMessage new];
                message.fromUser = textMessage.fromUser;
                message.message = model.content;
                message.timestamp = textMessage.timestamp;
                [weakself.messageView addMessageModel:message];
            }
            return;
        }
        
        // other message
        if ([classroom.roomInfo.roomUuid isEqualToString:room.roomInfo.roomUuid]) {
            
            AgoraEETextMessage *message = [AgoraEETextMessage new];
            message.fromUser = textMessage.fromUser;
            message.message = model.content;
            message.timestamp = textMessage.timestamp;
            [weakself.messageView addMessageModel:message];
        }

    } failure:^(NSError * error) {
        [AgoraBaseViewController showToast:error.localizedDescription];
    }];
}
// stream
- (void)classroom:(AgoraRTEClassroom * _Nonnull)classroom remoteStreamsInit:(NSArray<AgoraRTEStream*> *)streams {
    [self updateRoleCanvas:streams];
}
- (void)classroom:(AgoraRTEClassroom * _Nonnull)classroom remoteStreamsAdded:(NSArray<AgoraRTEStreamEvent*> *)events {
    [self updateRoleCanvas:events];
}
- (void)classroom:(AgoraRTEClassroom *)classroom remoteStreamUpdated:(NSArray<AgoraRTEStreamEvent*> *)events {
    [self updateRoleCanvas:events];
}
- (void)classroom:(AgoraRTEClassroom * _Nonnull)classroom remoteStreamsRemoved:(NSArray<AgoraRTEStreamEvent*> *)events {
    
    NSMutableArray<AgoraRTEStream *> *streams = [NSMutableArray array];
    for (AgoraRTEStreamEvent *event in events) {
        if(event.modifiedStream.userInfo.role == AgoraRTERoleTypeTeacher) {
            [self removeTeacherCanvas:event.modifiedStream];
        } else if(event.modifiedStream.userInfo.role == AgoraRTERoleTypeStudent) {
            [streams addObject:event.modifiedStream];
        }
    }
    [self removeStudentCanvas:streams];
}
- (void)classroom:(AgoraRTEClassroom * _Nonnull)classroom networkQualityChanged:(AgoraRTENetworkQuality)quality user:(AgoraRTEBaseUser *)user {
    
    if([self.localUser.userUuid isEqualToString:user.userUuid]) {
        switch (quality) {
            case AgoraRTENetworkQualityHigh:
                [self.navigationView updateSignalImageName:@"icon-signal3"];
                break;
            case AgoraRTENetworkQualityMiddle:
                [self.navigationView updateSignalImageName:@"icon-signal2"];
                break;
            case AgoraRTENetworkQualityLow:
                [self.navigationView updateSignalImageName:@"icon-signal1"];
                break;
            default:
                break;
        }
    }
}

#pragma mark AgoraRTEStudentDelegate
- (void)localUserStateUpdated:(AgoraRTEUserEvent*)event changeType:(AgoraRTEUserStateChangeType)changeType {
    [self updateChatViews];
}
- (void)localStreamAdded:(AgoraRTEStreamEvent*)event {
    self.localUser.streams = @[event.modifiedStream];
    [self updateRoleCanvas:@[event.modifiedStream]];
}
- (void)localStreamUpdated:(AgoraRTEStreamEvent*)event {
    self.localUser.streams = @[event.modifiedStream];
    [self updateRoleCanvas:@[event.modifiedStream]];
}
- (void)localStreamRemoved:(AgoraRTEStreamEvent*)event {
    self.localUser.streams = @[];
    
    if(event.modifiedStream.userInfo.role == AgoraRTERoleTypeTeacher) {
        [self removeTeacherCanvas:event.modifiedStream];
    } else if(event.modifiedStream.userInfo.role == AgoraRTERoleTypeStudent) {
        [self removeStudentCanvas:@[event.modifiedStream]];
    }
}

#pragma mark UITextFieldDelegate
- (void)onSendMessage:(AgoraEETextMessage *)message {
     [self.messageView addMessageModel:message];
}

#pragma mark onSyncSuccess
- (void)onSyncSuccess {
    [self setupWhiteBoard];
    [self updateTimeState];
    [self updateChatViews];
    
    WEAK(self);
    [AgoraEduManager.shareManager.groupRoomManager getClassroomInfoWithSuccess:^(AgoraRTEClassroom * _Nonnull room) {
            [weakself.navigationView updateClassName:room.roomInfo.roomName];
        } failure:^(NSError * _Nonnull error) {
            [AgoraBaseViewController showToast:error.localizedDescription];
    }];
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
            if(user.role == AgoraRTERoleTypeTeacher){
                [weakself updateTeacherViews:user];
                break;
            }
        }
        [weakself reloadStudentViews];
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
    AgoraEETextMessage *textMsg = [AgoraEETextMessage new];
    AgoraRTEUser *fromUser = [AgoraRTEUser new];
    [fromUser setValue:@"system" forKey:@"userName"];
    textMsg.fromUser = fromUser;
    textMsg.message = AgoraEduLocalizedString(@"ReplayRecordingText", nil);
    textMsg.recordRoomUuid = self.roomUuid;
    [self.messageView addMessageModel:textMsg];
}
@end
