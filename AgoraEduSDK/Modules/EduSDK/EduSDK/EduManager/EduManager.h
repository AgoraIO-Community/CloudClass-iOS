//
//  EduManager.h
//  Demo
//
//  Created by SRS on 2020/6/17.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EduClassroomManager.h"
#import "EduClassroomConfig.h"
#import "EduConfiguration.h"
#import "EduBaseTypes.h"
#import "EduManagerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^OnDebugItemUploadSuccessBlock)(NSString *serialNumber);

@interface EduManager : NSObject

@property (nonatomic, weak) id<EduManagerDelegate> delegate;

// init EduManager
- (instancetype)initWithConfig:(EduConfiguration *)config success:(EduSuccessBlock)successBlock failure:(EduFailureBlock _Nullable)failureBlock;

// generate EduClassroomManager
- (EduClassroomManager *)createClassroomWithConfig:(EduClassroomConfig *)config;

- (void)destory;

+ (NSString *)version;

// log
- (NSError * _Nullable)logMessage:(NSString *)message level:(EduLogLevel)level;
- (void)uploadDebugItem:(EduDebugItem)item uid:(NSString *)uid token:(NSString *)token success:(OnDebugItemUploadSuccessBlock) successBlock failure:(EduFailureBlock _Nullable)failureBlock;

#pragma mark Unavailable Initializers
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

