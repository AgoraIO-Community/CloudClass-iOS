//
//  AgoraClassroomSDK.h
//  AgoraClassroomSDK
//
//  Created by SRS on 2021/1/5.
//

#import <AgoraWidget/AgoraWidget.h>
#import <Foundation/Foundation.h>
#import "AgoraEduObjects.h"

NS_ASSUME_NONNULL_BEGIN
@class AgoraClassroomSDK;
@protocol AgoraEduClassroomSDKDelegate <NSObject>
@optional
- (void)classroomSDK:(AgoraClassroomSDK *)classroom
             didExit:(AgoraEduExitReason)reason;
@end

@interface AgoraClassroomSDK : NSObject
+ (void)launch:(AgoraEduLaunchConfig *)config
       success:(void (^)(void))success
       failure:(void (^)(NSError *))failure;

/** 职教课堂的加载方法*/
+ (void)vocationalLaunch:(AgoraEduLaunchConfig *)config
                 service:(AgoraEduServiceType)serviceType
                 success:(void (^)(void))success
                 failure:(void (^)(NSError *))failure;

+ (void)setDelegate:(id<AgoraEduClassroomSDKDelegate> _Nullable)delegate;

+ (void)exit;

+ (NSString *)version;
@end

NS_ASSUME_NONNULL_END
