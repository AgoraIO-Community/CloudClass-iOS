//
//  EduErrorManager.h
//  EduSDK
//
//  Created by SRS on 2020/10/26.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AgoraLog/AgoraLog.h>

NS_ASSUME_NONNULL_BEGIN

@interface EduErrorManager : NSObject

+ (NSError *)paramterInvalid:(NSString *)param code:(NSInteger)code;
+ (NSError *)internalError:(NSString *)message code:(NSInteger)code;
+ (NSError *)communicationError:(NSInteger)rtmCode code:(NSInteger)code;
+ (NSError *)mediaError:(NSInteger)rtcCode codeMsg:(NSString *)codeMsg code:(NSInteger)code;
+ (NSError *)networkError:(NSInteger)netCode codeMsg:(NSString *)codeMsg code:(NSInteger)code;

+ (NSError * _Nullable)paramterEmptyError:(NSString *)key value:(NSString *)value code:(NSInteger)code;

+ (NSError * _Nullable)logError:(AgoraLogErrorType)type message:(NSString *_Nullable)errMsg code:(NSInteger)code;

@end

NS_ASSUME_NONNULL_END
