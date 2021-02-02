//
//  AgoraRTELogService.m
//  AFNetworking
//
//  Created by SRS on 2020/8/10.
//

#import "AgoraRTELogService.h"
#import "AgoraRTEConstants.h"
#import <YYModel/YYModel.h>
#import "AgoraRTEErrorManager.h"

@interface AgoraRTELogService()
@property(nonatomic, strong) AgoraLogManager *logManager;
@end

static AgoraRTELogService *manager = nil;

@implementation AgoraRTELogService
+ (instancetype)shareManager{
    @synchronized(self){
        if (!manager) {
            manager = [AgoraRTELogService new];
            manager.logManager = [AgoraLogManager new];
        }
        return manager;
    }
}

+ (NSError * _Nullable)setupLog:(AgoraLogConfiguration *)config {
    
    if (config.logLevel != AgoraLogLevelNone && config.logLevel != AgoraLogLevelInfo && config.logLevel != AgoraLogLevelWarn && config.logLevel != AgoraLogLevelError) {
        
        NSError *eduError = [AgoraRTEErrorManager paramterInvalid:@"logLevel" code:1];
        return eduError;
    }
    
    if (![config.directoryPath isKindOfClass:NSString.class] || config.directoryPath.length == 0) {
        NSError *eduError = [AgoraRTEErrorManager paramterInvalid:@"directoryPath" code:1];
        return eduError;
    }
    
    if (config.consoleState != AgoraLogConsoleStateOpen && config.consoleState != AgoraLogConsoleStateClose) {
        
        NSError *eduError = [AgoraRTEErrorManager paramterInvalid:@"consoleState" code:1];
        return eduError;
    }
    [[AgoraRTELogService shareManager].logManager setupLog:config];

    return nil;
}

+ (NSError * _Nullable)logMessage:(NSString *)message level:(AgoraLogLevel)level {
    
    if (![message isKindOfClass:NSString.class] || message.length == 0) {
        NSError *eduError = [AgoraRTEErrorManager paramterInvalid:@"message" code:1];
        return eduError;
    }
    
    if (level != AgoraLogLevelNone && level != AgoraLogLevelInfo && level != AgoraLogLevelWarn && level != AgoraLogLevelError) {
        NSError *eduError = [AgoraRTEErrorManager paramterInvalid:@"logLevel" code:1];
        return eduError;
    }
    [[AgoraRTELogService shareManager].logManager logMessage:message level:level];
    return nil;
}

+ (void)logMessageWithDescribe:(NSString *)describe message:(id _Nullable)messageObj {
    
    NSString *string = [@"AgoraEduSDK " stringByAppendingString:describe];
    [AgoraRTELogService logMessageWithLevel:AgoraLogLevelInfo describe:string message:messageObj];
}

+ (void)logErrMessageWithDescribe:(NSString *)describe message:(id _Nullable)messageObj {
    
    NSString *string = [@"AgoraEduSDK " stringByAppendingString:describe];
    [AgoraRTELogService logMessageWithLevel:AgoraLogLevelError describe:string message:messageObj];
}

+ (void)uploadDebugItem:(AgoraRTEDebugItem)item appId:(NSString *)appId uid:(NSString *)uid token:(NSString *)token success:(void (^)(NSString *serialNumber)) successBlock failure:(void (^)(NSError *error))failureBlock {

    if (item != AgoraRTEDebugItemLog) {
        NSError *eduError = [AgoraRTEErrorManager paramterInvalid:@"item" code:1];
        if(failureBlock){
            failureBlock(eduError);
        }
        return;
    }

    AgoraLogUploadOptions *options = [AgoraLogUploadOptions new];
    options.appId = appId;
    options.uid = uid;
    options.rtmToken = token;
   
    AgoraLogErrorType errType = [[AgoraRTELogService shareManager].logManager uploadLogWithOptions:options progress:^(float progress) {
        
    } success:^(NSString *serialNumber) {
        if (successBlock != nil) {
            successBlock(serialNumber);
        }
    } failure:^(NSError *error) {
        if(failureBlock != nil) {
            NSError *eduError;
            if(error == nil) {
                eduError = [AgoraRTEErrorManager internalError:@"" code:2];
            } else {
                eduError = [AgoraRTEErrorManager logError:error.code message:error.localizedDescription code:301];
            }
            if(eduError == nil) {
                eduError = [AgoraRTEErrorManager internalError:@"" code:2];
            }
            failureBlock(eduError);
        }
    }];
    
    if (errType == AgoraLogErrorTypeInternalError) {
        NSError *error = [AgoraRTEErrorManager internalError:@"" code:2];
        if (error != nil && failureBlock != nil) {
            failureBlock(error);
        }
    } else if (errType == AgoraLogErrorTypeInvalidParemeter) {
        NSError *error = [AgoraRTEErrorManager paramterInvalid:@"log" code:1];
        if(error != nil && failureBlock != nil) {
            failureBlock(error);
        }
    }
}

#pragma mark ---
+ (void)logMessageWithLevel:(AgoraLogLevel)logLevel describe:(NSString *)describe message:(id _Nullable)messageObj {
    
    NSString *message = @"";
    if (messageObj != nil) {
        message = [messageObj yy_modelToJSONString];
    }
    if(message == nil) {
        if([messageObj isKindOfClass:NSNumber.class]) {
            message = [(NSNumber *)messageObj stringValue];
            
        } else if([messageObj isKindOfClass:NSString.class]) {
            message = messageObj;
        }
    }
    
    message = [describe stringByAppendingString:message];
    [[AgoraRTELogService shareManager].logManager logMessage:message level:logLevel];
}

@end
