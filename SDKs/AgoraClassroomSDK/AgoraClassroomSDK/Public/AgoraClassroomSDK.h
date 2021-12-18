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
       failure:(void (^)(NSError *))failure;

+ (NSString *)version;
@end

NS_ASSUME_NONNULL_END
