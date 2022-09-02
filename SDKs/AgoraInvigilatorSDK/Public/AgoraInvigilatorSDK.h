//
//  AgoraInvigilatorSDK.h
//  AgoraInvigilatorSDK
//
//  Created by SRS on 2021/1/5.
//

#import <AgoraWidget/AgoraWidget.h>
#import <Foundation/Foundation.h>
#import "AgoraInvigilatorObjects.h"

NS_ASSUME_NONNULL_BEGIN
@class AgoraInvigilatorSDK;
@protocol AgoraInvigilatorSDKDelegate <NSObject>
@optional
- (void)invigilatorSDK:(AgoraInvigilatorSDK *)classroom
               didExit:(AgoraInvigilatorExitReason)reason;
@end

@interface AgoraInvigilatorSDK : NSObject
+ (void)launch:(AgoraInvigilatorLaunchConfig *)config
       success:(void (^)(void))success
       failure:(void (^)(NSError *))failure;

+ (void)setDelegate:(id<AgoraInvigilatorSDKDelegate> _Nullable)delegate;

+ (void)exit;

+ (NSString *)version;
@end

NS_ASSUME_NONNULL_END
