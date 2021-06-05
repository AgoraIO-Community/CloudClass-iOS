//
//  AgoraBaseViewController+User.m
//  AgoraEduSDK
//
//  Created by SRS on 2021/3/15.
//

#import "AgoraBaseViewController+User.h"

@implementation AgoraBaseViewController (User)

#pragma mark VCProcessDelegate
- (void)onUpdateUserList:(NSArray<AgoraEduContextUserDetailInfo*> *)list {
    [self.eventDispatcher onUpdateUserList: list];
}

- (void)onUpdateCoHostList:(NSArray<AgoraEduContextUserDetailInfo*> *)list {
    [self.eventDispatcher onUpdateCoHostList: list];
}

- (void)onKickedOut {
    [self.eventDispatcher onKickedOut];
}

- (void)onUpdateAudioVolumeIndication:(NSInteger)value
                           streamUuid:(NSString *)streamUuid {
    [self.eventDispatcher onUpdateAudioVolumeIndication:value
                                             streamUuid:streamUuid];
}

- (void)onShowUserTips:(NSString *)message {
    if (message == nil || message.length == 0) {
        return;
    }
    [self.eventDispatcher onShowUserTips:message];
}

- (void)onFlexUserPropertiesChanged:(NSDictionary *)changedProperties
                         properties:(NSDictionary *)properties
                              cause:(NSDictionary *)cause
                           fromUser:(AgoraEduContextUserDetailInfo *)fromUser
                       operatorUser:(AgoraEduContextUserInfo *)operatorUser {
    [self.eventDispatcher onFlexUserPropertiesChanged:changedProperties
                                           properties:properties
                                                cause:cause
                                             fromUser:fromUser
                                             operator:operatorUser];
}

#pragma mark AgoraEduUserContext
- (AgoraEduContextUserInfo *)getLocalUserInfo {
    return self.userVM.localBaseUserInfo;
}

- (void)updateFlexUserProperties:(NSString *)userUuid
                      properties:(NSDictionary<NSString *,NSString *> *)properties
                           cause:(NSDictionary<NSString *,NSString *> *)cause {
    [self.userVM updateUserProperties:userUuid
                           properties:properties
                                cause:cause
                         successBlock:^{}
                         failureBlock:^(AgoraEduContextError * _Nonnull error) {}];
}

- (void)muteVideo:(BOOL)mute {
    AgoraWEAK(self);
    [self.userVM updateLocalVideoStream:mute
                           successBlock:^(AgoraRTEStream *stream) {

    } failureBlock:^(AgoraEduContextError *error) {
        [weakself onShowErrorInfo:error];
    }];
}

- (void)muteAudio:(BOOL)mute {
    AgoraWEAK(self);
    [self.userVM updateLocalAudioStream:mute
                           successBlock:^(AgoraRTEStream *stream) {
            
    } failureBlock:^(AgoraEduContextError *error) {
        [weakself onShowErrorInfo:error];
    }];
}

- (void)renderView:(UIView * _Nullable)view
        streamUuid:(NSString *)streamUuid {
    
    AgoraWEAK(self);
    [self.userVM getStreamInfoWithStreamUuid:streamUuid
                                successBlock:^(AgoraRTEStream *stream) {
        AgoraRTERenderConfig *config = [AgoraRTERenderConfig new];
        config.renderMode = AgoraRTERenderModeHidden;
        
        if (stream.sourceType == AgoraRTEVideoSourceTypeScreen) {
            config.renderMode = AgoraRTERenderModeFit;
        }
        
        AgoraRTESubscribeOptions *options = [[AgoraRTESubscribeOptions alloc] init];
        options.subscribeAudio = stream.hasAudio;
        options.subscribeVideo = view ? YES : NO;
        
        [AgoraEduManager.shareManager.studentService subscribeStream:stream
                                                             options:options
                                                             success:^{
            
        } failure:^(NSError * _Nonnull error) {
            
        }];
        
        [AgoraEduManager.shareManager.studentService setStreamView:view
                                                            stream:stream
                                                      renderConfig:config];
    } failureBlock:^(AgoraEduContextError *error) {
        [weakself onShowErrorInfo:error];
    }];
}

- (void)registerEventHandler:(id<AgoraEduUserHandler>)handler {
    [self.eventDispatcher registerWithObject:handler eventType:AgoraUIEventTypeUser];
}
@end
