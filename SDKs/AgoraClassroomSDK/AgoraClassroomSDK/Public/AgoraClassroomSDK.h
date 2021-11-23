//
//  AgoraClassroomSDK.h
//  AgoraClassroomSDK
//
//  Created by SRS on 2021/1/5.
//

#import <AgoraExtApp/AgoraExtApp.h>
#import <AgoraWidget/AgoraWidget.h>
#import <Foundation/Foundation.h>
#import "AgoraEduObjects.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AgoraEduCoursewareProcess <NSObject>
@optional
- (void)courseware:(AgoraEduCourseware *)courseware
 didProcessChanged:(float)process;
- (void)courseware:(AgoraEduCourseware *)courseware
      didCompleted:(NSError * _Nullable)error;
@end

@class AgoraClassroomSDK;
@protocol AgoraEduClassroomSDKDelegate <NSObject>
@optional
- (void)classroomSDK:(AgoraClassroomSDK *)classroom
           didExited:(AgoraEduExitReason)reason;
@end

@interface AgoraClassroomSDK : NSObject
+ (BOOL)setConfig:(AgoraClassroomSDKConfig *)config;

+ (void)launch:(AgoraEduLaunchConfig *)config
      delegate:(id<AgoraEduClassroomSDKDelegate> _Nullable)delegate
       success:(void (^)(void))success
          fail:(void (^)(NSError *))fail;

// 注册容器App
+ (void)registerExtApps:(NSArray<AgoraExtAppConfiguration *> *)apps;

+ (void)registerWidgets:(NSArray<AgoraWidgetConfiguration *> *)widgets;

+ (NSString *)version;
@end

NS_ASSUME_NONNULL_END
