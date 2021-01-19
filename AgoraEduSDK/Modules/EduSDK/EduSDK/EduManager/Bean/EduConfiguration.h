//
//  EduConfiguration.h
//  EduSDK
//
//  Created by SRS on 2020/7/6.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, EduLogLevel) {
    EduLogLevelNone,
    EduLogLevelInfo,
    EduLogLevelWarn,
    EduLogLevelError,
};

NS_ASSUME_NONNULL_BEGIN
@interface EduConfiguration : NSObject

@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *token;

@property (nonatomic, copy) NSString *userUuid;
@property (nonatomic, copy, nullable) NSString *userName;
@property (nonatomic, assign) NSInteger tag;

// default EduLogLevelInfo
@property (nonatomic, assign) EduLogLevel logLevel;
// default /AgoraEducation/
@property (nonatomic, copy, nullable) NSString *logDirectoryPath;

@property (nonatomic, assign) NSInteger logConsoleState;

- (instancetype)initWithAppId:(NSString *)appId userUuid:(NSString *)userUuid token:(NSString *)token;

- (instancetype)initWithAppId:(NSString *)appId userUuid:(NSString *)userUuid  token:(NSString *)token userName:(NSString *)userName;

@end

NS_ASSUME_NONNULL_END
