//
//  AgoraBaseViewController+Room.m
//  AgoraEduSDK
//
//  Created by SRS on 2021/3/14.
//  Copyright © 2021 Agora. All rights reserved.
//

//#import <AgoraEduContext/AgoraEduContext-Swift.h>
#import "AgoraBaseViewController+Room.h"
#import "ApaasUser.pbobjc.h"

@implementation AgoraBaseViewController (Room)

#pragma mark VCProcessDelegate
- (void)onSetClassroomName:(NSString *)roomName {
    [self.eventDispatcher onSetClassroomName:roomName];
}

- (void)onSetClassState:(AgoraEduContextClassState)state {
    [self.eventDispatcher onSetClassState:state];
}

- (void)onSetClassTime:(NSString *)time {
    [self.eventDispatcher onSetClassTime:time];
}

- (void)onShowClassTips:(NSString *)message {
    [self.eventDispatcher onShowClassTips:message];
}

- (void)onSetNetworkQuality:(AgoraEduContextNetworkQuality)quality {
    [self.eventDispatcher onSetNetworkQuality:quality];
}

- (void)onSetConnectionState:(AgoraEduContextConnectionState)state {
    [self.eventDispatcher onSetConnectionState:state];
}

- (void)onShowErrorInfo:(AgoraEduContextError *)error {
    [self.eventDispatcher onShowErrorInfo:error];
}

#pragma mark AgoraEduRoomContext
- (AgoraEduContextRoomInfo *)getRoomInfo {
    return self.roomVM.roomInfo;
}

- (void)uploadLog {
    __weak AgoraBaseViewController *weakSelf = self;
    
    [AgoraEduManager.shareManager uploadDebugItemSuccess:^(NSString * _Nonnull serialNumber) {
        [weakSelf.eventDispatcher onUploadLogSuccess:serialNumber];
    } failure:^(NSError * _Nonnull error) {
        AgoraEduContextError *eduError = [[AgoraEduContextError alloc] initWithCode:error.code
                                                                            message:error.localizedDescription];
        [weakSelf.eventDispatcher onShowErrorInfo:eduError];
    }];
}

- (void)leaveRoom {
    // Report
    [ApaasReporterWrapper localUserLeave];
    
    id<AgoraEduClassroomDelegate> delegate = AgoraManagerCache.share.classroomDelegate;
    AgoraEduClassroom *classroom = AgoraManagerCache.share.classroom;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    SEL sel = NSSelectorFromString(@"dismissVC:classroom:");
    if ([AgoraEduClassroom respondsToSelector:sel]) {
        [AgoraEduClassroom performSelector:sel withObject:delegate withObject:classroom];
    }
#pragma clang diagnostic pop
    
    [AgoraEduManager releaseResource];
}

// 事件监听
- (void)registerEventHandler:(id<AgoraEduRoomHandler>)handler {
    [self.eventDispatcher registerWithObject:handler];
}
@end
