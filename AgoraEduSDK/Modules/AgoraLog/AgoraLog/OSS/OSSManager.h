//
//  OSSManager.h
//  AgoraLog
//
//  Created by SRS on 2020/7/2.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>

#define LocalErrorDomain @"io.agora.AgoraLog"
#define LocalError(errCode, reason) ([NSError errorWithDomain:LocalErrorDomain \
    code:(errCode) \
userInfo:@{NSLocalizedDescriptionKey:(reason)}])

NS_ASSUME_NONNULL_BEGIN

@interface OSSManager : NSObject

+ (void)uploadOSSWithAppId:(NSString*)appId access:(NSString*)access secret:(NSString *)secret token:(NSString *)token bucketName:(NSString *)bucketName objectKey:(NSString *)objectKey callbackBody:(NSString *)callbackBody callbackBodyType:(NSString *)callbackBodyType endpoint:(NSString*)endpoint fileURL:(NSURL *)fileURL progress:(void (^ _Nullable) (float progress))progressBlock success:(void (^ _Nullable) (NSString *uploadSerialNumber))successBlock fail:(void (^ _Nullable) (NSError *error))failBlock;

@end

NS_ASSUME_NONNULL_END
