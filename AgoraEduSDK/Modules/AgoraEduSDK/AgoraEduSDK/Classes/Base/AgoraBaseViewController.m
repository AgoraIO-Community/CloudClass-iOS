//
//  AgoraBaseViewController.m
//  AgoraEducation
//
//  Created by SRS on 2020/8/3.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import "AgoraBaseViewController.h"
#import "UIView+AgoraEduToast.h"
#import "AgoraEduKeyCenter.h"
#import <YYModel/YYModel.h>
#import "AgoraRecordPropertyModel.h"
#import "AgoraTextMessageModel.h"
#import "AgoraEduTopVC.h"

#define ROOM_PROPERTY_KEY_RECORD @"record"

#define NoNullNumber(x) (([x isKindOfClass:NSNumber.class]) ? x : @(0))
#define NoNullString(x) ([x isKindOfClass:NSString.class] ? x : @"")
#define NoNullArray(x) ([x isKindOfClass:NSArray.class] ? x : @[])
#define NoNullDictionary(x) ([x isKindOfClass:NSDictionary.class] ? x : @{})

@interface AgoraBaseViewController ()<AgoraRTEClassroomDelegate, AgoraRTEStudentDelegate, WhiteManagerDelegate>

@property (nonatomic, assign) BOOL hasSignalReconnect;
@property (nonatomic, weak) UIActivityIndicatorView *activityIndicator;

@end

@implementation AgoraBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    if (@available(iOS 11, *)) {
        
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.view.backgroundColor = [UIColor whiteColor];
    [self initActivityIndicator];
    [self setLoadingVisible:YES];
    AgoraEduManager.shareManager.roomManager.delegate = self;
    
    WEAK(self);
    [AgoraEduManager.shareManager joinClassroomWithSceneType:self.sceneType userName:self.userName success:^{

        [weakself setLoadingVisible:NO];
        
        // delegate
        AgoraEduManager.shareManager.studentService.delegate = weakself;
        if (weakself.sceneType == AgoraRTESceneTypeBreakout) {
            AgoraEduManager.shareManager.groupRoomManager.delegate = weakself;
            AgoraEduManager.shareManager.groupStudentService.delegate = weakself;
        }
        
        weakself.hasSignalReconnect = NO;
        [weakself initLocalUser];
        
        [weakself onSyncSuccess];
        
    } failure:^(NSString * _Nonnull errorMsg) {
        [weakself setLoadingVisible:NO];
        [AgoraBaseViewController showToast:errorMsg];
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)initActivityIndicator {
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleWhiteLarge)];
    activityIndicator.frame = CGRectMake(0, 0, 100, 100);
    activityIndicator.color = [UIColor blackColor];
    activityIndicator.backgroundColor = [UIColor clearColor];
    activityIndicator.hidesWhenStopped = YES;
    [[UIApplication sharedApplication].windows.firstObject addSubview:activityIndicator];
    [activityIndicator centerTo:[UIApplication sharedApplication].windows.firstObject];
    
    self.activityIndicator = activityIndicator;
}

- (void)setLoadingVisible:(BOOL)show {
    if(show) {
        [self.activityIndicator startAnimating];
    } else {
        [self.activityIndicator stopAnimating];
    }
}

- (void)setLocalStreamVideo:(BOOL)hasVideo audio:(BOOL)hasAudio streamState:(LocalStreamState)state {

    AgoraRTEStreamConfig *config = [AgoraRTEStreamConfig new];
    config.streamUuid = self.localUser.streamUuid;
    config.streamName = @"";
    config.enableCamera = hasVideo;
    config.enableMicrophone = hasAudio;
  
    AgoraRTEStudentService *studentService = AgoraEduManager.shareManager.studentService;
    if(self.sceneType == AgoraRTESceneTypeBreakout) {
        studentService = AgoraEduManager.shareManager.groupStudentService;
    }
    [studentService startOrUpdateLocalStream:config success:^(AgoraRTEStream * _Nonnull stream) {
        
        if (state == LocalStreamStateRemove) {
            [studentService unpublishStream:stream success:^{
                
            } failure:^(NSError * error) {
                [AgoraBaseViewController showToast:error.localizedDescription];
            }];
        } else if(state == LocalStreamStateUpdate) {
            [studentService muteStream:stream success:^{
                
            } failure:^(NSError * error) {
                [AgoraBaseViewController showToast:error.localizedDescription];
            }];
        } else if(state == LocalStreamStateCreate) {
            [studentService publishStream:stream success:^{
                
            } failure:^(NSError * error) {
                [AgoraBaseViewController showToast:error.localizedDescription];
            }];
        }
    } failure:^(NSError * error) {
        [AgoraBaseViewController showToast:error.localizedDescription];
    }];
}

- (void)initLocalUser {
    
    AgoraRTEClassroomManager *roomManager = AgoraEduManager.shareManager.roomManager;
    if(self.sceneType == AgoraRTESceneTypeBreakout) {
        roomManager = AgoraEduManager.shareManager.groupRoomManager;
    }
    
    WEAK(self);
    [roomManager getLocalUserWithSuccess:^(AgoraRTELocalUser * _Nonnull user) {
        weakself.localUser = user;
    } failure:^(NSError * error) {
        [AgoraBaseViewController showToast:error.localizedDescription];
    }];
}

- (void)setupWhiteBoard:(void (^) (void))success {
    WhiteBoardManager *whiteBoardManager = AgoraEduManager.shareManager.whiteBoardManager;
    whiteBoardManager.delegate = self;
    WhiteBoardConfiguration *config = [WhiteBoardConfiguration new];
    config.appId = AgoraEduKeyCenter.boardAppid;
    [whiteBoardManager initBoardWithView:self.boardView config:config];
    
    [self setLoadingVisible:YES];
    
    WEAK(self);
    [AgoraEduManager.shareManager getWhiteBoardInfoWithSuccess:^(NSString * _Nonnull boardId, NSString * _Nonnull boardToken) {
        
        WhiteBoardJoinOptions *options = [WhiteBoardJoinOptions new];
        options.boardId = boardId;
        options.boardToken = boardToken;
        [whiteBoardManager joinBoardWithOptions:options success:^{
            
            WhiteBoardManager *whiteBoardManager = AgoraEduManager.shareManager.whiteBoardManager;
            weakself.boardState = [whiteBoardManager getWhiteBoardStateModel];
            
            [weakself setLoadingVisible:NO];
            if (success) {
                success();
            }
            
        } failure:^(NSError * error) {
            [weakself setLoadingVisible:NO];
            [AgoraBaseViewController showToast:error.localizedDescription];
        }];
        
    } failure:^(NSString * errorMsg) {
        [weakself setLoadingVisible:NO];
        [AgoraBaseViewController showToast:errorMsg];
    }];
}

- (void)updateTimeState:(AgoraEENavigationView *)navigationView {
    
    [AgoraEduManager.shareManager.roomManager getClassroomInfoWithSuccess:^(AgoraRTEClassroom * _Nonnull room) {
        
        if(room.roomState.courseState == AgoraRTECourseStateStart) {
            NSDate *currentDate = [NSDate dateWithTimeIntervalSinceNow:0];
            NSTimeInterval currenTimeInterval = [currentDate timeIntervalSince1970];
            [navigationView initTimerCount:(NSInteger)((currenTimeInterval * 1000 - room.roomState.startTime) * 0.001)];
            [navigationView startTimer];
        } else  {
            [navigationView stopTimer];
        }
        
    } failure:^(NSError * error) {
        [navigationView stopTimer];
        [AgoraBaseViewController showToast:error.localizedDescription];
    }];
}

- (void)updateChatViews:(AgoraEEChatTextFiled *)chatTextFiled {
    WEAK(self);
    [AgoraEduManager.shareManager.roomManager getClassroomInfoWithSuccess:^(AgoraRTEClassroom * _Nonnull room) {
        
        [AgoraEduManager.shareManager.roomManager getLocalUserWithSuccess:^(AgoraRTELocalUser * _Nonnull user) {
            weakself.localUser = user;

            BOOL muteChat = !room.roomState.isStudentChatAllowed;
            if(!muteChat) {
                BOOL muteChat = !weakself.localUser.isChatAllowed;
                chatTextFiled.contentTextFiled.enabled = muteChat ? NO : YES;
                chatTextFiled.contentTextFiled.placeholder = muteChat ? AgoraEduLocalizedString(@"ProhibitedPostText", nil) : AgoraEduLocalizedString(@"InputMessageText", nil);
            } else {
                chatTextFiled.contentTextFiled.enabled = muteChat ? NO : YES;
                chatTextFiled.contentTextFiled.placeholder = muteChat ? AgoraEduLocalizedString(@"ProhibitedPostText", nil) : AgoraEduLocalizedString(@"InputMessageText", nil);
            }

        } failure:^(NSError * error) {
            [AgoraBaseViewController showToast:error.localizedDescription];
        }];
        
    } failure:^(NSError * error) {
        [AgoraBaseViewController showToast:error.localizedDescription];
    }];
}

+ (void)showToast:(NSString *)title {
    
    UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
    dispatch_async(dispatch_get_main_queue(), ^{
        [window makeToast:title];
    });
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeRight;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
    [self setLoadingVisible:NO];
}


#pragma mark ConnectionState
- (void)classroom:(AgoraRTEClassroom *)classroom connectionStateChanged:(AgoraRTEConnectionState)state {
    
    if(state == AgoraRTEConnectionStateAborted) {
        [AgoraEduManager releaseResource];
        [self dismissViewControllerAnimated:YES completion:^{
            [AgoraBaseViewController showToast:AgoraEduLocalizedString(@"LoginOnAnotherDeviceText", nil)];
        }];
        return;
    }
    
    if(state == AgoraRTEConnectionStateConnected) {
        if(self.hasSignalReconnect) {
            self.hasSignalReconnect = NO;
            [self onReconnected];
        }
    } else if(state == AgoraRTEConnectionStateReconnecting) {
        self.hasSignalReconnect = YES;
    }
}

#pragma mark onClassroomPropertyUpdated
- (void)classroom:(AgoraRTEClassroom *)classroom stateUpdated:(AgoraRTEClassroomChangeType)changeType operatorUser:(AgoraRTEBaseUser *)user {
    
    if (changeType == AgoraRTEClassroomChangeTypeAllStudentsChat) {
        [self onUpdateChatViews];
    } else if (changeType == AgoraRTEClassroomChangeTypeCourseState) {
        
        if(classroom.roomState.courseState == AgoraRTECourseStateStop) {
            // dismiss
            id<AgoraEduClassroomDelegate> delegate = AgoraEduManager.shareManager.classroomDelegate;
            AgoraEduClassroom *classroom = AgoraEduManager.shareManager.classroom;
        
            [AgoraEduManager releaseResource];
            [AgoraEduAlertViewUtil showAlertWithController:AgoraEduTopVC.topVC title:@"" message:AgoraEduLocalizedString(@"ClassroomEndText", nil) cancelText:nil sureText:AgoraEduLocalizedString(@"OKText", nil) cancelHandler:nil sureHandler:^(UIAlertAction * _Nullable action) {
                
                #pragma clang diagnostic push
                #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    SEL sel = NSSelectorFromString(@"dismissVC:classroom:");
                    if ([AgoraEduClassroom respondsToSelector:sel]) {
                        [AgoraEduClassroom performSelector:sel withObject:delegate withObject:classroom];
                    }
                #pragma clang diagnostic pop
            }];
            return;
        }
        
        [self onUpdateCourseState];
    }
}

- (void)classroomPropertyUpdated:(AgoraRTEClassroom *)classroom cause:(AgoraRTEObject *)cause {
     
    if(classroom.roomProperties == nil) {
        return;
    }
    
    // record
    NSInteger cmd = [NoNullNumber(NoNullDictionary(cause)[@"cmd"]) intValue];
    if(cmd == 1){
        AgoraRecordPropertyModel *model = [AgoraRecordPropertyModel yy_modelWithDictionary:classroom.roomProperties[ROOM_PROPERTY_KEY_RECORD]];
        
        // record over
        if(model.state == 0) {
            [self onEndRecord];
        }
    }
  
    [self onUnknownPropertyUpdated:classroom cause:cause];
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    self.isChatTextFieldKeyboard = YES;
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    self.isChatTextFieldKeyboard =  NO;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
        
    NSString *content = textField.text;
    if (content.length > 0) {
        WEAK(self);

        if (self.sceneType == AgoraRTESceneTypeBreakout) {
            // send big class room
            [AgoraEduManager.shareManager.groupRoomManager getClassroomInfoWithSuccess:^(AgoraRTEClassroom * _Nonnull room) {
                
                AgoraTextMessageModel *model = [AgoraTextMessageModel new];
                model.content = content;
                model.fromRoomUuid = room.roomInfo.roomUuid;
                model.fromRoomName = room.roomInfo.roomName;
                model.role = AgoraRTERoleTypeStudent;

                [AgoraEduManager.shareManager.groupStudentService sendRoomChatMessageWithText:[model yy_modelToJSONString] success:^{
                    
                } failure:^(NSError * error) {
                    [AgoraBaseViewController showToast:error.localizedDescription];
                }];
                
                [AgoraEduManager.shareManager.studentService sendRoomChatMessageWithText:[model yy_modelToJSONString] success:^{
                    
                    AgoraEETextMessage *message = [AgoraEETextMessage new];
                    message.fromUser = weakself.localUser;
                    message.message = content;
                    message.timestamp = [[NSDate date] timeIntervalSince1970] * 1000;
                    [weakself onSendMessage:message];

                } failure:^(NSError * error) {
                    [AgoraBaseViewController showToast:error.localizedDescription];
                }];
                
            } failure:^(NSError * error) {
                [AgoraBaseViewController showToast:error.localizedDescription];
            }];
            
        } else {
            
            AgoraRoomChatConfiguration *config = [AgoraRoomChatConfiguration new];
            config.appId = AgoraEduKeyCenter.agoraAppid;
            config.roomUuid = self.roomUuid;
            config.userUuid = self.userUuid;
            config.userToken = self.localUser.userToken;
            config.message = content;
            config.type = 1;
            config.token = AgoraEduManager.shareManager.token;
            [AgoraHTTPManager roomChatWithConfig:config success:^(AgoraBaseModel * _Nonnull model) {
                    
                AgoraEETextMessage *message = [AgoraEETextMessage new];
                message.fromUser = weakself.localUser;
                message.message = content;
                message.timestamp = [[NSDate date] timeIntervalSince1970] * 1000;
                [weakself onSendMessage:message];
                
            } failure:^(NSError * _Nonnull error, NSInteger statusCode) {
                [AgoraBaseViewController showToast:error.localizedDescription];
            }];
        }
    }
    textField.text = nil;
    [textField resignFirstResponder];
    return NO;
}

#pragma mark WhiteManagerDelegate
- (void)onWhiteBoardStateChanged:(WhiteBoardStateModel * _Nonnull)state {
    
    BOOL follow = state.follow;
    if (self.boardState.follow != follow) {
        [self onBoardFollowMode:follow];
    }
    
    NSArray<NSString *> *grantUsers = state.grantUsers;
    if([grantUsers containsObject:self.localUser.userUuid] && ![self.boardState.grantUsers containsObject:self.localUser.userUuid]) {
        
        [self onBoardPermissionGranted:grantUsers];

    } else if(![grantUsers containsObject:self.localUser.userUuid] && [self.boardState.grantUsers containsObject:self.localUser.userUuid]) {
      [self onBoardPermissionRevoked:grantUsers];
        
    } else {
      [self onBoardPermissionUpdated:grantUsers];
    }
    self.boardState = state;
}

#pragma mark Subclass implementation
- (void)onSyncSuccess {
}
- (void)onSendMessage:(AgoraEETextMessage *)message {
}
- (void)onReconnected {
}

- (void)onUpdateChatViews {
}
- (void)onUpdateCourseState {
}

// white board
- (void)onBoardFollowMode:(BOOL)enable {
}
- (void)onBoardPermissionGranted:(NSArray<NSString *> *)grantUsers {
}
- (void)onBoardPermissionRevoked:(NSArray<NSString *> *)grantUsers {
}
- (void)onBoardPermissionUpdated:(NSArray<NSString *> *)grantUsers {
}

//record
- (void)onEndRecord {
}
- (void)onUnknownPropertyUpdated:(AgoraRTEClassroom *)classroom cause:(AgoraRTEObject *)cause {
}

@end
