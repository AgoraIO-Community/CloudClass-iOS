//
//  AgoraRTEConfiguration.h
//  EduSDK
//
//  Created by SRS on 2020/7/6.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, AgoraRTELogLevel) {
    AgoraRTELogLevelNone,
    AgoraRTELogLevelInfo,
    AgoraRTELogLevelWarn,
    AgoraRTELogLevelError,
};

NS_ASSUME_NONNULL_BEGIN
@interface AgoraRTEConfiguration : NSObject

@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *token;

@property (nonatomic, copy) NSString *userUuid;
@property (nonatomic, copy, nullable) NSString *userName;
@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, copy) NSString *urlRegion;
@property (nonatomic, copy) NSString *rtcRegion;
@property (nonatomic, copy) NSString *rtmRegion;

// default AgoraRTELogLevelInfo
@property (nonatomic, assign) AgoraRTELogLevel logLevel;
// default /AgoraEducation/
@property (nonatomic, copy, nullable) NSString *logDirectoryPath;

@property (nonatomic, assign) NSInteger logConsoleState;

@property (nonatomic, copy, nullable) NSString *encryptionKey;
@property (nonatomic, assign) NSInteger encryptionMode;

- (instancetype)initWithAppId:(NSString *)appId
                     userUuid:(NSString *)userUuid
                        token:(NSString *)token;

- (instancetype)initWithAppId:(NSString *)appId
                     userUuid:(NSString *)userUuid
                        token:(NSString *)token
                    urlRegion:(NSString *)urlRegion
                    rtcRegion:(NSString *)rtcRegion
                    rtmRegion:(NSString *)rtmRegion
                     userName:(NSString *)userName;

@end

NS_ASSUME_NONNULL_END
