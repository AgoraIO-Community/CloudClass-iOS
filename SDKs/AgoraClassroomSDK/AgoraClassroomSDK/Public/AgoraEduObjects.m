//
//  AgoraEduObjects.m
//  AgoraClassroomSDK
//
//  Created by SRS on 2021/1/7.
//

#import "AgoraEduObjects.h"

#pragma mark - Config
@implementation AgoraClassroomSDKConfig
- (instancetype)init {
    self = [super init];
    if (self) {
        self.eyeCare = NO;
    }
    return self;
}

- (instancetype)initWithAppId:(NSString *)appId {
    return [self initWithAppId:appId
                       eyeCare:NO];
}

- (instancetype)initWithAppId:(NSString *)appId
                      eyeCare:(BOOL)eyeCare {
    self = [super init];
    if (self) {
        self.appId = appId;
        self.eyeCare = eyeCare;
    }
    return self;
}
@end

#pragma mark - White board
@implementation AgoraEduPPTPage
- (instancetype)initWithSource:(NSString *)source
                          size:(CGSize)size {
    self = [super init];
    
    if (self) {
        self.source = source;
        self.height = size.height;
        self.width = size.width;
    }
    
    return self;
}

- (instancetype)initWithSource:(NSString *)source
                    previewURL:(NSString *)url
                          size:(CGSize)size {
    self = [super init];
    
    if (self) {
        self.source = source;
        self.previewURL = url;
        self.height = size.height;
        self.width = size.width;
    }
    
    return self;
}
@end

@implementation AgoraEduBoardScene
- (instancetype)initWithName:(NSString *)name
                     pptPage:(AgoraEduPPTPage * _Nullable)pptPage {
    self = [super init];
    
    if (self) {
        self.name = name;
        self.pptPage = pptPage;
    }
    
    return self;
}
@end

@implementation AgoraEduCourseware
- (instancetype)initWithResourceName:(NSString *)resourceName
                        resourceUuid:(NSString *)resourceUuid
                           scenePath:(NSString *)scenePath
                              scenes:(NSArray<AgoraEduBoardScene *> *)scenes
                         resourceUrl:(NSString *)resourceUrl
                                 ext:(NSString * _Nonnull)ext
                                size:(double)size
                          updateTime:(double)updateTime{
    self = [super init];
    
    if (self) {
        self.resourceName = resourceName;
        self.resourceUuid = resourceUuid;
        self.scenePath = scenePath;
        self.resourceUrl = resourceUrl;
        self.scenes = scenes;
        self.ext = ext;
        self.size = size;
        self.updateTime = updateTime;
    }
    return self;
}
@end

@implementation AgoraEduVideoEncoderConfiguration
- (instancetype)init {
    self = [super init];
    if (self) {
        self.width = 320;
        self.height = 240;
        self.frameRate = 15;
        self.bitrate = 200;
        self.mirrorMode = AgoraEduMirrorModeDisabled;
    }
    return self;
}

- (instancetype)initWithWidth:(NSUInteger)width
                       height:(NSUInteger)height
                    frameRate:(NSUInteger)frameRate
                      bitrate:(NSUInteger)bitrate
                   mirrorMode:(AgoraEduMirrorMode)mirrorMode{
    if (self = [super init]) {
        self.width = width;
        self.height = height;
        self.frameRate = frameRate;
        self.bitrate = bitrate;
        self.mirrorMode = mirrorMode;
    }
    return self;
}
@end

@implementation AgoraEduLaunchConfig
- (instancetype)init {
    self = [super init];
    if (self) {
        self.roleType = AgoraEduRoleTypeStudent;
    }
    return self;
}

- (instancetype)initWithUserName:(NSString *)userName
                        userUuid:(NSString *)userUuid
                        roleType:(AgoraEduRoleType)roleType
                        roomName:(NSString *)roomName
                        roomUuid:(NSString *)roomUuid
                        roomType:(AgoraEduRoomType)roomType
                           token:(NSString *)token {
    AgoraEduMediaOptions *mediaOptions = [[AgoraEduMediaOptions alloc] initWithEncryptionConfig:nil
                                                                     cameraEncoderConfiguration:nil
                                                                                   latencyLevel:AgoraEduLatencyLevelUltraLow
                                                                                     videoState:AgoraEduStreamStateDefault
                                                                                     audioState:AgoraEduStreamStateDefault];
    return [self initWithUserName:userName
                         userUuid:userUuid
                         roleType:roleType
                         roomName:roomName
                         roomUuid:roomUuid
                         roomType:roomType
                            token:token
                        startTime:nil
                         duration:nil
                           region:nil
                     mediaOptions:mediaOptions
                   userProperties:nil
                     boardFitMode:AgoraEduBoardFitModeAuto];
}

- (instancetype)initWithUserName:(NSString *)userName
                        userUuid:(NSString *)userUuid
                        roleType:(AgoraEduRoleType)roleType
                        roomName:(NSString *)roomName
                        roomUuid:(NSString *)roomUuid
                        roomType:(AgoraEduRoomType)roomType
                           token:(NSString *)token
                       startTime:(NSNumber * _Nullable)startTime
                        duration:(NSNumber * _Nullable)duration
                          region:(AgoraEduRegion)region
                    mediaOptions:(AgoraEduMediaOptions *)mediaOptions
                  userProperties:(NSDictionary * _Nullable)userProperties
                    boardFitMode:(AgoraEduBoardFitMode)boardFitMode {
    self = [self init];
    self.userName = userName;
    self.userUuid = userUuid;
    self.roleType = roleType;
    
    self.roomName = roomName;
    self.roomUuid = roomUuid;
    self.roomType = roomType;
    self.token = token;
    
    self.startTime = startTime;
    self.duration = duration;
    self.region = region;
    self.mediaOptions = mediaOptions;
    
    self.userProperties = userProperties;
    self.boardFitMode = boardFitMode;
    
    return self;
}
@end

/**设置媒体选项*/
@implementation AgoraEduMediaEncryptionConfig
- (instancetype)initWithMode:(AgoraEduMediaEncryptionMode)mode
                         key:(NSString *)key {
    self = [super init];
    
    if (self) {
        self.mode = mode;
        self.key = key;
    }
    
    return self;
}
@end

@implementation AgoraEduMediaOptions
- (instancetype)initWithEncryptionConfig:(AgoraEduMediaEncryptionConfig *_Nullable)encryptionConfig
              cameraEncoderConfiguration:(AgoraEduVideoEncoderConfiguration *_Nullable)cameraEncoderConfiguration
                            latencyLevel:(AgoraEduLatencyLevel)latencyLevel
                              videoState:(AgoraEduStreamState)videoState
                              audioState:(AgoraEduStreamState)audioState {
    self = [super init];
    
    if (self) {
        self.encryptionConfig = encryptionConfig;
        self.cameraEncoderConfiguration = cameraEncoderConfiguration;
        self.latencyLevel = latencyLevel;
        self.videoState = videoState;
        self.audioState = audioState;
    }
    
    return self;
}
@end

NSString * const AgoraEduCoreChatTranslationLanAUTO = @"auto";
NSString * const AgoraEduCoreChatTranslationLanCN = @"zh-CHS";
NSString * const AgoraEduCoreChatTranslationLanEN = @"en";
NSString * const AgoraEduCoreChatTranslationLanJA = @"ja";
NSString * const AgoraEduCoreChatTranslationLanKO = @"ko";
NSString * const AgoraEduCoreChatTranslationLanFR = @"fr";
NSString * const AgoraEduCoreChatTranslationLanES = @"es";
NSString * const AgoraEduCoreChatTranslationLanPT = @"pt";
NSString * const AgoraEduCoreChatTranslationLanIT = @"it";
NSString * const AgoraEduCoreChatTranslationLanRU = @"ru";
NSString * const AgoraEduCoreChatTranslationLanVI = @"vi";
NSString * const AgoraEduCoreChatTranslationLanDE = @"de";
NSString * const AgoraEduCoreChatTranslationLanAR = @"ar";
