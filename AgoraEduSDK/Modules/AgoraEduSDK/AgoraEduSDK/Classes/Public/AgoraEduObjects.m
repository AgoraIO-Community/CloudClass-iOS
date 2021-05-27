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
    self = [super init];
    if (self) {
        self.resourceName = resourceName;
        self.resourceUuid = resourceUuid;
        self.scenePath = scenePath;
        self.resourceUrl = resourceUrl;
        self.scenes = scenes;
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
                           token:(NSString *)token
                       startTime:(NSNumber * _Nullable)startTime
                        duration:(NSNumber * _Nullable)duration
                     boardRegion:(NSString * _Nullable)boardRegion{
    self = [self init];
    self.userName = userName;
    self.userUuid = userUuid;
    self.roomName = roomName;
    self.roomUuid = roomUuid;
    self.roomType = roomType;
    self.token = token;
    if (startTime != nil) {
        self.startTime = startTime;
    }
    if (duration != nil) {
        self.duration = duration;
    }
    if (boardRegion != nil) {
        self.boardRegion = boardRegion;
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
