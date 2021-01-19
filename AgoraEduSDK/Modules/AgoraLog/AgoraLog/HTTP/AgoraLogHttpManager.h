//
//  AgoraLogHttpManager.h
//  AgoraEdu
//
//  Created by SRS on 2020/5/3.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LogModel.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *AGORA_EDU_HTTP_LOG_OSS_BASE_URL;

@interface AgoraLogHttpManager : NSObject

// log
+ (void)getLogInfoWithAppId:(NSString *)appId baseURL:(NSString *)baseURL appSecret:(NSString *)appSecret uid:(NSString *)uid token:(NSString *)token ext:(NSDictionary *)ext apiVersion:(NSString *)apiVersion completeSuccessBlock:(void (^ _Nullable) (LogModel * model))successBlock completeFailBlock:(void (^ _Nullable) (NSError *error))failBlock;

@end

NS_ASSUME_NONNULL_END
