//
//  AgoraInternalClassroom.m
//  AgoraClassroomSDK
//
//  Created by Cavan on 2021/6/30.
//  Copyright © 2021 Agora. All rights reserved.
//

#import "AgoraInternalClassroom.h"
#import "AgoraEduEnums.h"

@implementation AgoraEduLaunchConfig (Internal)
- (BOOL)isLegal {
    if (self.userName.length <= 0) {
        return NO;
    }
    
    if (self.userUuid.length <= 0) {
        return NO;
    }
    
    if (self.userRole != AgoraEduUserRoleStudent) {
        return NO;
    }
    
    if (self.roomName.length <= 0) {
        return NO;
    }
    
    if (self.roomUuid.length <= 0) {
        return NO;
    }
    
    if (!(self.roomType == AgoraEduRoomTypeOneToOne
          || self.roomType == AgoraEduRoomTypeSmall
          || self.roomType == AgoraEduRoomTypeLecture)) {
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

@implementation AgoraClassroomSDK (Internal)
+ (AgoraEduCorePuppetLaunchConfig *)getPuppetLaunchConfig:(AgoraEduLaunchConfig *)config {
    AgoraEduCorePuppetMediaOptions *mediaOptions = [self getPuppetMediaOptions:config.mediaOptions];
    
    AgoraEduCorePuppetUserRole role = config.userRole;
    
    AgoraEduCorePuppetLaunchConfig *launchConfig = [[AgoraEduCorePuppetLaunchConfig alloc] initWithAppId:config.appId
                                                                                                rtmToken:config.token
                                                                                                  region:config.region
                                                                                                userName:config.userName
                                                                                                userUuid:config.userUuid
                                                                                                userRole:role
                                                                                          userProperties:config.userProperties
                                                                                            mediaOptions:mediaOptions
                                                                                                roomName:config.roomName
                                                                                                roomUuid:config.roomUuid
                                                                                                roomType:config.roomType
                                                                                               startTime:config.startTime
                                                                                                duration:config.duration];
    return launchConfig;
}

+ (AgoraEduCorePuppetMediaOptions *)getPuppetMediaOptions:(AgoraEduMediaOptions *)options {
    AgoraEduCorePuppetVideoConfig *videoConfig = nil;
    if (options.videoEncoderConfig) {
        videoConfig = [[AgoraEduCorePuppetVideoConfig alloc] initWithDimensionWidth:options.videoEncoderConfig.dimensionWidth
                                                                    dimensionHeight:options.videoEncoderConfig.dimensionHeight
                                                                          frameRate:options.videoEncoderConfig.frameRate
                                                                            bitRate:options.videoEncoderConfig.bitRate
                                                                         mirrorMode:options.videoEncoderConfig.mirrorMode];
    }
    AgoraEduCorePuppetMediaEncryptionConfig *encryptionConfig = nil;
    if (options.encryptionConfig) {
        NSString *key = options.encryptionConfig.key;
        AgoraEduCorePuppetMediaEncryptionMode mode = options.encryptionConfig.mode;
        encryptionConfig = [[AgoraEduCorePuppetMediaEncryptionConfig alloc] initWithKey:key
                                                                                   mode:mode];
    }
    AgoraEduCorePuppetMediaOptions *mediaOptions = [[AgoraEduCorePuppetMediaOptions alloc] initWithEncryptionConfig:encryptionConfig
                                                                                                        videoConfig:videoConfig
                                                                                                       latencyLevel:options.latencyLevel
                                                                                                         videoState:options.videoState
                                                                                                         audioState:options.audioState];
    return mediaOptions;
}
@end

