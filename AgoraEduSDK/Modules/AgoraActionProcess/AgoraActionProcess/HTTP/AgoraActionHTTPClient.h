//
//  AgoraActionHTTPClient.h
//  AgoraEducation
//
//  Created by SRS on 2020/8/2.
//  Copyright © 2020 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, AgoraActionHttpType) {
    AgoraActionHttpTypeGet            = 0,
    AgoraActionHttpTypePost,
    AgoraActionHttpTypePut,
    AgoraActionHttpTypeDelete,
};

@interface AgoraActionHTTPClient : NSObject

+ (void)get:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary<NSString*, NSString*> *)headers success:(void (^)(id responseObj))success failure:(void (^)(NSError *error, NSInteger statusCode))failure;
+ (void)post:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary<NSString*, NSString*> *)headers success:(void (^)(id responseObj))success failure:(void (^)(NSError *error, NSInteger statusCode))failure;
+ (void)put:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary<NSString*, NSString*> *)headers success:(void (^)(id responseObj))success failure:(void (^)(NSError *error, NSInteger statusCode))failure;
+ (void)del:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary<NSString*, NSString*> *)headers success:(void (^)(id responseObj))success failure:(void (^)(NSError *error, NSInteger statusCode))failure;

@end

NS_ASSUME_NONNULL_END
