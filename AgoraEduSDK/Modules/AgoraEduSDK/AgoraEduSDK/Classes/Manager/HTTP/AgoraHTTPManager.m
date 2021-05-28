//
//  AgoraHTTPManager.m
//  AgoraEducation
//
//  Created by SRS on 2020/8/2.
//  Copyright © 2020 Agora. All rights reserved.
//

#import "AgoraHTTPManager.h"
#import <AFNetworking/AFNetworking.h>
#import <YYModel/YYModel.h>
#import "AgoraRTEConfiguration.h"
#import "AgoraEduManager.h"

#define LocalErrorDomain @"io.agora.AgoraEduSDK"
#define LocalError(errCode, reason) ([NSError errorWithDomain:LocalErrorDomain \
    code:(errCode) \
userInfo:@{NSLocalizedDescriptionKey:(reason)}])

static NSString *AGORA_EDU_SDK_BASE_URL = @"https://api.agora.io";

#define HttpTypeStrings  (@[@"GET",@"POST",@"PUT",@"DELETE", @"DELETE-BODY"])

@interface AgoraHTTPManager ()
@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
@end
@implementation AgoraHTTPManager
+ (instancetype)shareInstance {
    static AgoraHTTPManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (manager == nil) {
            manager = [[AgoraHTTPManager alloc] init];
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
+ (NSString *)getBaseURL {
    return AGORA_EDU_SDK_BASE_URL;
}

+ (void)getConfig:(AgoraRoomConfiguration *)config
          success:(OnConfigSuccessBlock)successBlock
          failure:(OnHttpFailureBlock)failureBlock {
    
    NSString *url = [NSString stringWithFormat:HTTP_APP_CONFIG, AGORA_EDU_SDK_BASE_URL, config.appId];
    
    NSDictionary *headers = [AgoraHTTPManager headersWithUId:config.userUuid
                                                   userToken:nil
                                                       token:config.token];
    
    [AgoraHTTPManager fetchDispatch:HttpTypeGet
                                url:url
                         parameters:@{}
                            headers:headers
                         parseClass:AgoraConfigModel.class
                            success:^(id _Nonnull model) {
        if (successBlock) {
            successBlock(model);
        }
    } failure:^(NSError * _Nonnull error, NSInteger statusCode) {
        if (failureBlock) {
            failureBlock(error, statusCode);
        }
    }];
}
+ (void)roomStateWithConfig:(AgoraRoomStateConfiguration *)config
                    success:(OnRoomStateSuccessBlock)successBlock
                    failure:(OnHttpFailureBlock)failureBlock {
    
    NSString *url = [NSString stringWithFormat:HTTP_APP_ROOM_STATE, AGORA_EDU_SDK_BASE_URL, config.appId, config.roomUuid, config.userUuid];
    
    NSDictionary *headers = [AgoraHTTPManager headersWithUId:config.userUuid
                                                   userToken:nil
                                                       token:config.token];

    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"roomName"] = config.roomName;
    parameters[@"roomType"] = @(config.roomType);
    parameters[@"role"] = @(config.role);
    parameters[@"userName"] = config.userName;
    parameters[@"userProperties"] = config.userProperties;
    
    if (config.startTime != nil) {
        parameters[@"startTime"] = config.startTime;
    }
    
    if (config.duration != nil) {
        parameters[@"duration"] = config.duration;
    }
    
    [AgoraHTTPManager fetchDispatch:HttpTypePut
                                url:url
                         parameters:parameters
                            headers:headers
                         parseClass:AgoraRoomStateModel.class
                            success:^(id _Nonnull model) {
        if(successBlock){
            successBlock(model);
        }
    } failure:^(NSError * _Nonnull error, NSInteger statusCode) {
        if (failureBlock) {
            failureBlock(error, statusCode);
        }
    }];
}

+ (void)roomChatWithConfig:(AgoraRoomChatConfiguration *)config
                   success:(OnRoomChatSuccessBlock)successBlock
                   failure:(OnHttpFailureBlock)failureBlock {
    NSString *url = [NSString stringWithFormat:HTTP_APP_ROOM_CHAT, AGORA_EDU_SDK_BASE_URL, config.appId, config.roomUuid, config.userUuid];
    
    NSDictionary *headers = [AgoraHTTPManager headersWithUId:config.userUuid
                                                   userToken:@""
                                                       token:config.token];

    NSDictionary *parameters = @{
        @"message":config.message,
        @"type":@(config.type)
    };
    
    [AgoraHTTPManager fetchDispatch:HttpTypePost
                                url:url
                         parameters:parameters
                            headers:headers
                         parseClass:AgoraChatModel.class
                            success:^(id _Nonnull model) {
        if(successBlock){
            successBlock(model);
        }
    } failure:^(NSError * _Nonnull error, NSInteger statusCode) {
        if (failureBlock) {
            failureBlock(error, statusCode);
        }
    }];
}

+ (void)conversationChatWithConfig:(AgoraRoomChatConfiguration *)config
                           success:(OnRoomChatSuccessBlock)successBlock
                           failure:(OnHttpFailureBlock)failureBlock {
    
    // @"%@/edu/apps/%@/v2/rooms/%@/conversation/students/%@/messages"
    
    NSString *url = [NSString stringWithFormat:HTTP_APP_CONVERSATION_CHAT,
                                               AGORA_EDU_SDK_BASE_URL,
                                               config.appId,
                                               config.roomUuid,
                                               config.userUuid];
    
    NSDictionary *headers = [AgoraHTTPManager headersWithUId:config.userUuid
                                                   userToken:@""
                                                       token:config.token];

    NSDictionary *parameters = @{
        @"message":config.message,
        @"type":@(config.type)
    };
    
    [AgoraHTTPManager fetchDispatch:HttpTypePost
                                url:url
                         parameters:parameters
                            headers:headers
                         parseClass:AgoraChatModel.class
                            success:^(id _Nonnull model) {
        if(successBlock){
            successBlock(model);
        }
    } failure:^(NSError * _Nonnull error, NSInteger statusCode) {
        if (failureBlock) {
            failureBlock(error, statusCode);
        }
    }];
}

+ (void)handUpWithConfig:(AgoraHandUpConfiguration *)config
                 success:(OnHandUpSuccessBlock)successBlock
                 failure:(OnHttpFailureBlock)failureBlock {
    NSString *url = [NSString stringWithFormat:HTTP_APP_HANDUP, AGORA_EDU_SDK_BASE_URL, config.appId, config.roomUuid, config.toUserUuid];
    
    NSDictionary *headers = [AgoraHTTPManager headersWithUId:config.userUuid
                                                   userToken:config.userToken
                                                       token:config.token];
    
    NSDictionary *parameters = @{
        @"payload":config.payload,
    };
    
    [AgoraHTTPManager fetchDispatch:HttpTypePost
                                url:url
                         parameters:parameters
                            headers:headers
                         parseClass:AgoraHandUpModel.class
                            success:^(id _Nonnull model) {
        if(successBlock){
            successBlock(model);
        }
    } failure:^(NSError * _Nonnull error, NSInteger statusCode) {
        if (failureBlock) {
            failureBlock(error, statusCode);
        }
    }];
}

+ (void)getBoardInfoWithConfig:(AgoraBoardInfoConfiguration *)config
                       success:(OnBoardInfoGetSuccessBlock)successBlock
                       failure:(OnHttpFailureBlock)failureBlock {
    NSString *url = [NSString stringWithFormat:HTTP_BOARD_INFO, AGORA_EDU_SDK_BASE_URL, config.appId, config.roomUuid];

    NSDictionary *headers = [AgoraHTTPManager headersWithUId:config.userUuid
                                                   userToken:config.userToken
                                                       token:config.token];
    [AgoraHTTPManager fetchDispatch:HttpTypeGet
                                url:url
                         parameters:@{}
                            headers:headers
                         parseClass:AgoraBoardModel.class
                            success:^(id _Nonnull model) {
        if(successBlock){
            successBlock(model);
        }
    } failure:^(NSError * _Nonnull error, NSInteger statusCode) {
        if (failureBlock) {
            failureBlock(error, statusCode);
        }
    }];
}

+ (void)getRecordInfoWithConfig:(AgoraRecordInfoConfiguration *)config
                        success:(OnRecordInfoGetSuccessBlock)successBlock
                        failure:(OnHttpFailureBlock)failureBlock {
    NSString *url = [NSString stringWithFormat:HTTP_RECORD_INFO, AGORA_EDU_SDK_BASE_URL, config.appId, config.roomUuid];

    NSDictionary *headers = [AgoraHTTPManager headersWithUId:config.userUuid
                                                   userToken:nil
                                                       token:config.token];
    
    [AgoraHTTPManager fetchDispatch:HttpTypeGet
                                url:url
                         parameters:@{}
                            headers:headers
                         parseClass:AgoraRecordModel.class
                            success:^(id _Nonnull model) {
        if (successBlock){
            successBlock(model);
        }
    } failure:^(NSError * _Nonnull error, NSInteger statusCode) {
        if (failureBlock) {
            failureBlock(error, statusCode);
        }
    }];
}

+ (void)assignBreakOutGroupWithConfig:(AgoraAssignGroupInfoConfiguration *)config
                              success:(OnAssignBreakOutGroupSuccessBlock)successBlock
                              failure:(OnHttpFailureBlock)failureBlock {
    NSString *url = [NSString stringWithFormat:HTTP_BREAKOUT_GROUP_ROOM, AGORA_EDU_SDK_BASE_URL, config.appId, config.roomUuid];

    NSDictionary *headers = [AgoraHTTPManager headersWithUId:config.userUuid
                                                   userToken:config.userToken
                                                       token:config.token];
    
    NSDictionary *roleConfig = @{
        @"host": @{
                @"limit": @(config.host.limit),
                @"verifyType":@(0),
                @"subscribe":@(1),
            },
        @"assistant": @{
                @"limit": @(config.assistant.limit),
                @"verifyType": @(0),
                @"subscribe": @(1),
            },
        @"broadcaster": @{
                @"limit": @(config.broadcaster.limit),
                @"verifyType": @(0),
                @"subscribe": @(1),
            }
    };
    NSDictionary *parameters = @{
        @"memberLimit": @(config.memberLimit),
        @"roleConfig": roleConfig,
    };
    
    [AgoraHTTPManager fetchDispatch:HttpTypePost
                                url:url
                         parameters:parameters
                            headers:headers
                         parseClass:AgoraAssignGroupModel.class
                            success:^(id _Nonnull model) {
        if (successBlock){
            successBlock(model);
        }
    } failure:^(NSError * _Nonnull error, NSInteger statusCode) {
        if (failureBlock) {
            failureBlock(error, statusCode);
        }
    }];
}

#pragma mark fetch Dispatch
+ (NSError * _Nullable)checkResponseObject:(AgoraBaseModel *)model {
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

+ (void)fetchDispatch:(HttpType)type
                  url:(NSString *)url
           parameters:(NSDictionary *)parameters
              headers:(NSDictionary *)headers
           parseClass:(Class)classType
              success:(OnHttpSuccessBlock)successBlock
              failure:(OnHttpFailureBlock)failureBlock {
    NSCharacterSet *characterSet = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *encodeUrl = [url stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
    [AgoraHTTPManager httpStartLogWithType:type
                                       url:encodeUrl
                                   headers:headers
                                    params:parameters];
    void (^sucBlock)(id) = ^(id responseObj) {
        [AgoraHTTPManager httpSuccessLogWithType:type
                                             url:encodeUrl
                                  responseObject:responseObj];
        id model = [classType yy_modelWithDictionary:responseObj];
        if (successBlock) {
            NSError *error = [AgoraHTTPManager checkResponseObject:model];
            if (error != nil && failureBlock != nil) {
                failureBlock(error, 200);
            } else {
                successBlock(model);
            }
        }
    };
    
    void (^failBlock)(NSError *, NSInteger) = ^(NSError *error, NSInteger statusCode) {
        [AgoraHTTPManager httpErrorLogWithType:type
                                           url:encodeUrl
                                         error:error];
        if (failureBlock) {
            failureBlock(error, statusCode);
        }
    };
    
    AFHTTPSessionManager *sessionManager = [AgoraHTTPManager shareInstance].sessionManager;
    sessionManager.requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithObjects:@"GET", @"HEAD", @"DELETE", nil];
    
    if (type == HttpTypePut) {
        [sessionManager PUT:encodeUrl
                 parameters:parameters
                    headers:headers
                    success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            sucBlock(responseObject);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [AgoraHTTPManager checkHttpError:error
                                        task:task
                                     success:^(id responseObj) {
                sucBlock(responseObj);
            } failure:^(NSError *error, NSInteger statusCode) {
                failBlock(error, statusCode);
            }];
        }];
    } else if (type == HttpTypePost) {
        [sessionManager POST:encodeUrl
                  parameters:parameters
                     headers:headers
                    progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            sucBlock(responseObject);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [AgoraHTTPManager checkHttpError:error
                                        task:task
                                     success:^(id responseObj) {
                sucBlock(responseObj);
            } failure:^(NSError *error, NSInteger statusCode) {
                failBlock(error, statusCode);
            }];
        }];
    } else if (type == HttpTypeGet) {
        [sessionManager GET:encodeUrl
                 parameters:parameters
                    headers:headers
                   progress:^(NSProgress * _Nonnull uploadProgress) {

        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            sucBlock(responseObject);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [AgoraHTTPManager checkHttpError:error task:task success:^(id responseObj) {
                sucBlock(responseObj);
            } failure:^(NSError *error, NSInteger statusCode) {
                failBlock(error, statusCode);
            }];
        }];
    } else if (type == HttpTypeDelete) {
        [sessionManager DELETE:encodeUrl
                    parameters:parameters
                       headers:headers
                       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            sucBlock(responseObject);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [AgoraHTTPManager checkHttpError:error
                                        task:task
                                     success:^(id responseObj) {
                sucBlock(responseObj);
            } failure:^(NSError *error, NSInteger statusCode) {
                failBlock(error, statusCode);
            }];
        }];
    } else if (type == HttpTypeDeleteBody) {
        sessionManager.requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithObjects:@"GET", @"HEAD", nil];
        
        [sessionManager DELETE:encodeUrl
                    parameters:parameters
                       headers:headers
                       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            sucBlock(responseObject);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [AgoraHTTPManager checkHttpError:error
                                        task:task
                                     success:^(id responseObj) {
                sucBlock(responseObj);
            } failure:^(NSError *error, NSInteger statusCode) {
                failBlock(error, statusCode);
            }];
        }];
    }
}

#pragma mark Headers
+ (NSDictionary *)headersWithUId:(NSString *)uId
                       userToken:(NSString *)userToken
                           token:(NSString *)token {
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
+ (void)httpStartLogWithType:(HttpType)type
                         url:(NSString *)url
                     headers:(NSDictionary *)headers
                      params:(NSDictionary *)params {
    NSString *msg = [NSString stringWithFormat:
                     @"\n============>%@ HTTP Start<============\n\
                     \nurl==>\n%@\n\
                     \nheaders==>\n%@\n\
                     \nparams==>\n%@\n\
                     ",HttpTypeStrings[type], url, headers, params];
    [AgoraEduManager.shareManager logMessage:msg
                                       level:AgoraRTELogLevelInfo];
}

+ (void)httpSuccessLogWithType:(HttpType)type
                           url:(NSString *)url
                responseObject:(id)responseObject {
    
    NSString *msg = [NSString stringWithFormat:
                     @"\n============>%@ HTTP Success<============\n\
                     \nurl==>\n%@\n\
                     \nResult==>\n%@\n\
                     ",HttpTypeStrings[type], url, responseObject];
    [AgoraEduManager.shareManager logMessage:msg
                                       level:AgoraRTELogLevelInfo];
}

+ (void)httpErrorLogWithType:(HttpType)type
                         url:(NSString *)url
                       error:(NSError *)error {
    
    NSString *msg = [NSString stringWithFormat:
                     @"\n============>%@ HTTP Error<============\n\
                     \nurl==>\n%@\n\
                     \nError==>\n%@\n\
                     ",HttpTypeStrings[type], url, error.description];
    [AgoraEduManager.shareManager logMessage:msg
                                       level:AgoraRTELogLevelInfo];
}

#pragma mark Check
+ (void)checkHttpError:(NSError *)error
                  task:(NSURLSessionDataTask *)task
               success:(void (^)(id responseObj))success
               failure:(void (^)(NSError *error, NSInteger statusCode))failure {
    
    NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)task.response;
    
    NSData *errorData = error.userInfo[@"com.alamofire.serialization.response.error.data"];
    if (errorData == nil) {
        failure(error, urlResponse.statusCode);
        return;
    }
    
    NSDictionary *errorDataDict = [NSJSONSerialization JSONObjectWithData:errorData
                                                                  options:NSJSONReadingMutableLeaves
                                                                    error:nil];
    if (errorDataDict == nil) {
        failure(error, urlResponse.statusCode);
        return;
    }

    success(errorDataDict);
}

@end
