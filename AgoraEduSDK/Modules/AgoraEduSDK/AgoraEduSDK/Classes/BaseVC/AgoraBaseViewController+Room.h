//
//  AgoraBaseViewController+Room.h
//  AgoraEduSDK
//
//  Created by SRS on 2021/3/14.
//  Copyright © 2021 Agora. All rights reserved.
//

#import "AgoraBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface AgoraBaseViewController (Room)<AgoraEduRoomContext>
- (void)onSetClassroomName:(NSString *)roomName;
- (void)onSetClassState:(AgoraEduContextClassState)state;
- (void)onSetClassTime:(NSString *)time;
- (void)onShowClassTips:(NSString *)message;

- (void)onSetNetworkQuality:(AgoraEduContextNetworkQuality)quality;
- (void)onSetConnectionState:(AgoraEduContextConnectionState)state;
@end

NS_ASSUME_NONNULL_END
