//
//  AgoraProctorObjects.m
//  AgoraClassroomSDK
//
//  Created by SRS on 2021/1/7.
//

#import "AgoraProctorObjects.h"

#pragma mark - Media
/**设置媒体选项*/
@implementation AgoraProctorMediaEncryptionConfig
- (instancetype)initWithMode:(AgoraProctorMediaEncryptionMode)mode
                         key:(NSString *)key {
    self = [super init];
    
    if (self) {
        self.mode = mode;
        self.key = key;
    }
    
    return self;
}
@end

@implementation AgoraProctorVideoEncoderConfig
- (instancetype)init {
    self = [super init];
    if (self) {
        self.dimensionWidth = 320;
        self.dimensionHeight = 240;
        self.frameRate = 15;
        self.bitRate = 200;
        self.mirrorMode = AgoraEduCoreMirrorModeDisabled;
    }
    return self;
}

- (instancetype)initWithDimensionWidth:(NSUInteger)dimensionWidth
                       dimensionHeight:(NSUInteger)dimensionHeight
                             frameRate:(NSUInteger)frameRate
                               bitRate:(NSUInteger)bitRate
                            mirrorMode:(AgoraProctorMirrorMode)mirrorMode {
    if (self = [super init]) {
        self.dimensionWidth = dimensionWidth;
        self.dimensionHeight = dimensionHeight;
        self.frameRate = frameRate;
        self.bitRate = bitRate;
        self.mirrorMode = mirrorMode;
    }
    return self;
}
@end

@implementation AgoraProctorMediaOptions
- (instancetype)initWithEncryptionConfig:(AgoraProctorMediaEncryptionConfig * _Nullable)encryptionConfig
                      videoEncoderConfig:(AgoraProctorVideoEncoderConfig * _Nullable)videoEncoderConfig
                            latencyLevel:(AgoraProctorLatencyLevel)latencyLevel
                              videoState:(AgoraProctorStreamState)videoState
                              audioState:(AgoraProctorStreamState)audioState {
    self = [super init];
    
    if (self) {
        self.encryptionConfig = encryptionConfig;
        self.videoEncoderConfig = videoEncoderConfig;
        self.latencyLevel = latencyLevel;
        self.videoState = videoState;
        self.audioState = audioState;
    }
    
    return self;
}
@end

#pragma mark - Launch
@implementation AgoraProctorLaunchConfig
- (instancetype)initWithUserName:(NSString *)userName
                        userUuid:(NSString *)userUuid
                        userRole:(AgoraProctorUserRole)userRole
                        roomName:(NSString *)roomName
                        roomUuid:(NSString *)roomUuid
                           appId:(NSString *)appId
                           token:(NSString *)token {
    AgoraProctorMediaOptions *mediaOptions = [[AgoraProctorMediaOptions alloc] initWithEncryptionConfig:nil
                                                                             videoEncoderConfig:nil
                                                                                   latencyLevel:AgoraEduCoreLatencyLevelUltraLow
                                                                                     videoState:AgoraEduCoreStreamStateOn
                                                                                     audioState:AgoraEduCoreStreamStateOn];
    return [self initWithUserName:userName
                         userUuid:userUuid
                         userRole:userRole
                         roomName:roomName
                         roomUuid:roomUuid
                            appId:appId
                            token:token
                           region:AgoraEduCoreRegionCN
                     mediaOptions:mediaOptions
                   userProperties:nil];
}

- (instancetype)initWithUserName:(NSString *)userName
                        userUuid:(NSString *)userUuid
                        userRole:(AgoraProctorUserRole)userRole
                        roomName:(NSString *)roomName
                        roomUuid:(NSString *)roomUuid
                           appId:(NSString *)appId
                           token:(NSString *)token
                          region:(AgoraProctorRegion)region
                    mediaOptions:(AgoraProctorMediaOptions *)mediaOptions
                  userProperties:(NSDictionary * _Nullable)userProperties {
    self = [self init];
    self.userName = userName;
    self.userUuid = userUuid;
    self.userRole = userRole;
    
    self.roomName = roomName;
    self.roomUuid = roomUuid;
    
    self.appId = appId;
    self.token = token;
    
    self.region = region;
    self.mediaOptions = mediaOptions;
    self.userProperties = userProperties;
    
    return self;
}
@end
