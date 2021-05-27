//
//  Agora1V1ViewController.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/10/30.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "Agora1V1ViewController.h"
#import "AgoraBaseViewController+Chat.h"
#import "AgoraBaseViewController+Room.h"
#import "AgoraBaseViewController+User.h"

@interface Agora1V1ViewController ()<AgoraRTEClassroomDelegate>

@end
 
@implementation Agora1V1ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark AgoraRTEClassroomDelegate
- (void)classroomPropertyUpdated:(AgoraRTEClassroom *)classroom cause:(AgoraRTEObject *)cause {
    [super classroomPropertyUpdated:classroom
                              cause:cause];

    AgoraWEAK(self);
//    NSDictionary<NSString*, AgoraEduContextUserDetailInfo*> *userDetailInfos = [self.userVM getChangedRewardsWithCause:cause];
//    NSArray<NSString *> *rewardUuids = userDetailInfos.allKeys;
//    if (rewardUuids.count > 0) {
//        [self.userVM updateKitUserListWithRewardUuids:rewardUuids cause:cause successBlock:^{
//            [weakself updateAllList];
//        } failureBlock:^(AgoraEduContextError *error) {
//            [weakself onShowErrorInfo:error];
//        }];
        
//        // 奖励更新
//        for (AgoraEduContextUserDetailInfo *userInfo in userDetailInfos.allValues) {
//
//            if (userInfo.user != nil) {
//                [self.appView onShowUserReward: userInfo.user];
//            }
//        }
//    }
}

#pragma mark --Private--Update UserList & CoHostList
- (void)updateAllList {
    if ([self respondsToSelector:@selector(onUpdateUserList:)]) {
        [self onUpdateUserList:self.userVM.kitUserInfos];
    }
}
@end
