//
//  AgoraExtAppController.h
//  AgoraExtApp
//
//  Created by Cavan on 2021/4/25.
//

#import <Foundation/Foundation.h>
#import <AgoraUIBaseViews/AgoraUIBaseViews-Swift.h>
#import "AgoraExtAppObjects.h"
#import "AgoraBaseExtApp.h"

NS_ASSUME_NONNULL_BEGIN

// 容器App协议
@protocol AgoraExtAppProtocol <NSObject>
// 启动App， 注册之后需要通过该方法启动App
- (NSInteger)willLaunchExtApp:(NSString *)appIdentifier;
//获取 容器App的注册信息，用于启动容器App交互所需的信息
- (NSArray<AgoraExtAppInfo *> * _Nullable)getExtAppInfos;
@end

@class AgoraExtAppsController;
@protocol AgoraExtAppsControllerDataSource <NSObject>

- (void)appsController:(AgoraExtAppsController *)controller
needPropertiesOfExtAppIdentifier:(NSString *)appIdentifier
            properties:(void(^) (NSDictionary *properties))properties;

- (void)appsController:(AgoraExtAppsController *)controller
          needUserInfo:(void(^) (AgoraExtAppUserInfo *userInfo))userInfo
          needRoomInfo:(void(^) (AgoraExtAppRoomInfo *roomInfo))roomInfo;
@end

@interface AgoraExtAppsController : NSObject <AgoraExtAppDelegate>
@property (nonatomic, weak) id<AgoraExtAppsControllerDataSource> dataSource;
@property (nonatomic, strong, readonly) AgoraBaseUIView *containerView;

- (void)registerApps:(NSArray<AgoraExtAppConfiguration *> *)apps;
- (void)perExtAppPropertiesDidUpdate:(NSDictionary *)properties;
- (void)userInfoDidUpdate:(AgoraExtAppUserInfo *)userInfo;
- (void)roomInfoDidUpdate:(AgoraExtAppRoomInfo *)roomInfo;
- (void)appsCommonDidUpdate:(NSDictionary<NSString *, id> *)appsCommonDic;
- (NSInteger)willLaunchExtApp:(NSString *)appIdentifier;
- (NSArray<AgoraExtAppInfo *> *)getExtAppInfos;
@end

NS_ASSUME_NONNULL_END
