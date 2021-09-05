//
//  EduObjects.h
//  AgoraEduSDK
//
//  Created by SRS on 2021/1/7.
//

#import <Foundation/Foundation.h>
#import <Whiteboard/Whiteboard.h>
#import <AgoraExtApp/AgoraExtApp.h>
#import <AgoraEduCore/AgoraEduCore-Swift.h>
#import "AgoraEduEnums.h"

NS_ASSUME_NONNULL_BEGIN
/**设置全局配置*/
@interface AgoraEduSDKConfig : NSObject
// 声网App Id
@property (nonatomic, copy) NSString *appId;
// 是否开启护眼模式
// default false
@property (nonatomic, assign) BOOL eyeCare;
- (instancetype)initWithAppId:(NSString *)appId;
- (instancetype)initWithAppId:(NSString *)appId
                      eyeCare:(BOOL)eyeCare;
@end

/**设置课件预加载配置*/
@interface AgoraEduCourseware : NSObject
// 资源名称，必须要"/"开头
@property (nonatomic, copy) NSString *resourceName;
// 资源Id
@property (nonatomic, copy) NSString *resourceUuid;
// 场景路径，必须要"/"开头，相当于文件目录
// 建议这样拼接：resourceUuid + "/" + convertedFileList里面第一个对象的name
@property (nonatomic, copy) NSString *scenePath;
// 课件下载地址
// 参考： "https://convertcdn.netless.link/dynamicConvert/{taskUuid}.zip"
@property (nonatomic, copy) NSString *resourceUrl;
// 课件文件列表，用于目录里面每页的数据
// 对应convertedFileList对象
@property (nonatomic, strong) NSArray<WhiteScene *> *scenes;
- (instancetype)initWithResourceName:(NSString *)resourceName
                        resourceUuid:(NSString *)resourceUuid
                           scenePath:(NSString *)scenePath
                              scenes:(NSArray<WhiteScene *> *)scenes
                         resourceUrl:(NSString *)resourceUrl;
@end

/**设置媒体选项*/
@interface AgoraEduMediaEncryptionConfig : NSObject
@property (nonatomic, assign) AgoraEduMediaEncryptionMode mode;
@property (nonatomic, copy) NSString *key;

- (instancetype)initWithMode:(AgoraEduMediaEncryptionMode)mode key:(NSString *)key;
@end

@interface AgoraEduMediaOptions : NSObject
@property (nonatomic, strong) AgoraEduMediaEncryptionConfig *encryptionConfig;

- (instancetype)initWithConfig:(AgoraEduMediaEncryptionConfig *)encryptionConfig;
@end

@interface AgoraEduVideoEncoderConfiguration : NSObject
@property (nonatomic, assign) NSUInteger width;
@property (nonatomic, assign) NSUInteger height;
@property (nonatomic, assign) NSUInteger frameRate;
@property (nonatomic, assign) NSUInteger bitrate;
@property (nonatomic, assign) AgoraEduCoreMirrorMode mirrorMode;

- (instancetype)initWithWidth:(NSUInteger)width
                       height:(NSUInteger)height
                    frameRate:(NSUInteger)frameRate
                      bitrate:(NSUInteger)bitrate
                   mirrorMode:(AgoraEduCoreMirrorMode)mirrorMode;
@end

/**启动课堂配置*/
@interface AgoraEduLaunchConfig : NSObject
// 用户名
@property (nonatomic, copy) NSString *userName;
// 用户全局唯一id，需要与你签发token时使用的uid一致
@property (nonatomic, copy) NSString *userUuid;
// 角色类型(参考AgoraEduRoleType)
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
@property (nonatomic, copy) NSString *region;
// 加密
@property (nonatomic, strong, nullable) AgoraEduMediaOptions *mediaOptions;
// 用户自定属性
@property (nonatomic, copy, nullable) NSDictionary<NSString *, NSString *> * userProperties;
// 学生上麦默认打开/关闭视频
@property (nonatomic, assign) AgoraEduStreamState videoState;
// 学生上麦默认打开/关闭音频
@property (nonatomic, assign) AgoraEduStreamState audioState;
// 分辨率配置属性
@property (nonatomic, strong, nullable) AgoraEduVideoEncoderConfiguration *cameraEncoderConfiguration;
// RTC观众延时级别,默认lowlatency（极速直播）
@property (nonatomic, assign) AgoraEduLatencyLevel latencyLevel;

@property (nonatomic, assign) AgoraBoardFitMode boardFitMode;

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
                          region:(NSString * _Nullable)region
                    mediaOptions:(AgoraEduMediaOptions * _Nullable)mediaOptions
                  userProperties:(NSDictionary * _Nullable)userProperties
                      videoState:(AgoraEduStreamState)videoState
                      audioState:(AgoraEduStreamState)audioState
                    latencyLevel:(AgoraEduLatencyLevel)latencyLevel
                    boardFitMode:(AgoraBoardFitMode)boardFitMode;
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
