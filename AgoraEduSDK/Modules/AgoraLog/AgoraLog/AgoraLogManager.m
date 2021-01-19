//
//  AgoraLogManager.m
//  AgoraLog
//
//  Created by SRS on 2020/7/1.
//  Copyright © 2020 agora. All rights reserved.
//

#import "AgoraLogManager.h"
#import <CocoaLumberjack/CocoaLumberjack.h>
#import "OSSManager.h"
#import "SSZipArchive.h"
#import "AgoraLogHttpManager.h"
#import "AgoraLogHttpClient.h"
#import "AgoraOSLogger.h"
#import "AgoraLogFormatter.h"

// Error
#define LocalAgoraLogErrorCode 9990

#define APIVersion1 @"v1"

#define AgoraLogError(level, context, frmt, ...)   LOG_MAYBE(LOG_ASYNC_ENABLED, level, DDLogFlagError,   context, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

#define AgoraLogWarn(level, context, frmt, ...)    LOG_MAYBE(LOG_ASYNC_ENABLED, level, DDLogFlagWarning, context, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

#define AgoraLogInfo(level, context, frmt, ...)    LOG_MAYBE(LOG_ASYNC_ENABLED, level, DDLogFlagInfo, context, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

#define AgoraLogDebug(level, context, frmt, ...)   LOG_MAYBE(LOG_ASYNC_ENABLED, level, DDLogFlagDebug, context, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

#define AgoraLogVerbose(level, context, frmt, ...) LOG_MAYBE(LOG_ASYNC_ENABLED, level, DDLogFlagVerbose, context, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

// ==========================================================

typedef NS_ENUM(NSInteger, ZipStateType) {
    ZipStateTypeOK              = 0,
    ZipStateTypeOnNotFound      = 1,
    ZipStateTypeOnRemoveError   = 2,
    ZipStateTypeOnZipError      = 3,
};

NSString *AGORA_EDU_HTTP_LOG_BASE_URL = @"https://api.agora.io";
NSString *AGORA_EDU_HTTP_LOG_OSS_BASE_URL = @"https://api-solutions.agoralab.co";
NSString *AGORA_EDU_HTTP_LOG_SECRET = @"7AIsPeMJgQAppO0Z";

@interface AgoraLogManager ()
@property (nonatomic, copy) NSString *logDirectoryPath;
@property (nonatomic, assign) DDLogLevel logFileLevel;
@property (nonatomic, assign) NSUInteger logContext;

@property (nonatomic, strong) NSPointerArray *loggerArray;

@end

@implementation AgoraLogManager
+ (void)setAppSecret:(NSString *)appSecret {
    AGORA_EDU_HTTP_LOG_SECRET = appSecret;
}

+ (void)setBaseURL:(NSString *)baseURL {
    AGORA_EDU_HTTP_LOG_BASE_URL = baseURL;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.loggerArray = [NSPointerArray weakObjectsPointerArray];
    }
    return self;
}

- (AgoraLogErrorType)setupLog:(AgoraLogConfiguration *)config {
    
    DDLogLevel _ddLogLevel = DDLogLevelAll;
    BOOL levelVerify = YES;
    switch (config.logLevel) {
        case AgoraLogLevelNone:
            _ddLogLevel = DDLogLevelOff;
            break;
        case AgoraLogLevelInfo:
            _ddLogLevel = DDLogLevelInfo;
            break;
        case AgoraLogLevelWarn:
            _ddLogLevel = DDLogLevelWarning;
            break;
        case AgoraLogLevelError:
            _ddLogLevel = DDLogLevelError;
            break;
        default:
            levelVerify = NO;
            break;
    }
    if (!levelVerify) {
        return AgoraLogErrorTypeInvalidParemeter;
    }
    
//    DDLogLevel _ddLogConsoleLevel = DDLogLevelAll;
//    switch (config.logConsoleLevel) {
//        case AgoraLogLevelNone:
//            _ddLogConsoleLevel = DDLogLevelOff;
//            break;
//        case AgoraLogLevelInfo:
//            _ddLogConsoleLevel = DDLogLevelInfo;
//            break;
//        case AgoraLogLevelWarn:
//            _ddLogConsoleLevel = DDLogLevelWarning;
//            break;
//        case AgoraLogLevelError:
//            _ddLogConsoleLevel = DDLogLevelError;
//            break;
//        default:
//            levelVerify = NO;
//            break;
//    }
//    if (!levelVerify) {
//        return AgoraLogErrorTypeInvalidParemeter;
//    }
    
    NSString *logDirectoryPath = config.directoryPath;
    self.logDirectoryPath = logDirectoryPath;
    self.logFileLevel = _ddLogLevel;
    self.logContext = self.logDirectoryPath.hash;
    
    #ifdef DEBUG
        NSLog(@"AgoraLog logDirectoryPath==>%@", logDirectoryPath);
    #endif
    
    BOOL isDirectory = NO;
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager fileExistsAtPath:logDirectoryPath isDirectory:&isDirectory];
    if(!isDirectory) {
        NSError *error;
        [manager createDirectoryAtPath:logDirectoryPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (error != nil) {
            return AgoraLogErrorTypeInternalError;
        }
    }

    AgoraOSLogger *osLogger = [[AgoraOSLogger alloc] initWithSubsystem:@"" category:@""];
    [self.loggerArray addPointer:(__bridge void * _Nullable)(osLogger)];
    osLogger.consoleState = config.consoleState;
    osLogger.content = self.logContext;
    [DDLog addLogger:osLogger withLevel:DDLogLevelAll];
    
    DDLogFileManagerDefault *logFileManager = [[DDLogFileManagerDefault alloc] initWithLogsDirectory:logDirectoryPath];
    DDFileLogger *fileLogger = [[DDFileLogger alloc] initWithLogFileManager:logFileManager];
    [self.loggerArray addPointer:(__bridge void * _Nullable)(fileLogger)];
    
    AgoraLogFormatter *formatter = [[AgoraLogFormatter alloc] init];
    [formatter addToWhitelist:self.logContext];
    [fileLogger setLogFormatter:formatter];
    
    fileLogger.rollingFrequency = 60 * 60 * 24;
    fileLogger.maximumFileSize = 1024 * 1024;
    fileLogger.logFileManager.maximumNumberOfLogFiles = 3;
    [DDLog addLogger:fileLogger withLevel:self.logFileLevel];;
    
    return AgoraLogErrorTypeNone;
}

- (AgoraLogErrorType)logMessage:(NSString *)message level:(AgoraLogLevel)level {

    BOOL levelVerify = YES;
    switch (level) {
        case AgoraLogLevelError:
            AgoraLogError(self.logFileLevel, self.logContext, @"%@", message);
            break;
        case AgoraLogLevelWarn:
            AgoraLogWarn(self.logFileLevel, self.logContext, @"%@", message);
            break;
        case AgoraLogLevelInfo:
            AgoraLogInfo(self.logFileLevel, self.logContext, @"%@", message);
            break;
        default:
            levelVerify = NO;
            break;
    }
    if(message == nil || message.length == 0 || !levelVerify) {
        return AgoraLogErrorTypeInvalidParemeter;
    } else {
        return AgoraLogErrorTypeNone;
    }
}

- (AgoraLogErrorType)uploadLogWithOptions:(AgoraLogUploadOptions*)options progress:(void (^ _Nullable) (float progress))progressBlock success:(void (^ _Nullable) (NSString *serialNumber))successBlock failure:(void (^ _Nullable) (NSError *error))failureBlock {

    if (options.appId == nil
       || options.appId.length == 0) {
        return AgoraLogErrorTypeInvalidParemeter;
    }

    NSString *logDirectoryPath = self.logDirectoryPath;
    
    NSString *logBaseDirectoryPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    NSString *zipDirectoryPath = [logBaseDirectoryPath stringByAppendingPathComponent:@"/AgoraLogZip/"];
    
    NSString *zipName = [AgoraLogManager generateZipName];
    NSString *zipPath = [NSString stringWithFormat:@"%@/%@", zipDirectoryPath, zipName];
    
    [AgoraLogHttpClient setAgoraLogManager:self];

    [AgoraLogManager zipFilesWithSourceDirectory:logDirectoryPath zipdirectoryPath:zipDirectoryPath zipPath:zipPath  completeBlock:^(ZipStateType zipCode) {
        
        if(zipCode != ZipStateTypeOK){
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *errMsg = [@"error during compressing file：" stringByAppendingString:@(zipCode).stringValue];
                NSError *error = LocalError(AgoraLogErrorTypeInternalError, errMsg);
                if(failureBlock != nil) {
                    failureBlock(error);
                }
            });
            return;
        }
        
        [AgoraLogManager checkZipCodeAndUploadWithZipCode:zipCode zipPath:zipPath logParams:options progress:progressBlock success:successBlock fail:^(NSError *error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *sdkError = LocalError(AgoraLogErrorTypeNetworkError, error.localizedDescription);
                if(failureBlock != nil) {
                    failureBlock(sdkError);
                }
            });
        }];
    }];
    
    return AgoraLogErrorTypeNone;
}

- (void)dealloc {

    NSArray *loggers = [self.loggerArray allObjects];
    for (int i = 0; i < loggers.count; i ++) {
        void *item = (__bridge void *)(loggers[i]);
        if (item == NULL) {
            continue;;
        }
        id<DDLogger> object = (__bridge id<DDLogger>)item;
        [DDLog removeLogger:object];
    }
}

#pragma mark Private
+ (void)checkZipCodeAndUploadWithZipCode:(ZipStateType)zipCode zipPath:(NSString *)zipPath logParams:(AgoraLogUploadOptions *)logParams progress:(void (^ _Nullable) (float progress))progressBlock success:(void (^ _Nullable) (NSString *uploadSerialNumber))successBlock fail:(void (^ _Nullable) (NSError *error))failBlock {
    
    switch (zipCode) {
        case ZipStateTypeOnNotFound:
            if(failBlock != nil) {
                NSError *error = LocalError(LocalAgoraLogErrorCode, @"no log files found");
                dispatch_async(dispatch_get_main_queue(), ^{
                    failBlock(error);
                });
            }
            return;
            break;
        case ZipStateTypeOnRemoveError:
            if(failBlock != nil) {
                NSError *error = LocalError(LocalAgoraLogErrorCode, @"failed to clear log files");
                dispatch_async(dispatch_get_main_queue(), ^{
                    failBlock(error);
                });
            }
            return;
            break;
        case ZipStateTypeOnZipError:
            if(failBlock != nil) {
                NSError *error = LocalError(LocalAgoraLogErrorCode, @"log file compression failed");
                dispatch_async(dispatch_get_main_queue(), ^{
                    failBlock(error);
                });
            }
            return;
            break;
        default:
            break;
    }
    if (zipCode != ZipStateTypeOK){
        if(failBlock != nil) {
            NSError *error = LocalError(LocalAgoraLogErrorCode, @"log file compression failed");
            dispatch_async(dispatch_get_main_queue(), ^{
                failBlock(error);
            });
        }
        return;
    }

    [AgoraLogHttpManager getLogInfoWithAppId:logParams.appId baseURL:AGORA_EDU_HTTP_LOG_BASE_URL appSecret:AGORA_EDU_HTTP_LOG_SECRET uid:logParams.uid token:logParams.rtmToken ext:logParams.ext apiVersion:APIVersion1 completeSuccessBlock:^(LogModel * _Nonnull logModel) {
        
        if(logModel.code != 0){
            if(failBlock != nil) {
                NSError *error = LocalError(logModel.code, logModel.msg);
                dispatch_async(dispatch_get_main_queue(), ^{
                    failBlock(error);
                });
            }
            return;
        }
        
        LogInfoModel *model = logModel.data;
        
        [OSSManager uploadOSSWithAppId:logParams.appId access:model.accessKeyId secret:model.accessKeySecret token:model.securityToken bucketName:model.bucketName objectKey:model.ossKey callbackBody:model.callbackBody callbackBodyType:model.callbackContentType endpoint:model.ossEndpoint fileURL:[NSURL URLWithString:zipPath] progress:^(float progress) {

            if(progressBlock != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    progressBlock(progress);
                });
            }
        } success:^(NSString * _Nonnull uploadSerialNumber) {

            if(successBlock != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    successBlock(uploadSerialNumber);
                });
            }
        } fail:^(NSError * _Nonnull error) {
            if(failBlock != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    failBlock(error);
                });
            }
        }];
        
    } completeFailBlock:^(NSError * _Nonnull error) {
        if(failBlock != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                failBlock(error);
            });
        }
    }];
}

+ (void)zipFilesWithSourceDirectory:(NSString *)directoryPath zipdirectoryPath:(NSString *)zipDirectoryPath zipPath:(NSString *)zipPath completeBlock:(void (^) (NSInteger zipCode))block {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isDirectoryExist = [fileManager fileExistsAtPath:directoryPath];
        if(!isDirectoryExist) {
            [fileManager createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        isDirectoryExist = [fileManager fileExistsAtPath:zipDirectoryPath];
        if(!isDirectoryExist) {
            [fileManager createDirectoryAtPath:zipDirectoryPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        NSDirectoryEnumerator *direnum = [fileManager enumeratorAtPath:zipDirectoryPath];
        NSString *filename;
        while (filename = [direnum nextObject]) {
            if ([[filename pathExtension] isEqualToString:@"zip"]) {
                
                NSString *logZipPath = [NSString stringWithFormat:@"%@/%@", zipDirectoryPath, filename];
                
                NSError *error;
                BOOL rmvSuccess = [fileManager removeItemAtPath:logZipPath error:&error];
                if (error || !rmvSuccess) {
                    block(ZipStateTypeOnRemoveError);
                    return;
                }
                break;
            }
        }
        
        BOOL zipSuccess = [SSZipArchive createZipFileAtPath:zipPath withContentsOfDirectory:directoryPath];
        
        if(zipSuccess){
            block(ZipStateTypeOK);
        } else {
            block(ZipStateTypeOnZipError);
        }
    });
}

+ (NSString *)generateZipName {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYYMMddHHmmss"];
    NSDate *datenow = [NSDate date];
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    NSString *zipName = [NSString stringWithFormat:@"%@.zip", currentTimeString];
    return zipName;
}

@end
