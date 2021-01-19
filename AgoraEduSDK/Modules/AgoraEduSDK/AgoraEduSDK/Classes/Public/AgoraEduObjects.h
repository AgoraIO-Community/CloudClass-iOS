//
//  EduObjects.h
//  AgoraEduSDK
//
//  Created by SRS on 2021/1/7.
//

#import <Foundation/Foundation.h>
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
- (instancetype)initWithAppId:(NSString *)appId eyeCare:(BOOL)eyeCare;
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

- (instancetype)initWithUserName:(NSString *)userName userUuid:(NSString *)userUuid roleType:(AgoraEduRoleType)roleType roomName:(NSString *)roomName roomUuid:(NSString *)roomUuid roomType:(AgoraEduRoomType)roomType token:(NSString *)token;

@end

/**设置回放配置*/
@interface AgoraEduReplayConfig : NSObject
// 白板的App Id
@property (nonatomic, copy) NSString *whiteBoardAppId;
// 白板Id
@property (nonatomic, copy) NSString *whiteBoardId;
// 白板token
@property (nonatomic, copy) NSString *whiteBoardToken;
// 视频URL地址
@property (nonatomic, copy) NSString *videoUrl;
// 需要截取录制的开始时间戳，单位毫秒
@property (nonatomic, assign) NSInteger beginTime;
// 需要截取录制的结束时间戳，单位毫秒
@property (nonatomic, assign) NSInteger endTime;

- (instancetype)initWithBoardAppId:(NSString *)whiteBoardAppId boardId:(NSString *)whiteBoardId boardToken:(NSString *)whiteBoardToken videoUrl:(NSString *)videoUrl beginTime:(NSInteger)beginTime endTime:(NSInteger)endTime;

@end

NS_ASSUME_NONNULL_END
