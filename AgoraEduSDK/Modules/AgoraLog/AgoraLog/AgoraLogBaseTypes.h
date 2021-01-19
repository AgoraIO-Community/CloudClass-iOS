//
//  LogUploadConfiguration.h
//  AgoraLog
//
//  Created by SRS on 2020/7/1.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, AgoraLogLevel) {
    AgoraLogLevelNone,
    AgoraLogLevelInfo,
    AgoraLogLevelWarn,
    AgoraLogLevelError,
};

typedef NS_ENUM(NSInteger, AgoraLogErrorType) {
    // No error.
    AgoraLogErrorTypeNone                        = 0,

    // General error indicating that a supplied parameter is invalid.
    AgoraLogErrorTypeInvalidParemeter,

    // An error occurred within an underlying network protocol.
    AgoraLogErrorTypeNetworkError,

    // The operation failed due to an internal error.
    AgoraLogErrorTypeInternalError,
};

typedef NS_ENUM(NSInteger, AgoraLogConsoleState) {
    AgoraLogConsoleStateClose = 0,
    AgoraLogConsoleStateOpen,
};

NS_ASSUME_NONNULL_BEGIN

@interface AgoraLogConfiguration : NSObject

@property (nonatomic, assign) AgoraLogLevel logLevel;
// folder path of upload log
@property (nonatomic, copy) NSString *directoryPath;

// default close
@property (nonatomic, assign) AgoraLogConsoleState consoleState;

@end

@interface AgoraLogUploadOptions : NSObject
// rtc/rtm AppId
@property(nonatomic, copy) NSString *appId;
@property(nonatomic, copy) NSString *uid;
@property(nonatomic, copy) NSString *rtmToken;

// 自定义参数
@property(nonatomic, copy) NSDictionary<NSString *, NSString *> *ext;
@end

NS_ASSUME_NONNULL_END
