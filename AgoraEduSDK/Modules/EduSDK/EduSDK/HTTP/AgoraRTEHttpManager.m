//
//  CYXHttpRequest.m
//  TenMinDemo
//
//  Created by apple开发 on 16/5/31.
//  Copyright © 2016年 CYXiang. All rights reserved.
//

#import "AgoraRTEHttpManager.h"
#import "AgoraRTEHttpClient.h"
#import "AgoraRTEURL.h"
#import <YYModel/YYModel.h>

#define AgoraRTEHTTPErrorDomain @"io.agora.AgoraRTEHTTP"
#define AgoraRTE_LocalError(errCode,reason) ([NSError errorWithDomain:AgoraRTEHTTPErrorDomain \
code:(errCode) \
userInfo:@{NSLocalizedDescriptionKey:(reason)}])

#define AgoraRTE_HTTP_STATUE_OK 200

static HttpManagerConfig *config;

@implementation HttpManagerConfig
@end

@implementation AgoraRTEHttpManager
+ (HttpManagerConfig *)getHttpManagerConfig {
    if(config == nil) {
        config = [HttpManagerConfig new];
    }
    return config;
}
+ (void)setupHttpManagerConfig:(HttpManagerConfig *)httpConfig {
    config = httpConfig;
}

+ (void)loginWithParam:(NSDictionary *)param apiVersion:(NSString *)apiVersion analysisClass:(Class)classType success:(void (^ _Nullable) (id<AgoraRTEBaseModel> objModel))successBlock failure:(void (^ _Nullable) (NSError * _Nullable error, NSInteger statusCode))failureBlock {
    
    NSString *urlStr = [NSString stringWithFormat:HTTP_LOGIN, config.baseURL, config.appid, config.userUuid];
    
    [AgoraRTEHttpManager post:urlStr token:nil params:param headers:nil apiVersion:apiVersion success:^(id responseObj) {
        id<AgoraRTEBaseModel> model = [classType yy_modelWithDictionary:responseObj];
        if(model.code == 0){
            if(successBlock){
                successBlock(model);
            }
        } else {
            if(failureBlock){
                NSError *error = AgoraRTE_LocalError(model.code, model.msg);
                failureBlock(error, AgoraRTE_HTTP_STATUE_OK);
            }
        }
        
    } failure:^(NSError *error, NSInteger statusCode) {
        if(failureBlock) {
            failureBlock(error, statusCode);
        }
    }];
}

+ (void)joinRoomWithRoomUuid:(NSString *)roomUuid
                       param:(NSDictionary *)param
                  apiVersion:(NSString *)apiVersion
               analysisClass:(Class)classType
                     success:(void (^ _Nullable) (id<AgoraRTEBaseModel> objModel))successBlock
                     failure:(void (^ _Nullable) (NSError * _Nullable error, NSInteger statusCode))failureBlock {
    
    NSString *urlStr = [NSString stringWithFormat:HTTP_JOIN_ROOM, config.baseURL, config.appid, roomUuid, config.userUuid];
    
    [AgoraRTEHttpManager post:urlStr token:nil params:param headers:nil apiVersion:apiVersion success:^(id responseObj) {
        
        id<AgoraRTEBaseModel> model = [classType yy_modelWithDictionary:responseObj];
        if(model.code == 0){
            if(successBlock){
                successBlock(model);
            }
        } else {
            if(failureBlock){
                NSError *error = AgoraRTE_LocalError(model.code, model.msg);
                failureBlock(error, AgoraRTE_HTTP_STATUE_OK);
            }
        }
        
    } failure:^(NSError *error, NSInteger statusCode) {
        if(failureBlock) {
            failureBlock(error, statusCode);
        }
    }];
}

+ (void)getRoomInfoWithRoomUuid:(NSString *)roomUuid userToken:(NSString *)userToken param:(NSDictionary *)param apiVersion:(NSString *)apiVersion analysisClass:(Class)classType success:(void (^ _Nullable) (id<AgoraRTEBaseModel> objModel))successBlock failure:(void (^ _Nullable) (NSError * _Nullable error, NSInteger statusCode))failureBlock {
    
    NSString *urlStr = [NSString stringWithFormat:HTTP_GET_ROOM_INFO, config.baseURL, config.appid, roomUuid];
    
    [AgoraRTEHttpManager get:urlStr token:userToken params:param headers:nil apiVersion:apiVersion success:^(id responseObj) {
        id<AgoraRTEBaseModel> model = [classType yy_modelWithDictionary:responseObj];
        if(model.code == 0){
            if(successBlock){
                successBlock(model);
            }
        } else {
            if(failureBlock){
                NSError *error = AgoraRTE_LocalError(model.code, model.msg);
                failureBlock(error, AgoraRTE_HTTP_STATUE_OK);
            }
        }
    } failure:^(NSError *error, NSInteger statusCode) {
        if(failureBlock) {
            failureBlock(error, statusCode);
        }
    }];
}
//
+ (void)syncTotalWithRoomUuid:(NSString *)roomUuid userToken:(NSString *)userToken param:(NSDictionary *)param apiVersion:(NSString *)apiVersion analysisClass:(Class)classType success:(void (^ _Nullable) (id<AgoraRTEBaseModel> objModel))successBlock failure:(void (^ _Nullable) (NSError * _Nullable error, NSInteger statusCode))failureBlock {
    
    NSString *urlStr = [NSString stringWithFormat:HTTP_SYNC_TOTAL_ROOM, config.baseURL, config.appid, roomUuid];
    
    [AgoraRTEHttpManager get:urlStr token:userToken params:param headers:nil apiVersion:apiVersion success:^(id responseObj) {
        id<AgoraRTEBaseModel> model = [classType yy_modelWithDictionary:responseObj];
        if (model.code == 0) {
            if(successBlock){
                successBlock(model);
            }
        } else {
            if(failureBlock){
                NSError *error = AgoraRTE_LocalError(model.code, model.msg);
                failureBlock(error, AgoraRTE_HTTP_STATUE_OK);
            }
        }
        
    } failure:^(NSError *error, NSInteger statusCode) {
        if(failureBlock) {
            failureBlock(error, statusCode);
        }
    }];
}

+ (void)syncIncreaseWithRoomUuid:(NSString *)roomUuid userToken:(NSString *)userToken param:(NSDictionary *)param apiVersion:(NSString *)apiVersion analysisClass:(Class)classType success:(void (^ _Nullable) (id<AgoraRTEBaseModel> objModel))successBlock failure:(void (^ _Nullable) (NSError * _Nullable error, NSInteger statusCode))failureBlock {
    
    NSString *urlStr = [NSString stringWithFormat:HTTP_SYNC_INCREASE_ROOM, config.baseURL, config.appid, roomUuid];
    
    [AgoraRTEHttpManager get:urlStr token:userToken params:param headers:nil apiVersion:apiVersion success:^(id responseObj) {
        id<AgoraRTEBaseModel> model = [classType yy_modelWithDictionary:responseObj];
        if (model.code == 0) {
            if(successBlock){
                successBlock(model);
            }
        } else {
            if(failureBlock){
                NSError *error = AgoraRTE_LocalError(model.code, model.msg);
                failureBlock(error, AgoraRTE_HTTP_STATUE_OK);
            }
        }
        
    } failure:^(NSError *error, NSInteger statusCode) {
        if(failureBlock) {
            failureBlock(error, statusCode);
        }
    }];
}

//+ (void)getUserStreamListWithParam:(NSDictionary *)param apiVersion:(NSString *)apiVersion analysisClass:(Class)classType success:(void (^ _Nullable) (id<AgoraRTEBaseModel> objModel))successBlock failure:(void (^ _Nullable) (NSError * _Nullable error, NSInteger statusCode))failureBlock {
//
//    NSString *urlStr = [NSString stringWithFormat:HTTP_GET_USER_STREAM, config.baseURL, config.appid, param[PARAM_KEY_ROOMUUID]];
//
//    [AgoraRTEHttpManager get:urlStr params:param headers:nil apiVersion:apiVersion success:^(id responseObj) {
//        id<AgoraRTEBaseModel> model = [classType yy_modelWithDictionary:responseObj];
//        if (model.code == 0) {
//            if(successBlock){
//                successBlock(model);
//            }
//        } else {
//            if(failureBlock){
//                NSError *error = AgoraRTE_LocalError(model.code, model.msg);
//                failureBlock(error, AgoraRTE_HTTP_STATUE_OK);
//            }
//        }
//
//    } failure:^(NSError *error, NSInteger statusCode) {
//        if(failureBlock) {
//            failureBlock(error, statusCode);
//        }
//    }];
//}
//+ (void)getUserListWithParam:(NSDictionary *)param apiVersion:(NSString *)apiVersion analysisClass:(Class)classType success:(void (^ _Nullable) (id<AgoraRTEBaseModel> objModel))successBlock failure:(void (^ _Nullable) (NSError * _Nullable error, NSInteger statusCode))failureBlock {
//
//    NSString *urlStr = [NSString stringWithFormat:HTTP_GET_USER, config.baseURL, config.appid, param[PARAM_KEY_ROOMUUID]];
//
//    [AgoraRTEHttpManager get:urlStr params:param headers:nil apiVersion:apiVersion success:^(id responseObj) {
//        id<AgoraRTEBaseModel> model = [classType yy_modelWithDictionary:responseObj];
//        if (model.code == 0) {
//            if(successBlock){
//                successBlock(model);
//            }
//        } else {
//            if(failureBlock){
//                NSError *error = AgoraRTE_LocalError(model.code, model.msg);
//                failureBlock(error, AgoraRTE_HTTP_STATUE_OK);
//            }
//        }
//    } failure:^(NSError *error, NSInteger statusCode) {
//        if(failureBlock) {
//            failureBlock(error, statusCode);
//        }
//    }];
//}
//+ (void)getStreamListWithParam:(NSDictionary *)param apiVersion:(NSString *)apiVersion analysisClass:(Class)classType success:(void (^ _Nullable) (id<AgoraRTEBaseModel> objModel))successBlock failure:(void (^ _Nullable) (NSError * _Nullable error, NSInteger statusCode))failureBlock {
//
//    NSString *urlStr = [NSString stringWithFormat:HTTP_GET_STREAM, config.baseURL, config.appid, param[PARAM_KEY_ROOMUUID]];
//
//    [AgoraRTEHttpManager get:urlStr params:param headers:nil apiVersion:apiVersion success:^(id responseObj) {
//        id<AgoraRTEBaseModel> model = [classType yy_modelWithDictionary:responseObj];
//        if (model.code == 0) {
//            if(successBlock){
//                successBlock(model);
//            }
//        } else {
//            if(failureBlock){
//                NSError *error = AgoraRTE_LocalError(model.code, model.msg);
//                failureBlock(error, AgoraRTE_HTTP_STATUE_OK);
//            }
//        }
//    } failure:^(NSError *error, NSInteger statusCode) {
//        if(failureBlock) {
//            failureBlock(error, statusCode);
//        }
//    }];
//}

+ (void)upsetStreamWithRoomUuid:(NSString *)roomUuid userUuid:(NSString *)tagetUserUuid userToken:(NSString *)userToken streamUuid:(NSString *)streamUuid param:(NSDictionary *)param apiVersion:(NSString *)apiVersion analysisClass:(Class)classType success:(void (^ _Nullable) (id<AgoraRTEBaseModel> objModel))successBlock failure:(void (^ _Nullable) (NSError * _Nullable error, NSInteger statusCode))failureBlock {
    
    NSString *urlStr = [NSString stringWithFormat:HTTP_UPSET_STREAM, config.baseURL, config.appid, roomUuid, tagetUserUuid, streamUuid == nil ? @"0" : streamUuid];
    
    [AgoraRTEHttpManager put:urlStr token:userToken params:param headers:nil apiVersion:apiVersion success:^(id responseObj) {
        id<AgoraRTEBaseModel> model = [classType yy_modelWithDictionary:responseObj];
        if (model.code == 0) {
            if(successBlock){
                successBlock(model);
            }
        } else {
            if(failureBlock){
                NSError *error = AgoraRTE_LocalError(model.code, model.msg);
                failureBlock(error, AgoraRTE_HTTP_STATUE_OK);
            }
        }
    } failure:^(NSError *error, NSInteger statusCode) {
        if(failureBlock) {
            failureBlock(error, statusCode);
        }
    }];
}
+ (void)removeStreamWithRoomUuid:(NSString *)roomUuid userUuid:(NSString *)tagetUserUuid userToken:(NSString *)userToken streamUuid:(NSString *)streamUuid param:(NSDictionary *)param apiVersion:(NSString *)apiVersion analysisClass:(Class)classType success:(void (^ _Nullable) (id<AgoraRTEBaseModel> objModel))successBlock failure:(void (^ _Nullable) (NSError * _Nullable error, NSInteger statusCode))failureBlock {
    
    NSString *urlStr = [NSString stringWithFormat:HTTP_DELETE_STREAM, config.baseURL, config.appid, roomUuid, tagetUserUuid, streamUuid];
    
    [AgoraRTEHttpManager delete:urlStr token:userToken params:param headers:nil apiVersion:apiVersion success:^(id responseObj) {
        id<AgoraRTEBaseModel> model = [classType yy_modelWithDictionary:responseObj];
        if (model.code == 0) {
            if(successBlock){
                successBlock(model);
            }
        } else {
            if(failureBlock){
                NSError *error = AgoraRTE_LocalError(model.code, model.msg);
                failureBlock(error, AgoraRTE_HTTP_STATUE_OK);
            }
        }
    } failure:^(NSError *error, NSInteger statusCode) {
        if(failureBlock) {
            failureBlock(error, statusCode);
        }
    }];
}

+ (void)upsetStreamsWithRoomUuid:(NSString *)roomUuid userToken:(NSString *)userToken param:(NSDictionary *)param apiVersion:(NSString *)apiVersion analysisClass:(Class)classType success:(void (^ _Nullable) (id<AgoraRTEBaseModel> objModel))successBlock failure:(void (^ _Nullable) (NSError * _Nullable error, NSInteger statusCode))failureBlock {
    NSString *urlStr = [NSString stringWithFormat:HTTP_UPSET_STREAMS, config.baseURL, config.appid, roomUuid];
    
    [AgoraRTEHttpManager put:urlStr token:userToken params:param headers:nil apiVersion:apiVersion success:^(id responseObj) {
        id<AgoraRTEBaseModel> model = [classType yy_modelWithDictionary:responseObj];
        if (model.code == 0) {
            if(successBlock){
                successBlock(model);
            }
        } else {
            if(failureBlock){
                NSError *error = AgoraRTE_LocalError(model.code, model.msg);
                failureBlock(error, AgoraRTE_HTTP_STATUE_OK);
            }
        }
    } failure:^(NSError *error, NSInteger statusCode) {
        if(failureBlock) {
            failureBlock(error, statusCode);
        }
    }];
}
+ (void)removeStreamsWithRoomUuid:(NSString *)roomUuid userToken:(NSString *)userToken param:(NSDictionary *)param apiVersion:(NSString *)apiVersion analysisClass:(Class)classType success:(void (^ _Nullable) (id<AgoraRTEBaseModel> objModel))successBlock failure:(void (^ _Nullable) (NSError * _Nullable error, NSInteger statusCode))failureBlock {
    NSString *urlStr = [NSString stringWithFormat:HTTP_DELETE_STREAMS, config.baseURL, config.appid, roomUuid];
    
    [AgoraRTEHttpManager delete:urlStr token:userToken params:param headers:nil apiVersion:apiVersion success:^(id responseObj) {
        id<AgoraRTEBaseModel> model = [classType yy_modelWithDictionary:responseObj];
        if (model.code == 0) {
            if(successBlock){
                successBlock(model);
            }
        } else {
            if(failureBlock){
                NSError *error = AgoraRTE_LocalError(model.code, model.msg);
                failureBlock(error, AgoraRTE_HTTP_STATUE_OK);
            }
        }
    } failure:^(NSError *error, NSInteger statusCode) {
        if(failureBlock) {
            failureBlock(error, statusCode);
        }
    }];
}

+ (void)roomChatWithRoomUuid:(NSString *)roomUuid userToken:(NSString *)userToken param:(NSDictionary *)param apiVersion:(NSString *)apiVersion analysisClass:(Class)classType success:(void (^ _Nullable) (id<AgoraRTEBaseModel> objModel))successBlock failure:(void (^ _Nullable) (NSError * _Nullable error, NSInteger statusCode))failureBlock {
    
    NSString *urlStr = [NSString stringWithFormat:HTTP_ROOM_CHAT, config.baseURL, config.appid, roomUuid];
    
    [AgoraRTEHttpManager post:urlStr token:userToken params:param headers:nil apiVersion:apiVersion success:^(id responseObj) {
        id<AgoraRTEBaseModel> model = [classType yy_modelWithDictionary:responseObj];
        if (model.code == 0) {
            if(successBlock){
                successBlock(model);
            }
        } else {
            if(failureBlock){
                NSError *error = AgoraRTE_LocalError(model.code, model.msg);
                failureBlock(error, AgoraRTE_HTTP_STATUE_OK);
            }
        }
    } failure:^(NSError *error, NSInteger statusCode) {
        if(failureBlock) {
            failureBlock(error, statusCode);
        }
    }];
}
+ (void)userChatWithRoomUuid:(NSString *)roomUuid userToken:(NSString *)userToken userUuid:(NSString *)toUserUuid param:(NSDictionary *)param apiVersion:(NSString *)apiVersion analysisClass:(Class)classType success:(void (^ _Nullable) (id<AgoraRTEBaseModel> objModel))successBlock failure:(void (^ _Nullable) (NSError * _Nullable error, NSInteger statusCode))failureBlock {
    
    NSString *urlStr = [NSString stringWithFormat:HTTP_USER_CHAT, config.baseURL, config.appid, roomUuid, toUserUuid];
    
    [AgoraRTEHttpManager post:urlStr token:userToken params:param headers:nil apiVersion:apiVersion success:^(id responseObj) {
        id<AgoraRTEBaseModel> model = [classType yy_modelWithDictionary:responseObj];
        if (model.code == 0) {
            if(successBlock){
                successBlock(model);
            }
        } else {
            if(failureBlock){
                NSError *error = AgoraRTE_LocalError(model.code, model.msg);
                failureBlock(error, AgoraRTE_HTTP_STATUE_OK);
            }
        }
    } failure:^(NSError *error, NSInteger statusCode) {
        if(failureBlock) {
            failureBlock(error, statusCode);
        }
    }];
}

// update state
+ (void)updateUserStateWithRoomUuid:(NSString *)roomUuid userUuid:(NSString *)tagetUserUuid userToken:(NSString *)userToken param:(NSDictionary *)param apiVersion:(NSString *)apiVersion analysisClass:(Class)classType success:(void (^ _Nullable) (id<AgoraRTEBaseModel> objModel))successBlock failure:(void (^ _Nullable) (NSError * _Nullable error, NSInteger statusCode))failureBlock {
 
    NSString *urlStr = [NSString stringWithFormat:HTTP_USER_STATE, config.baseURL, config.appid, roomUuid, tagetUserUuid];
    
    [AgoraRTEHttpManager put:urlStr token:userToken params:param headers:nil apiVersion:apiVersion success:^(id responseObj) {
        id<AgoraRTEBaseModel> model = [classType yy_modelWithDictionary:responseObj];
        if (model.code == 0) {
            if(successBlock){
                successBlock(model);
            }
        } else {
            if(failureBlock){
                NSError *error = AgoraRTE_LocalError(model.code, model.msg);
                failureBlock(error, AgoraRTE_HTTP_STATUE_OK);
            }
        }
    } failure:^(NSError *error, NSInteger statusCode) {
        if(failureBlock) {
            failureBlock(error, statusCode);
        }
    }];
}
+ (void)updateRoomStartOrStopWithRoomUuid:(NSString *)roomUuid state:(NSInteger)state userToken:(NSString *)userToken param:(NSDictionary *)param apiVersion:(NSString *)apiVersion analysisClass:(Class)classType success:(void (^ _Nullable) (id<AgoraRTEBaseModel> objModel))successBlock failure:(void (^ _Nullable) (NSError * _Nullable error, NSInteger statusCode))failureBlock {

    NSString *urlStr = [NSString stringWithFormat:HTTP_ROOM_START_STOP, config.baseURL, config.appid, roomUuid, @(state)];
    
    [AgoraRTEHttpManager put:urlStr token:userToken params:param headers:nil apiVersion:apiVersion success:^(id responseObj) {
        id<AgoraRTEBaseModel> model = [classType yy_modelWithDictionary:responseObj];
        if (model.code == 0) {
            if(successBlock){
                successBlock(model);
            }
        } else {
            if(failureBlock){
                NSError *error = AgoraRTE_LocalError(model.code, model.msg);
                failureBlock(error, AgoraRTE_HTTP_STATUE_OK);
            }
        }
    } failure:^(NSError *error, NSInteger statusCode) {
        if(failureBlock) {
            failureBlock(error, statusCode);
        }
    }];
}
+ (void)updateRoomMuteWithRoomUuid:(NSString *)roomUuid userToken:(NSString *)userToken param:(NSDictionary *)param apiVersion:(NSString *)apiVersion analysisClass:(Class)classType success:(void (^ _Nullable) (id<AgoraRTEBaseModel> objModel))successBlock failure:(void (^ _Nullable) (NSError * _Nullable error, NSInteger statusCode))failureBlock {
    
    NSString *urlStr = [NSString stringWithFormat:HTTP_ROOM_MUTE, config.baseURL, config.appid, roomUuid];
    
    [AgoraRTEHttpManager put:urlStr token:userToken params:param headers:nil apiVersion:apiVersion success:^(id responseObj) {
        id<AgoraRTEBaseModel> model = [classType yy_modelWithDictionary:responseObj];
        if (model.code == 0) {
            if(successBlock){
                successBlock(model);
            }
        } else {
            if(failureBlock){
                NSError *error = AgoraRTE_LocalError(model.code, model.msg);
                failureBlock(error, AgoraRTE_HTTP_STATUE_OK);
            }
        }
    } failure:^(NSError *error, NSInteger statusCode) {
        if(failureBlock) {
            failureBlock(error, statusCode);
        }
    }];
}

+ (void)roomMsgWithRoomUuid:(NSString *)roomUuid userToken:(NSString *)userToken param:(NSDictionary *)param apiVersion:(NSString *)apiVersion analysisClass:(Class)classType success:(void (^ _Nullable) (id<AgoraRTEBaseModel> objModel))successBlock failure:(void (^ _Nullable) (NSError * _Nullable error, NSInteger statusCode))failureBlock {
    
    NSString *urlStr = [NSString stringWithFormat:HTTP_ROOM_MESSAGE, config.baseURL, config.appid, roomUuid];
    
    [AgoraRTEHttpManager post:urlStr token:userToken params:param headers:nil apiVersion:apiVersion success:^(id responseObj) {
        id<AgoraRTEBaseModel> model = [classType yy_modelWithDictionary:responseObj];
        if (model.code == 0) {
            if(successBlock){
                successBlock(model);
            }
        } else {
            if(failureBlock){
                NSError *error = AgoraRTE_LocalError(model.code, model.msg);
                failureBlock(error, AgoraRTE_HTTP_STATUE_OK);
            }
        }
    } failure:^(NSError *error, NSInteger statusCode) {
        if(failureBlock) {
            failureBlock(error, statusCode);
        }
    }];
}
+ (void)userMsgWithRoomUuid:(NSString *)roomUuid userToken:(NSString *)userToken userUuid:(NSString *)toUserUuid param:(NSDictionary *)param apiVersion:(NSString *)apiVersion analysisClass:(Class)classType success:(void (^ _Nullable) (id<AgoraRTEBaseModel> objModel))successBlock failure:(void (^ _Nullable) (NSError * _Nullable error, NSInteger statusCode))failureBlock {
    
    NSString *urlStr = [NSString stringWithFormat:HTTP_USER_MESSAGE, config.baseURL, config.appid, roomUuid, toUserUuid];
    
    [AgoraRTEHttpManager post:urlStr token:userToken params:param headers:nil apiVersion:apiVersion success:^(id responseObj) {
        id<AgoraRTEBaseModel> model = [classType yy_modelWithDictionary:responseObj];
        if (model.code == 0) {
            if(successBlock){
                successBlock(model);
            }
        } else {
            if(failureBlock){
                NSError *error = AgoraRTE_LocalError(model.code, model.msg);
                failureBlock(error, AgoraRTE_HTTP_STATUE_OK);
            }
        }
    } failure:^(NSError *error, NSInteger statusCode) {
        if(failureBlock) {
            failureBlock(error, statusCode);
        }
    }];
}

+ (void)startActionWithProcessUuid:(NSString *)processUuid userToken:(NSString *)userToken param:(NSDictionary *)param apiVersion:(NSString *)apiVersion analysisClass:(Class)classType success:(void (^ _Nullable) (id<AgoraRTEBaseModel> objModel))successBlock failure:(void (^ _Nullable) (NSError * _Nullable error, NSInteger statusCode))failureBlock {
    
    NSString *urlStr = [NSString stringWithFormat:HTTP_START_ACTION_PROCESS, config.baseURL, config.appid, processUuid];
    
    [AgoraRTEHttpManager post:urlStr token:userToken params:param headers:nil apiVersion:apiVersion success:^(id responseObj) {
        id<AgoraRTEBaseModel> model = [classType yy_modelWithDictionary:responseObj];
        if (model.code == 0) {
            if(successBlock){
                successBlock(model);
            }
        } else {
            if(failureBlock){
                NSError *error = AgoraRTE_LocalError(model.code, model.msg);
                failureBlock(error, AgoraRTE_HTTP_STATUE_OK);
            }
        }
    } failure:^(NSError *error, NSInteger statusCode) {
        if(failureBlock) {
            failureBlock(error, statusCode);
        }
    }];
}
+ (void)stopActionWithProcessUuid:(NSString *)processUuid userToken:(NSString *)userToken param:(NSDictionary *)param apiVersion:(NSString *)apiVersion analysisClass:(Class)classType success:(void (^ _Nullable) (id<AgoraRTEBaseModel> objModel))successBlock failure:(void (^ _Nullable) (NSError * _Nullable error, NSInteger statusCode))failureBlock {
    
    NSString *urlStr = [NSString stringWithFormat:HTTP_STOP_ACTION_PROCESS, config.baseURL, config.appid, processUuid];
    
    [AgoraRTEHttpManager post:urlStr token:userToken params:param headers:nil apiVersion:apiVersion success:^(id responseObj) {
        id<AgoraRTEBaseModel> model = [classType yy_modelWithDictionary:responseObj];
        if (model.code == 0) {
            if(successBlock){
                successBlock(model);
            }
        } else {
            if(failureBlock){
                NSError *error = AgoraRTE_LocalError(model.code, model.msg);
                failureBlock(error, AgoraRTE_HTTP_STATUE_OK);
            }
        }
    } failure:^(NSError *error, NSInteger statusCode) {
        if(failureBlock) {
            failureBlock(error, statusCode);
        }
    }];
}

+ (void)setRoomPropertiesWithRoomUuid:(NSString *)roomUuid userToken:(NSString *)userToken param:(NSDictionary *)param apiVersion:(NSString *)apiVersion analysisClass:(Class)classType success:(void (^ _Nullable) (id<AgoraRTEBaseModel> objModel))successBlock failure:(void (^ _Nullable) (NSError * _Nullable error, NSInteger statusCode))failureBlock {
    
    NSString *urlStr = [NSString stringWithFormat:HTTP_ROOM_PROPERTIES, config.baseURL, config.appid, roomUuid];
    
    [AgoraRTEHttpManager put:urlStr token:userToken params:param headers:nil apiVersion:apiVersion success:^(id responseObj) {
        id<AgoraRTEBaseModel> model = [classType yy_modelWithDictionary:responseObj];
        if (model.code == 0) {
            if(successBlock){
                successBlock(model);
            }
        } else {
            if(failureBlock){
                NSError *error = AgoraRTE_LocalError(model.code, model.msg);
                failureBlock(error, AgoraRTE_HTTP_STATUE_OK);
            }
        }
    } failure:^(NSError *error, NSInteger statusCode) {
        if(failureBlock) {
            failureBlock(error, statusCode);
        }
    }];
}
+ (void)deleteRoomPropertiesWithRoomUuid:(NSString *)roomUuid userToken:(NSString *)userToken param:(NSDictionary *)param apiVersion:(NSString *)apiVersion analysisClass:(Class)classType success:(void (^ _Nullable) (id<AgoraRTEBaseModel> objModel))successBlock failure:(void (^ _Nullable) (NSError * _Nullable error, NSInteger statusCode))failureBlock {
    
    NSString *urlStr = [NSString stringWithFormat:HTTP_ROOM_PROPERTIES, config.baseURL, config.appid, roomUuid];
    
    [AgoraRTEHttpManager delete:urlStr token:userToken params:param headers:nil apiVersion:apiVersion success:^(id responseObj) {
        id<AgoraRTEBaseModel> model = [classType yy_modelWithDictionary:responseObj];
        if (model.code == 0) {
            if(successBlock){
                successBlock(model);
            }
        } else {
            if(failureBlock){
                NSError *error = AgoraRTE_LocalError(model.code, model.msg);
                failureBlock(error, AgoraRTE_HTTP_STATUE_OK);
            }
        }
    } failure:^(NSError *error, NSInteger statusCode) {
        if(failureBlock) {
            failureBlock(error, statusCode);
        }
    }];
}

+ (void)userPropertiesWithRoomUuid:(NSString *)roomUuid userToken:(NSString *)userToken userUuid:(NSString *)userUuid key:(NSString *)key param:(NSDictionary *)param apiVersion:(NSString *)apiVersion analysisClass:(Class)classType success:(void (^ _Nullable) (id<AgoraRTEBaseModel> objModel))successBlock failure:(void (^ _Nullable) (NSError * _Nullable error, NSInteger statusCode))failureBlock {

    NSString *urlStr = [NSString stringWithFormat:HTTP_USER_PROPERTIES, config.baseURL, config.appid, roomUuid, userUuid, key];
    
    [AgoraRTEHttpManager put:urlStr token:userToken params:param headers:nil apiVersion:apiVersion success:^(id responseObj) {
        id<AgoraRTEBaseModel> model = [classType yy_modelWithDictionary:responseObj];
        if (model.code == 0) {
            if(successBlock){
                successBlock(model);
            }
        } else {
            if(failureBlock){
                NSError *error = AgoraRTE_LocalError(model.code, model.msg);
                failureBlock(error, AgoraRTE_HTTP_STATUE_OK);
            }
        }
    } failure:^(NSError *error, NSInteger statusCode) {
        if(failureBlock) {
            failureBlock(error, statusCode);
        }
    }];
}

+ (void)leaveRoomWithRoomUuid:(NSString *)roomUuid userToken:(NSString *)userToken param:(NSDictionary *)param apiVersion:(NSString *)apiVersion analysisClass:(Class)classType success:(void (^ _Nullable) (id<AgoraRTEBaseModel> objModel))successBlock failure:(void (^ _Nullable) (NSError * _Nullable error, NSInteger statusCode))failureBlock {
    
    NSString *urlStr = [NSString stringWithFormat:HTTP_LEAVE_ROOM, config.baseURL, config.appid, roomUuid, config.userUuid];
    
    [AgoraRTEHttpManager post:urlStr token:userToken params:param headers:nil apiVersion:apiVersion success:^(id responseObj) {
        id<AgoraRTEBaseModel> model = [classType yy_modelWithDictionary:responseObj];
        if(model.code == 0){
            if(successBlock){
                successBlock(model);
            }
        } else {
            if(failureBlock){
                NSError *error = AgoraRTE_LocalError(model.code, model.msg);
                failureBlock(error, AgoraRTE_HTTP_STATUE_OK);
            }
        }
        
    } failure:^(NSError *error, NSInteger statusCode) {
        if(failureBlock) {
            failureBlock(error, statusCode);
        }
    }];
}

#pragma mark private
+ (void)get:(NSString *)url token:(NSString * _Nullable)token params:(NSDictionary *)params headers:(NSDictionary<NSString*, NSString*> *)headers apiVersion:(NSString *)apiVersion success:(void (^)(id))success failure:(void (^)(NSError *error, NSInteger statusCode))failure {
    
    // add header
    NSMutableDictionary *_headers = [NSMutableDictionary dictionaryWithDictionary:[AgoraRTEHttpManager httpHeader]];
    if (token != nil) {
        _headers[@"token"] = token;
    }
    if(headers != nil){
        [_headers addEntriesFromDictionary:headers];
    }
    
    NSString *_url = [url stringByReplacingOccurrencesOfString:@"v1" withString:apiVersion];
    if (params != nil) {
        NSArray<NSString *> *keys = params.allKeys;
        
        if (![_url containsString:@"?"] && keys.count > 0) {
            _url = [_url stringByAppendingString:@"?"];
        }
        
        for (NSInteger index = 0; index < keys.count; index ++) {
            NSString *key = keys[index];
            _url = [_url stringByAppendingFormat:@"%@=%@", key, params[key]];
            if (index < keys.count - 1) {
                _url = [_url stringByAppendingString:@"&"];
            }
        }
    }
    [AgoraRTEHttpClient get:_url params:@{} headers:_headers success:success failure:failure];
}

+ (void)post:(NSString *)url token:(NSString * _Nullable)token params:(NSDictionary *)params headers:(NSDictionary<NSString*, NSString*> *)headers apiVersion:(NSString *)apiVersion success:(void (^)(id responseObj))success failure:(void (^)(NSError *error, NSInteger statusCode))failure {
    
    NSString *_url = [url stringByReplacingOccurrencesOfString:@"v1" withString:apiVersion];
    
    // add header
    NSMutableDictionary *_headers = [NSMutableDictionary dictionaryWithDictionary:[AgoraRTEHttpManager httpHeader]];
    if (token != nil) {
        _headers[@"token"] = token;
    }
    
    if(headers != nil){
        [_headers addEntriesFromDictionary:headers];
    }
    
    [AgoraRTEHttpClient post:_url params:params headers:_headers success:success failure:failure];
}

+ (void)put:(NSString *)url token:(NSString * _Nullable)token params:(NSDictionary *)params headers:(NSDictionary<NSString*, NSString*> *)headers apiVersion:(NSString *)apiVersion success:(void (^)(id responseObj))success failure:(void (^)(NSError *error, NSInteger statusCode))failure {
    
    NSString *_url = [url stringByReplacingOccurrencesOfString:@"v1" withString:apiVersion];
    
    // add header
    NSMutableDictionary *_headers = [NSMutableDictionary dictionaryWithDictionary:[AgoraRTEHttpManager httpHeader]];
    if (token != nil) {
        _headers[@"token"] = token;
    }
    if(headers != nil){
        [_headers addEntriesFromDictionary:headers];
    }
    
    [AgoraRTEHttpClient put:_url params:params headers:_headers success:success failure:failure];
}

+ (void)delete:(NSString *)url token:(NSString * _Nullable)token params:(NSDictionary *)params headers:(NSDictionary<NSString*, NSString*> *)headers apiVersion:(NSString *)apiVersion success:(void (^)(id responseObj))success failure:(void (^)(NSError *error, NSInteger statusCode))failure {
    
    NSString *_url = [url stringByReplacingOccurrencesOfString:@"v1" withString:apiVersion];
    
    // add header
    NSMutableDictionary *_headers = [NSMutableDictionary dictionaryWithDictionary:[AgoraRTEHttpManager httpHeader]];
    if (token != nil) {
        _headers[@"token"] = token;
    }
    if(headers != nil){
        [_headers addEntriesFromDictionary:headers];
    }
    
    [AgoraRTEHttpClient del:_url params:params headers:_headers success:success failure:failure];
}

+ (NSDictionary *)httpHeader {
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    if(config.token) {
        headers[@"x-agora-token"] = config.token;
    }
    if(config.userUuid) {
        headers[@"x-agora-uid"] = config.userUuid;
    }
    return headers;
}

@end
