//
//  AgoraLogManager.h
//  AgoraLog
//
//  Created by SRS on 2020/7/1.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AgoraLogBaseTypes.h"

NS_ASSUME_NONNULL_BEGIN

@interface AgoraLogManager : NSObject

- (AgoraLogErrorType)setupLog:(AgoraLogConfiguration *)config;

- (AgoraLogErrorType)logMessage:(NSString *)message level:(AgoraLogLevel)level;

- (AgoraLogErrorType)uploadLogWithOptions:(AgoraLogUploadOptions*)options progress:(void (^ _Nullable) (float progress))progressBlock success:(void (^ _Nullable) (NSString *serialNumber))successBlock failure:(void (^ _Nullable) (NSError *error))failureBlock;

@end

NS_ASSUME_NONNULL_END
