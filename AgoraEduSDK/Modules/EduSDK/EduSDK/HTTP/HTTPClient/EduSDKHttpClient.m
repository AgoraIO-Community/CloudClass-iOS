//
//  EduSDKHttpClient.m
//  AgoraEdu
//
//  Created by SRS on 2020/5/3.
//  Copyright © 2020 agora. All rights reserved.
//

#import "EduSDKHttpClient.h"
#import <AFNetworking/AFNetworking.h>
#import "AgoraLogService.h"

typedef NS_ENUM(NSInteger, AgoraHttpType) {
    AgoraHttpTypeGet            = 0,
    AgoraHttpTypePost,
    AgoraHttpTypePut,
    AgoraHttpTypeDelete,
};
#define AgoraHttpTypeStrings  (@[@"GET",@"POST",@"PUT",@"DELETE"])


@interface EduSDKHttpClient ()

@property (nonatomic,strong) AFHTTPSessionManager *sessionManager;

@end

static EduSDKHttpClient *manager = nil;

@implementation EduSDKHttpClient
+ (instancetype)shareManager{
    @synchronized(self){
        if (!manager) {
            manager = [[self alloc]init];
            [manager initSessionManager];
        }
        return manager;
    }
}

- (void)initSessionManager {
    self.sessionManager = [AFHTTPSessionManager manager];
    self.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    self.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    self.sessionManager.requestSerializer.timeoutInterval = 30;
}

+ (void)get:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary<NSString*, NSString*> *)headers success:(void (^)(id))success failure:(void (^)(NSError *error, NSInteger statusCode))failure {
    
    if(headers != nil && headers.allKeys.count > 0){
        NSArray<NSString*> *keys = headers.allKeys;
        for(NSString *key in keys){
            [EduSDKHttpClient.shareManager.sessionManager.requestSerializer setValue:headers[key] forHTTPHeaderField:key];
        }
    }
    
    NSString *encodeUrl = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [EduSDKHttpClient httpStartLogWithType:AgoraHttpTypeGet url:encodeUrl headers:headers params:params];
    
    [EduSDKHttpClient.shareManager.sessionManager GET:encodeUrl parameters:params headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [EduSDKHttpClient httpSuccessLogWithType:AgoraHttpTypeGet url:encodeUrl responseObject:responseObject];
        
        if (success) {
            success(responseObject);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [EduSDKHttpClient checkHttpError:error task:task success:^(id responseObj) {
            
            [EduSDKHttpClient httpSuccessLogWithType:AgoraHttpTypeGet url:encodeUrl responseObject:responseObj];
            if (success) {
                success(responseObj);
            }
            
        } failure:^(NSError *error, NSInteger statusCode) {
            [EduSDKHttpClient httpErrorLogWithType:AgoraHttpTypeGet url:encodeUrl error:error];
            
            if (failure) {
                failure(error, statusCode);
            }
        }];
    }];
}

+ (void)post:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary<NSString*, NSString*> *)headers success:(void (^)(id responseObj))success failure:(void (^)(NSError *error, NSInteger statusCode))failure {

    if(headers != nil && headers.allKeys.count > 0){
        NSArray<NSString*> *keys = headers.allKeys;
        for (NSString *key in keys) {
            [EduSDKHttpClient.shareManager.sessionManager.requestSerializer setValue:headers[key] forHTTPHeaderField:key];
        }
    }
    
    NSString *encodeUrl = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [EduSDKHttpClient httpStartLogWithType:AgoraHttpTypePost url:encodeUrl headers:headers params:params];
    
    [EduSDKHttpClient.shareManager.sessionManager POST:encodeUrl parameters:params headers:headers progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [EduSDKHttpClient httpSuccessLogWithType:AgoraHttpTypePost url:encodeUrl responseObject:responseObject];
        if (success) {
            success(responseObject);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [EduSDKHttpClient checkHttpError:error task:task success:^(id responseObj) {
            
            [EduSDKHttpClient httpSuccessLogWithType:AgoraHttpTypePost url:encodeUrl responseObject:responseObj];
            if (success) {
                success(responseObj);
            }
            
        } failure:^(NSError *error, NSInteger statusCode) {
            [EduSDKHttpClient httpErrorLogWithType:AgoraHttpTypePost url:encodeUrl error:error];
            
            if (failure) {
                failure(error, statusCode);
            }
        }];
    }];
}

+ (void)put:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary<NSString*, NSString*> *)headers success:(void (^)(id responseObj))success failure:(void (^)(NSError *error, NSInteger statusCode))failure {

    if(headers != nil && headers.allKeys.count > 0){
        NSArray<NSString*> *keys = headers.allKeys;
        for(NSString *key in keys){
            [EduSDKHttpClient.shareManager.sessionManager.requestSerializer setValue:headers[key] forHTTPHeaderField:key];
        }
    }
    
    NSString *encodeUrl = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [EduSDKHttpClient httpStartLogWithType:AgoraHttpTypePut url:encodeUrl headers:headers params:params];
    
    [EduSDKHttpClient.shareManager.sessionManager PUT:encodeUrl parameters:params headers:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [EduSDKHttpClient httpSuccessLogWithType:AgoraHttpTypePut url:encodeUrl responseObject:responseObject];

        if (success) {
            success(responseObject);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [EduSDKHttpClient checkHttpError:error task:task success:^(id responseObj) {
            
            [EduSDKHttpClient httpSuccessLogWithType:AgoraHttpTypePut url:encodeUrl responseObject:responseObj];
            if (success) {
                success(responseObj);
            }
            
        } failure:^(NSError *error, NSInteger statusCode) {
            [EduSDKHttpClient httpErrorLogWithType:AgoraHttpTypePut url:encodeUrl error:error];
            
            if (failure) {
                failure(error, statusCode);
            }
        }];
    }];
}

+ (void)del:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary<NSString*, NSString*> *)headers success:(void (^)(id responseObj))success failure:(void (^)(NSError *error, NSInteger statusCode))failure {

    if(headers != nil && headers.allKeys.count > 0){
        NSArray<NSString*> *keys = headers.allKeys;
        for(NSString *key in keys){
            [EduSDKHttpClient.shareManager.sessionManager.requestSerializer setValue:headers[key] forHTTPHeaderField:key];
        }
    }
    
    NSString *encodeUrl = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [EduSDKHttpClient httpStartLogWithType:AgoraHttpTypeDelete url:encodeUrl headers:headers params:params];
    
    [EduSDKHttpClient.shareManager.sessionManager DELETE:encodeUrl parameters:params headers:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [EduSDKHttpClient httpSuccessLogWithType:AgoraHttpTypeDelete url:encodeUrl responseObject:responseObject];

        if (success) {
            success(responseObject);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [EduSDKHttpClient checkHttpError:error task:task success:^(id responseObj) {
            
            [EduSDKHttpClient httpSuccessLogWithType:AgoraHttpTypeDelete url:encodeUrl responseObject:responseObj];
            if (success) {
                success(responseObj);
            }
            
        } failure:^(NSError *error, NSInteger statusCode) {
            [EduSDKHttpClient httpErrorLogWithType:AgoraHttpTypeDelete url:encodeUrl error:error];
            
            if (failure) {
                failure(error, statusCode);
            }
        }];
    }];
}

#pragma mark LOG
+ (void)httpStartLogWithType:(AgoraHttpType)type url:(NSString *)url
                     headers:(NSDictionary *)headers params:(NSDictionary *)params {
    
    NSString *msg = [NSString stringWithFormat:
                     @"\n============>%@ HTTP Start<============\n\
                     \nurl==>\n%@\n\
                     \nheaders==>\n%@\n\
                     \nparams==>\n%@\n\
                     ",AgoraHttpTypeStrings[type], url, headers, params];
    [AgoraLogService logMessage:msg level:AgoraLogLevelInfo];
}
+ (void)httpSuccessLogWithType:(AgoraHttpType)type url:(NSString *)url
                     responseObject:(id)responseObject {
    
    NSString *msg = [NSString stringWithFormat:
                     @"\n============>%@ HTTP Success<============\n\
                     \nurl==>\n%@\n\
                     \nResult==>\n%@\n\
                     ",AgoraHttpTypeStrings[type], url, responseObject];
    [AgoraLogService logMessage:msg level:AgoraLogLevelInfo];
}

+ (void)httpErrorLogWithType:(AgoraHttpType)type url:(NSString *)url
                     error:(NSError *)error {
    
    NSString *msg = [NSString stringWithFormat:
                     @"\n============>%@ HTTP Error<============\n\
                     \nurl==>\n%@\n\
                     \nError==>\n%@\n\
                     ",AgoraHttpTypeStrings[type], url, error.description];
    [AgoraLogService logMessage:msg level:AgoraLogLevelError];
}

#pragma mark Check
+ (void)checkHttpError:(NSError *)error task:(NSURLSessionDataTask *)task success:(void (^)(id responseObj))success failure:(void (^)(NSError *error, NSInteger statusCode))failure {
    
    NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)task.response;
    
    NSData *errorData = error.userInfo[@"com.alamofire.serialization.response.error.data"];
    if (errorData == nil) {
        failure(error, urlResponse.statusCode);
        return;
    }
    
    NSDictionary *errorDataDict = [NSJSONSerialization JSONObjectWithData:errorData options:NSJSONReadingMutableLeaves error:nil];
    if (errorDataDict == nil) {
        failure(error, urlResponse.statusCode);
        return;
    }

    success(errorDataDict);
}
@end
