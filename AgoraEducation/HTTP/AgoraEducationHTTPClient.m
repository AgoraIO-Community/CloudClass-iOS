//
//  AgoraEducationHTTPClient.m
//  AgoraEducation
//
//  Created by SRS on 2020/8/2.
//  Copyright © 2020 Agora. All rights reserved.
//

#import "AgoraEducationHTTPClient.h"
#import <AFNetworking/AFNetworking.h>

#ifdef DEBUG
#define AgoraEducationHTTPLog(...) NSLog(__VA_ARGS__)
#else
#define AgoraEducationHTTPLog(...)
#endif

typedef NS_ENUM(NSInteger, AgoraEducationHttpType) {
    AgoraEducationHttpTypeGet            = 0,
    AgoraEducationHttpTypePost,
    AgoraEducationHttpTypePut,
    AgoraEducationHttpTypeDelete,
};
#define AgoraEducationHttpTypeStrings  (@[@"GET",@"POST",@"PUT",@"DELETE"])

@implementation AgoraEducationHTTPClient

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

    [AgoraEducationHTTPClient httpStartLogWithType:AgoraEducationHttpTypeGet url:encodeUrl headers:headers params:params];

    [[AgoraEducationHTTPClient sessionManager] GET:encodeUrl parameters:params headers:headers progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

        [AgoraEducationHTTPClient httpSuccessLogWithType:AgoraEducationHttpTypeGet url:encodeUrl responseObject:responseObject];

        if (success) {
            success(responseObject);
        }

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

        [AgoraEducationHTTPClient checkHttpError:error task:task success:^(id responseObj) {

            [AgoraEducationHTTPClient httpSuccessLogWithType:AgoraEducationHttpTypeGet url:encodeUrl responseObject:responseObj];
            if (success) {
                success(responseObj);
            }

        } failure:^(NSError *error, NSInteger statusCode) {
            [AgoraEducationHTTPClient httpErrorLogWithType:AgoraEducationHttpTypeGet url:encodeUrl error:error];

            if (failure) {
                failure(error, statusCode);
            }
        }];
    }];
}

+ (void)post:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary<NSString*, NSString*> *)headers success:(void (^)(id responseObj))success failure:(void (^)(NSError *error, NSInteger statusCode))failure {

    NSString *encodeUrl = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [AgoraEducationHTTPClient httpStartLogWithType:AgoraEducationHttpTypePost url:encodeUrl headers:headers params:params];
    
    [[AgoraEducationHTTPClient sessionManager] POST:encodeUrl parameters:params headers:headers progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

        [AgoraEducationHTTPClient httpSuccessLogWithType:AgoraEducationHttpTypePost url:encodeUrl responseObject:responseObject];
        if (success) {
            success(responseObject);
        }

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

        [AgoraEducationHTTPClient checkHttpError:error task:task success:^(id responseObj) {

            [AgoraEducationHTTPClient httpSuccessLogWithType:AgoraEducationHttpTypePost url:encodeUrl responseObject:responseObj];
            if (success) {
                success(responseObj);
            }

        } failure:^(NSError *error, NSInteger statusCode) {
            [AgoraEducationHTTPClient httpErrorLogWithType:AgoraEducationHttpTypePost url:encodeUrl error:error];

            if (failure) {
                failure(error, statusCode);
            }
        }];
    }];
}

+ (void)put:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary<NSString*, NSString*> *)headers success:(void (^)(id responseObj))success failure:(void (^)(NSError *error, NSInteger statusCode))failure {

    NSString *encodeUrl = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    [AgoraEducationHTTPClient httpStartLogWithType:AgoraEducationHttpTypePut url:encodeUrl headers:headers params:params];

    [[AgoraEducationHTTPClient sessionManager] PUT:encodeUrl parameters:params headers:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

        [AgoraEducationHTTPClient httpSuccessLogWithType:AgoraEducationHttpTypePut url:encodeUrl responseObject:responseObject];

        if (success) {
            success(responseObject);
        }

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

        [AgoraEducationHTTPClient checkHttpError:error task:task success:^(id responseObj) {

            [AgoraEducationHTTPClient httpSuccessLogWithType:AgoraEducationHttpTypePut url:encodeUrl responseObject:responseObj];
            if (success) {
                success(responseObj);
            }

        } failure:^(NSError *error, NSInteger statusCode) {
            [AgoraEducationHTTPClient httpErrorLogWithType:AgoraEducationHttpTypePut url:encodeUrl error:error];

            if (failure) {
                failure(error, statusCode);
            }
        }];
    }];
}

+ (void)del:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary<NSString*, NSString*> *)headers success:(void (^)(id responseObj))success failure:(void (^)(NSError *error, NSInteger statusCode))failure {

    NSString *encodeUrl = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    [AgoraEducationHTTPClient httpStartLogWithType:AgoraEducationHttpTypeDelete url:encodeUrl headers:headers params:params];

    [[AgoraEducationHTTPClient sessionManager] DELETE:encodeUrl parameters:params headers:headers success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

        [AgoraEducationHTTPClient httpSuccessLogWithType:AgoraEducationHttpTypeDelete url:encodeUrl responseObject:responseObject];

        if (success) {
            success(responseObject);
        }

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

        [AgoraEducationHTTPClient checkHttpError:error task:task success:^(id responseObj) {

            [AgoraEducationHTTPClient httpSuccessLogWithType:AgoraEducationHttpTypeDelete url:encodeUrl responseObject:responseObj];
            if (success) {
                success(responseObj);
            }

        } failure:^(NSError *error, NSInteger statusCode) {
            [AgoraEducationHTTPClient httpErrorLogWithType:AgoraEducationHttpTypeDelete url:encodeUrl error:error];

            if (failure) {
                failure(error, statusCode);
            }
        }];
    }];
}

#pragma mark LOG
+ (void)httpStartLogWithType:(AgoraEducationHttpType)type url:(NSString *)url
                     headers:(NSDictionary *)headers params:(NSDictionary *)params {

    NSString *msg = [NSString stringWithFormat:
                     @"\n============>%@ HTTP Start<============\n\
                     \nurl==>\n%@\n\
                     \nheaders==>\n%@\n\
                     \nparams==>\n%@\n\
                     ",AgoraEducationHttpTypeStrings[type], url, headers, params];
    AgoraEducationHTTPLog(@"%@", msg);
}
+ (void)httpSuccessLogWithType:(AgoraEducationHttpType)type url:(NSString *)url
                     responseObject:(id)responseObject {

    NSString *msg = [NSString stringWithFormat:
                     @"\n============>%@ HTTP Success<============\n\
                     \nurl==>\n%@\n\
                     \nResult==>\n%@\n\
                     ",AgoraEducationHttpTypeStrings[type], url, responseObject];
    AgoraEducationHTTPLog(@"%@", msg);
}

+ (void)httpErrorLogWithType:(AgoraEducationHttpType)type url:(NSString *)url
                     error:(NSError *)error {

    NSString *msg = [NSString stringWithFormat:
                     @"\n============>%@ HTTP Error<============\n\
                     \nurl==>\n%@\n\
                     \nError==>\n%@\n\
                     ",AgoraEducationHttpTypeStrings[type], url, error.description];
    AgoraEducationHTTPLog(@"%@", msg);
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
