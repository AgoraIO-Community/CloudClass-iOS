//
//  AgoraEduObjects.m
//  AgoraClassroomSDK
//
//  Created by SRS on 2021/1/7.
//

#import "AgoraEduObjects.h"
@import AgoraWidgets;

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
    
    return self;
}

- (NSMutableDictionary<NSString *, AgoraWidgetConfig *> *)baseWidgets {
    // Register widgets
    NSMutableDictionary<NSString *, AgoraWidgetConfig *> *widgets = [NSMutableDictionary dictionary];
    // TODO: replace rtm to im (chat)
    AgoraWidgetConfig *chat = [[AgoraWidgetConfig alloc] initWithClass:[AgoraChatEasemobWidget class]
                                                              widgetId:@"easemobIM"];
    widgets[chat.widgetId] = chat;
    
    // AgoraWhiteboardWidget
    AgoraWidgetConfig *whiteboardConfig = [[AgoraWidgetConfig alloc] initWithClass:[FcrBoardWidget class]
                                                                          widgetId:@"netlessBoard"];
    
    NSString *courseFolder = [NSString stringWithFormat:@"%@/%@", NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                                                                      NSUserDomainMask,
                                                                                                      YES)[0], @"AgoraDownload"];
    whiteboardConfig.extraInfo = @{@"coursewareDirectory": courseFolder};
    
    widgets[whiteboardConfig.widgetId] = whiteboardConfig;
    
    // RTM IM Widget
    AgoraWidgetConfig *rtm = [[AgoraWidgetConfig alloc] initWithClass:[AgoraChatRtmWidget class]
                                                             widgetId:@"AgoraChatWidget"];
    widgets[rtm.widgetId] = rtm;

    
    // CountdownTimer Widget
    AgoraWidgetConfig *countdownTimer = [[AgoraWidgetConfig alloc] initWithClass:[AgoraCountdownTimerWidget class]
                                                                        widgetId:@"countdownTimer"];
    widgets[countdownTimer.widgetId] = countdownTimer;
    
    // Poll Widget
    AgoraWidgetConfig *poll = [[AgoraWidgetConfig alloc] initWithClass:[AgoraPollWidget class]
                                                              widgetId:@"poll"];
    widgets[poll.widgetId] = poll;
    
    // Render Spread Widget
    AgoraWidgetConfig *window = [[AgoraWidgetConfig alloc] initWithClass:[AgoraStreamWindowWidget class]
                                                                widgetId:@"streamWindow"];
    widgets[window.widgetId] = window;
    
    // WebView Widget
    AgoraWidgetConfig *webView = [[AgoraWidgetConfig alloc] initWithClass:[AgoraWebViewWidget class]
                                                                widgetId:@"webView"];
    widgets[webView.widgetId] = webView;
    
    // Media Player Widget
    AgoraWidgetConfig *mediaPlayer = [[AgoraWidgetConfig alloc] initWithClass:[AgoraWebViewWidget class]
                                                                     widgetId:@"mediaPlayer"];
    widgets[mediaPlayer.widgetId] = mediaPlayer;
    
    // Cloud Widget
    AgoraWidgetConfig *cloud = [[AgoraWidgetConfig alloc] initWithClass:[AgoraCloudWidget class]
                                                               widgetId:@"AgoraCloudWidget"];
    widgets[cloud.widgetId] = cloud;
    
    // PopupQuiz Selector
    AgoraWidgetConfig *popupQuiz = [[AgoraWidgetConfig alloc] initWithClass:[AgoraPopupQuizWidget class]
                                                                   widgetId:@"popupQuiz"];
    widgets[popupQuiz.widgetId] = popupQuiz;
    
    return widgets;
}
@end
