//
//  AgoraLogService.h
//  AFNetworking
//
//  Created by SRS on 2020/8/10.
//

#import <Foundation/Foundation.h>
#import "EduBaseTypes.h"
#import <AgoraLog/AgoraLog.h>

NS_ASSUME_NONNULL_BEGIN

@interface AgoraLogService : NSObject

+ (NSError * _Nullable)setupLog:(AgoraLogConfiguration *)config;

+ (NSError * _Nullable)logMessage:(NSString *)message level:(AgoraLogLevel)level;

+ (void)logMessageWithDescribe:(NSString *)describe message:(id _Nullable)messageObj;

+ (void)logErrMessageWithDescribe:(NSString *)describe message:(id _Nullable)messageObj;

+ (void)uploadDebugItem:(EduDebugItem)item appId:(NSString *)appId uid:(NSString *)uid token:(NSString *)token success:(void (^)(NSString *serialNumber)) successBlock failure:(void (^)(NSError *error))failureBlock;

@end

NS_ASSUME_NONNULL_END
