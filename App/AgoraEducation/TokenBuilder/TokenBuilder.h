//
//  TokenBuilder.h
//  AgoraEducation
//
//  Created by SRS on 2021/1/13.
//  Copyright © 2021 yangmoumou. All rights reserved.
//

#if __has_include(<AgoraClassroomSDK_iOS/AgoraClassroomSDK.h>)
    #import <AgoraClassroomSDK_iOS/AgoraClassroomSDK.h>
#else
    #import <AgoraClassroomSDK/AgoraClassroomSDK.h>
#endif

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TokenBuilder : NSObject

// 本地生成token。用于本地快速演示使用， 我们建议你使用服务器生成token( buildToken:success:failure:)
+ (NSString *)buildToken:(NSString *)appID
          appCertificate:(NSString *)appCertificate
                userUuid:(NSString *)userUuid;

// 服务器生成token。
+ (void)buildToken:(NSString *)url
           success:(void (^)(NSString *token))success
           failure:(void (^)(NSError *error))failure;

// 服务器生成token。
+ (void)serverInfo:(NSString *)region
          userUuid:(NSString *)userUuid
           success:(void (^)(NSString *appid,
                             NSString *userId,
                             NSString *rtmToken))success
           failure:(void (^)(NSError *error))failure;

// 获取白板课件
+ (void)boardResources:(NSString *)url
                 token:(NSString *)token
               success:(void (^)(NSArray<AgoraEduBoardScene *> *models,
                                 NSString *resourceName,
                                 NSString *resourceUuid,
                                 NSString *scenePath,
                                 NSString *downURL))success
               failure:(void (^)(NSError *error))failure;
@end

NS_ASSUME_NONNULL_END
