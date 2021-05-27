//
//  AgoraExtAppObjects.h
//  AgoraExtApp
//
//  Created by Cavan on 2021/4/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**容器App配置*/
@interface AgoraExtAppConfiguration : NSObject
// 容器App Class Type, 由SDK创建该class的实例
@property (nonatomic, strong) Class extAppClass;
// 容器App Layout
@property (nonatomic, assign) UIEdgeInsets frame;
// 容器App Id
@property (nonatomic, copy) NSString *appIdentifier;
// 语言
@property (nonatomic, copy) NSString *language;
// 图片
@property (nonatomic, strong, nullable) UIImage *image;
// 选中图片
@property (nonatomic, strong, nullable) UIImage *selectedImage;

- (instancetype)initWithAppIdentifier:(NSString *)appIdentifier
                          extAppClass:(Class)extAppClass
                                frame:(UIEdgeInsets)frame
                             language:(NSString *)language;
@end

@class AgoraExtAppInfo;

/// 错误类
@interface AgoraExtAppError : NSObject
// 错误码
@property (nonatomic, assign) NSInteger code;
// 错误信息
@property (nonatomic, copy) NSString *message;

- (instancetype)initWithCode:(NSInteger )code
                     message:(NSString *)message;
@end

/// 人员信息
@interface AgoraExtAppUserInfo : NSObject
// 用户id
@property (nonatomic, copy) NSString *userUuid;
// 用户名字
@property (nonatomic, copy) NSString *userName;
// 用户角色
@property (nonatomic, copy) NSString *userRole;

- (instancetype)initWithUserUuid:(NSString *)userUuid
                        userName:(NSString *)userName
                        userRole:(NSString *)userRole;
@end

/// 房间信息
@interface AgoraExtAppRoomInfo : NSObject
// 房间id
@property (nonatomic, copy) NSString *roomUuid;
// 房间名称
@property (nonatomic, copy) NSString *roomName;
// 房间类型
@property (nonatomic, assign) NSUInteger roomType;

- (instancetype)initWithRoomUuid:(NSString *)roomUuid
                        roomName:(NSString *)roomName
                        roomType:(NSUInteger)roomType;
@end

/// 容器App信息： 聚合了容器内所需要的所有信息
@interface AgoraExtAppContext : NSObject
// 本地用户信息
@property (nonatomic, strong) AgoraExtAppUserInfo *localUserInfo;
// 房间信息
@property (nonatomic, strong) AgoraExtAppRoomInfo *roomInfo;
// 属性数据
@property (nonatomic, strong) NSDictionary *properties;
// Id
@property (nonatomic, copy) NSString *appIdentifier;
// 语言
@property (nonatomic, copy) NSString *language;

- (instancetype)initWithAppIdentifier:(NSString *)appIdentifier
                        localUserInfo:(AgoraExtAppUserInfo *)userInfo
                             roomInfo:(AgoraExtAppRoomInfo *)roomInfo
                           properties:(NSDictionary *)properties
                             language:(NSString *)language;
@end

/// 容器App的注册信息：用于启动容器App交互所需的信息
@interface AgoraExtAppInfo : NSObject
// Id
@property (nonatomic, copy) NSString *appIdentifier;
// 语言
@property (nonatomic, copy) NSString *language;
// 图片
@property (nonatomic, strong, nullable) UIImage *image;
// 选中图片
@property (nonatomic, strong, nullable) UIImage *selectedImage;

- (instancetype)initWithAppIdentifier:(NSString *)appIdentifier
                             language:(NSString *)language;
@end

NS_ASSUME_NONNULL_END
