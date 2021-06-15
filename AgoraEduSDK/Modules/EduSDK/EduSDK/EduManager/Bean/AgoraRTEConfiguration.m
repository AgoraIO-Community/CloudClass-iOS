//
//  AgoraRTEConfiguration.m
//  EduSDK
//
//  Created by SRS on 2020/7/6.
//  Copyright © 2020 agora. All rights reserved.
//

#import "AgoraRTEConfiguration.h"
#import <AgoraLog/AgoraLog.h>

@implementation AgoraRTEConfiguration

- (instancetype)initWithAppId:(NSString *)appId userUuid:(NSString *)userUuid token:(NSString *)token {
    return [self initWithAppId:appId
                      userUuid:userUuid
                         token:token
                     urlRegion:@"cn"
                     rtcRegion:@"AREA_GLOBAL"
                     rtmRegion:@"AREA_GLOBAL"
                      userName:@""];
}

- (instancetype)initWithAppId:(NSString *)appId
                     userUuid:(NSString *)userUuid
                        token:(NSString *)token
                    urlRegion:(NSString *)urlRegion
                    rtcRegion:(NSString *)rtcRegion
                    rtmRegion:(NSString *)rtmRegion
                     userName:(NSString *)userName {
    
    if (self = [super init]) {
        self.logConsoleState = AgoraLogConsoleStateClose;
        self.appId = appId;
        self.userUuid = userUuid;
        self.userName = userName;
        self.token = token;
        self.logLevel = AgoraRTELogLevelInfo;
        self.urlRegion = urlRegion;
        self.rtcRegion = rtcRegion;
        self.rtmRegion = rtmRegion;
        
        NSString *logFilePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"/AgoraEducation"];
        self.logDirectoryPath = logFilePath;
    }

    return self;
}
@end
