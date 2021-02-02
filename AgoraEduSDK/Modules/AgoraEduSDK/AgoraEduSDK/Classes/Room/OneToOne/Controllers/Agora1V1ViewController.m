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

#import <AgoraEduSDK/AgoraEduSDK-Swift.h>

@interface Agora1V1ViewController ()<UITextFieldDelegate, AgoraRTEClassroomDelegate, AgoraRTEStudentDelegate, AgoraRTEMediaStreamDelegate, AgoraPageControlProtocol, WhiteManagerDelegate>

@property (weak, nonatomic) AgoraBaseImageView *bgView;
@property (weak, nonatomic) AgoraBaseView *contentView;
@property (weak, nonatomic) AgoraToolView *toolView;
@property (weak, nonatomic) AgoraUserView *teaView;
@property (weak, nonatomic) AgoraUserView *stuView;
@property (weak, nonatomic) AgoraBaseView *boardContentView;
@property (weak, nonatomic) AgoraPageControlView *boardPageControlView;
@property (weak, nonatomic) AgoraChatPanelView *chatPanelView;

@property (assign, nonatomic) CGFloat boardRight;
@property (assign, nonatomic) BOOL boardMax;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatRoomViewWidthCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatRoomViewRightCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textFiledRightCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textFiledWidthCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textFiledBottomCon;

@property (weak, nonatomic) IBOutlet AgoraEENavigationView *navigationView;
@property (weak, nonatomic) IBOutlet UIView *chatRoomView;
@property (weak, nonatomic) IBOutlet UILabel *chatRoomLabel;
@property (weak, nonatomic) IBOutlet UIButton *uiContorlBtn;

@property (weak, nonatomic) IBOutlet AgoraOTOTeacherView *teacherView;
@property (weak, nonatomic) IBOutlet AgoraOTOStudentView *studentView;
@property (weak, nonatomic) IBOutlet AgoraEEChatTextFiled *chatTextFiled;
@property (weak, nonatomic) IBOutlet AgoraEEMessageView *messageListView;
@property (weak, nonatomic) IBOutlet UIView *shareScreenView;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

@property (weak, nonatomic) IBOutlet UIView *whiteboardBaseView;

@property (nonatomic, weak) AgoraBoardTouchView *whiteBoardTouchView;

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
    self.studentView.delegate = self;
    self.navigationView.delegate = self;
    self.chatTextFiled.contentTextFiled.delegate = self;

    [self.navigationView updateClassName:self.className];
    
    AgoraEduManager.shareManager.studentService.mediaStreamDelegate = self;
    
    WEAK(self);
    self.toolView.leftTouchBlock = ^{
        [AgoraEduAlertViewUtil showAlertWithController:weakself title:AgoraEduLocalizedString(@"QuitClassroomText", nil) sureHandler:^(UIAlertAction * _Nullable action) {

            [weakself.navigationView stopTimer];
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
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.teaView updateView];
//        [self.stuView updateView];
        [self.toolView updateView];
    });
    
    NSMutableArray *array = [NSMutableArray array];
    {
        AgoraChatMessageModel *model = [[AgoraChatMessageModel alloc] init];
        model.isSelf = YES;
        model.message = @"过年过年过年123";
        model.userName = @"我";
        model.type = AgoraChatMessageTypeText;
        model.translateState = AgoraChatLoadingStateSuccess;
        model.sendState = AgoraChatLoadingStateLoading;
        model.translateMessage = @"asjdfjlasljdasjdfjlasljdasjdfjlasljdasjdfdasjdfjlasljdasjdfjlasljdasjdfjlasljd";
        [array addObject:model];
    }
    
    {
        AgoraChatMessageModel *model = [[AgoraChatMessageModel alloc] init];
        model.isSelf = NO;
        model.message = @"过年过年过年123";
        model.userName = @"老师";
        model.type = AgoraChatMessageTypeText;
        model.translateState = AgoraChatLoadingStateNone;
        model.sendState = AgoraChatLoadingStateLoading;

        [array addObject:model];
    }
    
    {
        AgoraChatMessageModel *model = [[AgoraChatMessageModel alloc] init];
        model.isSelf = NO;
        model.message = @"Jerry（老师）加入教室";
        model.type = AgoraChatMessageTypeUserInout;
        [array addObject:model];
    }

    self.chatPanelView.chatModels = array;
    
//    public var messageId = 0
//    public var message = ""
//    public var translateMessage = ""
//    public var userName = ""
//
//    public var type:AgoraChatMessageType = .text
//
//    public var isSelf = false
//    public var translateState: AgoraChatLoadingState = .none
//    public var sendState: AgoraChatLoadingState = .none
//
//    public var cellHeight: CGFloat = 0
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
    CGFloat top = self.toolView.height + 9;
    CGFloat right = 9;
    CGFloat width = 180;
    CGFloat height = 128;
    CGFloat minGap = 8;
    CGFloat minRight = 15;
    CGFloat minBottom = 15;
    CGFloat minHeight = 31;
    CGFloat minWidth = 140;
    if(IsPad) {
        top = self.toolView.height + 15;
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
            weakself.teaView.bottom = weakself.stuView.isMin ? minGap + minHeight + minBottom : minBottom;
            weakself.teaView.right = minRight;
            weakself.teaView.width = minWidth;
            weakself.teaView.height = minHeight;

            // adjust stuview layout
            if (!weakself.stuView.isMin) {
                CGFloat differ = (weakself.stuView.y + weakself.stuView.height) -  (kScreenHeight - weakself.teaView.bottom - 20);

                if (differ < 0) {
                    weakself.stuView.y -= abs(differ);
                }
            }

        } else {
            weakself.teaView.y = top;
            weakself.teaView.right = right;
            weakself.teaView.width = width;
            weakself.teaView.height = height;

            if(!weakself.stuView.isMin) {
                CGFloat stuViewY = top + 10 + height;
                weakself.stuView.y = stuViewY;
            }
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
            if (weakself.teaView.isMin) {
                weakself.teaView.bottom = weakself.stuView.isMin ? minGap + minHeight + minBottom : minBottom;
            }

            CGFloat stuViewY = top + 10 + height;
            weakself.stuView.right = right;
            weakself.stuView.width = width;
            weakself.stuView.height = height;

            // adjust stuview layout
            if (weakself.teaView.isMin) {
                CGFloat differ = (weakself.stuView.y + weakself.stuView.height) -  (kScreenHeight - weakself.teaView.bottom - 20);

                if (differ < 0) {
                    stuViewY -= abs(differ);
                }
            }
            weakself.stuView.y = stuViewY;
        }
        [UIView animateWithDuration:0.35 animations:^{
            [weakself.view layoutIfNeeded];
        }];
    };
    
    //board
    self.boardContentView.x = 0;
    self.boardContentView.right = IsPad ? right + width + 20 : right + width + 20;
    self.boardRight = self.boardContentView.right;
    self.boardContentView.y = self.toolView.height;
    self.boardContentView.bottom = 0;

    // boardView
    [self.boardView equalTo:self.boardContentView];

    // boardPageControlView
    self.boardPageControlView.x = right + 20;
    self.boardPageControlView.height = IsPad ? 42 : 21;
    self.boardPageControlView.bottom = 20;

    // chatPanelView
    CGFloat chatPanelViewMaxWidth = IsPad ? 246 : 137;
    CGFloat chatPanelViewMinWidth = IsPad ? 44 : 24;
    CGFloat chatPanelViewMaxHeight = IsPad ? 362 : 203;
    CGFloat chatPanelViewMinHeight = IsPad ? 44 : 24;

    self.chatPanelView.width = chatPanelViewMaxWidth;
    self.chatPanelView.height = chatPanelViewMaxHeight;
    self.chatPanelView.bottom = self.boardContentView.bottom + 20;
    self.chatPanelView.right = self.boardContentView.right + 20;
    self.chatPanelView.scaleTouchBlock = ^(BOOL isMin) {
        weakself.chatPanelView.width = isMin ? chatPanelViewMinWidth : chatPanelViewMaxWidth;
        weakself.chatPanelView.height = isMin ? chatPanelViewMinHeight : chatPanelViewMaxHeight;
        [UIView animateWithDuration:0.35 animations:^{
            [weakself.view layoutIfNeeded];
        }];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            weakself.chatPanelView.unreadNum = 8;
        });
    };
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

    // page control
    AgoraPageControlView *pageControlView = [[AgoraPageControlView alloc] initWithDelegate:self];
    pageControlView.hidden = YES;
    [self.contentView addSubview:pageControlView];
    self.boardPageControlView = pageControlView;

    // chat view
    AgoraChatPanelView *chatPanelView = [[AgoraChatPanelView alloc] init];
    [self.contentView addSubview:chatPanelView];
    self.chatPanelView = chatPanelView;
    
//    self.chatRoomLabel.text = AgoraEduLocalizedString(@"ChatroomText", nil);
//    [self.uiContorlBtn setImage:AgoraEduImageWithName(@"view-close") forState:UIControlStateNormal];

//
//    self.tipLabel.layer.backgroundColor = [UIColor colorWithHexString:@"000000" alpha:0.7].CGColor;
//    self.tipLabel.layer.cornerRadius = 6;
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
            
            weakself.boardPageControlView.hidden = NO;
            
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

- (void)updateRoleViews:(AgoraRTEUser *) user {
    if (user.role == AgoraRTERoleTypeTeacher) {
        self.teaView.userName = user.userName;
    } else if (user.role == AgoraRTERoleTypeStudent) {
        self.stuView.userName = user.userName;
    }
}
- (void)removeRoleViews:(AgoraRTEUser *) user {
    if (user.role == AgoraRTERoleTypeTeacher) {
        [self.teacherView updateUserName:@""];
        
    } else if(user.role == AgoraRTERoleTypeStudent) {
        [self.studentView updateUserName:@""];
    }
}
- (void)updateRoleCanvas:(AgoraRTEStream *)stream {
    
    if(stream.userInfo.role == AgoraRTERoleTypeTeacher) {
        if(stream.sourceType == AgoraRTEVideoSourceTypeCamera) {
            
            [AgoraEduManager.shareManager.studentService setStreamView:(stream.hasVideo ? self.teaView.videoCanvas : nil) stream:stream];
            
            [self.teaView updateViewWithStream:stream cupNum:0];
            
        } else if(stream.sourceType == AgoraRTEVideoSourceTypeScreen) {
            AgoraRTERenderConfig *config = [AgoraRTERenderConfig new];
            config.renderMode = AgoraRTERenderModeFit;
            [AgoraEduManager.shareManager.studentService setStreamView:(stream.hasVideo ? self.shareScreenView : nil) stream:stream renderConfig:config];
            self.shareScreenView.hidden = NO;
        }
    } else if(stream.userInfo.role == AgoraRTERoleTypeStudent) {
        
        [AgoraEduManager.shareManager.studentService setStreamView:(stream.hasVideo ? self.stuView.videoCanvas : nil) stream:stream];
        
        [self.stuView updateViewWithStream:stream cupNum:234];
    }
}
- (void)removeRoleCanvas:(AgoraRTEStream *)stream {
    [AgoraEduManager.shareManager.studentService setStreamView:nil stream:stream];
    
    if (stream.userInfo.role == AgoraRTERoleTypeTeacher) {
        if (stream.sourceType == AgoraRTEVideoSourceTypeScreen) {
            self.shareScreenView.hidden = YES;
        } else if (stream.sourceType == AgoraRTEVideoSourceTypeCamera) {
            self.teacherView.defaultImageView.hidden = NO;
            [self.teacherView updateSpeakerEnabled:NO];
        }
    } else {
        [self.studentView updateVideoImageWithMuted:YES];
        [self.studentView updateAudioImageWithMuted:YES];
    }
}

#pragma mark AgoraRTEClassroomDelegate
// User in or out
- (void)classroom:(AgoraRTEClassroom * _Nonnull)classroom remoteUsersInit:(NSArray<AgoraRTEUser*> *)users {
    for (AgoraRTEUser *user in users) {
        [self updateRoleViews:user];
    }
}
- (void)classroom:(AgoraRTEClassroom * _Nonnull)classroom remoteUsersJoined:(NSArray<AgoraRTEUser*> *)users {
    for (AgoraRTEUser *user in users) {
        [self updateRoleViews:user];
    }
}
- (void)classroom:(AgoraRTEClassroom * _Nonnull)classroom remoteUsersLeft:(NSArray<AgoraRTEUserEvent*> *)events leftType:(AgoraRTEUserLeftType)type {
    for (AgoraRTEUserEvent *event in events) {
        [self removeRoleViews:event.modifiedUser];
    }
}

// message
- (void)classroom:(AgoraRTEClassroom * _Nonnull)classroom roomChatMessageReceived:(AgoraRTETextMessage *)textMessage {
    AgoraEETextMessage *message = [AgoraEETextMessage new];
    message.fromUser = textMessage.fromUser;
    message.message = textMessage.message;
    message.timestamp = textMessage.timestamp;

    [self.messageListView addMessageModel:message];
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

#pragma mark UITextFieldDelegate
- (void)onSendMessage:(AgoraEETextMessage *)message {
    [self.messageListView addMessageModel:message];
}

#pragma mark onSyncSuccess
- (void)onSyncSuccess {
    AgoraEduManager.shareManager.studentService.mediaStreamDelegate = self;

    [self setupWhiteBoard];
//    [self updateTimeState];
//    [self updateChatViews];
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
- (void)onEndRecord {
    AgoraEETextMessage *textMsg = [AgoraEETextMessage new];
    AgoraRTEUser *fromUser = [AgoraRTEUser new];
    [fromUser setValue:@"system" forKey:@"userName"];
    textMsg.fromUser = fromUser;
    textMsg.message = AgoraEduLocalizedString(@"ReplayRecordingText", nil);
    textMsg.recordRoomUuid = self.roomUuid;
    [self.messageListView addMessageModel:textMsg];
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
- (void)onPageLeftEvent {
    WhiteBoardManager *whiteBoardManager = AgoraEduManager.shareManager.whiteBoardManager;
    [whiteBoardManager setPageIndex:self.boardPageControlView.pageIndex];
}
- (void)onPageRightEvent {
    WhiteBoardManager *whiteBoardManager = AgoraEduManager.shareManager.whiteBoardManager;
    [whiteBoardManager setPageIndex:self.boardPageControlView.pageIndex];
}
- (void)onPageIncreaseEvent {
    WhiteBoardManager *whiteBoardManager = AgoraEduManager.shareManager.whiteBoardManager;
    [whiteBoardManager increaseScale];
}
- (void)onPageDecreaseEvent {
    WhiteBoardManager *whiteBoardManager = AgoraEduManager.shareManager.whiteBoardManager;
    [whiteBoardManager decreaseScale];
}
- (void)onPageZoomEvent {
    self.boardMax = !self.boardMax;
    if (self.boardMax) {
        self.boardContentView.right = self.boardContentView.x;
    } else {
        self.boardContentView.right = self.boardRight;
    }
    [UIView animateWithDuration:0.35 animations:^{
        [self.view layoutIfNeeded];
    }];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        WhiteBoardManager *whiteBoardManager = AgoraEduManager.shareManager.whiteBoardManager;
        [whiteBoardManager refreshViewSize];
    });
}

#pragma mark WhiteManagerDelegate
- (void)onWhiteBoardPageChanged:(NSInteger)pageIndex pageCount:(NSInteger)pageCount {
    self.boardPageControlView.pageIndex = pageIndex + 1;
    self.boardPageControlView.pageCount = pageCount;
}
@end
