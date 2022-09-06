//
//  EduObjects.h
//  AgoraClassroomSDK
//
//  Created by SRS on 2021/1/7.
//

#import <Foundation/Foundation.h>
@import AgoraWidget;
#import "AgoraInvigilatorEnums.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Media
/**设置媒体选项*/
@interface AgoraInvigilatorMediaEncryptionConfig : NSObject
@property (nonatomic, assign) AgoraInvigilatorMediaEncryptionMode mode;
@property (nonatomic, copy) NSString *key;

- (instancetype)initWithMode:(AgoraInvigilatorMediaEncryptionMode)mode
                         key:(NSString *)key;
@end

@interface AgoraInvigilatorVideoEncoderConfig : NSObject
@property (nonatomic, assign) NSUInteger dimensionWidth;
@property (nonatomic, assign) NSUInteger dimensionHeight;
@property (nonatomic, assign) NSUInteger frameRate;
@property (nonatomic, assign) NSUInteger bitRate;
@property (nonatomic, assign) AgoraInvigilatorMirrorMode mirrorMode;

- (instancetype)initWithDimensionWidth:(NSUInteger)dimensionWidth
                       dimensionHeight:(NSUInteger)dimensionHeight
                             frameRate:(NSUInteger)frameRate
                               bitRate:(NSUInteger)bitRate
                            mirrorMode:(AgoraInvigilatorMirrorMode)mirrorMode;
@end

@interface AgoraInvigilatorMediaOptions : NSObject
@property (nonatomic, strong, nullable) AgoraInvigilatorMediaEncryptionConfig *encryptionConfig;
// 分辨率配置属性
@property (nonatomic, strong, nullable) AgoraInvigilatorVideoEncoderConfig *videoEncoderConfig;
// RTC观众延时级别,默认lowlatency（极速直播）
@property (nonatomic, assign) AgoraInvigilatorLatencyLevel latencyLevel;
// 学生上麦默认打开/关闭视频
@property (nonatomic, assign) AgoraInvigilatorStreamState videoState;
// 学生上麦默认打开/关闭音频
@property (nonatomic, assign) AgoraInvigilatorStreamState audioState;

- (instancetype)initWithEncryptionConfig:(AgoraInvigilatorMediaEncryptionConfig * _Nullable)encryptionConfig
                      videoEncoderConfig:(AgoraInvigilatorVideoEncoderConfig * _Nullable)videoEncoderConfig
                            latencyLevel:(AgoraInvigilatorLatencyLevel)latencyLevel
                              videoState:(AgoraInvigilatorStreamState)videoState
                              audioState:(AgoraInvigilatorStreamState)audioState;
@end

#pragma mark - Launch
/**启动配置*/
@interface AgoraInvigilatorLaunchConfig : NSObject
// 用户名
@property (nonatomic, copy) NSString *userName;
// 用户全局唯一id，需要与你签发token时使用的uid一致
@property (nonatomic, copy) NSString *userUuid;
// 角色类型(参考AgoraInvigilatorCoreRoleType)
@property (nonatomic, assign) AgoraInvigilatorUserRole userRole;
// 教室名称
@property (nonatomic, copy) NSString *roomName;
// 全局唯一的教室id
@property (nonatomic, copy) NSString *roomUuid;
// 声网App Id
@property (nonatomic, copy) NSString *appId;
// 声网Token
@property (nonatomic, copy) NSString *token;
// 开始上课的时间（毫秒）
@property (nonatomic, copy, nullable) NSNumber *startTime;
// 课程时长（秒）
@property (nonatomic, copy, nullable) NSNumber *duration;
// 区域
@property (nonatomic, assign) AgoraInvigilatorRegion region;
// 媒体选项
@property (nonatomic, strong, nullable) AgoraInvigilatorMediaOptions *mediaOptions;
// 用户自定属性
@property (nonatomic, copy, nullable) NSDictionary<NSString *, id> *userProperties;
// widgets
@property (nonatomic, strong) NSDictionary<NSString *, AgoraWidgetConfig *> *widgets;

- (instancetype)initWithUserName:(NSString *)userName
                        userUuid:(NSString *)userUuid
                        userRole:(AgoraInvigilatorUserRole)userRole
                        roomName:(NSString *)roomName
                        roomUuid:(NSString *)roomUuid
                        roomType:(AgoraInvigilatorRoomType)roomType
                           appId:(NSString *)appId
                           token:(NSString *)token;

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
                    mediaOptions:(AgoraInvigilatorMediaOptions * _Nullable)mediaOptions
                  userProperties:(NSDictionary * _Nullable)userProperties;
@end

NS_ASSUME_NONNULL_END
