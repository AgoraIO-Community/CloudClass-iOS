//
//  AgoraEduSDK.h
//  AgoraEduSDK
//
//  Created by SRS on 2021/1/5.
//

#import <Foundation/Foundation.h>
#import "AgoraEduObjects.h"
#import "AgoraEduClassroom.h"
#import "AgoraEduReplay.h"

NS_ASSUME_NONNULL_BEGIN

@interface AgoraEduSDK : NSObject

+ (void)setConfig:(AgoraEduSDKConfig *)config;

+ (AgoraEduClassroom * _Nullable)launch:(AgoraEduLaunchConfig *)config delegate:(id<AgoraEduClassroomDelegate> _Nullable)delegate;

+ (AgoraEduReplay * _Nullable)replay:(AgoraEduReplayConfig *)config delegate:(id<AgoraEduReplayDelegate> _Nullable)delegate;

+ (NSString *)version;

@end

NS_ASSUME_NONNULL_END
