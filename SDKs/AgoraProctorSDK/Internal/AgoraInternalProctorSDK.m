//
//  AgoraInternalClassroom.m
//  AgoraClassroomSDK
//
//  Created by Cavan on 2021/6/30.
//  Copyright © 2021 Agora. All rights reserved.
//

#import <AgoraProctorUI/AgoraProctorUI-Swift.h>
#import "AgoraInternalProctorSDK.h"
#import "AgoraProctorEnums.h"

@implementation AgoraProctorLaunchConfig (Internal)
- (BOOL)isLegal {
    if (self.userName.length <= 0) {
        return NO;
    }
    
    if (self.userUuid.length <= 0) {
        return NO;
    }
    
    if (self.roomName.length <= 0) {
        return NO;
    }
    
    if (self.roomUuid.length <= 0) {
        return NO;
    }
    
    if (self.appId.length <= 0) {
        return NO;
    }
    
    if (self.token.length <= 0) {
        return NO;
    }
    
    return YES;
}
@end

@implementation AgoraProctorSDK (Internal)
- (AgoraEduCoreLaunchConfig *)getCoreLaunchConfig:(AgoraProctorLaunchConfig *)config {
    AgoraEduCoreMediaOptions *mediaOptions = [self getPuppetMediaOptions:config.mediaOptions];
    
    AgoraEduCoreUserRole role = config.userRole;
    
    AgoraEduCoreRoomType roomType = AgoraEduCoreRoomTypeProctor;
    
    AgoraEduCoreLaunchConfig *launchConfig = [[AgoraEduCoreLaunchConfig alloc] initWithUserName:config.userName
                                                                                       userUuid:config.userUuid
                                                                                       userRole:role
                                                                                 userProperties:config.userProperties
                                                                                       roomName:config.roomName
                                                                                       roomUuid:config.roomUuid
                                                                                       roomType:roomType
                                                                                      startTime:nil
                                                                                       duration:nil
                                                                                          appId:config.appId
                                                                                       rtmToken:config.token
                                                                                         region:config.region
                                                                                   mediaOptions:mediaOptions];
    
    return launchConfig;
}

- (AgoraEduCoreMediaOptions *)getPuppetMediaOptions:(AgoraProctorMediaOptions *)options {
    AgoraEduCoreVideoConfig *videoConfig = nil;
    
    if (options.videoEncoderConfig) {
        videoConfig = [[AgoraEduCoreVideoConfig alloc] initWithDimensionWidth:options.videoEncoderConfig.dimensionWidth
                                                                    dimensionHeight:options.videoEncoderConfig.dimensionHeight
                                                                          frameRate:options.videoEncoderConfig.frameRate
                                                                            bitRate:options.videoEncoderConfig.bitRate
                                                                         mirrorMode:options.videoEncoderConfig.mirrorMode];
    }
    
    AgoraEduCoreMediaEncryptionConfig *encryptionConfig = nil;
    
    if (options.encryptionConfig) {
        NSString *key = options.encryptionConfig.key;
        AgoraEduCoreMediaEncryptionMode mode = options.encryptionConfig.mode;
        encryptionConfig = [[AgoraEduCoreMediaEncryptionConfig alloc] initWithKey:key
                                                                             mode:mode];
    }
    
    AgoraEduCoreMediaOptions *mediaOptions = [[AgoraEduCoreMediaOptions alloc] initWithEncryptionConfig:encryptionConfig
                                                                                            videoConfig:videoConfig
                                                                                           latencyLevel:options.latencyLevel
                                                                                             videoState:options.videoState
                                                                                             audioState:options.audioState];
    return mediaOptions;
}
@end
