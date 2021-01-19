//
//  CYXHttpRequest.h
//  TenMinDemo
//
//  Created by apple开发 on 16/5/31.
//  Copyright © 2016年 CYXiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"

#define APIVersion1 @"v1"
#define APIVersion2 @"v2"

NS_ASSUME_NONNULL_BEGIN

@interface HttpManagerConfig : NSObject
@property(nonatomic, strong) NSString *baseURL;
@property(nonatomic, strong) NSString *appCode;
@property(nonatomic, strong) NSString *appid;
@property(nonatomic, strong) NSString *userUuid;
//@property(nonatomic, strong) NSString *authorization;

// B认证方式
@property(nonatomic, strong) NSString *token;
@property(nonatomic, strong)NSString *logDirectoryPath;

@property(nonatomic, assign) NSInteger tag;

@end

@interface HttpManager : NSObject

+ (HttpManagerConfig *)getHttpManagerConfig;
+ (void)setupHttpManagerConfig:(HttpManagerConfig *)httpConfig;

+ (void)loginWithParam:(NSDictionary *)param apiVersion:(NSString *)apiVersion analysisClass:(Class)classType success:(void (^ _Nullable) (id<BaseModel> objModel))successBlock failure:(void (^ _Nullable) (NSError * _Nullable error, NSInteger statusCode))failureBlock;

+ (void)joinRoomWithRoomUuid:(NSString *)roomUuid param:(NSDictionary *)param apiVersion:(NSString *)apiVersion analysisClass:(Class)classType success:(void (^ _Nullable) (id<BaseModel> objModel))successBlock failure:(void (^ _Nullable) (NSError * _Nullable error, NSInteger statusCode))failureBlock;

+ (void)getRoomInfoWithRoomUuid:(NSString *)roomUuid userToken:(NSString *)userToken param:(NSDictionary *)param apiVersion:(NSString *)apiVersion analysisClass:(Class)classType success:(void (^ _Nullable) (id<BaseModel> objModel))successBlock failure:(void (^ _Nullable) (NSError * _Nullable error, NSInteger statusCode))failureBlock;

+ (void)syncTotalWithRoomUuid:(NSString *)roomUuid userToken:(NSString *)userToken param:(NSDictionary *)param apiVersion:(NSString *)apiVersion analysisClass:(Class)classType success:(void (^ _Nullable) (id<BaseModel> objModel))successBlock failure:(void (^ _Nullable) (NSError * _Nullable error, NSInteger statusCode))failureBlock;
+ (void)syncIncreaseWithRoomUuid:(NSString *)roomUuid userToken:(NSString *)userToken param:(NSDictionary *)param apiVersion:(NSString *)apiVersion analysisClass:(Class)classType success:(void (^ _Nullable) (id<BaseModel> objModel))successBlock failure:(void (^ _Nullable) (NSError * _Nullable error, NSInteger statusCode))failureBlock;

//+ (void)getUserStreamListWithParam:(NSDictionary *)param apiVersion:(NSString *)apiVersion analysisClass:(Class)classType success:(void (^ _Nullable) (id<BaseModel> objModel))successBlock failure:(void (^ _Nullable) (NSError * _Nullable error, NSInteger statusCode))failureBlock;
//+ (void)getUserListWithParam:(NSDictionary *)param apiVersion:(NSString *)apiVersion analysisClass:(Class)classType success:(void (^ _Nullable) (id<BaseModel> objModel))successBlock failure:(void (^ _Nullable) (NSError * _Nullable error, NSInteger statusCode))failureBlock;
//+ (void)getStreamListWithParam:(NSDictionary *)param apiVersion:(NSString *)apiVersion analysisClass:(Class)classType success:(void (^ _Nullable) (id<BaseModel> objModel))successBlock failure:(void (^ _Nullable) (NSError * _Nullable error, NSInteger statusCode))failureBlock;

+ (void)upsetStreamWithRoomUuid:(NSString *)roomUuid userUuid:(NSString *)tagetUserUuid userToken:(NSString *)userToken streamUuid:(NSString *)streamUuid param:(NSDictionary *)param apiVersion:(NSString *)apiVersion analysisClass:(Class)classType success:(void (^ _Nullable) (id<BaseModel> objModel))successBlock failure:(void (^ _Nullable) (NSError * _Nullable error, NSInteger statusCode))failureBlock;
+ (void)removeStreamWithRoomUuid:(NSString *)roomUuid userUuid:(NSString *)tagetUserUuid userToken:(NSString *)userToken streamUuid:(NSString *)streamUuid param:(NSDictionary *)param apiVersion:(NSString *)apiVersion analysisClass:(Class)classType success:(void (^ _Nullable) (id<BaseModel> objModel))successBlock failure:(void (^ _Nullable) (NSError * _Nullable error, NSInteger statusCode))failureBlock;

+ (void)upsetStreamsWithRoomUuid:(NSString *)roomUuid userToken:(NSString *)userToken param:(NSDictionary *)param apiVersion:(NSString *)apiVersion analysisClass:(Class)classType success:(void (^ _Nullable) (id<BaseModel> objModel))successBlock failure:(void (^ _Nullable) (NSError * _Nullable error, NSInteger statusCode))failureBlock;
+ (void)removeStreamsWithRoomUuid:(NSString *)roomUuid userToken:(NSString *)userToken param:(NSDictionary *)param apiVersion:(NSString *)apiVersion analysisClass:(Class)classType success:(void (^ _Nullable) (id<BaseModel> objModel))successBlock failure:(void (^ _Nullable) (NSError * _Nullable error, NSInteger statusCode))failureBlock;

+ (void)roomChatWithRoomUuid:(NSString *)roomUuid userToken:(NSString *)userToken param:(NSDictionary *)param apiVersion:(NSString *)apiVersion analysisClass:(Class)classType success:(void (^ _Nullable) (id<BaseModel> objModel))successBlock failure:(void (^ _Nullable) (NSError * _Nullable error, NSInteger statusCode))failureBlock;
+ (void)userChatWithRoomUuid:(NSString *)roomUuid userToken:(NSString *)userToken userUuid:(NSString *)toUserUuid param:(NSDictionary *)param apiVersion:(NSString *)apiVersion analysisClass:(Class)classType success:(void (^ _Nullable) (id<BaseModel> objModel))successBlock failure:(void (^ _Nullable) (NSError * _Nullable error, NSInteger statusCode))failureBlock;

// update state
+ (void)updateUserStateWithRoomUuid:(NSString *)roomUuid userUuid:(NSString *)tagetUserUuid userToken:(NSString *)userToken param:(NSDictionary *)param apiVersion:(NSString *)apiVersion analysisClass:(Class)classType success:(void (^ _Nullable) (id<BaseModel> objModel))successBlock failure:(void (^ _Nullable) (NSError * _Nullable error, NSInteger statusCode))failureBlock;
+ (void)updateRoomStartOrStopWithRoomUuid:(NSString *)roomUuid state:(NSInteger)state userToken:(NSString *)userToken param:(NSDictionary *)param apiVersion:(NSString *)apiVersion analysisClass:(Class)classType success:(void (^ _Nullable) (id<BaseModel> objModel))successBlock failure:(void (^ _Nullable) (NSError * _Nullable error, NSInteger statusCode))failureBlock;
+ (void)updateRoomMuteWithRoomUuid:(NSString *)roomUuid userToken:(NSString *)userToken param:(NSDictionary *)param apiVersion:(NSString *)apiVersion analysisClass:(Class)classType success:(void (^ _Nullable) (id<BaseModel> objModel))successBlock failure:(void (^ _Nullable) (NSError * _Nullable error, NSInteger statusCode))failureBlock;

+ (void)roomMsgWithRoomUuid:(NSString *)roomUuid userToken:(NSString *)userToken param:(NSDictionary *)param apiVersion:(NSString *)apiVersion analysisClass:(Class)classType success:(void (^ _Nullable) (id<BaseModel> objModel))successBlock failure:(void (^ _Nullable) (NSError * _Nullable error, NSInteger statusCode))failureBlock;
+ (void)userMsgWithRoomUuid:(NSString *)roomUuid userToken:(NSString *)userToken userUuid:(NSString *)toUserUuid param:(NSDictionary *)param apiVersion:(NSString *)apiVersion analysisClass:(Class)classType success:(void (^ _Nullable) (id<BaseModel> objModel))successBlock failure:(void (^ _Nullable) (NSError * _Nullable error, NSInteger statusCode))failureBlock;
+ (void)startActionWithProcessUuid:(NSString *)processUuid userToken:(NSString *)userToken param:(NSDictionary *)param apiVersion:(NSString *)apiVersion analysisClass:(Class)classType success:(void (^ _Nullable) (id<BaseModel> objModel))successBlock failure:(void (^ _Nullable) (NSError * _Nullable error, NSInteger statusCode))failureBlock;
+ (void)stopActionWithProcessUuid:(NSString *)processUuid userToken:(NSString *)userToken param:(NSDictionary *)param apiVersion:(NSString *)apiVersion analysisClass:(Class)classType success:(void (^ _Nullable) (id<BaseModel> objModel))successBlock failure:(void (^ _Nullable) (NSError * _Nullable error, NSInteger statusCode))failureBlock;

+ (void)setRoomPropertiesWithRoomUuid:(NSString *)roomUuid userToken:(NSString *)userToken param:(NSDictionary *)param apiVersion:(NSString *)apiVersion analysisClass:(Class)classType success:(void (^ _Nullable) (id<BaseModel> objModel))successBlock failure:(void (^ _Nullable) (NSError * _Nullable error, NSInteger statusCode))failureBlock;
+ (void)deleteRoomPropertiesWithRoomUuid:(NSString *)roomUuid userToken:(NSString *)userToken param:(NSDictionary *)param apiVersion:(NSString *)apiVersion analysisClass:(Class)classType success:(void (^ _Nullable) (id<BaseModel> objModel))successBlock failure:(void (^ _Nullable) (NSError * _Nullable error, NSInteger statusCode))failureBlock;
+ (void)userPropertiesWithRoomUuid:(NSString *)roomUuid userToken:(NSString *)userToken userUuid:(NSString *)userUuid key:(NSString *)key param:(NSDictionary *)param apiVersion:(NSString *)apiVersion analysisClass:(Class)classType success:(void (^ _Nullable) (id<BaseModel> objModel))successBlock failure:(void (^ _Nullable) (NSError * _Nullable error, NSInteger statusCode))failureBlock;

+ (void)leaveRoomWithRoomUuid:(NSString *)roomUuid userToken:(NSString *)userToken param:(NSDictionary *)param apiVersion:(NSString *)apiVersion analysisClass:(Class)classType success:(void (^ _Nullable) (id<BaseModel> objModel))successBlock failure:(void (^ _Nullable) (NSError * _Nullable error, NSInteger statusCode))failureBlock;

@end

NS_ASSUME_NONNULL_END
