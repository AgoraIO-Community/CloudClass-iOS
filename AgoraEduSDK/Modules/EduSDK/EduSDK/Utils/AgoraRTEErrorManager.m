//
//  AgoraRTEErrorManager.m
//  EduSDK
//
//  Created by SRS on 2020/10/26.
//  Copyright © 2020 agora. All rights reserved.
//

#import "AgoraRTEErrorManager.h"
#import "AgoraRTEConstants.h"

// error message
#define AgoraRTE_Error_ParamterInvalid @"parameter %@ is invalid"
#define AgoraRTE_Error_InternalError @"%@"
#define AgoraRTE_Error_CommunicationError @"communication error:%ld"

#define AgoraRTE_Error_MediaErrorReason @"media error:%ld reason:%@"
#define AgoraRTE_Error_MediaError @"media error:%ld"

#define AgoraRTE_Error_NetworkError @"network error:%ld reason:%@"

@implementation AgoraRTEErrorManager
+ (NSError *)paramterInvalid:(NSString *)param code:(NSInteger)code {
    NSString *msg = [NSString stringWithFormat:AgoraRTE_Error_ParamterInvalid, param];
    return AgoraRTELocalError(code, msg);
}

+ (NSError *)internalError:(NSString *)message code:(NSInteger)code {
    NSString *errMsg = @"restful-internal error";
    if(message != nil && message.length > 0){
        errMsg = message;
    }
    
    return AgoraRTELocalError(code, errMsg);
}

+ (NSError *)communicationError:(NSInteger)rtmCode code:(NSInteger)code {
    NSString *msg = [NSString stringWithFormat:@"rtm-%@", AgoraRTE_Error_CommunicationError, rtmCode];
    return AgoraRTELocalError(code, msg);
}

+ (NSError *)mediaError:(NSInteger)rtcCode codeMsg:(NSString *)codeMsg code:(NSInteger)code {
    
    NSString *msg = @"";
    if(codeMsg.length > 0) {
        msg = [NSString stringWithFormat:@"rtc-%@", AgoraRTE_Error_MediaErrorReason, rtcCode, codeMsg];
    } else {
        msg = [NSString stringWithFormat:@"rtc-%@", AgoraRTE_Error_MediaError, rtcCode];
    }
    return AgoraRTELocalError(code, msg);
}

+ (NSError *)networkError:(NSInteger)netCode codeMsg:(NSString *)codeMsg code:(NSInteger)code {
    NSString *errMsg = @"restful-network error";
    if(codeMsg != nil && codeMsg.length > 0){
        errMsg = [NSString stringWithFormat:@"restful-%@", AgoraRTE_Error_NetworkError, netCode, codeMsg];
    }
    return AgoraRTELocalError(code, errMsg);
}

+ (NSError * _Nullable)paramterEmptyError:(NSString *)key value:(NSString *)value code:(NSInteger)code {
    
    if(![value isKindOfClass:NSString.class] || value.length == 0){
        return [AgoraRTEErrorManager paramterInvalid:key code:code];
    }
    return nil;
}

#pragma mark --
+ (NSError * _Nullable)logError:(AgoraLogErrorType)type message:(NSString *_Nullable)errMsg code:(NSInteger)code {
    
    NSString *str = errMsg ? errMsg : @"";
    if (type == AgoraLogErrorTypeNone) {
        return nil;
        
    } else if (type == AgoraLogErrorTypeInvalidParemeter) {
        return [AgoraRTEErrorManager paramterInvalid:str.length > 0 ? str : @"log" code:code];
        
    } else if (type == AgoraLogErrorTypeInternalError) {
        return [AgoraRTEErrorManager internalError:str.length > 0 ? str : @"log internal error" code:code];
        
    } else {
        return [AgoraRTEErrorManager internalError:str.length > 0 ? str : @"log network error" code:code];
    }
}
@end
