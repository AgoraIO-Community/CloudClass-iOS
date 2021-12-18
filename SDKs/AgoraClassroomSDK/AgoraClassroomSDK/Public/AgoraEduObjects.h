//
//  EduObjects.h
//  AgoraClassroomSDK
//
//  Created by SRS on 2021/1/7.
//

#import <Foundation/Foundation.h>
#import <AgoraExtApp/AgoraExtApp.h>
#import <AgoraWidget/AgoraWidget.h>
#import "AgoraEduEnums.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Config
/**设置全局配置*/
@interface AgoraClassroomSDKConfig : NSObject
// 声网App Id
@property (nonatomic, copy) NSString *appId;
// 是否开启护眼模式
// default false
@property (nonatomic, assign) BOOL eyeCare;
- (instancetype)initWithAppId:(NSString *)appId;
@end

#pragma mark - Media
/**设置媒体选项*/
@interface AgoraEduMediaEncryptionConfig : NSObject
@property (nonatomic, assign) AgoraEduMediaEncryptionMode mode;
@property (nonatomic, copy) NSString *key;

- (instancetype)initWithMode:(AgoraEduMediaEncryptionMode)mode key:(NSString *)key;
@end

@interface AgoraEduVideoEncoderConfiguration : NSObject
@property (nonatomic, assign) NSUInteger width;
@property (nonatomic, assign) NSUInteger height;
@property (nonatomic, assign) NSUInteger frameRate;
@property (nonatomic, assign) NSUInteger bitrate;
@property (nonatomic, assign) AgoraEduMirrorMode mirrorMode;

- (instancetype)initWithWidth:(NSUInteger)width
                       height:(NSUInteger)height
                    frameRate:(NSUInteger)frameRate
                      bitrate:(NSUInteger)bitrate
                   mirrorMode:(AgoraEduMirrorMode)mirrorMode;
@end

@interface AgoraEduMediaOptions : NSObject
@property (nonatomic, strong, nullable) AgoraEduMediaEncryptionConfig *encryptionConfig;
// 分辨率配置属性
@property (nonatomic, strong, nullable) AgoraEduVideoEncoderConfiguration *cameraEncoderConfiguration;
// RTC观众延时级别,默认lowlatency（极速直播）
@property (nonatomic, assign) AgoraEduLatencyLevel latencyLevel;
// 学生上麦默认打开/关闭视频
@property (nonatomic, assign) AgoraEduStreamState videoState;
// 学生上麦默认打开/关闭音频
@property (nonatomic, assign) AgoraEduStreamState audioState;

- (instancetype)initWithEncryptionConfig:(AgoraEduMediaEncryptionConfig *_Nullable)encryptionConfig
              cameraEncoderConfiguration:(AgoraEduVideoEncoderConfiguration *_Nullable)cameraEncoderConfiguration
                            latencyLevel:(AgoraEduLatencyLevel)latencyLevel
                              videoState:(AgoraEduStreamState)videoState
                              audioState:(AgoraEduStreamState)audioState;
@end

#pragma mark - Launch
/**启动课堂配置*/
@interface AgoraEduLaunchConfig : NSObject
// 用户名
@property (nonatomic, copy) NSString *userName;
// 用户全局唯一id，需要与你签发token时使用的uid一致
@property (nonatomic, copy) NSString *userUuid;
// 角色类型(参考AgoraEduCoreRoleType)
@property (nonatomic, assign) AgoraEduRoleType roleType;
// 教室名称
@property (nonatomic, copy) NSString *roomName;
// 全局唯一的教室id
@property (nonatomic, copy) NSString *roomUuid;
// 教室类型(参考AgoraEduRoomType)
@property (nonatomic, assign) AgoraEduRoomType roomType;
// 声网RESTfule API token, 是RTMToken
@property (nonatomic, copy) NSString *token;
// 上课开始时间（毫秒）
@property (nonatomic, copy, nullable) NSNumber *startTime;
// 课程时间（秒）
@property (nonatomic, copy, nullable) NSNumber *duration;
// 区域
@property (nonatomic, assign) AgoraEduRegion region;
// 加密
@property (nonatomic, strong, nullable) AgoraEduMediaOptions *mediaOptions;
// 用户自定属性
@property (nonatomic, copy, nullable) NSDictionary<NSString *, NSString *> * userProperties;
// widgets
@property (nonatomic, strong) NSDictionary<NSString *, AgoraWidgetConfig *> *widgets;
// ext apps
@property (nonatomic, strong) NSDictionary<NSString *, AgoraExtAppConfiguration *> *extApps;

- (instancetype)initWithUserName:(NSString *)userName
                        userUuid:(NSString *)userUuid
                        roleType:(AgoraEduRoleType)roleType
                        roomName:(NSString *)roomName
                        roomUuid:(NSString *)roomUuid
                        roomType:(AgoraEduRoomType)roomType
                           token:(NSString *)token;

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
                    mediaOptions:(AgoraEduMediaOptions * _Nullable)mediaOptions
                  userProperties:(NSDictionary * _Nullable)userProperties;
@end

// 聊天翻译
typedef NSString *AgoraEduChatTranslationLan NS_STRING_ENUM;
FOUNDATION_EXPORT AgoraEduChatTranslationLan const AgoraEduChatTranslationLanAUTO;
FOUNDATION_EXPORT AgoraEduChatTranslationLan const AgoraEduChatTranslationLanCN;
FOUNDATION_EXPORT AgoraEduChatTranslationLan const AgoraEduChatTranslationLanEN;
FOUNDATION_EXPORT AgoraEduChatTranslationLan const AgoraEduChatTranslationLanJA;
FOUNDATION_EXPORT AgoraEduChatTranslationLan const AgoraEduChatTranslationLanKO;
FOUNDATION_EXPORT AgoraEduChatTranslationLan const AgoraEduChatTranslationLanFR;
FOUNDATION_EXPORT AgoraEduChatTranslationLan const AgoraEduChatTranslationLanES;
FOUNDATION_EXPORT AgoraEduChatTranslationLan const AgoraEduChatTranslationLanPT;
FOUNDATION_EXPORT AgoraEduChatTranslationLan const AgoraEduChatTranslationLanIT;
FOUNDATION_EXPORT AgoraEduChatTranslationLan const AgoraEduChatTranslationLanRU;
FOUNDATION_EXPORT AgoraEduChatTranslationLan const AgoraEduChatTranslationLanVI;
FOUNDATION_EXPORT AgoraEduChatTranslationLan const AgoraEduChatTranslationLanDE;
FOUNDATION_EXPORT AgoraEduChatTranslationLan const AgoraEduChatTranslationLanAR;

NS_ASSUME_NONNULL_END
