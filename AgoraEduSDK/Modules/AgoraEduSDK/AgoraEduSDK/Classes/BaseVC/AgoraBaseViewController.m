//
//  AgoraBaseViewController.m
//  AgoraEducation
//
//  Created by SRS on 2020/8/3.
//  Copyright © 2020 Agora. All rights reserved.
//

#import "AgoraBaseViewController.h"

@interface AgoraBaseViewController () <AgoraRTEClassroomDelegate,
                                       AgoraRTEStudentDelegate,
                                       AgoraRTEMediaStreamDelegate,
                                       AgoraRootController,
                                       AgoraBoardControllerDelegate,
                                       AgoraExtAppsControllerDataSource,
                                       AgoraURLGroupDataSource>
@property (nonatomic, strong) AgoraUIManager *uimanager;
@property (nonatomic, strong) AgoraBoardController *boardController;
@property (nonatomic, strong) AgoraExtAppsController *appsController;
@property (nonatomic, strong) AgoraApaasReportor *reportor;
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

#pragma mark - Private ContextPool
- (void)initContextPool {
    self.contextPool = [AgoraEduContextPoolIMP new];
    self.contextPool.whiteBoardIMP = self.boardController;
    self.contextPool.whiteBoardToolIMP = self.boardController;
    self.contextPool.whiteBoardPageControlIMP = self.boardController;
    self.contextPool.extAppIMP = self.appsController;
    self.contextPool.chatIMP = self;
    self.contextPool.roomIMP = self;
    self.contextPool.userIMP = self;
    self.contextPool.handsUpIMP = self;
    self.contextPool.privateChatIMP = self;
    self.contextPool.shareScreenIMP = self;
    
    self.eventDispatcher = [AgoraUIEventDispatcher new];
}

#pragma mark - Private Rect
- (void)initView {
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    if (@available(iOS 11, *)) {
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    AgoraEduContextAppType appType = (AgoraEduContextAppType)self.vmConfig.sceneType;
    
    self.uimanager = [self.contextPool agoraUIManager:appType];
    [self.view addSubview:self.uimanager.appView];
    self.appView = self.uimanager.appView;
    self.appView.agora_x = 0;
    self.appView.agora_y = 0;
    self.appView.agora_right = 0;
    self.appView.agora_bottom = 0;
    
    [self.view addSubview:self.appsController.containerView];
    self.appsController.containerView.agora_safe_x = 0;
    self.appsController.containerView.agora_safe_y = 0;
    self.appsController.containerView.agora_safe_right = 0;
    self.appsController.containerView.agora_safe_bottom = 0;
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

    AgoraEduManager.shareManager.roomManager.delegate = self;
    [self.roomVM joinClassroomWithSuccessBlock:^(AgoraRTELocalUser *localUser) {
        
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
        
        [weakself.userVM initKitUserInfos:^{
            [weakself updateAllList];

        } failureBlock:^(AgoraEduContextError *error) {
            [weakself onShowErrorInfo:error];
        }];
    } failureBlock:^(AgoraEduContextError *error) {
        [weakself onShowErrorInfo:error];
    }];
}

- (void)initChildren {
    self.children = [NSMutableArray array];
    
    id<AgoraController> board = [self createBoardController];
    [self addChildWithChild:board];
    
    id<AgoraController> extApps = [self createExtAppsController];
    [self addChildWithChild:extApps];
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
    NSString *boardId = self.cache.roomStateInfoModel.board.boardId;
    NSString *boardToken = self.cache.roomStateInfoModel.board.boardToken;
    NSString *userId = self.vmConfig.userUuid;
    self.boardController = [[AgoraBoardController alloc] initWithBoardAppId:boardAppId
                                                                    boardId:boardId
                                                                 boardToken:boardToken
                                                                   userUuid:userId
                                                                   download:self.download
                                                                   reportor:self.reportor
                                                                      cache:self.cache
                                                                   delegate:self];
    return self.boardController;
}

#pragma mark - ExtAppsController
- (id<AgoraController>)createExtAppsController {
    self.appsController = [[AgoraEduExtAppsController alloc] initWithUrlGroup:self.urlGroup];
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

#pragma mark - AgoraBoardControllerDelegate
- (void)boardController:(AgoraBoardController *)controller
        didUpdateUsers:(NSArray<NSString *> *)usersId {
    
    AgoraWEAK(self);
    [self.userVM updateUsersBoardGranted:usersId completeBlock:^{
        [weakself updateAllList];
    }];
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
}

- (void)classroomPropertyUpdated:(AgoraRTEClassroom *)classroom
                           cause:(AgoraRTEObject *)cause {
    NSDictionary *extAppsDic = classroom.roomProperties[@"extApps"];
    
    if (extAppsDic) {
        [self.appsController updatePerExtAppProperties:extAppsDic];
    }
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
    if (changeType == AgoraRTEClassroomChangeTypeAllStudentsChat) {
        
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

    } else if (changeType == AgoraRTEClassroomChangeTypeCourseState) {
        [self updateClassState];
    }
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
remoteUserPropertyUpdated:(AgoraRTEUser *)user
            cause:(NSDictionary *)cause {
    [self updateDevice:user
                 cause:cause];
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
- (void)localUserLeft:(AgoraRTEUserEvent*)event leftType:(AgoraRTEUserLeftType)type {
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
    [self updateStreamEvents:@[event]
                  changeType:AgoraInfoChangeTypeAdd];
    [self.userVM updateLocalStream:event type: AgoraInfoChangeTypeAdd];
}

- (void)localStreamRemoved:(AgoraRTEStreamEvent*)event {
    [self.userVM updateLocalStream:event type: AgoraInfoChangeTypeRemove];
    [self updateStreamEvents:@[event]
                  changeType:AgoraInfoChangeTypeRemove];
}

- (void)localStreamUpdated:(AgoraRTEStreamEvent*)event {
    [self updateStreamEvents:@[event]
                  changeType:AgoraInfoChangeTypeUpdate];
    
    NSString *message = [self.userVM getStreamTipMessage:event];
    if (message && [self respondsToSelector:@selector(onShowUserTips:)]) {
        [self onShowUserTips:message];
    }
    
    [self.userVM updateLocalStream:event type: AgoraInfoChangeTypeUpdate];
}

- (void)localUserStateUpdated:(AgoraRTEUserEvent*)event
                   changeType:(AgoraRTEUserStateChangeType)changeType {
    // 没有单禁言
}

- (void)localUserPropertyUpdated:(AgoraRTEUser*)user
                           cause:(NSDictionary * _Nullable)cause {
    [self updateDevice:user cause:cause];
}

#pragma mark - AgoraRTEMediaStreamDelegate
- (void)didChangeOfLocalVideoStream:(NSString *)streamId
                          withState:(AgoraRTEStreamState)state {
    [self updateStreamState:state
                    isAudio:NO
                    isVideo:YES
                 streamUuid:streamId];
}

- (void)didChangeOfRemoteVideoStream:(NSString *)streamId
                           withState:(AgoraRTEStreamState)state {
    [self updateStreamState:state
                    isAudio:NO
                    isVideo:YES
                 streamUuid:streamId];
}

- (void)didChangeOfLocalAudioStream:(NSString *)streamId
                          withState:(AgoraRTEStreamState)state {
    [self updateStreamState:state
                    isAudio:YES
                    isVideo:NO
                 streamUuid:streamId];
}

- (void)didChangeOfRemoteAudioStream:(NSString *)streamId
                           withState:(AgoraRTEStreamState)state {
    [self updateStreamState:state
                    isAudio:YES
                    isVideo:NO
                 streamUuid:streamId];
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
    
    NSDictionary<NSString *,NSString *> *screenStreamInfos = [self.userVM getUpdateScreenStreamInfosWithRteStreams:rteStreams];
    if (screenStreamInfos.count > 0) {
        if ([self respondsToSelector:@selector(onUpdateScreenShareState:streamUuid:)]) {
            BOOL sharing = changeType == AgoraInfoChangeTypeRemove ? NO : YES;
            [self onUpdateScreenShareState:sharing
                              streamUuid:screenStreamInfos.allKeys.firstObject];
        }
    }

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
    
    NSDictionary<NSString *,NSString *> *screenStreamInfos = [self.userVM getUpdateScreenStreamInfosWithRteStreamEvents:rteStreamEvents];

    if (screenStreamInfos.count > 0) {
        if ([self respondsToSelector:@selector(onUpdateScreenShareState:streamUuid:)]) {
            BOOL sharing = changeType == AgoraInfoChangeTypeRemove ? NO : YES;
            NSString *subStr = sharing ? AgoraLocalizedString(@"ScreensharedBySb", nil) : AgoraLocalizedString(@"ScreenshareStoppedBySb", nil);
            NSString *message = [NSString stringWithFormat:@"%@%@",screenStreamInfos.allValues.firstObject,subStr];
            [self onShowScreenShareTips:message];
            [self onUpdateScreenShareState:sharing
                              streamUuid:screenStreamInfos.allKeys.firstObject];
        }
    }
}

#pragma mark - Private--Update Device
- (void)updateDevice:(AgoraRTEUser *)rteUser
               cause:(NSDictionary * _Nullable)cause {
    AgoraWEAK(self);
    [self.userVM updateKitUserDeviceWithRteUser:rteUser cause:cause successBlock:^{
        [weakself updateAllList];
    } failureBlock:^(AgoraEduContextError *error) {
        [weakself onShowErrorInfo:error];
    }];
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

#pragma mark - Private--Update Stream State
- (void)updateStreamState:(AgoraRTEStreamState)state
                  isAudio:(BOOL)isAudio
                  isVideo:(BOOL)isVideo
               streamUuid:(NSString *)streamUuid {
    AgoraWEAK(self);
    [self.userVM updateStreamState:state
                           isAudio:isAudio
                           isVideo:isVideo
                        streamUuid:streamUuid
                      successBlock:^{
        [weakself updateAllList];
    } failureBlock:^(AgoraEduContextError *error) {
        [weakself onShowErrorInfo:error];
    }];
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
- (AgoraApaasReportor *)reportor {
    if (!_reportor) {
        _reportor = AgoraApaasReportor.apaasShared;
    }
    
    return _reportor;
}

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
        _urlGroup.urlRegion = AgoraManagerCache.share.urlRegion;
        _urlGroup.dataSource = self;
    }
    
    return _urlGroup;
}
@end
