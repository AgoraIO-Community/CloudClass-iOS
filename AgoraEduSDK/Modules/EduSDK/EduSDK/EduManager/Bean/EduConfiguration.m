//
//  EduConfiguration.m
//  EduSDK
//
//  Created by SRS on 2020/7/6.
//  Copyright © 2020 agora. All rights reserved.
//

#import "EduConfiguration.h"
#import <AgoraLog/AgoraLog.h>

@implementation EduConfiguration
- (instancetype)initWithAppId:(NSString *)appId userUuid:(NSString *)userUuid token:(NSString *)token {
    return [self initWithAppId:appId userUuid:userUuid token:token userName:@""];
}
- (instancetype)initWithAppId:(NSString *)appId userUuid:(NSString *)userUuid token:(NSString *)token userName:(NSString *)userName {
    
    if (self = [super init]) {
        self.logConsoleState = AgoraLogConsoleStateClose;
        self.appId = appId;
        self.userUuid = userUuid;
        self.userName = userName;
        self.token = token;
        self.logLevel = EduLogLevelInfo;
        
        NSString *logFilePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"/AgoraEducation"];
        self.logDirectoryPath = logFilePath;
    }

    return self;
}
@end
