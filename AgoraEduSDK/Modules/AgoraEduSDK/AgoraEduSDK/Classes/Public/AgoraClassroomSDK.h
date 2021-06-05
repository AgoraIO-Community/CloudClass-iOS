//
//  AgoraEduSDK.h
//  AgoraEduSDK
//
//  Created by SRS on 2021/1/5.
//

#import <Foundation/Foundation.h>
#import <AgoraExtApp/AgoraExtApp.h>
#import <AgoraWidget/AgoraWidget.h>
#import "AgoraEduObjects.h"
#import "AgoraEduClassroom.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AgoraEduCoursewareDelegate <NSObject>
@optional
- (void)courseware:(AgoraEduCourseware *)courseware
 didProcessChanged:(float)process;
- (void)courseware:(AgoraEduCourseware *)courseware
      didCompleted:(NSError * _Nullable)error;
@end

@interface AgoraClassroomSDK : NSObject
+ (void)setConfig:(AgoraEduSDKConfig *)config;

+ (AgoraEduClassroom * _Nullable)launch:(AgoraEduLaunchConfig *)config
                               delegate:(id<AgoraEduClassroomDelegate> _Nullable)delegate;

// 配置白板课件
+ (void)configCoursewares:(NSArray<AgoraEduCourseware *> *)coursewares;
// 下载白板课件
+ (void)downloadCoursewares:(id<AgoraEduCoursewareDelegate> _Nullable)delegate;
// 注册容器App， ExtApp更倾向于独立的模块， 不太和外部其他UI交互
+ (void)registerExtApps:(NSArray<AgoraExtAppConfiguration *> *)apps;
// 注册组件， Widget倾向于UI层的一个独立组件，会和外部其他UI交互。
+ (void)registerWidgets:(NSArray<AgoraWidgetConfiguration *> *)widgets;

+ (NSString *)version;
@end

NS_ASSUME_NONNULL_END
