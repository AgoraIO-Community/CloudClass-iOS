//
//  AppHTTPManager.m
//  AgoraEducation
//
//  Created by SRS on 2020/8/2.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import "AppHTTPManager.h"
#import <YYModel/YYModel.h>
#import "EduConfiguration.h"

#define LocalErrorDomain @"io.agora.AgoraEduSDK"
#define LocalError(errCode, reason) ([NSError errorWithDomain:LocalErrorDomain \
    code:(errCode) \
userInfo:@{NSLocalizedDescriptionKey:(reason)}])

static NSString *AGORA_EDU_SDK_BASE_URL = @"https://api.agora.io";

typedef NS_ENUM(NSInteger, HttpType) {
    HttpTypeGet            = 0,
    HttpTypePost,
    HttpTypePut,
    HttpTypeDelete,
};
#define HttpTypeStrings  (@[@"GET",@"POST",@"PUT",@"DELETE"])

@interface AppHTTPManager ()
@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
@end
@implementation AppHTTPManager
+ (instancetype)shareInstance {
    static AppHTTPManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (manager == nil) {
            manager = [[AppHTTPManager alloc] init];
            manager.sessionManager = [AFHTTPSessionManager manager];
            manager.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
            manager.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
            manager.sessionManager.requestSerializer.timeoutInterval = 30;
        }
    });
    return manager;
}

+ (void)setBaseURL:(NSString *)url {
    AGORA_EDU_SDK_BASE_URL = url;
}

+ (void)getConfig:(RoomConfiguration *)config success:(OnConfigSuccessBlock)successBlock failure:(OnHttpFailureBlock)failureBlock {
    
    NSString *url = [NSString stringWithFormat:HTTP_APP_CONFIG, AGORA_EDU_SDK_BASE_URL, config.appId];
    
    NSDictionary *headers = [AppHTTPManager headersWithUId:config.userUuid userToken:nil token:config.token];
    
    [AppHTTPManager fetchDispatch:HttpTypeGet url:url parameters:@{} headers:headers parseClass:AppConfigModel.class success:^(id _Nonnull model) {
        
        if(successBlock){
            successBlock(model);
        }
    } failure:^(NSError * _Nonnull error, NSInteger statusCode) {
        if (failureBlock) {
            failureBlock(error, statusCode);
        }
    }];
}
+ (void)roomStateWithConfig:(RoomStateConfiguration *)config  success:(OnRoomStateSuccessBlock)successBlock failure:(OnHttpFailureBlock)failureBlock {
    
    NSString *url = [NSString stringWithFormat:HTTP_APP_ROOM_STATE, AGORA_EDU_SDK_BASE_URL, config.appId, config.roomUuid, config.userUuid];
    
    NSDictionary *headers = [AppHTTPManager headersWithUId:config.userUuid  userToken:nil token:config.token];

    NSDictionary *parameters = @{
        @"roomName":config.roomName,
        @"roomType":@(config.roomType),
        @"role":@(config.role)
    };
    
    [AppHTTPManager fetchDispatch:HttpTypePut url:url parameters:parameters headers:headers parseClass:AppRoomStateModel.class success:^(id _Nonnull model) {
        if(successBlock){
            successBlock(model);
        }
    } failure:^(NSError * _Nonnull error, NSInteger statusCode) {
        if (failureBlock) {
            failureBlock(error, statusCode);
        }
    }];
}
+ (void)roomChatWithConfig:(RoomChatConfiguration *)config  success:(OnRoomChatSuccessBlock)successBlock failure:(OnHttpFailureBlock)failureBlock {
    
    NSString *url = [NSString stringWithFormat:HTTP_APP_ROOM_CHAT, AGORA_EDU_SDK_BASE_URL, config.appId, config.roomUuid, config.userUuid];
    
    NSDictionary *headers = [AppHTTPManager headersWithUId:config.userUuid  userToken:config.userToken token:config.token];

    NSDictionary *parameters = @{
        @"message":config.message,
        @"type":@(config.type)
    };
    
    [AppHTTPManager fetchDispatch:HttpTypePost url:url parameters:parameters headers:headers parseClass:AppRoomStateModel.class success:^(id _Nonnull model) {
        if(successBlock){
            successBlock(model);
        }
    } failure:^(NSError * _Nonnull error, NSInteger statusCode) {
        if (failureBlock) {
            failureBlock(error, statusCode);
        }
    }];
}
+ (void)handUpWithConfig:(HandUpConfiguration *)config  success:(OnHandUpSuccessBlock)successBlock failure:(OnHttpFailureBlock)failureBlock {
    
    NSString *url = [NSString stringWithFormat:HTTP_APP_HANDUP, AGORA_EDU_SDK_BASE_URL, config.appId, config.roomUuid, config.toUserUuid];
    
    NSDictionary *headers = [AppHTTPManager headersWithUId:config.userUuid  userToken:config.userToken token:config.token];
    
    NSDictionary *parameters = @{
        @"payload":config.payload,
    };
    
    [AppHTTPManager fetchDispatch:HttpTypePost url:url parameters:parameters headers:headers parseClass:AppHandUpModel.class success:^(id _Nonnull model) {
        if(successBlock){
            successBlock(model);
        }
    } failure:^(NSError * _Nonnull error, NSInteger statusCode) {
        if (failureBlock) {
            failureBlock(error, statusCode);
        }
    }];
}

+ (void)getBoardInfoWithConfig:(BoardInfoConfiguration *)config  success:(OnBoardInfoGetSuccessBlock)successBlock failure:(OnHttpFailureBlock)failureBlock {
    
    NSString *url = [NSString stringWithFormat:HTTP_BOARD_INFO, AGORA_EDU_SDK_BASE_URL, config.appId, config.roomUuid];

    NSDictionary *headers = [AppHTTPManager headersWithUId:config.userUuid  userToken:config.userToken token:config.token];
    
    [AppHTTPManager fetchDispatch:HttpTypeGet url:url parameters:@{} headers:headers parseClass:BoardModel.class success:^(id _Nonnull model) {
        if(successBlock){
            successBlock(model);
        }
    } failure:^(NSError * _Nonnull error, NSInteger statusCode) {
        if (failureBlock) {
            failureBlock(error, statusCode);
        }
    }];
}

+ (void)getRecordInfoWithConfig:(RecordInfoConfiguration *)config  success:(OnRecordInfoGetSuccessBlock)successBlock failure:(OnHttpFailureBlock)failureBlock {

    NSString *url = [NSString stringWithFormat:HTTP_RECORD_INFO, AGORA_EDU_SDK_BASE_URL, config.appId, config.roomUuid];

    NSDictionary *headers = [AppHTTPManager headersWithUId:config.userUuid userToken:nil token:config.token];
    
    [AppHTTPManager fetchDispatch:HttpTypeGet url:url parameters:@{} headers:headers parseClass:RecordModel.class success:^(id _Nonnull model) {
        if(successBlock){
            successBlock(model);
        }
    } failure:^(NSError * _Nonnull error, NSInteger statusCode) {
        if (failureBlock) {
            failureBlock(error, statusCode);
        }
    }];
}

+ (void)assignBreakOutGroupWithConfig:(AssignGroupInfoConfiguration *)config  success:(OnAssignBreakOutGroupSuccessBlock)successBlock failure:(OnHttpFailureBlock)failureBlock {

    NSString *url = [NSString stringWithFormat:HTTP_BREAKOUT_GROUP_ROOM, AGORA_EDU_SDK_BASE_URL, config.appId, config.roomUuid];

    NSDictionary *headers = [AppHTTPManager headersWithUId:config.userUuid  userToken:config.userToken token:config.token];
    
    NSDictionary *roleConfig = @{
        @"host" : @{
                @"limit":@(config.host.limit),
                @"verifyType":@(0),
                @"subscribe":@(1),
            },
        @"assistant" : @{
                @"limit":@(config.assistant.limit),
                @"verifyType":@(0),
                @"subscribe":@(1),
            },
        @"broadcaster" : @{
                @"limit":@(config.broadcaster.limit),
                @"verifyType":@(0),
                @"subscribe":@(1),
            }
    };
    NSDictionary *parameters = @{
        @"memberLimit":@(config.memberLimit),
        @"roleConfig":roleConfig,
    };
    
    [AppHTTPManager fetchDispatch:HttpTypePost url:url parameters:parameters headers:headers parseClass:AssignGroupModel.class success:^(id _Nonnull model) {
        if(successBlock){
            successBlock(model);
        }
    } failure:^(NSError * _Nonnull error, NSInteger statusCode) {
        if (failureBlock) {
            failureBlock(error, statusCode);
        }
    }];
}

#pragma mark fetch Dispatch
+ (NSError * _Nullable)checkResponseObject:(AppBaseModel *)model {

    if (model.code == 0) {
        return nil;
        
    } else if (model.code == -1) {
        NSString *msg = model.message;
        if(msg == nil) {
            return LocalError(model.code, @"unknown error");
        } else{
            return LocalError(model.code, msg);
        }
    } else {
        return LocalError(model.code, model.msg);
    }
}

+ (void)fetchDispatch:(HttpType)type url:(NSString *)url parameters:parameters headers:headers parseClass:(Class)classType success:(OnHttpSuccessBlock)successBlock failure:(OnHttpFailureBlock)failureBlock {
    
    NSString *encodeUrl = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [AppHTTPManager httpStartLogWithType:type url:encodeUrl headers:headers params:parameters];
    
    void (^sucBlock)(id) = ^(id responseObj) {
        [AppHTTPManager httpSuccessLogWithType:type url:encodeUrl responseObject:responseObj];
        id model = [classType yy_modelWithDictionary:responseObj];
        if (successBlock) {
            NSError *error = [AppHTTPManager checkResponseObject:model];
            if (error != nil && failureBlock != nil) {
                failureBlock(error, 200);
            } else {
                successBlock(model);
            }
        }
    };
    
    void (^failBlock)(NSError *, NSInteger) = ^(NSError *error, NSInteger statusCode) {
        [AppHTTPManager httpErrorLogWithType:type url:encodeUrl error:error];
        
        if (failureBlock) {
            failureBlock(error, statusCode);
        }
    };
    
    AFHTTPSessionManager *sessionManager = [AppHTTPManager shareInstance].sessionManager;
    if(type == HttpTypePut) {
        [sessionManager PUT:encodeUrl parameters:parameters headers:headers success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            sucBlock(responseObject);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [AppHTTPManager checkHttpError:error task:task success:^(id responseObj) {
                sucBlock(responseObj);
            } failure:^(NSError *error, NSInteger statusCode) {
                failBlock(error, statusCode);
            }];
        }];
    } else if(type == HttpTypePost) {
        [sessionManager POST:encodeUrl parameters:parameters headers:headers progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            sucBlock(responseObject);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [AppHTTPManager checkHttpError:error task:task success:^(id responseObj) {
                sucBlock(responseObj);
            } failure:^(NSError *error, NSInteger statusCode) {
                failBlock(error, statusCode);
            }];
        }];
    } else if(type == HttpTypeGet) {
        [sessionManager GET:encodeUrl parameters:parameters headers:headers progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            sucBlock(responseObject);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [AppHTTPManager checkHttpError:error task:task success:^(id responseObj) {
                sucBlock(responseObj);
            } failure:^(NSError *error, NSInteger statusCode) {
                failBlock(error, statusCode);
            }];
        }];
    } else if(type == HttpTypeDelete) {
        [sessionManager DELETE:encodeUrl parameters:parameters headers:headers success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            sucBlock(responseObject);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [AppHTTPManager checkHttpError:error task:task success:^(id responseObj) {
                sucBlock(responseObj);
            } failure:^(NSError *error, NSInteger statusCode) {
                failBlock(error, statusCode);
            }];
        }];
    }
}

#pragma mark Headers
+ (NSDictionary *)headersWithUId:(NSString *)uId userToken:(NSString *)userToken token:(NSString *)token {
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:@"application/json" forKey:@"Content-Type"];
    if (userToken != nil && userToken.length > 0) {
        [dic setValue:userToken forKey:@"token"];
    }
    if (uId != nil && uId.length > 0) {
        [dic setValue:uId forKey:@"x-agora-uid"];
    }
    if (token != nil && token.length > 0) {
        [dic setValue:token forKey:@"x-agora-token"];
    }
    return dic;
}

#pragma mark LOG
+ (void)httpStartLogWithType:(HttpType)type url:(NSString *)url
                     headers:(NSDictionary *)headers params:(NSDictionary *)params {
    
    NSString *msg = [NSString stringWithFormat:
                     @"\n============>%@ HTTP Start<============\n\
                     \nurl==>\n%@\n\
                     \nheaders==>\n%@\n\
                     \nparams==>\n%@\n\
                     ",HttpTypeStrings[type], url, headers, params];
    [AgoraEduManager.shareManager logMessage:msg level:EduLogLevelInfo];
}
+ (void)httpSuccessLogWithType:(HttpType)type url:(NSString *)url
                     responseObject:(id)responseObject {
    
    NSString *msg = [NSString stringWithFormat:
                     @"\n============>%@ HTTP Success<============\n\
                     \nurl==>\n%@\n\
                     \nResult==>\n%@\n\
                     ",HttpTypeStrings[type], url, responseObject];
    [AgoraEduManager.shareManager logMessage:msg level:EduLogLevelInfo];
}

+ (void)httpErrorLogWithType:(HttpType)type url:(NSString *)url
                     error:(NSError *)error {
    
    NSString *msg = [NSString stringWithFormat:
                     @"\n============>%@ HTTP Error<============\n\
                     \nurl==>\n%@\n\
                     \nError==>\n%@\n\
                     ",HttpTypeStrings[type], url, error.description];
    [AgoraEduManager.shareManager logMessage:msg level:EduLogLevelError];
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
