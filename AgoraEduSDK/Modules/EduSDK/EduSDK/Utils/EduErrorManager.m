//
//  EduErrorManager.m
//  EduSDK
//
//  Created by SRS on 2020/10/26.
//  Copyright © 2020 agora. All rights reserved.
//

#import "EduErrorManager.h"
#import "EduConstants.h"

// error message
#define Error_ParamterInvalid @"parameter %@ is invalid"
#define Error_InternalError @"%@"
#define Error_CommunicationError @"communication error:%ld"

#define Error_MediaErrorReason @"media error:%ld reason:%@"
#define Error_MediaError @"media error:%ld"

#define Error_NetworkError @"network error:%ld reason:%@"

@implementation EduErrorManager
+ (NSError *)paramterInvalid:(NSString *)param code:(NSInteger)code {
    NSString *msg = [NSString stringWithFormat:Error_ParamterInvalid, param];
    return LocalError(code, msg);
}

+ (NSError *)internalError:(NSString *)message code:(NSInteger)code {
    NSString *errMsg = @"internal error";
    if(message != nil && message.length > 0){
        errMsg = message;
    }
    
    return LocalError(code, errMsg);
}

+ (NSError *)communicationError:(NSInteger)rtmCode code:(NSInteger)code {
    NSString *msg = [NSString stringWithFormat:Error_CommunicationError, rtmCode];
    return LocalError(code, msg);
}

+ (NSError *)mediaError:(NSInteger)rtcCode codeMsg:(NSString *)codeMsg code:(NSInteger)code {
    
    NSString *msg = @"";
    if(codeMsg.length > 0) {
        msg = [NSString stringWithFormat:Error_MediaErrorReason, rtcCode, codeMsg];
    } else {
        msg = [NSString stringWithFormat:Error_MediaError, rtcCode];
    }
    return LocalError(code, msg);
}

+ (NSError *)networkError:(NSInteger)netCode codeMsg:(NSString *)codeMsg code:(NSInteger)code {
    NSString *errMsg = @"network error";
    if(codeMsg != nil && codeMsg.length > 0){
        errMsg = [NSString stringWithFormat:Error_NetworkError, netCode, codeMsg];
    }
    return LocalError(code, errMsg);
}

+ (NSError * _Nullable)paramterEmptyError:(NSString *)key value:(NSString *)value code:(NSInteger)code {
    
    if(![value isKindOfClass:NSString.class] || value.length == 0){
        return [EduErrorManager paramterInvalid:key code:code];
    }
    return nil;
}

#pragma mark --
+ (NSError * _Nullable)logError:(AgoraLogErrorType)type message:(NSString *_Nullable)errMsg code:(NSInteger)code {
    
    NSString *str = errMsg ? errMsg : @"";
    if (type == AgoraLogErrorTypeNone) {
        return nil;
        
    } else if (type == AgoraLogErrorTypeInvalidParemeter) {
        return [EduErrorManager paramterInvalid:str.length > 0 ? str : @"log" code:code];
        
    } else if (type == AgoraLogErrorTypeInternalError) {
        return [EduErrorManager internalError:str.length > 0 ? str : @"log internal error" code:code];
        
    } else {
        return [EduErrorManager internalError:str.length > 0 ? str : @"log network error" code:code];
    }
}
@end
