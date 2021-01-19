//
//  OSSManager.m
//  AgoraLog
//
//  Created by SRS on 2020/7/2.
//  Copyright © 2020 agora. All rights reserved.
//

#import "OSSManager.h"
#import <AliyunOSSiOS/AliyunOSSiOS.h>
#import "OSSModel.h"
#import "AgoraLogHttpManager.h"

// http: get app config
#define AGORA_HTTP_LOG_PARAMS @"%@/v1/log/params"
// http: get app config
#define AGORA_HTTP_OSS_STS_CALLBACK @"%@/monitor/apps/%@/v1/log/oss/callback"

static OSSManager *manager = nil;

@interface OSSManager()
@property(nonatomic, strong)OSSClient *ossClient;
@property(nonatomic, strong)NSString *endpoint;
@property(nonatomic, assign)BOOL initOSSAuthClient;

@end

@implementation OSSManager

+ (instancetype)shareManager{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
        manager.initOSSAuthClient = NO;
    });
    return manager;
}

+ (void)initOSSAuthClientWithAccess:(NSString*)access secret:(NSString *)secret token:(NSString *)token endpoint:(NSString*)endpoint {
    
    OSSAuthCredentialProvider *credentialProvider = [[OSSAuthCredentialProvider alloc] initWithFederationTokenGetter:^OSSFederationToken * _Nullable{
            OSSFederationToken *federationToken = [OSSFederationToken new];
            federationToken.tAccessKey = access;
            federationToken.tSecretKey = secret;
            federationToken.tToken = token;
            return federationToken;
    }];
    
    OSSClientConfiguration *cfg = [[OSSClientConfiguration alloc] init];
    
    [OSSManager shareManager].ossClient = [[OSSClient alloc] initWithEndpoint:endpoint credentialProvider:credentialProvider clientConfiguration:cfg];
}

+ (void)uploadOSSWithAppId:(NSString*)appId access:(NSString*)access secret:(NSString *)secret token:(NSString *)token bucketName:(NSString *)bucketName objectKey:(NSString *)objectKey callbackBody:(NSString *)callbackBody callbackBodyType:(NSString *)callbackBodyType endpoint:(NSString*)endpoint fileURL:(NSURL *)fileURL progress:(void (^ _Nullable) (float progress))progressBlock success:(void (^ _Nullable) (NSString *uploadSerialNumber))successBlock fail:(void (^ _Nullable) (NSError *error))failBlock {
    
    if(!OSSManager.shareManager.initOSSAuthClient){
        OSSManager.shareManager.initOSSAuthClient = YES;
        [OSSManager initOSSAuthClientWithAccess:access secret:secret token:token endpoint:endpoint];
    }

    OSSPutObjectRequest * request = [OSSPutObjectRequest new];
    request.bucketName = bucketName;
    request.objectKey = objectKey;
    request.uploadingFileURL = fileURL;
    NSString *callbackURL = [NSString stringWithFormat:AGORA_HTTP_OSS_STS_CALLBACK, AGORA_EDU_HTTP_LOG_OSS_BASE_URL, appId];
    request.callbackParam = @{
        @"callbackUrl": callbackURL,
        @"callbackBody": callbackBody,
        @"callbackBodyType": callbackBodyType};

    request.uploadProgress = ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        if(progressBlock != nil) {
            progressBlock((float)totalBytesSent / (float)totalBytesExpectedToSend);
        }
    };
    
    OSSTask *putTask = [[OSSManager shareManager].ossClient putObject:request];
    [putTask continueWithBlock:^id _Nullable(OSSTask * _Nonnull task) {

        if (!task.error) {

            OSSPutObjectResult *uploadResult = task.result;

            NSError *error = nil;
            OSSModel *model = [OSSModel initWithJsonString:uploadResult.serverReturnJsonString error:&error];
            if(error != nil) {
                if(failBlock != nil) {
                    failBlock(error);
                }
                return nil;
            }
            
            if(model.code == 0){
                if(successBlock != nil) {
                    successBlock(model.data);
                }
            } else {
                if(failBlock != nil) {
                    NSError *error = LocalError(model.code, model.msg);
                    failBlock(error);
                }
            }

        } else {
            if(failBlock != nil) {
                failBlock(task.error);
            }
        }
        return nil;
    }];
}
@end

