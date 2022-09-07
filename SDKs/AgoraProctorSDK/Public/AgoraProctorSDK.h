//
//  AgoraProctorSDK.h
//  AgoraProctorSDK
//
//  Created by SRS on 2021/1/5.
//

#import <AgoraWidget/AgoraWidget.h>
#import <Foundation/Foundation.h>
#import "AgoraProctorObjects.h"

NS_ASSUME_NONNULL_BEGIN
@class AgoraProctorSDK;
@protocol AgoraProctorSDKDelegate <NSObject>
@optional
- (void)invigilatorSDK:(AgoraProctorSDK *)classroom
               didExit:(AgoraProctorExitReason)reason;
@end

@interface AgoraProctorSDK : NSObject
+ (void)launch:(AgoraProctorLaunchConfig *)config
       success:(void (^)(void))success
       failure:(void (^)(NSError *))failure;

+ (void)setDelegate:(id<AgoraProctorSDKDelegate> _Nullable)delegate;

+ (void)exit;

+ (NSString *)version;
@end

NS_ASSUME_NONNULL_END
