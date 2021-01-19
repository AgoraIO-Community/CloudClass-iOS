//
//  SmallViewController.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/15.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "SmallViewController.h"
#import "EENavigationView.h"
#import "MCStudentVideoListView.h"
#import "MCTeacherVideoView.h"
#import "EEChatTextFiled.h"
#import "EEMessageView.h"
#import "MCStudentListView.h"
#import "MCSegmentedView.h"
#import "MCStudentVideoCell.h"
#import "UIView+AgoraEduToast.h"
#import "WhiteBoardTouchView.h"
#import "AppHTTPManager.h"
#import <YYModel/YYModel.h>

@interface SmallViewController ()<UITextFieldDelegate, RoomProtocol, EduClassroomDelegate, EduStudentDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoManagerViewRightCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatTextFiledBottomCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatTextFiledWidthCon;

@property (weak, nonatomic) IBOutlet EENavigationView *navigationView;
@property (weak, nonatomic) IBOutlet MCStudentVideoListView *studentVideoListView;
@property (weak, nonatomic) IBOutlet MCTeacherVideoView *teacherVideoView;
@property (weak, nonatomic) IBOutlet UIView *roomManagerView;
@property (weak, nonatomic) IBOutlet UIView *shareScreenView;
@property (weak, nonatomic) IBOutlet EEChatTextFiled *chatTextFiled;
@property (weak, nonatomic) IBOutlet EEMessageView *messageView;
@property (weak, nonatomic) IBOutlet MCStudentListView *studentListView;
@property (weak, nonatomic) IBOutlet MCSegmentedView *segmentedView;
@property (weak, nonatomic) IBOutlet UIButton *uiContorlBtn;

@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

@property (weak, nonatomic) IBOutlet UIView *whiteboardBaseView;

@property (nonatomic, weak) WhiteBoardTouchView *whiteBoardTouchView;

@property (assign, nonatomic) BOOL hasVideo;
@property (assign, nonatomic) BOOL hasAudio;
@end

@implementation SmallViewController
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

    [self.navigationView updateClassName:self.className];
}

- (void)lockViewTransform:(BOOL)lock {
    
    [AgoraEduManager.shareManager.whiteBoardManager lockViewTransform:lock];
    
    self.whiteBoardTouchView.hidden = YES;
    
    if(lock){
        if([self.boardState.grantUsers containsObject:self.localUser.userUuid]){
            self.whiteBoardTouchView.hidden = NO;
        }
    }
}

- (void)allowTeachingaids:(BOOL)allow {
    
    WEAK(self);
    [AgoraEduManager.shareManager.whiteBoardManager allowTeachingaids:allow success:^{
        
        BOOL boardFollow = weakself.boardState.follow;
        [weakself lockViewTransform:boardFollow];
        
    } failure:^(NSError * error) {
        [AgoraEduBaseViewController showToast:error.localizedDescription];
    }];
}

- (void)setupWhiteBoard {
    
    WEAK(self);
    [self setupWhiteBoard:^{
        if([weakself.boardState.grantUsers containsObject:weakself.localUser.userUuid]) {
            [weakself allowTeachingaids:YES];
        }
        [weakself.studentListView updateGrantStudentArray:weakself.boardState.grantUsers];
        
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

    WEAK(self);
    WhiteBoardTouchView *whiteBoardTouchView = [WhiteBoardTouchView new];
    [whiteBoardTouchView setupInView:self.boardView onTouchBlock:^{
        NSString *toastMessage = AgoraEduLocalizedString(@"LockBoardTouchText", nil);
        [weakself showTipWithMessage:toastMessage];
    }];
    self.whiteBoardTouchView = whiteBoardTouchView;
}

- (void)initStudentRenderBlock {
    WEAK(self);
    [self.studentVideoListView setStudentVideoList:^(MCStudentVideoCell * _Nonnull cell, EduStream *stream) {

        [AgoraEduManager.shareManager.studentService setStreamView:cell.videoCanvasView stream:stream];
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
    if (objModels.count == 0){
        return;
    }
    
    if([objModels.firstObject isKindOfClass:EduUserEvent.class]) {
        for (EduUserEvent *event in objModels) {
            if(event.modifiedUser.role == EduRoleTypeTeacher){
                [self updateTeacherViews:event.modifiedUser];
            } else if(event.modifiedUser.role == EduRoleTypeStudent) {

            }
        }
    } else if([objModels.firstObject isKindOfClass:EduUser.class]) {
        for (EduUser *user in objModels) {
            if(user.role == EduRoleTypeTeacher){
                [self updateTeacherViews:user];
            } else if(user.role == EduRoleTypeStudent) {

            }
        }
    }
    
    [self reloadStudentViews];
}
- (void)updateTeacherViews:(EduUser *)user {
    [self.teacherVideoView updateUserName:user.userName];
}
- (void)removeTeacherViews:(EduUser *)user {
    [self.teacherVideoView updateUserName:@""];
}
- (void)updateRoleCanvas:(NSArray<id> *)objModels {
    if (objModels.count == 0){
        return;
    }
    
    BOOL hasStudent = NO;
    if([objModels.firstObject isKindOfClass:EduStreamEvent.class]) {
        for (EduStreamEvent *event in objModels) {
            if(event.modifiedStream.userInfo.role == EduRoleTypeTeacher){
                [self updateTeacherCanvas:event.modifiedStream];
                
            } else if(event.modifiedStream.userInfo.role == EduRoleTypeStudent) {
                
                if([event.modifiedStream.userInfo.userUuid isEqualToString:self.localUser.userUuid]) {
                    [self setLocalStreamVideo:event.modifiedStream.hasVideo audio:event.modifiedStream.hasAudio streamState:LocalStreamStateIdle];
                }
                hasStudent = YES;
            }
        }
    } else if([objModels.firstObject isKindOfClass:EduStream.class]) {
        for (EduStream *stream in objModels) {
            if(stream.userInfo.role == EduRoleTypeTeacher){
                [self updateTeacherCanvas:stream];
                
            } else if(stream.userInfo.role == EduRoleTypeStudent) {
                if([stream.userInfo.userUuid isEqualToString:self.localUser.userUuid]) {
                    [self setLocalStreamVideo:stream.hasVideo audio:stream.hasAudio streamState:LocalStreamStateIdle];
                }
                hasStudent = YES;
            }
        }
    }
    
    if(hasStudent) {
        [self reloadStudentViews];
    }
}
- (void)updateTeacherCanvas:(EduStream *)stream {
    if(stream.sourceType == EduVideoSourceTypeCamera) {
        [AgoraEduManager.shareManager.studentService setStreamView:(stream.hasVideo ? self.teacherVideoView.videoRenderView : nil) stream:stream];
        
        self.teacherVideoView.defaultImageView.hidden = stream.hasVideo ? YES : NO;
        
        NSString *imageName = stream.hasAudio ? @"icon-speaker" : @"icon-speakeroff-white";
        [self.teacherVideoView updateSpeakerImageName: imageName];
        
    } else if(stream.sourceType == EduVideoSourceTypeScreen) {
        EduRenderConfig *config = [EduRenderConfig new];
        config.renderMode = EduRenderModeFit;
        [AgoraEduManager.shareManager.studentService setStreamView:(stream.hasVideo ? self.shareScreenView : nil) stream:stream renderConfig:config];
        self.shareScreenView.hidden = NO;
    }
}
- (void)removeTeacherCanvas:(EduStream *)stream {
    [AgoraEduManager.shareManager.studentService setStreamView:nil stream:stream];
    if (stream.sourceType == EduVideoSourceTypeScreen) {
        self.shareScreenView.hidden = YES;
    } else if (stream.sourceType == EduVideoSourceTypeCamera) {
        self.teacherVideoView.defaultImageView.hidden = NO;
        [self.teacherVideoView updateSpeakerImageName: @"icon-speakeroff-white"];
    }
}
- (void)removeStudentCanvas:(NSArray<EduStream*> *)streams {
    if(streams.count == 0){
        return;
    }
    for(EduStream *stream in streams){
        [AgoraEduManager.shareManager.studentService setStreamView:nil stream:stream];
    }
    
    [self reloadStudentViews];
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
    WEAK(self);
    self.studentListView.userUuid = self.localUser.userUuid;
    [AgoraEduManager.shareManager.roomManager getFullStreamListWithSuccess:^(NSArray<EduStream *> * _Nonnull streams) {
         
         NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userInfo.role != %d", EduRoleTypeTeacher];
         NSArray<EduStream*> *filtes = [streams filteredArrayUsingPredicate:predicate];
        
        [weakself.studentVideoListView updateStudentArray:filtes];
        [weakself.studentListView updateStudentArray:filtes];
        
    } failure:^(NSError * error) {
        [AgoraEduBaseViewController showToast:error.localizedDescription];
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


#pragma mark EduClassroomDelegate
// User in or out
- (void)classroom:(EduClassroom * _Nonnull)classroom remoteUsersInit:(NSArray<EduUser*> *)users {
    [self updateRoleViews:users];
}
- (void)classroom:(EduClassroom * _Nonnull)classroom remoteUsersJoined:(NSArray<EduUser*> *)users {
    [self updateRoleViews:users];
}
- (void)classroom:(EduClassroom *)classroom remoteUsersLeft:(NSArray<EduUserEvent *> *)events leftType:(EduUserLeftType)type {
    
    for (EduUserEvent *event in events) {
        if(event.modifiedUser.role == EduRoleTypeTeacher){
            [self removeTeacherViews:event.modifiedUser];
        } else if(event.modifiedUser.role == EduRoleTypeStudent) {
            
        }
    }
    [self reloadStudentViews];
}

// message
- (void)classroom:(EduClassroom * _Nonnull)classroom roomChatMessageReceived:(EduTextMessage *)textMessage {

    EETextMessage *message = [EETextMessage new];
    message.fromUser = textMessage.fromUser;
    message.message = textMessage.message;
    message.timestamp = textMessage.timestamp;

    [self.messageView addMessageModel:message];
}
// stream
- (void)classroom:(EduClassroom * _Nonnull)classroom remoteStreamsInit:(NSArray<EduStream*> *)streams {
    [self updateRoleCanvas:streams];
}
- (void)classroom:(EduClassroom * _Nonnull)classroom remoteStreamsAdded:(NSArray<EduStreamEvent*> *)events {
    [self updateRoleCanvas:events];
}
- (void)classroom:(EduClassroom *)classroom remoteStreamUpdated:(NSArray<EduStreamEvent*> *)events {
    [self updateRoleCanvas:events];
}
- (void)classroom:(EduClassroom * _Nonnull)classroom remoteStreamsRemoved:(NSArray<EduStreamEvent*> *)events {
    
    NSMutableArray<EduStream *> *streams = [NSMutableArray array];
    for (EduStreamEvent *event in events) {
        if(event.modifiedStream.userInfo.role == EduRoleTypeTeacher) {
            [self removeTeacherCanvas:event.modifiedStream];
        } else if(event.modifiedStream.userInfo.role == EduRoleTypeStudent) {
            [streams addObject:event.modifiedStream];
        }
    }
    [self removeStudentCanvas:streams];
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
    [self updateRoleCanvas:@[event.modifiedStream]];
}
- (void)localStreamUpdated:(EduStreamEvent*)event {
    self.localUser.streams = @[event.modifiedStream];
    [self updateRoleCanvas:@[event.modifiedStream]];
}
- (void)localStreamRemoved:(EduStreamEvent*)event {
    self.localUser.streams = @[];
    
    if(event.modifiedStream.userInfo.role == EduRoleTypeTeacher) {
        [self removeTeacherCanvas:event.modifiedStream];
    } else if(event.modifiedStream.userInfo.role == EduRoleTypeStudent) {
        [self removeStudentCanvas:@[event.modifiedStream]];
    }
}

#pragma mark UITextFieldDelegate
- (void)onSendMessage:(EETextMessage *)message {
     [self.messageView addMessageModel:message];
}

#pragma mark onSyncSuccess
- (void)onSyncSuccess {
    [self setupWhiteBoard];
    [self updateTimeState];
    [self updateChatViews];
}

#pragma mark onReconnected
- (void)onReconnected {
    [self updateTimeState];
    [self updateChatViews];

    BOOL lock = self.boardState.follow;
    [self lockViewTransform:lock];
    
    BOOL allowBoardTool = NO;
    if([self.boardState.grantUsers containsObject:self.localUser.userUuid]){
        allowBoardTool = YES;
    }
    [self allowTeachingaids:allowBoardTool];
    
    WEAK(self);
    [AgoraEduManager.shareManager.roomManager getFullUserListWithSuccess:^(NSArray<EduUser *> * _Nonnull users) {
        for(EduUser *user in users){
            if(user.role == EduRoleTypeTeacher){
                [weakself updateTeacherViews:user];
                break;
            }
        }
        [weakself reloadStudentViews];
    } failure:^(NSError * error) {
        [AgoraEduBaseViewController showToast:error.localizedDescription];
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
    [AgoraEduBaseViewController showToast:toastMessage];
    [self lockViewTransform:enable];
}
- (void)onBoardPermissionGranted:(NSArray<NSString *> *)grantUsers {
    NSString *toastMessage = AgoraEduLocalizedString(@"UnMuteBoardText", nil);
    [self showTipWithMessage:toastMessage];
    [self allowTeachingaids:YES];

    [self.studentListView updateGrantStudentArray:grantUsers];
}
- (void)onBoardPermissionRevoked:(NSArray<NSString *> *)grantUsers {
    
    NSString *toastMessage = AgoraEduLocalizedString(@"MuteBoardText", nil);
    [self showTipWithMessage:toastMessage];
    [self allowTeachingaids:NO];

    [self.studentListView updateGrantStudentArray:grantUsers];
}
- (void)onBoardPermissionUpdated:(NSArray<NSString *> *)grantUsers {[self.studentListView updateGrantStudentArray:grantUsers];
}
- (void)onEndRecord {
    EETextMessage *textMsg = [EETextMessage new];
    EduUser *fromUser = [EduUser new];
    [fromUser setValue:@"system" forKey:@"userName"];
    textMsg.fromUser = fromUser;
    textMsg.message = AgoraEduLocalizedString(@"ReplayRecordingText", nil);
    textMsg.recordRoomUuid = self.roomUuid;
    [self.messageView addMessageModel:textMsg];
}
@end
