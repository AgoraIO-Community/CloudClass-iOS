//
//  AgoraLectureViewController.m
//  AgoraEduSDK
//
//  Created by Cavan on 2021/4/22.
//

#import "AgoraLectureViewController.h"
#import "AgoraBaseViewController+Chat.h"
#import "AgoraBaseViewController+Room.h"
#import "AgoraBaseViewController+User.h"
#import "AgoraBaseViewController+HandsUp.h"

@interface AgoraLectureViewController () <AgoraRTEClassroomDelegate, AgoraPrivateChatControllerDelegate>
@property (nonatomic, strong) AgoraPrivateChatController *privateChatController;
@end
 
@implementation AgoraLectureViewController
- (void)viewDidLoad {
    [super viewDidLoad];

    AgoraWEAK(self);
    self.handsUpVM = [[AgoraHandsUpVM alloc] initWithConfig:self.vmConfig];
    self.handsUpVM.updateEnableBlock = ^(BOOL enable) {
        if ([weakself respondsToSelector:@selector(onSetHandsUpEnable:)]) {
            [weakself onSetHandsUpEnable:enable];
        }
    };
    self.handsUpVM.updateHandsUpBlock = ^(AgoraEduContextHandsUpState state) {
        if ([weakself respondsToSelector:@selector(onSetHandsUpState:)]) {
            [weakself onSetHandsUpState:state];
        }
    };
    self.handsUpVM.showTipsBlock = ^(NSString *message) {
        if ([weakself respondsToSelector:@selector(onShowHandsUpTips:)]) {
            [weakself onShowHandsUpTips:message];
        }
    };
}

- (void)onJoinClassroomSuccess {
    AgoraWEAK(self);
    [self.handsUpVM initHandsUpStateWithSuccessBlock:^{
        // 更新数据
    } failureBlock:^(AgoraEduContextError *error) {
        [weakself onShowErrorInfo:error];
    }];
    
    // 初始化私密语音
    [self.privateChatController initPrivateChat];
}

#pragma mark - AgoraPrivateChatController
- (id<AgoraController>)createPrivateChatController {
    
    self.privateChatController = [[AgoraPrivateChatController alloc] initWithVmConfig:self.vmConfig delegate:self];
    self.contextPool.privateChatIMP = self.privateChatController;
    return self.privateChatController;
}

#pragma mark - AgoraPrivateChatControllerDelegate
- (void)privateChatController:(AgoraPrivateChatController *)controller
          didOccurError:(AgoraEduContextError *)error {
    [self onShowErrorInfo:error];
}

#pragma mark AgoraRTEClassroomDelegate
- (void)classroomPropertyUpdated:(AgoraRTEClassroom *)classroom cause:(AgoraRTEObject *)cause {
    [super classroomPropertyUpdated:classroom
                              cause:cause];
    
    AgoraWEAK(self);
    NSDictionary<NSString*, AgoraEduContextUserDetailInfo*> *userDetailInfos = [self.userVM getChangedRewardsWithCause:cause];
    NSArray<NSString *> *rewardUuids = userDetailInfos.allKeys;
    if (rewardUuids.count > 0) {
        [self.userVM updateKitUserListWithRewardUuids:rewardUuids cause:cause successBlock:^{
            [weakself updateAllList];
        } failureBlock:^(AgoraEduContextError *error) {
            [weakself onShowErrorInfo:error];
        }];
        
        // 奖励更新
        for (AgoraEduContextUserDetailInfo *userDetailInfo in userDetailInfos.allValues) {
            if (userDetailInfo.user != nil) {
                [self.eventDispatcher onShowUserReward:userDetailInfo.user];
            }
        }
    }
    
    // HandsUp
    [self.handsUpVM updateHandsUpInfoWithCause:cause successBlock:^() {

    } failureBlock:^(AgoraEduContextError *error) {
        [weakself onShowErrorInfo:error];
    }];
    
    // CoHost
    [self.handsUpVM getChangedCoHostsWithCause:cause completeBlock:^(NSArray<NSString *> *onCoHosts, NSArray<NSString *> *offCoHosts) {
            
        AgoraWEAK(self);
        [weakself.userVM updateKitUserListOnCoHosts:onCoHosts offCoHosts:offCoHosts successBlock:^{
            [weakself updateAllList];
        } failureBlock:^(AgoraEduContextError *error) {
            [weakself onShowErrorInfo:error];
        }];
    }];

    // 私密语音
    [self.privateChatController updatePrivateChatWithCause:cause];
}
- (void)classroom:(AgoraRTEClassroom * _Nonnull)classroom
remoteStreamsInit:(NSArray<AgoraRTEStream*> *)streams {
    [super classroom:classroom remoteStreamsInit:streams];
    for (AgoraRTEStream *stream in streams) {
        [self.privateChatController addRemoteStream:stream];
    }
}
- (void)classroom:(AgoraRTEClassroom * _Nonnull)classroom
remoteStreamsAdded:(NSArray<AgoraRTEStreamEvent*> *)events {
    [super classroom:classroom remoteStreamsAdded:events];
    for (AgoraRTEStreamEvent *event in events) {
        [self.privateChatController addRemoteStream:event.modifiedStream];
    }
}

#pragma mark --Private--Update UserList & CoHostList
- (void)updateAllList {
    if ([self respondsToSelector:@selector(onUpdateUserList:)]) {
        [self onUpdateUserList:self.userVM.kitUserInfos];
    }
    if ([self respondsToSelector:@selector(onUpdateCoHostList:)]) {
        [self onUpdateCoHostList:self.userVM.kitCoHostInfos];
    }
}

#pragma mark --Init Controllers
- (void)initChildren {
    [super initChildren];
    id<AgoraController> privateChat = [self createPrivateChatController];

    if ([self conformsToProtocol:@protocol(AgoraRootController)]) {
        id<AgoraRootController> rContoller = (id<AgoraRootController>)self;
        [rContoller addChildWithChild:privateChat];
    }
}

@end
