//
//  AgoraInvigilatorObjects.m
//  AgoraClassroomSDK
//
//  Created by SRS on 2021/1/7.
//

#import "AgoraInvigilatorObjects.h"

#pragma mark - Media
/**设置媒体选项*/
@implementation AgoraInvigilatorMediaEncryptionConfig
- (instancetype)initWithMode:(AgoraInvigilatorMediaEncryptionMode)mode
                         key:(NSString *)key {
    self = [super init];
    
    if (self) {
        self.mode = mode;
        self.key = key;
    }
    
    return self;
}
@end

@implementation AgoraInvigilatorVideoEncoderConfig
- (instancetype)init {
    self = [super init];
    if (self) {
        self.dimensionWidth = 320;
        self.dimensionHeight = 240;
        self.frameRate = 15;
        self.bitRate = 200;
        self.mirrorMode = AgoraInvigilatorMirrorModeDisabled;
    }
    return self;
}

- (instancetype)initWithDimensionWidth:(NSUInteger)dimensionWidth
                       dimensionHeight:(NSUInteger)dimensionHeight
                             frameRate:(NSUInteger)frameRate
                               bitRate:(NSUInteger)bitRate
                            mirrorMode:(AgoraInvigilatorMirrorMode)mirrorMode {
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

@implementation AgoraInvigilatorMediaOptions
- (instancetype)initWithEncryptionConfig:(AgoraInvigilatorMediaEncryptionConfig * _Nullable)encryptionConfig
                      videoEncoderConfig:(AgoraInvigilatorVideoEncoderConfig * _Nullable)videoEncoderConfig
                            latencyLevel:(AgoraInvigilatorLatencyLevel)latencyLevel
                              videoState:(AgoraInvigilatorStreamState)videoState
                              audioState:(AgoraInvigilatorStreamState)audioState {
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
@implementation AgoraInvigilatorLaunchConfig
- (instancetype)initWithUserName:(NSString *)userName
                        userUuid:(NSString *)userUuid
                        userRole:(AgoraInvigilatorUserRole)userRole
                        roomName:(NSString *)roomName
                        roomUuid:(NSString *)roomUuid
                        roomType:(AgoraInvigilatorRoomType)roomType
                           appId:(NSString *)appId
                           token:(NSString *)token {
    AgoraInvigilatorMediaOptions *mediaOptions = [[AgoraInvigilatorMediaOptions alloc] initWithEncryptionConfig:nil
                                                                             videoEncoderConfig:nil
                                                                                   latencyLevel:AgoraInvigilatorLatencyLevelUltraLow
                                                                                     videoState:AgoraInvigilatorStreamStateOn
                                                                                     audioState:AgoraInvigilatorStreamStateOn];
    return [self initWithUserName:userName
                         userUuid:userUuid
                         userRole:userRole
                         roomName:roomName
                         roomUuid:roomUuid
                         roomType:roomType
                            appId:appId
                            token:token
                        startTime:nil
                         duration:nil
                           region:AgoraInvigilatorRegionCN
                     mediaOptions:mediaOptions
                   userProperties:nil];
}

- (instancetype)initWithUserName:(NSString *)userName
                        userUuid:(NSString *)userUuid
                        userRole:(AgoraInvigilatorUserRole)userRole
                        roomName:(NSString *)roomName
                        roomUuid:(NSString *)roomUuid
                        roomType:(AgoraInvigilatorRoomType)roomType
                           appId:(NSString *)appId
                           token:(NSString *)token
                       startTime:(NSNumber * _Nullable)startTime
                        duration:(NSNumber * _Nullable)duration
                          region:(AgoraInvigilatorRegion)region
                    mediaOptions:(AgoraInvigilatorMediaOptions *)mediaOptions
                  userProperties:(NSDictionary * _Nullable)userProperties {
    self = [self init];
    self.userName = userName;
    self.userUuid = userUuid;
    self.userRole = userRole;
    
    self.roomName = roomName;
    self.roomUuid = roomUuid;
    self.roomType = roomType;
    
    self.appId = appId;
    self.token = token;
    
    self.startTime = startTime;
    self.duration = duration;
    self.region = region;
    self.mediaOptions = mediaOptions;
    self.userProperties = userProperties;
    
    return self;
}
@end
