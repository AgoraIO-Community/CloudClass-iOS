//
//  AgoraBaseExtApp.h
//  AgoraExtApp
//
//  Created by Cavan on 2021/4/8.
//

#import <UIKit/UIKit.h>
#import <AgoraUIBaseViews/AgoraUIBaseViews-Swift.h>
#import "AgoraExtAppObjects.h"

NS_ASSUME_NONNULL_BEGIN

// 定义Block
typedef void(^AgoraExtAppCompletion) (void);
typedef void(^AgoraExtAppErrorCompletion) (AgoraExtAppError *error);

@class AgoraBaseExtApp;

// 容器App代理
@protocol AgoraExtAppDelegate <NSObject>
// 更新属性
- (void)extApp:(AgoraBaseExtApp *)app
updateProperties:(NSDictionary *)properties
       success:(AgoraExtAppCompletion)success
          fail:(AgoraExtAppErrorCompletion)fail;
// 删除属性
- (void)extApp:(AgoraBaseExtApp *)app
deleteProperties:(NSArray <NSString *> *)keys
       success:(AgoraExtAppCompletion)success
          fail:(AgoraExtAppErrorCompletion)fail;
// App将被卸载， 你可以在该方法做些数据备份等
- (void)extAppWillUnload:(AgoraBaseExtApp *)app;
// 位置同步， 给AgoraEduExtAppsController处理
- (void)extApp:(AgoraBaseExtApp *)app
syncAppPosition:(CGPoint)diffPoint;
@end

// 容器App基类, 可以通过继承该类实现自己的容器应用
@interface AgoraBaseExtApp : NSObject
// 基础视图
@property (nonatomic, strong, readonly) AgoraBaseUIView *view;
// Id
@property (nonatomic, copy, readonly) NSString *appIdentifier;
// 属性数据， 你可以主动获取
@property (nonatomic, strong) NSDictionary *properties;
// 本地用户信息
@property (nonatomic, strong) AgoraExtAppUserInfo *localUserInfo;
// 房间信息
@property (nonatomic, strong) AgoraExtAppRoomInfo *roomInfo;
// 协议， 一般情况下你不需要实现该协议
@property (nonatomic, weak) id<AgoraExtAppDelegate> delegate;

// 初始化
- (instancetype)initWithAppIdentifier:(NSString *)appIdentifier
                        localUserInfo:(AgoraExtAppUserInfo *)userInfo
                             roomInfo:(AgoraExtAppRoomInfo *)roomInfo
                           properties:(NSDictionary *)properties;

// 个人用户信息更新
- (void)localUserInfoDidUpdate:(AgoraExtAppUserInfo *)userInfo;

// 房间信息更新
- (void)roomInfoDidUpdate:(AgoraExtAppRoomInfo *)roomInfo;

// 属性已经更新， 你可以通过子类实现该方法 做事件监听
- (void)propertiesDidUpdate:(NSDictionary *)properties;

// 更新房间属性
- (void)updateProperties:(NSDictionary *)properties
                 success:(AgoraExtAppCompletion)success
                    fail:(AgoraExtAppErrorCompletion)fail;

// 删除房间属性
- (void)deleteProperties:(NSArray <NSString *> *)keys
                 success:(AgoraExtAppCompletion)success
                    fail:(AgoraExtAppErrorCompletion)fail;

// 移除当前App
- (void)unload;

// Life cycle
// App已经加载，你可以在该方法初始化
- (void)extAppDidLoad:(AgoraExtAppContext *)context;
// App将被卸载， 你可以在该方法做些数据备份等
- (void)extAppWillUnload;
@end

NS_ASSUME_NONNULL_END
