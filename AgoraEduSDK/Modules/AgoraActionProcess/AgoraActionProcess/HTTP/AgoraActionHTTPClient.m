//
//  AgoraActionHTTPClient.m
//  AgoraEducation
//
//  Created by SRS on 2020/8/2.
//  Copyright © 2020 Agora. All rights reserved.
//

#import "AgoraActionHTTPClient.h"
#import <AFNetworking/AFNetworking.h>

#ifdef DEBUG
#define AgoraActionLog(...) NSLog(__VA_ARGS__)
#else
#define AgoraActionLog(...)
#endif

#define AgoraActionHttpTypeStrings  (@[@"GET",@"POST",@"PUT",@"DELETE"])

@implementation AgoraActionHTTPClient

#pragma mark SessionManager
+ (AFHTTPSessionManager *)sessionManager {
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    sessionManager.requestSerializer.timeoutInterval = 10;
    sessionManager.requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithObjects:@"GET", @"HEAD", nil];
    return sessionManager;
}

+ (void)get:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary<NSString*, NSString*> *)headers success:(void (^)(id))success failure:(void (^)(NSError *error, NSInteger statusCode))failure {

    NSString *encodeUrl = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    [AgoraActionHTTPClient httpStartLogWithType:AgoraActionHttpTypeGet url:encodeUrl headers:headers params:params];

    [[AgoraActionHTTPClient sessionManager] GET:encodeUrl parameters:params headers:headers progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

        [AgoraActionHTTPClient httpSuccessLogWithType:AgoraActionHttpTypeGet url:encodeUrl responseObject:responseObject];

        if (success) {
            success(responseObject);
        }

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

        [AgoraActionHTTPClient checkHttpError:error task:task success:^(id responseObj) {

            [AgoraActionHTTPClient httpSuccessLogWithType:AgoraActionHttpTypeGet url:encodeUrl responseObject:responseObj];
            if (success) {
                success(responseObj);
            }

        } failure:^(NSError *error, NSInteger statusCode) {
            [AgoraActionHTTPClient httpErrorLogWithType:AgoraActionHttpTypeGet url:encodeUrl error:error];

            if (failure) {
                failure(error, statusCode);
            }
        }];
    }];
}

+ (void)post:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary<NSString*, NSString*> *)headers success:(void (^)(id responseObj))success failure:(void (^)(NSError *error, NSInteger statusCode))failure {

    NSString *encodeUrl = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [AgoraActionHTTPClient httpStartLogWithType:AgoraActionHttpTypePost url:encodeUrl headers:headers params:params];
    
    [[AgoraActionHTTPClient sessionManager] POST:encodeUrl parameters:params headers:headers progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

        [AgoraActionHTTPClient httpSuccessLogWithType:AgoraActionHttpTypePost url:encodeUrl responseObject:responseObject];
        if (success) {
            success(responseObject);
        }

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

        [AgoraActionHTTPClient checkHttpError:error task:task success:^(id responseObj) {

            [AgoraActionHTTPClient httpSuccessLogWithType:AgoraActionHttpTypePost url:encodeUrl responseObject:responseObj];
            if (success) {
                success(responseObj);
            }

        } failure:^(NSError *error, NSInteger statusCode) {
            [AgoraActionHTTPClient httpErrorLogWithType:AgoraActionHttpTypePost url:encodeUrl error:error];

            if (failure) {
                failure(error, statusCode);
            }
        }];
    }];
}

+ (void)put:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary<NSString*, NSString*> *)headers success:(void (^)(id responseObj))success failure:(void (^)(NSError *error, NSInteger statusCode))failure {

    NSString *encodeUrl = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    [AgoraActionHTTPClient httpStartLogWithType:AgoraActionHttpTypePut url:encodeUrl headers:headers params:params];

    [[AgoraActionHTTPClient sessionManager] PUT:encodeUrl parameters:params headers:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

        [AgoraActionHTTPClient httpSuccessLogWithType:AgoraActionHttpTypePut url:encodeUrl responseObject:responseObject];

        if (success) {
            success(responseObject);
        }

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

        [AgoraActionHTTPClient checkHttpError:error task:task success:^(id responseObj) {

            [AgoraActionHTTPClient httpSuccessLogWithType:AgoraActionHttpTypePut url:encodeUrl responseObject:responseObj];
            if (success) {
                success(responseObj);
            }

        } failure:^(NSError *error, NSInteger statusCode) {
            [AgoraActionHTTPClient httpErrorLogWithType:AgoraActionHttpTypePut url:encodeUrl error:error];

            if (failure) {
                failure(error, statusCode);
            }
        }];
    }];
}

+ (void)del:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary<NSString*, NSString*> *)headers success:(void (^)(id responseObj))success failure:(void (^)(NSError *error, NSInteger statusCode))failure {

    NSString *encodeUrl = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    [AgoraActionHTTPClient httpStartLogWithType:AgoraActionHttpTypeDelete url:encodeUrl headers:headers params:params];

    [[AgoraActionHTTPClient sessionManager] DELETE:encodeUrl parameters:params headers:headers success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

        [AgoraActionHTTPClient httpSuccessLogWithType:AgoraActionHttpTypeDelete url:encodeUrl responseObject:responseObject];

        if (success) {
            success(responseObject);
        }

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

        [AgoraActionHTTPClient checkHttpError:error task:task success:^(id responseObj) {

            [AgoraActionHTTPClient httpSuccessLogWithType:AgoraActionHttpTypeDelete url:encodeUrl responseObject:responseObj];
            if (success) {
                success(responseObj);
            }

        } failure:^(NSError *error, NSInteger statusCode) {
            [AgoraActionHTTPClient httpErrorLogWithType:AgoraActionHttpTypeDelete url:encodeUrl error:error];

            if (failure) {
                failure(error, statusCode);
            }
        }];
    }];
}

#pragma mark LOG
+ (void)httpStartLogWithType:(AgoraActionHttpType)type url:(NSString *)url
                     headers:(NSDictionary *)headers params:(NSDictionary *)params {

    NSString *msg = [NSString stringWithFormat:
                     @"\n============>%@ HTTP Start<============\n\
                     \nurl==>\n%@\n\
                     \nheaders==>\n%@\n\
                     \nparams==>\n%@\n\
                     ",AgoraActionHttpTypeStrings[type], url, headers, params];
    AgoraActionLog(@"%@", msg);
}
+ (void)httpSuccessLogWithType:(AgoraActionHttpType)type url:(NSString *)url
                     responseObject:(id)responseObject {

    NSString *msg = [NSString stringWithFormat:
                     @"\n============>%@ HTTP Success<============\n\
                     \nurl==>\n%@\n\
                     \nResult==>\n%@\n\
                     ",AgoraActionHttpTypeStrings[type], url, responseObject];
    AgoraActionLog(@"%@", msg);
}

+ (void)httpErrorLogWithType:(AgoraActionHttpType)type url:(NSString *)url
                     error:(NSError *)error {

    NSString *msg = [NSString stringWithFormat:
                     @"\n============>%@ HTTP Error<============\n\
                     \nurl==>\n%@\n\
                     \nError==>\n%@\n\
                     ",AgoraActionHttpTypeStrings[type], url, error.description];
    AgoraActionLog(@"%@", msg);
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
