//
//  AgoraBaseViewController.m
//  AgoraEducation
//
//  Created by SRS on 2020/8/3.
//  Copyright © 2020 Agora. All rights reserved.
//

#import "AgoraBaseViewController.h"
#import "AgoraHttpModel.h"
#import "ApaasUser.pbobjc.h"
#import <EduSDK/AgoraRTCManager.h>

#define FlexPropsKey @"flexProps"
#define FlexPropsCauseDataKey @"data"

@interface AgoraBaseViewController () <AgoraRTEManagerDelegate,
                                       AgoraRTEClassroomDelegate,
                                       AgoraRTEStudentDelegate,
                                       AgoraRTEMediaStreamDelegate,
                                       AgoraRootController,
                                       AgoraBoardControllerDelegate,
                                       AgoraExtAppsControllerDataSource,
                                       AgoraURLGroupDataSource,
                                       AgoraDeviceControllerDelegate>
@property (nonatomic, strong) AgoraUIManager *uimanager;
@property (nonatomic, strong) AgoraBoardController *boardController;
@property (nonatomic, strong) AgoraEduExtAppsController *appsController;
@property (nonatomic, strong) AgoraEduWidgetController *widgetsController;
@property (nonatomic, strong) AgoraScreenShareController *screenShareController;
@property (nonatomic, strong) AgoraDeviceController *deviceController;
@property (nonatomic, strong) AgoraMediaController *mediaController;
@property (nonatomic, strong) AgoraManagerCache *cache;
@property (nonatomic, strong) AgoraDownloadManager *download;
@property (nonatomic, strong) AgoraKeyGroup *keyGroup;
@property (nonatomic, strong) AgoraURLGroup *urlGroup;
@end

@implementation AgoraBaseViewController

@synthesize children;

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initData];
    [self initChildren];
    [self childrenViewDidLoad];
    [self initContextPool];
    [self initView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self childrenViewDidAppear];
}

- (BOOL)shouldAutorotate {
    return YES;
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

- (void)releaseVM {
    self.roomVM = nil;
    self.userVM = nil;
    self.chatVM = nil;
    self.handsUpVM = nil;
    self.screenVM = nil;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (AgoraEduContextPoolIMP *)contextPool {
    if (_contextPool == nil) {
        _contextPool = [AgoraEduContextPoolIMP new];
    }
    return _contextPool;
}

#pragma mark - Private ContextPool
- (void)initContextPool {
    self.contextPool.whiteBoardIMP = self.boardController;
    self.contextPool.whiteBoardToolIMP = self.boardController;
    self.contextPool.whiteBoardPageControlIMP = self.boardController;
    self.contextPool.extAppIMP = self.appsController;
    self.contextPool.chatIMP = self;
    self.contextPool.roomIMP = self;
    self.contextPool.userIMP = self;
    self.contextPool.handsUpIMP = self;
    self.contextPool.shareScreenIMP = self.screenShareController;
    self.contextPool.widgetIMP = self.widgetsController;
    self.contextPool.deviceIMP = self.deviceController;
    self.contextPool.mediaIMP = self.mediaController;

    self.eventDispatcher = [AgoraUIEventDispatcher new];
}

#pragma mark - Private Rect
- (void)initView {
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    if (@available(iOS 11, *)) {
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.view.backgroundColor = UIColor.blackColor;

    [self widgetsController];
    AgoraEduContextAppType appType = (AgoraEduContextAppType)self.vmConfig.sceneType;

    self.uimanager = [self.contextPool agoraUIManager:appType];
    [self.view addSubview:self.uimanager.appView];
    self.appView = self.uimanager.appView;
    self.appView.agora_center_x = 0;
    self.appView.agora_center_y = 0;
    self.appView.agora_width = AgoraLayoutAssist.agoraRealMaxWidth;
    self.appView.agora_height = AgoraLayoutAssist.agoraRealMaxHeight;

    [self.view addSubview:self.appsController.containerView];
    self.appsController.containerView.agora_center_x = 0;
    self.appsController.containerView.agora_center_y = 0;
    self.appsController.containerView.agora_width = self.appView.agora_width;
    self.appsController.containerView.agora_height = self.appView.agora_height;
}

#pragma mark AgoraEduRoomContext
// 加入房间
- (void)joinClassroom {
    __weak AgoraBaseViewController *weakself = self;
    [self.roomVM joinClassroomWithSuccessBlock:^(AgoraRTELocalUser *localUser, uint64_t timestamp) {

        // apaas的小班课是4， 上报rtc也是4
        NSInteger appScenario = weakself.vmConfig.sceneType;
        // 0代表aPaaS， 1代表PaaS
        NSInteger serviceType = 0;
        NSString *appVersion = AgoraClassroomSDK.version;
        [AgoraEduManager.shareManager.eduManager reportAppScenario:appScenario
                                                       serviceType:serviceType
                                                        appVersion:appVersion];
        
        // Report
        AgoraRTEClassroomManager *manager = AgoraEduManager.shareManager.roomManager;
        AgoraReportor *report = [ApaasReporterWrapper getApaasReportor];
        AgoraReportorContextV2 *context = report.contextV2;
        context.streamUuid = localUser.streamUuid;
        context.streamSessionId = [[AgoraRTCManager shareManager] getCallIdWithChannelId:self.vmConfig.roomUuid];
        context.rtmSid = [[AgoraRTMManager shareManager] getSessionId];
        context.roomCreatTs = timestamp;
        [report setV2WithContext:context];
       
        NSLog(@"context.streamSessionId: %@", context.streamSessionId);
        
        [ApaasReporterWrapper localUserJoin];
        
        [manager getClassroomInfoWithSuccess:^(AgoraRTEClassroom * _Nonnull room) {
            [weakself flexRoomPropsInitialize:room];
            [weakself updateExtApps:room];
            [weakself updateClassState];
            [weakself.widgetsController updateRoomProperties:room.roomProperties];
            
            [weakself.eventDispatcher onClassroomJoined];
            
        } failure:nil];
        
        AgoraEduManager.shareManager.studentService.delegate = weakself;
        AgoraEduManager.shareManager.studentService.mediaStreamDelegate = weakself;

        [weakself.chatVM setLocalUser:localUser];
        [weakself.userVM setLocalUser:localUser];
        [weakself updateRoomChatPermission];

        if ([weakself respondsToSelector:@selector(onJoinClassroomSuccess)]) {
            [weakself onJoinClassroomSuccess];
        }
        if ([weakself respondsToSelector:@selector(onSetClassroomName:)]) {
            [weakself onSetClassroomName:weakself.vmConfig.className];
        }
        
        [weakself.deviceController initDeviceState];

        [weakself.userVM initKitUserInfos:^{
            [weakself updateAllList];

        } failureBlock:^(AgoraEduContextError *error) {
            [weakself onShowErrorInfo:error];
        }];

    } failureBlock:^(AgoraEduContextError *error) {
        [weakself onShowErrorInfo:error];
    }];
}

#pragma mark - Private Data
- (void)initData {
    AgoraWEAK(self);

    self.keyGroup.agoraAppId = self.vmConfig.appId;
    self.keyGroup.localUserUuid = self.vmConfig.userUuid;
    self.keyGroup.rtmToken = self.vmConfig.token;

    self.roomVM = [[AgoraRoomVM alloc] initWithConfig:self.vmConfig];
    self.roomVM.classOverBlock = ^{
        [weakself updateClassState];
    };
    self.roomVM.timerToastBlock = ^(NSString *message) {
        if ([weakself respondsToSelector:@selector(onShowClassTips:)]) {
            [weakself onShowClassTips:message];
        }
    };
    self.roomVM.updateTimerBlock = ^(NSString *timerString) {
        if ([weakself respondsToSelector:@selector(onSetClassTime:)]) {
            [weakself onSetClassTime:timerString];
        }
    };

    self.userVM = [[AgoraUserVM alloc] initWithConfig:self.vmConfig];
    self.chatVM = [[AgoraChatVM alloc] initWithConfig:self.vmConfig];

    AgoraEduManager.shareManager.eduManager.delegate = self;
    AgoraEduManager.shareManager.roomManager.delegate = self;
}

- (void)initChildren {
    self.children = [NSMutableArray array];

    id<AgoraController> board = [self createBoardController];
    [self addChildWithChild:board];

    id<AgoraController> extApps = [self createExtAppsController];
    [self addChildWithChild:extApps];
    
    id<AgoraController> screenShare = [self createScreenShareController];
    [self addChildWithChild:screenShare];
    
    id<AgoraController> device = [self createDeviceController];
    [self addChildWithChild:device];
    
    id<AgoraController> media = [self createMediaController];
    [self addChildWithChild:media];
}

#pragma mark - AgoraRootController
- (void)addChildWithChild:(id<AgoraController>)child {
    NSMutableArray *children = (NSMutableArray *)self.children;
    [children addObject:child];
}

- (void)removeChildWithChild:(id<AgoraController>)child {
    NSMutableArray *children = (NSMutableArray *)self.children;
    [children removeObject:child];
}

- (void)childrenViewWillAppear {
    for (id<AgoraController> child in self.children) {
        [child viewWillAppear];
    }
}

- (void)childrenViewDidLoad {
    for (id<AgoraController> child in self.children) {
        [child viewDidLoad];
    }
}

- (void)childrenViewDidAppear {
    for (id<AgoraController> child in self.children) {
        [child viewDidAppear];
    }
}

- (void)childrenViewWillDisappear {
    for (id<AgoraController> child in self.children) {
        [child viewWillDisappear];
    }
}

- (void)childrenViewDidDisappear {
    for (id<AgoraController> child in self.children) {
        [child viewDidDisappear];
    }
}

#pragma mark - WhiteBoarController
- (id<AgoraController>)createBoardController {
    NSString *boardAppId = self.cache.boardAppId;
    
    NSString *boardId = @"";
    NSString *boardToken = @"";
    
    AgoraRoomStateInfoModel *stateModel = self.cache.roomStateInfoModel;
    if ([stateModel isKindOfClass:AgoraRoomStateInfoModel.class]) {
        boardId = stateModel.board.boardId;
        boardToken = stateModel.board.boardToken;
    }

    NSString *userId = self.vmConfig.userUuid;
    id<AgoraApaasReportorEventTube> reportor = (id<AgoraApaasReportorEventTube>)[ApaasReporterWrapper getApaasReportor];
    
    self.boardController = [[AgoraBoardController alloc] initWithBoardAppId:boardAppId
                                                                    boardId:boardId
                                                                 boardToken:boardToken
                                                                   userUuid:userId
                                                            collectionStyle:AgoraManagerCache.share.collectionStyle
                                                                boardStyles:AgoraManagerCache.share.boardStyles
                                                                   download:self.download
                                                                   reportor:reportor
                                                                      cache:self.cache
                                                              boardAutoMode:self.vmConfig.boardAutoFitMode
                                                                   delegate:self];
    return self.boardController;
}

#pragma mark - AgoraScreenShareController
- (id<AgoraController>)createScreenShareController {
    self.screenShareController = [[AgoraScreenShareController alloc] initWithVmConfig:self.vmConfig];
    return self.screenShareController;
}

#pragma mark - AgoraMediaController
- (id<AgoraController>)createMediaController {
    self.mediaController = [[AgoraMediaController alloc] initWithVmConfig:self.vmConfig];
    return self.mediaController;
}

#pragma mark - AgoraDeviceController
- (id<AgoraController>)createDeviceController {
    self.deviceController = [[AgoraDeviceController alloc] initWithVmConfig:self.vmConfig
                                                                   delegate:self];
    
    AgoraWEAK(self);
//    self.userVM.onStreamStatesChangedBlock = ^(NSDictionary<NSString *,AgoraDeviceStreamState *> * _Nonnull streamStates,
//                                               AgoraDeviceStateType deviceType) {
//        [weakself.deviceController updateRteStreamStates:streamStates
//                                              deviceType:deviceType];
//    };
//    self.userVM.onResetStreamStatesBlock = ^(NSDictionary<NSString *,AgoraDeviceStreamState *> * _Nonnull streamStates) {
//        [weakself.deviceController resetRteStreamStates:streamStates];
//    };
//
    self.userVM.userDeviceStateBlock = ^enum AgoraEduContextDeviceState(enum AgoraDeviceStateType deviceStateType,
                                                                        AgoraRTEUser * _Nonnull user,
                                                                        AgoraRTEStream * _Nullable stream) {
        switch (deviceStateType) {
            case AgoraDeviceStateTypeCamera:
                return [weakself.deviceController getCameraStateWithUser:user
                                                                  stream:stream];
                break;
            case AgoraDeviceStateTypeMicrophone:
                return [weakself.deviceController getMicroStateWithUser:user
                                                                 stream:stream];
            default:
                break;
        }
    };
    return self.deviceController;
}

#pragma mark - ExtAppsController
- (id<AgoraController>)createExtAppsController {
    self.appsController = [[AgoraEduExtAppsController alloc] initWithUrlGroup:self.urlGroup
                                                                  contextPool:self.contextPool.eduContextPool];
    self.appsController.dataSource = self;

    if (AgoraManagerCache.share.extApps.count > 0) {
        NSArray *apps = AgoraManagerCache.share.extApps;
        [self.appsController registerApps:apps];
    }

    return self.appsController;
}

- (void)registerExtApps:(NSArray<AgoraExtAppConfiguration *> *)apps {
    if (apps.count <= 0) {
        return;
    }

    [self.appsController registerApps:apps];
}

- (void)registerWidgets:(NSArray<AgoraWidgetConfiguration *> *)widgets {
    if (widgets.count <= 0) {
        return;
    }
    
    [self.widgetsController registerWidgets:widgets];
}

- (void)appsController:(AgoraExtAppsController *)controller
needPropertiesOfExtAppIdentifier:(NSString *)appIdentifier
            properties:(void (^)(NSDictionary * _Nonnull))properties {
    AgoraRTEClassroomManager *roomManager = AgoraEduManager.shareManager.roomManager;

    [roomManager getClassroomInfoWithSuccess:^(AgoraRTEClassroom * _Nonnull room) {
        NSDictionary *extAppsDic = room.roomProperties[@"extApps"];

        NSDictionary *extAppDic = extAppsDic[appIdentifier];
        
        if (!extAppDic) {
            extAppDic = [NSDictionary dictionary];
        }

        if (properties && extAppDic) {
            properties(extAppDic);
        }
    } failure:nil];
}

- (void)appsController:(AgoraExtAppsController *)controller
          needUserInfo:(void (^)(AgoraExtAppUserInfo * _Nonnull))userInfo
          needRoomInfo:(void (^)(AgoraExtAppRoomInfo * _Nonnull))roomInfo {
    __weak AgoraBaseViewController *weakself = self;
    AgoraRTEClassroomManager *roomManager = AgoraEduManager.shareManager.roomManager;

    [roomManager getLocalUserWithSuccess:^(AgoraRTELocalUser * _Nonnull user) {
        NSString *roleString = [weakself getDescriptionWithRole:user.role];
        AgoraExtAppUserInfo *userModel = [[AgoraExtAppUserInfo alloc] initWithUserUuid:user.userUuid
                                                                              userName:user.userName
                                                                              userRole:roleString];
        if (userInfo) {
            userInfo(userModel);
        }
    } failure:nil];

    [roomManager getClassroomInfoWithSuccess:^(AgoraRTEClassroom * _Nonnull room) {
        AgoraExtAppRoomInfo *roomModel = [[AgoraExtAppRoomInfo alloc] initWithRoomUuid:room.roomInfo.roomUuid
                                                                              roomName:room.roomInfo.roomName
                                                                              roomType:weakself.vmConfig.sceneType];
        if (roomInfo) {
            roomInfo(roomModel);
        }
    } failure:nil];
}

- (void)appsController:(AgoraExtAppsController *)controller
       syncAppPosition:(NSString *)appIdentifier
             diffPoint:(CGPoint)diffPoint {
    // 设置到白板
    [self.boardController syncAppPositionWithAppIdentifier:appIdentifier
                                                 diffPoint:diffPoint];
}

- (NSString *)getDescriptionWithRole:(AgoraRTERoleType)role {
    switch (role) {
        case AgoraRTERoleTypeStudent:
            return @"student";
        case AgoraRTERoleTypeTeacher:
            return @"teacher";
        case AgoraRTERoleTypeAssistant:
            return @"assistant";
        default:
            return @"";
    }
}

#pragma mark - AgoraDeviceControllerDelegate
- (void)deviceController:(AgoraDeviceController *)controller
           didOccurError:(AgoraEduContextError *)error {
    [self onShowErrorInfo:error];
}

- (void)deviceController:(AgoraDeviceController *)controller
   didCameraStateChanged:(enum AgoraEduContextDeviceState)cameraState
    didMicroStateChanged:(enum AgoraEduContextDeviceState)microState fromUser:(AgoraRTEUser *)user {
    
    [self.userVM updateKitUserDeviceWithRteUser:user
                                    cameraState:cameraState
                                     microState:microState];
    [self updateAllList];
}

#pragma mark - AgoraBoardControllerDelegate
- (void)boardController:(AgoraBoardController *)controller
        didUpdateUsers:(NSArray<NSString *> *)usersId {

    AgoraWEAK(self);
    [self.userVM updateUsersBoardGranted:usersId completeBlock:^{
        [weakself updateAllList];
    }];
}

- (void)boardController:(AgoraBoardController *)controller
    didScenePathChanged:(NSString *)path {
//    [self.screenShareController updateScenePath:path];
}

- (void)boardController:(AgoraBoardController *)controller
     didPositionUpdated:(NSString *)appIdentifier
              diffPoint:(CGPoint)diffPoint {
    [self.appsController syncAppPosition:appIdentifier
                               diffPoint:diffPoint];
}

- (void)boardController:(AgoraBoardController *)controller
          didOccurError:(NSError *)error {
    AgoraEduContextError *kitError = [[AgoraEduContextError alloc] initWithCode:error.code
                                                                        message:error.localizedDescription];
    [self onShowErrorInfo:kitError];
}

- (void)classroom:(AgoraRTEClassroom *)classroom
connectionStateChanged:(AgoraRTEConnectionState)state {
    if ([self.roomVM isReconnected:state]) {
        [self updateRoomChatPermission];
        [self updateClassState];
    }

    if (state == AgoraRTEConnectionStateAborted) {
        [AgoraEduManager releaseResource];
    }

    if ([self respondsToSelector:@selector(onSetConnectionState:)]) {
        [self onSetConnectionState:[self.roomVM getConnectionState:state]];
    }
    
    if (state == AgoraRTEConnectionStateReconnecting) {
        [ApaasReporterWrapper localUserReconnect];
    }
}

- (void)classroomPropertyUpdated:(NSDictionary *)changedProperties
                       classroom:(AgoraRTEClassroom *)classroom
                           cause:(NSDictionary * _Nullable)cause
                    operatorUser:(AgoraRTEBaseUser *)operatorUser {
    [self updateExtApps:classroom];

    [self.widgetsController updateRoomProperties:classroom.roomProperties];
        
    [self flexRoomPropsChanged:changedProperties
                     classroom:classroom
                         cause:cause
                  operatorUser:operatorUser];
}

// message
- (void)classroom:(AgoraRTEClassroom * _Nonnull)classroom
roomChatMessageReceived:(AgoraRTETextMessage *)textMessage {
    if ([self respondsToSelector:@selector(onAddRoomMessage:)]) {
        AgoraEduContextChatInfo *chatInfo = [self.chatVM kitChatInfoWithRteMessage:textMessage];
        [self onAddRoomMessage:chatInfo];
    }
}

- (void)classroom:(AgoraRTEClassroom *)classroom
     stateUpdated:(AgoraRTEClassroomChangeType)changeType
     operatorUser:(AgoraRTEBaseUser *)user {
    AgoraWEAK(self);
    
    switch (changeType) {
        case AgoraRTEClassroomChangeTypeAllStudentsChat: {
            [self.roomVM getRoomMuteChatWithSuccessBlock:^(BOOL muteChat) {

                if ([weakself respondsToSelector:@selector(updateRoomChatState:)]) {
                    [weakself updateRoomChatState:muteChat];
                }

                if ([weakself respondsToSelector:@selector(onShowChatTips:)]) {
                    NSString *message = [weakself.chatVM getRoomChatTipMessage:muteChat];
                    [weakself onShowChatTips:message];
                }

            } failureBlock:^(AgoraEduContextError *error) {
                [weakself onShowErrorInfo:error];
            }];
            break;
        }
        case AgoraRTEClassroomChangeTypeCourseState:
            [self updateClassState];
            break;
        default:
            break;
    }
}

- (void)classroom:(AgoraRTEClassroom * _Nonnull)classroom
remoteRTCJoinedOfStreamId:(nonnull NSString *)streamId {
    [self.screenShareController rtcStreamChanged:streamId
                                        rtcState:AgoraScreenShareRTCStateOnLine];
}

- (void)classroom:(AgoraRTEClassroom * _Nonnull)classroom
remoteRTCOfflineOfStreamId:(nonnull NSString *)streamId {
    [self.screenShareController rtcStreamChanged:streamId
                                        rtcState:AgoraScreenShareRTCStateOffLine];
}

- (void)classroom:(AgoraRTEClassroom * _Nonnull)classroom
networkQualityChanged:(AgoraRTENetworkQuality)quality
             user:(AgoraRTEBaseUser *)user {
    if ([user.userUuid isEqualToString: self.vmConfig.userUuid]) {
        if ([self respondsToSelector:@selector(onSetNetworkQuality:)]) {
            [self onSetNetworkQuality:[self.roomVM getNetworkQuality:quality]];
        }
    }
}

- (void)classroom:(AgoraRTEClassroom *)classroom
remoteUserPropertyUpdated:(NSDictionary *)changedProperties
             user:(AgoraRTEUser *)user
            cause:(NSDictionary * _Nullable)cause
     operatorUser:(AgoraRTEBaseUser *)operatorUser {
    [self.deviceController updateDeviceStateWithUser:user cause:cause];
    
    AgoraWEAK(self);
    [self.chatVM updateUserChat:user
                          cause:cause
                  completeBlock:^(BOOL muteChat,
                                  AgoraEduContextUserInfo *toUser,
                                  AgoraEduContextUserInfo *byUser) {
        [weakself updateRemoteChatState:muteChat
                                     to:toUser
                                     by:byUser];
        
        [weakself.userVM updateUserMuteChat:toUser.userUuid
                                   muteChat:muteChat];
        [weakself updateAllList];
    }];
    
    [self flexUserPropsChanged:changedProperties
                          user:user
                         cause:cause
                  operatorUser:operatorUser];
}

- (void)classroom:(AgoraRTEClassroom * _Nonnull)classroom
  remoteUsersInit:(NSArray<AgoraRTEUser*> *)users {
    [self updateUsers:users
           changeType:AgoraInfoChangeTypeAdd];
}

- (void)classroom:(AgoraRTEClassroom * _Nonnull)classroom
remoteUsersJoined:(NSArray<AgoraRTEUser*> *)users {
    [self updateUsers:users
           changeType:AgoraInfoChangeTypeAdd];
}

- (void)classroom:(AgoraRTEClassroom * _Nonnull)classroom
  remoteUsersLeft:(NSArray<AgoraRTEUserEvent*> *)events
         leftType:(AgoraRTEUserLeftType)type {
    [self updateUserEvents:events
                changeType:AgoraInfoChangeTypeRemove];
}

// stream
- (void)classroom:(AgoraRTEClassroom * _Nonnull)classroom
remoteStreamsInit:(NSArray<AgoraRTEStream*> *)streams {
    [self updateStreams:streams
             changeType:AgoraInfoChangeTypeAdd];
}

- (void)classroom:(AgoraRTEClassroom * _Nonnull)classroom
remoteStreamsAdded:(NSArray<AgoraRTEStreamEvent*> *)events {
    [self updateStreamEvents:events
                  changeType:AgoraInfoChangeTypeAdd];
}

- (void)classroom:(AgoraRTEClassroom *)classroom
remoteStreamUpdated:(NSArray<AgoraRTEStreamEvent*> *)events {
    [self updateStreamEvents:events
                  changeType:AgoraInfoChangeTypeUpdate];
}

- (void)classroom:(AgoraRTEClassroom * _Nonnull)classroom
remoteStreamsRemoved:(NSArray<AgoraRTEStreamEvent*> *)events  {
    [self updateStreamEvents:events
                  changeType:AgoraInfoChangeTypeRemove];
}

#pragma mark - AgoraRTEStudentDelegate
- (void)localUserLeft:(AgoraRTEUserEvent*)event
             leftType:(AgoraRTEUserLeftType)type {
    if (type == AgoraRTEUserLeftTypeKickOff) {
        [self releaseVM];
        [AgoraEduManager releaseResource];
        if ([self respondsToSelector:@selector(onKickedOut)]) {
            [self onKickedOut];
        }
    }
// 有时候网络不好， 会收到自己离开 又加入的消息
//    [self updateUserEvents:[event] changeType:AgoraInfoChangeTypeAdd];
}

- (void)localStreamAdded:(AgoraRTEStreamEvent*)event {
    // 先更新本地流状态
    [self.userVM updateLocalStream:event type: AgoraInfoChangeTypeAdd];
    
    [self updateStreamEvents:@[event]
                  changeType:AgoraInfoChangeTypeAdd];
    
    // 流状态更新后，RTE会先更新状态，需要重置下
    [self.deviceController updateLocalDeviceState:event.modifiedStream];
}

- (void)localStreamRemoved:(AgoraRTEStreamEvent*)event {
    // 先更新本地流状态
    [self.userVM updateLocalStream:event
                              type:AgoraInfoChangeTypeRemove];
    [self updateStreamEvents:@[event]
                  changeType:AgoraInfoChangeTypeRemove];
}

- (void)localStreamUpdated:(AgoraRTEStreamEvent*)event {
    // 先更新本地流状态
    [self.userVM updateLocalStream:event
                              type:AgoraInfoChangeTypeUpdate];
    
    [self updateStreamEvents:@[event]
                  changeType:AgoraInfoChangeTypeUpdate];

    NSString *message = [self.userVM getStreamTipMessage:event];
    if (message && [self respondsToSelector:@selector(onShowUserTips:)]) {
        [self onShowUserTips:message];
    }
    
    // 流状态更新后，RTE会先更新状态，需要重置下
    [self.deviceController updateLocalDeviceState:event.modifiedStream];
}

- (void)localUserStateUpdated:(AgoraRTEUserEvent*)event
                   changeType:(AgoraRTEUserStateChangeType)changeType {
    // 没有单禁音视频
}

- (void)localUserPropertyUpdated:(NSDictionary *)changedProperties
                            user:(AgoraRTEUser *)user
                           cause:(NSDictionary * _Nullable)cause
                    operatorUser:(AgoraRTEBaseUser *)operatorUser {

    AgoraWEAK(self);
    [self.chatVM updateUserChat:user cause:cause
                  completeBlock:^(BOOL muteChat,
                                  AgoraEduContextUserInfo *toUser,
                                  AgoraEduContextUserInfo *byUser) {
        [weakself updateLocalChatState:muteChat
                                    to:toUser
                                    by:byUser];
        
        [weakself.userVM updateUserMuteChat:toUser.userUuid
                                   muteChat:muteChat];
        [weakself updateAllList];
    }];
    
    [self flexUserPropsChanged:changedProperties
                          user:user
                         cause:cause
                  operatorUser:operatorUser];
}

#pragma mark - AgoraRTEManagerDelegate
- (void)userChatMessageReceived:(AgoraRTETextMessage *)textMessage {
    if ([self respondsToSelector:@selector(onAddConversationMessage:)]) {
        AgoraEduContextChatInfo *chatInfo = [self.chatVM kitChatInfoWithRteMessage:textMessage];
        [self onAddConversationMessage:chatInfo];
    }
}

#pragma mark - AgoraRTEMediaStreamDelegate
- (void)didChangeOfLocalVideoStream:(NSString *)streamId
                          withState:(AgoraRTEStreamState)state {
    [self updateStreamState:state
                       type:AgoraDeviceStateTypeCamera
                 streamUuid:streamId];
}

- (void)didChangeOfRemoteVideoStream:(NSString *)streamId
                           withState:(AgoraRTEStreamState)state {
//    [self updateStreamState:state
//                    isAudio:NO
//                    isVideo:YES
//                 streamUuid:streamId];
}

- (void)didChangeOfLocalAudioStream:(NSString *)streamId
                          withState:(AgoraRTEStreamState)state {
    [self updateStreamState:state
                       type:AgoraDeviceStateTypeMicrophone
                 streamUuid:streamId];
}

- (void)didChangeOfRemoteAudioStream:(NSString *)streamId
                           withState:(AgoraRTEStreamState)state {
//    [self updateStreamState:state
//                    isAudio:YES
//                    isVideo:NO
//                 streamUuid:streamId];
}

- (void)audioVolumeIndicationOfLocalStream:(NSString *)streamId
                                withVolume:(NSUInteger)volume {
    [self onUpdateAudioVolumeIndication:volume
                             streamUuid:streamId];
}

- (void)audioVolumeIndicationOfRemoteStream:(NSString *)streamId
                                 withVolume:(NSUInteger)volume {
    [self onUpdateAudioVolumeIndication:volume
                             streamUuid:streamId];
}

#pragma mark - Private--Update Room
- (void)updateRoomChatPermission {
    AgoraWEAK(self);
    [self.roomVM getRoomMuteChatWithSuccessBlock:^(BOOL mute) {
        if ([weakself respondsToSelector:@selector(updateRoomChatState:)]) {
            [weakself updateRoomChatState:mute];
        }
    } failureBlock:^(AgoraEduContextError *error) {
        [weakself onShowErrorInfo:error];
    }];
}

- (void)updateClassState {
    AgoraWEAK(self);
    [self.roomVM getClassStateWithSuccessBlock:^(AgoraEduContextClassState state) {
        
        NSString *message = [NSString stringWithFormat:@"%@%d", @"class state:", state];
        [AgoraEduManager.shareManager logMessage:message
                                           level:AgoraRTELogLevelInfo];
        
        if (state == AgoraEduContextClassStateClose) {
            [weakself releaseVM];
            [AgoraEduManager releaseResource];
        }

        if ([weakself respondsToSelector:@selector(onSetClassState:)]) {
            [weakself onSetClassState:state];
        }
    } failureBlock:^(AgoraEduContextError *error) {
        [weakself onShowErrorInfo:error];
    }];
}

- (void)updateExtApps:(AgoraRTEClassroom *)classroom {
    NSDictionary *extAppsCommonDic = classroom.roomProperties[@"extAppsCommon"];
    
    if (extAppsCommonDic && extAppsCommonDic.count > 0) {
        [self.appsController appsCommonDidUpdate:extAppsCommonDic];
    }
    
    NSDictionary *extAppsDic = classroom.roomProperties[@"extApps"];
    if (extAppsDic && extAppsDic.count > 0) {
        [self.appsController perExtAppPropertiesDidUpdate:extAppsDic];
    }
}

#pragma mark - Private--Update Stream
- (void)updateUsers:(NSArray<AgoraRTEUser *> *)rteUsers
         changeType:(AgoraInfoChangeType)changeType {
    AgoraWEAK(self);
    [self.userVM updateKitUserListWithRteUsers:rteUsers
                                          type:changeType
                                  successBlock:^{
        [weakself updateAllList];
    } failureBlock:^(AgoraEduContextError *error) {
        [weakself onShowErrorInfo:error];
    }];
}

- (void)updateUserEvents:(NSArray<AgoraRTEUserEvent *> *)rteUserEvents
              changeType:(AgoraInfoChangeType)changeType {
    AgoraWEAK(self);
    [self.userVM updateKitUserListWithRteUserEvents:rteUserEvents
                                               type:changeType
                                       successBlock:^{
        [weakself updateAllList];
    } failureBlock:^(AgoraEduContextError *error) {
        [weakself onShowErrorInfo:error];
    }];
}

#pragma mark - Private--Update Stream
- (void)updateStreams:(NSArray<AgoraRTEStream *> *)rteStreams
           changeType:(AgoraInfoChangeType)changeType {
    AgoraWEAK(self);
    [self.userVM updateKitStreamsWithRteStreams:rteStreams
                                           type:changeType
                                   successBlock:^{
        [weakself updateAllList];
        
    } failureBlock:^(AgoraEduContextError *error) {
        [weakself onShowErrorInfo:error];
    }];
    
    [self.screenShareController updateStreams:rteStreams
                                   changeType:changeType];
}

- (void)updateStreamEvents:(NSArray<AgoraRTEStreamEvent *> *)rteStreamEvents
                changeType:(AgoraInfoChangeType)changeType {
    AgoraWEAK(self);
    [self.userVM updateKitStreamsWithRteStreamEvents:rteStreamEvents
                                                type:changeType
                                        successBlock:^{
        [weakself updateAllList];
    } failureBlock:^(AgoraEduContextError *error) {
        [weakself onShowErrorInfo:error];
    }];

    [self.screenShareController updateStreamEvents:rteStreamEvents
                                        changeType:changeType];
}

#pragma mark - Private--Update UserList & CoHostList
- (void)updateAllList {
    if ([self respondsToSelector:@selector(onUpdateUserList:)]) {
        [self onUpdateUserList:self.userVM.kitUserInfos];
    }
    if ([self respondsToSelector:@selector(onUpdateCoHostList:)]) {
        [self onUpdateCoHostList:self.userVM.kitCoHostInfos];
    }
}

#pragma mark - FlexPropsChanged
- (void)flexUserPropsChanged:(NSDictionary *)changedProperties
                        user:(AgoraRTEUser *)user
                       cause:(NSDictionary * _Nullable)cause
                operatorUser:(AgoraRTEBaseUser *)operatorUser {
    
    // 确认properties 里面是不是flex
    if ([self.userVM isFlexPropsChangedWithCause:cause]) {
        if ([self respondsToSelector:@selector(onFlexUserPropertiesChanged:properties:cause:fromUser:operatorUser:)]) {
            AgoraEduContextUserInfo *baseUserInfo = [self.userVM getContextBaseUserInfo:operatorUser];
            AgoraEduContextUserDetailInfo *detailUserInfo = [self.userVM getContextDetailUserInfo:user];
            NSDictionary *fixChangedProperties = [self fixFlexPropsChangedPropertyKeys:changedProperties];
            
            [self onFlexUserPropertiesChanged:fixChangedProperties
                                   properties:user.userProperties[FlexPropsKey]
                                        cause:cause[FlexPropsCauseDataKey]
                                     fromUser:detailUserInfo
                                 operatorUser:baseUserInfo];
        }
    }
}
- (NSDictionary *)fixFlexPropsChangedPropertyKeys:(NSDictionary *)changedProperties {
    NSMutableDictionary *mapChangedProperties = [NSMutableDictionary dictionary];
    for (NSString *key in changedProperties.allKeys) {
        NSString *subString = [NSString stringWithFormat:@"%@.", FlexPropsKey];
        if (key.length <= subString.length) {
            continue;
        }
        NSString *newKey = [key substringFromIndex:subString.length];
        [mapChangedProperties setValue:changedProperties[key] forKey:newKey];
    }
    return mapChangedProperties;
}
- (void)flexRoomPropsChanged:(NSDictionary *)changedProperties
                   classroom:(AgoraRTEClassroom *)classroom
                       cause:(NSDictionary * _Nullable)cause
                operatorUser:(AgoraRTEBaseUser *)operatorUser {
    
    // 确认properties 里面是不是flex
    if ([self.userVM isFlexPropsChangedWithCause:cause]) {
        if ([self respondsToSelector:@selector(onFlexRoomPropertiesChanged:properties:cause:operatorUser:)]) {

            AgoraEduContextUserInfo *baseUserInfo = [self.userVM getContextBaseUserInfo:operatorUser];
            NSDictionary *fixChangedProperties = [self fixFlexPropsChangedPropertyKeys:changedProperties];
            [self onFlexRoomPropertiesChanged:fixChangedProperties
                                   properties:classroom.roomProperties[FlexPropsKey]
                                        cause:cause[FlexPropsCauseDataKey]
                                 operatorUser:baseUserInfo];
        }
    }
}
- (void)flexRoomPropsInitialize:(AgoraRTEClassroom *)classroom {
    
    if (classroom.roomProperties == nil || classroom.roomProperties[FlexPropsKey] == nil) {
        return;
    }
    NSDictionary *properties = classroom.roomProperties[FlexPropsKey];
    if ([self respondsToSelector:@selector(onFlexRoomPropertiesInitialize:)]) {
        [self onFlexRoomPropertiesInitialize:properties];
    }
}

#pragma mark - Private--Update Stream State
- (void)updateStreamState:(AgoraRTEStreamState)state
                  type:(AgoraDeviceStateType)type
               streamUuid:(NSString *)streamUuid {
    
    // 更新 devicecontroller
    // 由devicecontroller delegate 回调里面更新userVM
    [self.deviceController updateLocalRteStreamStates:state
                                           deviceType:type
                                           streamUuid:streamUuid];;
}

#pragma mark - AgoraURLGroupDataSource
- (NSString *)needAgoraAppId {
    return self.keyGroup.agoraAppId;
}

- (NSString *)needAgoraRtmToken {
    return self.keyGroup.rtmToken;
}

- (NSString *)needLocalUserUuid {
    return self.keyGroup.localUserUuid;
}

#pragma mark - Private lazy load
- (AgoraManagerCache *)cache {
    if (!_cache) {
        _cache = [AgoraManagerCache share];
    }

    return _cache;
}

- (AgoraDownloadManager *)download {
    if (!_download) {
        _download = [AgoraDownloadManager shared];
    }

    return _download;
}

- (AgoraKeyGroup *)keyGroup {
    if (!_keyGroup) {
        _keyGroup = [[AgoraKeyGroup alloc] init];
    }

    return _keyGroup;
}

- (AgoraURLGroup *)urlGroup {
    if (!_urlGroup) {
        _urlGroup = [[AgoraURLGroup alloc] init];
        _urlGroup.host = self.host;
        _urlGroup.dataSource = self;
    }

    return _urlGroup;
}

- (AgoraEduWidgetController *)widgetsController {
    if (!_widgetsController) {
        _widgetsController = [[AgoraEduWidgetController alloc] init];
        
        AgoraEduWidgetHelper *helper = [[AgoraEduWidgetHelper alloc] init];
        [helper registerWidgets:_widgetsController];
        
        if (AgoraManagerCache.share.components.count > 0) {
            NSArray *widgets = AgoraManagerCache.share.components;
            [_widgetsController registerWidgets:widgets];
        }
    }
    
    return _widgetsController;
}
@end
