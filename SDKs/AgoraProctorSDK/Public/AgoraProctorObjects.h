//
//  EduObjects.h
//  AgoraClassroomSDK
//
//  Created by SRS on 2021/1/7.
//

#import <Foundation/Foundation.h>
@import AgoraWidget;
#import "AgoraProctorEnums.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Media
/**设置媒体选项*/
@interface AgoraProctorMediaEncryptionConfig : NSObject
@property (nonatomic, assign) AgoraProctorMediaEncryptionMode mode;
@property (nonatomic, copy) NSString *key;

- (instancetype)initWithMode:(AgoraProctorMediaEncryptionMode)mode
                         key:(NSString *)key;
@end

@interface AgoraProctorVideoEncoderConfig : NSObject
@property (nonatomic, assign) NSUInteger dimensionWidth;
@property (nonatomic, assign) NSUInteger dimensionHeight;
@property (nonatomic, assign) NSUInteger frameRate;
@property (nonatomic, assign) NSUInteger bitRate;
@property (nonatomic, assign) AgoraProctorMirrorMode mirrorMode;

- (instancetype)initWithDimensionWidth:(NSUInteger)dimensionWidth
                       dimensionHeight:(NSUInteger)dimensionHeight
                             frameRate:(NSUInteger)frameRate
                               bitRate:(NSUInteger)bitRate
                            mirrorMode:(AgoraProctorMirrorMode)mirrorMode;
@end

@interface AgoraProctorMediaOptions : NSObject
@property (nonatomic, strong, nullable) AgoraProctorMediaEncryptionConfig *encryptionConfig;
// 分辨率配置属性
@property (nonatomic, strong, nullable) AgoraProctorVideoEncoderConfig *videoEncoderConfig;
// RTC观众延时级别,默认lowlatency（极速直播）
@property (nonatomic, assign) AgoraProctorLatencyLevel latencyLevel;
// 学生上麦默认打开/关闭视频
@property (nonatomic, assign) AgoraProctorStreamState videoState;
// 学生上麦默认打开/关闭音频
@property (nonatomic, assign) AgoraProctorStreamState audioState;

- (instancetype)initWithEncryptionConfig:(AgoraProctorMediaEncryptionConfig * _Nullable)encryptionConfig
                      videoEncoderConfig:(AgoraProctorVideoEncoderConfig * _Nullable)videoEncoderConfig
                            latencyLevel:(AgoraProctorLatencyLevel)latencyLevel
                              videoState:(AgoraProctorStreamState)videoState
                              audioState:(AgoraProctorStreamState)audioState;
@end

#pragma mark - Launch
/**启动配置*/
@interface AgoraProctorLaunchConfig : NSObject
// 用户名
@property (nonatomic, copy) NSString *userName;
// 用户全局唯一id，需要与你签发token时使用的uid一致
@property (nonatomic, copy) NSString *userUuid;
// 角色类型(参考AgoraProctorCoreRoleType)
@property (nonatomic, assign) AgoraProctorUserRole userRole;
// 教室名称
@property (nonatomic, copy) NSString *roomName;
// 全局唯一的教室id
@property (nonatomic, copy) NSString *roomUuid;
// 声网App Id
@property (nonatomic, copy) NSString *appId;
// 声网Token
@property (nonatomic, copy) NSString *token;
// 区域
@property (nonatomic, assign) AgoraProctorRegion region;
// 媒体选项
@property (nonatomic, strong, nullable) AgoraProctorMediaOptions *mediaOptions;
// 用户自定属性
@property (nonatomic, copy, nullable) NSDictionary<NSString *, id> *userProperties;
// widgets
@property (nonatomic, strong) NSDictionary<NSString *, AgoraWidgetConfig *> *widgets;

- (instancetype)initWithUserName:(NSString *)userName
                        userUuid:(NSString *)userUuid
                        userRole:(AgoraProctorUserRole)userRole
                        roomName:(NSString *)roomName
                        roomUuid:(NSString *)roomUuid
                           appId:(NSString *)appId
                           token:(NSString *)token;

- (instancetype)initWithUserName:(NSString *)userName
                        userUuid:(NSString *)userUuid
                        userRole:(AgoraProctorUserRole)userRole
                        roomName:(NSString *)roomName
                        roomUuid:(NSString *)roomUuid
                           appId:(NSString *)appId
                           token:(NSString *)token
                          region:(AgoraProctorRegion)region
                    mediaOptions:(AgoraProctorMediaOptions * _Nullable)mediaOptions
                  userProperties:(NSDictionary * _Nullable)userProperties;
@end

NS_ASSUME_NONNULL_END
