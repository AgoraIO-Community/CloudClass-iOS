//
//  AgoraLogHttpManager.h
//  AgoraEdu
//
//  Created by SRS on 2020/5/3.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AgoraLogModel.h"
#import "AgoraLogBaseTypes.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *AGORA_EDU_HTTP_LOG_OSS_BASE_URL;

@interface AgoraLogHttpManager : NSObject

// log
+ (void)getLogInfoWithOptions:(AgoraLogUploadOptions *)options
         completeSuccessBlock:(void (^)(AgoraLogModel * _Nonnull))successBlock
            completeFailBlock:(void (^)(NSError * _Nonnull))failBlock;

@end

NS_ASSUME_NONNULL_END
