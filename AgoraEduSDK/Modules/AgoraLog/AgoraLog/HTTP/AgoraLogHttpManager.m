//
//  AgoraLogHttpManager.m
//  AgoraEdu
//
//  Created by SRS on 2020/5/3.
//  Copyright © 2020 agora. All rights reserved.
//

#import "AgoraLogHttpManager.h"
#import <UIKit/UIKit.h>
#import "AgoraLogHttpClient.h"
#import "AgoraLogDeviceManager.h"
#import "AgoraLogStringMD5.h"

NSString *AGORA_EDU_HTTP_LOG_INFO = @"";

@implementation AgoraLogHttpManager

+ (void)getLogInfoWithOptions:(AgoraLogUploadOptions *)options
         completeSuccessBlock:(void (^)(AgoraLogModel * _Nonnull))successBlock
            completeFailBlock:(void (^)(NSError * _Nonnull))failBlock {
    if (AGORA_EDU_HTTP_LOG_INFO.length == 0) {
        NSString *hostString = [NSString stringWithFormat:@"/monitor/apps/%@/v1/log/oss/policy", options.appId];
        AGORA_EDU_HTTP_LOG_INFO = [options.baseURL stringByAppendingString:hostString];
    }
    
    AGORA_EDU_HTTP_LOG_INFO = [AGORA_EDU_HTTP_LOG_INFO stringByReplacingOccurrencesOfString:@"v1" withString:options.apiVersion];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"appId"] = options.appId;
    if(options.ext != nil) {
        params[@"ext"] = options.ext;
    }
    
    params[@"platform"] = [UIDevice currentDevice].systemName;
    params[@"deviceName"] = [AgoraLogDeviceManager getDeviceIdentifier];
    params[@"deviceVersion"] = [UIDevice currentDevice].systemVersion;
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    params[@"appVersion"] = app_Version;
    
    params[@"fileExt"] = @"zip";
    params[@"tag"] = @{@"userUuid":options.userUuid,
                       @"userName":options.userName,
                       @"role":options.role,
                       @"roomUuid":options.roomUuid,
                       @"roomName":options.roomName,
                       @"roomType":options.roomType
    };
    
    NSDictionary *headers = [AgoraLogHttpManager httpHeader:params
                                                  appSecret:options.appSecret
                                                        uid:options.userUuid
                                                      token:options.rtmToken];
    
    [AgoraLogHttpClient post:AGORA_EDU_HTTP_LOG_INFO params:params headers:headers success:^(id _Nonnull responseObj) {
        
        AgoraLogModel *model = [AgoraLogModel initWithObject:responseObj];
        if(successBlock != nil){
            successBlock(model);
        }
        
    } failure:failBlock];
}

#pragma mark private
+ (NSDictionary *)httpHeader:(NSDictionary<NSString *, NSString *> *)params appSecret:(NSString *)appSecret uid:(NSString *)uid token:(NSString *)token {
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:0];
    NSString *paramsStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSDate *datenow = [NSDate date];
    NSString *timestamp = [NSString stringWithFormat:@"%ld", (long)([datenow timeIntervalSince1970] * 1000)];
    
    NSString *signStr = @"";
    signStr = [signStr stringByAppendingString:appSecret];
    signStr = [signStr stringByAppendingString:paramsStr];
    signStr = [signStr stringByAppendingString:timestamp];
    signStr = [AgoraLogStringMD5 MD5:signStr];
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    headers[@"sign"] = signStr;
    headers[@"timestamp"] = timestamp;
    
    if (uid != nil && uid.length > 0) {
        [headers setValue:uid forKey:@"x-agora-uid"];
    }
    if (token != nil && token.length > 0) {
        [headers setValue:token forKey:@"x-agora-token"];
    }
    
    return headers;
}

@end
