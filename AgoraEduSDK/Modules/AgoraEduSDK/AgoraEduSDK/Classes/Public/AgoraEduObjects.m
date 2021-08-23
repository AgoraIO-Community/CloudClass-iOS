//
//  AgoraEduObjects.m
//  AgoraEduSDK
//
//  Created by SRS on 2021/1/7.
//

#import "AgoraEduObjects.h"

@implementation AgoraEduSDKConfig
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

@implementation AgoraEduCourseware
- (instancetype)initWithResourceName:(NSString *)resourceName
                        resourceUuid:(NSString *)resourceUuid
                           scenePath:(NSString *)scenePath
                              scenes:(NSArray<WhiteScene *> *)scenes
                         resourceUrl:(NSString *)resourceUrl {
    if (self = [super init]) {
        self.resourceName = resourceName;
        self.resourceUuid = resourceUuid;
        self.scenePath = scenePath;
        self.resourceUrl = resourceUrl;
        self.scenes = scenes;
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
    }
    return self;
}

- (instancetype)initWithWidth:(NSInteger)width
                       height:(NSInteger)height
                    frameRate:(NSInteger)frameRate
                      bitrate:(NSInteger)bitrate {
    if (self = [super init]) {
        self.width = width;
        self.height = height;
        self.frameRate = frameRate;
        self.bitrate = bitrate;
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

    return [self initWithUserName:userName
                         userUuid:userUuid
                         roleType:roleType
                         roomName:roomName
                         roomUuid:roomUuid
                         roomType:roomType
                            token:token
                        startTime:nil
                         duration:nil
                      boardRegion:nil
                   userProperties:nil
                     boardFitMode:AgoraBoardFitModeAuto];
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
                     boardRegion:(NSString * _Nullable)boardRegion
                  userProperties:(NSDictionary * _Nullable)userProperties
                    boardFitMode:(AgoraBoardFitMode)boardFitMode {
    if (self = [super init]) {
        self.userName = userName;
        self.userUuid = userUuid;
        self.roomName = roomName;
        self.roomUuid = roomUuid;
        self.roomType = roomType;
        self.token = token;
        self.roleType = roleType;
        self.boardFitMode = boardFitMode;
        
        if (startTime != nil) {
            self.startTime = startTime;
        }
        if (duration != nil) {
            self.duration = duration;
        }
        if (boardRegion != nil) {
            self.boardRegion = boardRegion;
        }
        if (userProperties != nil) {
            self.userProperties = userProperties;
        }
        
        self.cameraEncoderConfiguration = [AgoraEduVideoEncoderConfiguration new];
    }
    return self;
}
@end

NSString * const AgoraEduChatTranslationLanAUTO = @"auto";
NSString * const AgoraEduChatTranslationLanCN = @"zh-CHS";
NSString * const AgoraEduChatTranslationLanEN = @"en";
NSString * const AgoraEduChatTranslationLanJA = @"ja";
NSString * const AgoraEduChatTranslationLanKO = @"ko";
NSString * const AgoraEduChatTranslationLanFR = @"fr";
NSString * const AgoraEduChatTranslationLanES = @"es";
NSString * const AgoraEduChatTranslationLanPT = @"pt";
NSString * const AgoraEduChatTranslationLanIT = @"it";
NSString * const AgoraEduChatTranslationLanRU = @"ru";
NSString * const AgoraEduChatTranslationLanVI = @"vi";
NSString * const AgoraEduChatTranslationLanDE = @"de";
NSString * const AgoraEduChatTranslationLanAR = @"ar";
