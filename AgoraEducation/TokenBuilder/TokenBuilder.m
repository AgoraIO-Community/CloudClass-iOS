//
//  TokenBuilder.m
//  AgoraEducation
//
//  Created by SRS on 2021/1/13.
//  Copyright © 2021 yangmoumou. All rights reserved.
//

#import "TokenBuilder.h"
#import "RtmTokenTool.h"
#import "AgoraEducationHTTPClient.h"

#define NoNullString(x) ([x isKindOfClass:NSString.class] ? x : @"")
#define NoNullDictionary(x) ([x isKindOfClass:NSDictionary.class] ? x : @{})

@implementation TokenBuilder
// 本地生成token。用于本地快速演示使用， 我们建议你使用服务器生成token( buildToken:success:failure:)
+ (NSString *)buildToken:(NSString *)appID appCertificate:(NSString *)appCertificate userUuid:(NSString *)userUuid {
 
    return [RtmTokenTool token:appID appCertificate:appCertificate uid:userUuid];
}

// 服务器生成token。
+ (void)buildToken:(NSString *)url success:(void (^)(NSString *token))success failure:(void (^)(NSError *error))failure {
    
    [AgoraEducationHTTPClient get:url params:@{} headers:@{} success:^(id  _Nonnull responseObj) {
    
        NSString *rtmToken = NoNullDictionary(NoNullDictionary(responseObj)[@"data"])[@"rtmToken"];
        if(success != nil) {
            success(NoNullString(rtmToken));
        }
    
    } failure:^(NSError * _Nonnull error, NSInteger statusCode) {
        if(failure != nil) {
            failure(error);
        }
    }];
    
}
@end
