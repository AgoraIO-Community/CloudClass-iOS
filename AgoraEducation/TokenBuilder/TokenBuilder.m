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
#import <YYModel/YYModel.h>

#define NoNullString(x) ([x isKindOfClass:NSString.class] ? x : @"")
#define NoNullDictionary(x) ([x isKindOfClass:NSDictionary.class] ? x : @{})
#define NoNullArray(x) ([x isKindOfClass:NSArray.class] ? x : @[])

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

+ (void)boardResources:(NSString *)url token:(NSString *)token success:(void (^)(NSArray<WhiteScene *> *models, NSString *resourceName, NSString *resourceUuid, NSString *scenePath, NSString *downURL))success failure:(void (^)(NSError *error))failure {
    
    [AgoraEducationHTTPClient get:url params:@{} headers:@{@"token":token} success:^(id  _Nonnull responseObj) {
        
        NSDictionary *data = NoNullDictionary(NoNullDictionary(responseObj)[@"data"]);
        NSDictionary *big = NoNullDictionary(data[@"large"]);
        
        NSString *type = NoNullString(NoNullDictionary(big[@"conversion"])[@"type"]);
        NSString *taskUuid = NoNullString(big[@"taskUuid"]);
        NSString *resourceUuid = NoNullString(big[@"resourceUuid"]);
        NSString *resourceName = [NSString stringWithFormat:@"/%@", NoNullString(big[@"resourceName"])];
        
        NSDictionary *taskProgress = NoNullDictionary(big[@"taskProgress"]);
        NSArray *convertedFileList = NoNullArray(taskProgress[@"convertedFileList"]);
        
        NSMutableArray<WhiteScene *> *models = [NSMutableArray array];
        for (id dic in convertedFileList) {
            WhiteScene *model = [WhiteScene.class yy_modelWithDictionary:NoNullDictionary(dic)];
            [models addObject:model];
        }
        
        NSString *scenePath = [NSString stringWithFormat:@"%@/%@", resourceName, [models.firstObject name]];
        
        NSString *downURL = [NSString stringWithFormat:@"%@%@%@", @"https://convertcdn.netless.link/dynamicConvert/", taskUuid, @".zip"];    
        if(success != nil) {
            success(models, resourceName, resourceUuid, scenePath, downURL);
        }
    
    } failure:^(NSError * _Nonnull error, NSInteger statusCode) {
        if(failure != nil) {
            failure(error);
        }
    }];
}
@end
