//
//  AgoraEduObjects.m
//  AgoraClassroomSDK
//
//  Created by SRS on 2021/1/7.
//

#import "AgoraEduObjects.h"
@import AgoraWidgets;
@import ChatWidget;
@import AgoraExtApps;

#pragma mark - Config
@implementation AgoraClassroomSDKConfig
- (instancetype)initWithAppId:(NSString *)appId {
    self = [super init];
    if (self) {
        self.appId = appId;
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
                   userProperties:nil];
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
                  userProperties:(NSDictionary * _Nullable)userProperties {
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
    
    self.widgets = [self baseWidgets];
    self.extApps = [self baseExtApps];
    
    return self;
}

- (NSMutableDictionary<NSString *, AgoraWidgetConfig *> *)baseWidgets {
    // Register widgets
    NSMutableDictionary<NSString *, AgoraWidgetConfig *> *widgets = [NSMutableDictionary dictionary];
    // TODO: replace rtm to im (chat)
    AgoraWidgetConfig *chat = [[AgoraWidgetConfig alloc] initWithClass:[ChatWidget class]
                                                              widgetId:@"easemobIM"];
    widgets[chat.widgetId] = chat;
    
    // AgoraSpreadRenderWidget
    AgoraWidgetConfig *spreadRender = [[AgoraWidgetConfig alloc] initWithClass:[AgoraSpreadRenderWidget class]
                                                                      widgetId:@"big-window"];
    widgets[spreadRender.widgetId] = spreadRender;
    
    // AgoraCloudWidget
    AgoraWidgetConfig *cloudWidgetConfig = [[AgoraWidgetConfig alloc] initWithClass:[AgoraCloudWidget class]
                                                                           widgetId:@"AgoraCloudWidget"];
    widgets[cloudWidgetConfig.widgetId] = cloudWidgetConfig;
    
    // AgoraWhiteboardWidget
    AgoraWidgetConfig *whiteboardConfig = [[AgoraWidgetConfig alloc] initWithClass:[AgoraWhiteboardWidget class]
                                                                          widgetId:@"netlessBoard"];
    // RTM IM Widget
    AgoraWidgetConfig *rtm = [[AgoraWidgetConfig alloc] initWithClass:[AgoraRtmIMWidget class]
                                                             widgetId:@"AgoraChatWidget"];
    widgets[rtm.widgetId] = rtm;
    
    NSString *courseFolder = [NSString stringWithFormat:@"%@/%@",NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0],@"AgoraDownload"];
    whiteboardConfig.extraInfo = @{@"coursewareDirectory":courseFolder,
                                   @"useMultiViews": @YES,
                                   @"autoFit": @NO};
    
    widgets[whiteboardConfig.widgetId] = whiteboardConfig;
    return widgets;
}

- (NSMutableDictionary<NSString *, AgoraExtAppConfiguration *> *)baseExtApps {
    NSMutableDictionary<NSString *, AgoraWidgetConfig *> *exts = [NSMutableDictionary dictionary];
    AgoraExtAppConfiguration *countdown = [[AgoraExtAppConfiguration alloc] initWithAppIdentifier:@"io.agora.countdown"
                                                                                      extAppClass:[CountDownExtApp class]
                                                                                            frame:UIEdgeInsetsZero
                                                                                         language:@"zh"];
    
    AgoraExtAppConfiguration *answerExt = [[AgoraExtAppConfiguration alloc] initWithAppIdentifier:@"io.agora.answer"
                                                                                      extAppClass:[AnswerSheetExtApp class]
                                                                                            frame:UIEdgeInsetsZero
                                                                                         language:@"zh"];
    
    AgoraExtAppConfiguration *voteExt = [[AgoraExtAppConfiguration alloc] initWithAppIdentifier:@"io.agora.vote"
                                                                                      extAppClass:[VoteExtApp class]
                                                                                            frame:UIEdgeInsetsZero
                                                                                         language:@"zh"];
    
    exts[countdown.appIdentifier] = countdown;
    exts[answerExt.appIdentifier] = answerExt;
    exts[answerExt.appIdentifier] = voteExt;
    return exts;
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
