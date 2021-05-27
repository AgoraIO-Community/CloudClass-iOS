//
//  AgoraLogHttpClient.h
//  AgoraEdu
//
//  Created by SRS on 2020/5/3.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class AgoraLogManager;

@interface AgoraLogHttpClient : NSObject

+ (void)setAgoraLogManager:(AgoraLogManager *)logManager;

+ (void)get:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary<NSString*, NSString*> *)headers success:(void (^)(id))success failure:(void (^)(NSError *))failure;
+ (void)post:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary<NSString*, NSString*> *)headers success:(void (^)(id responseObj))success failure:(void (^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
