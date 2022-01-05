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
             didExit:(AgoraEduExitReason)reason;
@end

@interface AgoraClassroomSDK : NSObject
+ (void)launch:(AgoraEduLaunchConfig *)config
       success:(void (^)(void))success
       failure:(void (^)(NSError *))failure;

+ (void)setDelegate:(id<AgoraEduClassroomSDKDelegate> _Nullable)delegate;

+ (void)exit;

+ (NSString *)version;
@end

NS_ASSUME_NONNULL_END
