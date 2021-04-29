//
//  AgoraRTEManager.h
//  Demo
//
//  Created by SRS on 2020/6/17.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AgoraRTEClassroomManager.h"
#import "AgoraRTEClassroomConfig.h"
#import "AgoraRTEConfiguration.h"
#import "AgoraRTEBaseTypes.h"
#import "AgoraRTEManagerDelegate.h"
@import AgoraLog.AgoraLogBaseTypes;

NS_ASSUME_NONNULL_BEGIN

typedef void(^OnDebugItemUploadSuccessBlock)(NSString *serialNumber);

@interface AgoraRTEManager : NSObject

@property (nonatomic, weak) id<AgoraRTEManagerDelegate> delegate;

// init AgoraRTEManager
- (instancetype)initWithConfig:(AgoraRTEConfiguration *)config success:(AgoraRTESuccessBlock)successBlock failure:(AgoraRTEFailureBlock _Nullable)failureBlock;

// generate AgoraRTEClassroomManager
- (AgoraRTEClassroomManager *)createClassroomWithConfig:(AgoraRTEClassroomConfig *)config;

- (void)destory;

+ (NSString *)version;

// log
- (NSError * _Nullable)logMessage:(NSString *)message level:(AgoraRTELogLevel)level;
- (void)uploadDebugItem:(AgoraRTEDebugItem)item
                options:(AgoraLogUploadOptions *)options
                success:(OnDebugItemUploadSuccessBlock)successBlock
                failure:(AgoraRTEFailureBlock _Nullable)failureBlock;

#pragma mark Unavailable Initializers
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

