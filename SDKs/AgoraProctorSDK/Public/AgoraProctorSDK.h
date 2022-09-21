//
//  AgoraProctorSDK.h
//  AgoraProctorSDK
//
//  Created by SRS on 2021/1/5.
//

#import <Foundation/Foundation.h>
#import "AgoraProctorObjects.h"

NS_ASSUME_NONNULL_BEGIN
@class AgoraProctorSDK;
@protocol AgoraProctorSDKDelegate <NSObject>
@optional
- (void)proctorSDK:(AgoraProctorSDK *)classroom
           didExit:(AgoraProctorExitReason)reason;
@end

@interface AgoraProctorSDK : NSObject
- (instancetype)init:(AgoraProctorLaunchConfig *)config
            delegate:(id<AgoraProctorSDKDelegate> _Nullable)delegate;

- (void)launch:(void (^)(void))success
       failure:(void (^)(NSError *))failure;

- (NSString *)version;
@end

NS_ASSUME_NONNULL_END
