//
//  EduObjects.h
//  AgoraClassroomSDK
//
//  Created by SRS on 2021/1/7.
//

#import <Foundation/Foundation.h>
#import <AgoraWidget/AgoraWidget.h>
#import "AgoraEduEnums.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Media
/**设置媒体选项*/
@interface AgoraEduMediaEncryptionConfig : NSObject
@property (nonatomic, assign) AgoraEduMediaEncryptionMode mode;
@property (nonatomic, copy) NSString *key;

- (instancetype)initWithMode:(AgoraEduMediaEncryptionMode)mode
                         key:(NSString *)key;
@end

@interface AgoraEduVideoEncoderConfig : NSObject
@property (nonatomic, assign) NSUInteger dimensionWidth;
@property (nonatomic, assign) NSUInteger dimensionHeight;
@property (nonatomic, assign) NSUInteger frameRate;
@property (nonatomic, assign) NSUInteger bitRate;
@property (nonatomic, assign) AgoraEduMirrorMode mirrorMode;

- (instancetype)initWithDimensionWidth:(NSUInteger)dimensionWidth
                       dimensionHeight:(NSUInteger)dimensionHeight
                             frameRate:(NSUInteger)frameRate
                               bitRate:(NSUInteger)bitRate
                            mirrorMode:(AgoraEduMirrorMode)mirrorMode;
@end

@interface AgoraEduMediaOptions : NSObject
@property (nonatomic, strong, nullable) AgoraEduMediaEncryptionConfig *encryptionConfig;
// 分辨率配置属性
@property (nonatomic, strong, nullable) AgoraEduVideoEncoderConfig *videoEncoderConfig;
// RTC观众延时级别,默认lowlatency（极速直播）
@property (nonatomic, assign) AgoraEduLatencyLevel latencyLevel;
// 学生上麦默认打开/关闭视频
@property (nonatomic, assign) AgoraEduStreamState videoState;
// 学生上麦默认打开/关闭音频
@property (nonatomic, assign) AgoraEduStreamState audioState;

- (instancetype)initWithEncryptionConfig:(AgoraEduMediaEncryptionConfig * _Nullable)encryptionConfig
                      videoEncoderConfig:(AgoraEduVideoEncoderConfig * _Nullable)videoEncoderConfig
                            latencyLevel:(AgoraEduLatencyLevel)latencyLevel
                              videoState:(AgoraEduStreamState)videoState
                              audioState:(AgoraEduStreamState)audioState;
@end

#pragma mark - Launch
/**启动配置*/
@interface AgoraEduLaunchConfig : NSObject
// 用户名
@property (nonatomic, copy) NSString *userName;
// 用户全局唯一id，需要与你签发token时使用的uid一致
@property (nonatomic, copy) NSString *userUuid;
// 角色类型(参考AgoraEduCoreRoleType)
@property (nonatomic, assign) AgoraEduUserRole userRole;
// 教室名称
@property (nonatomic, copy) NSString *roomName;
// 全局唯一的教室id
@property (nonatomic, copy) NSString *roomUuid;
// 教室类型
@property (nonatomic, assign) AgoraEduRoomType roomType;
// 声网App Id
@property (nonatomic, copy) NSString *appId;
// 声网Token
@property (nonatomic, copy) NSString *token;
// 开始上课的时间（毫秒）
@property (nonatomic, copy, nullable) NSNumber *startTime;
// 课程时长（秒）
@property (nonatomic, copy, nullable) NSNumber *duration;
// 区域
@property (nonatomic, assign) AgoraEduRegion region;
// 媒体选项
@property (nonatomic, strong, nullable) AgoraEduMediaOptions *mediaOptions;
// 用户自定属性
@property (nonatomic, copy, nullable) NSDictionary<NSString *, id> *userProperties;
// widgets
@property (nonatomic, strong) NSDictionary<NSString *, AgoraWidgetConfig *> *widgets;

- (instancetype)initWithUserName:(NSString *)userName
                        userUuid:(NSString *)userUuid
                        userRole:(AgoraEduUserRole)userRole
                        roomName:(NSString *)roomName
                        roomUuid:(NSString *)roomUuid
                        roomType:(AgoraEduRoomType)roomType
                           appId:(NSString *)appId
                           token:(NSString *)token;

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
                    mediaOptions:(AgoraEduMediaOptions * _Nullable)mediaOptions
                  userProperties:(NSDictionary * _Nullable)userProperties;
@end

NS_ASSUME_NONNULL_END
