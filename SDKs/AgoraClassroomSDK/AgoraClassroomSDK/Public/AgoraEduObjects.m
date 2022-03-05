//
//  AgoraEduObjects.m
//  AgoraClassroomSDK
//
//  Created by SRS on 2021/1/7.
//

#import "AgoraEduObjects.h"
@import AgoraWidgets;
@import AgoraExtApps;

#pragma mark - Media
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

@implementation AgoraEduVideoEncoderConfig
- (instancetype)init {
    self = [super init];
    if (self) {
        self.dimensionWidth = 320;
        self.dimensionHeight = 240;
        self.frameRate = 15;
        self.bitRate = 200;
        self.mirrorMode = AgoraEduMirrorModeDisabled;
    }
    return self;
}

- (instancetype)initWithDimensionWidth:(NSUInteger)dimensionWidth
                       dimensionHeight:(NSUInteger)dimensionHeight
                             frameRate:(NSUInteger)frameRate
                               bitRate:(NSUInteger)bitRate
                            mirrorMode:(AgoraEduMirrorMode)mirrorMode {
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

@implementation AgoraEduMediaOptions
- (instancetype)initWithEncryptionConfig:(AgoraEduMediaEncryptionConfig * _Nullable)encryptionConfig
                      videoEncoderConfig:(AgoraEduVideoEncoderConfig * _Nullable)videoEncoderConfig
                            latencyLevel:(AgoraEduLatencyLevel)latencyLevel
                              videoState:(AgoraEduStreamState)videoState
                              audioState:(AgoraEduStreamState)audioState {
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
@implementation AgoraEduLaunchConfig
- (instancetype)initWithUserName:(NSString *)userName
                        userUuid:(NSString *)userUuid
                        userRole:(AgoraEduUserRole)userRole
                        roomName:(NSString *)roomName
                        roomUuid:(NSString *)roomUuid
                        roomType:(AgoraEduRoomType)roomType
                           appId:(NSString *)appId
                           token:(NSString *)token {
    AgoraEduMediaOptions *mediaOptions = [[AgoraEduMediaOptions alloc] initWithEncryptionConfig:nil
                                                                             videoEncoderConfig:nil
                                                                                   latencyLevel:AgoraEduLatencyLevelUltraLow
                                                                                     videoState:AgoraEduStreamStateOn
                                                                                     audioState:AgoraEduStreamStateOn];
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
                           region:AgoraEduRegionCN
                     mediaOptions:mediaOptions
                   userProperties:nil];
}

- (instancetype)initWithUserName:(NSString *)userName
                        userUuid:(NSString *)userUuid
                        userRole:(AgoraEduUserRole)userRole
                        roomName:(NSString *)roomName
                        roomUuid:(NSString *)roomUuid
                        roomType:(AgoraEduRoomType)roomType
                           appId:(NSString *)appId
                           token:(NSString *)token
                       startTime:(NSNumber * _Nullable)startTime
                        duration:(NSNumber * _Nullable)duration
                          region:(AgoraEduRegion)region
                    mediaOptions:(AgoraEduMediaOptions *)mediaOptions
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
    
    // AgoraWhiteboardWidget
    AgoraWidgetConfig *whiteboardConfig = [[AgoraWidgetConfig alloc] initWithClass:[AgoraWhiteboardWidget class]
                                                                          widgetId:@"netlessBoard"];
    // RTM IM Widget
    AgoraWidgetConfig *rtm = [[AgoraWidgetConfig alloc] initWithClass:[AgoraRtmIMWidget class]
                                                             widgetId:@"AgoraChatWidget"];
    widgets[rtm.widgetId] = rtm;
    
    NSString *courseFolder = [NSString stringWithFormat:@"%@/%@", NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                                                                      NSUserDomainMask,
                                                                                                      YES)[0], @"AgoraDownload"];
    whiteboardConfig.extraInfo = @{@"coursewareDirectory": courseFolder,
                                   @"useMultiViews": @YES,
                                   @"autoFit": @NO};
    
    widgets[whiteboardConfig.widgetId] = whiteboardConfig;
    
    // Poller Widget
    AgoraWidgetConfig *poller = [[AgoraWidgetConfig alloc] initWithClass:[AgoraPollerWidget class]
                                                                widgetId:@"polling"];
    widgets[poller.widgetId] = poller;
    
    // Render Spread Widget
    AgoraWidgetConfig *spread = [[AgoraWidgetConfig alloc] initWithClass:[AgoraRenderSpreadWidget class]
                                                                widgetId:@"streamWindow"];
    widgets[spread.widgetId] = spread;
    
    // Cloud Widget
    AgoraWidgetConfig *cloud = [[AgoraWidgetConfig alloc] initWithClass:[AgoraCloudWidget class]
                                                                widgetId:@"AgoraCloudWidget"];
    widgets[cloud.widgetId] = cloud;
    
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
    exts[voteExt.appIdentifier] = voteExt;
    return exts;
}
@end
