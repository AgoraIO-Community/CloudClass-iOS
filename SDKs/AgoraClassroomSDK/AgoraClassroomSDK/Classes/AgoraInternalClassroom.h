//
//  AgoraInternalClassroom.h
//  AgoraClassroomSDK
//
//  Created by Cavan on 2021/6/30.
//  Copyright © 2021 Agora. All rights reserved.
//

#if __has_include(<AgoraEduCorePuppet/AgoraEduCoreWrapper.h>)
#import <AgoraEduCorePuppet/AgoraEduCoreWrapper.h>
#elif __has_include(<AgoraEduCore/AgoraEduCoreWrapper.h>)
#import <AgoraEduCore/AgoraEduCoreWrapper.h>
#else
# error "Invalid import"
#endif

#import <Foundation/Foundation.h>
#import "AgoraClassroomSDK.h"
#import "AgoraEduObjects.h"

NS_ASSUME_NONNULL_BEGIN

@interface AgoraEduLaunchConfig (Internal)
- (BOOL)isLegal;
@end

#pragma mark - Model translation
@interface AgoraClassroomSDK (Internal)
+ (AgoraEduCorePuppetLaunchConfig *)getPuppetLaunchConfig:(AgoraEduLaunchConfig *)config;
+ (AgoraEduCorePuppetMediaOptions *)getPuppetMediaOptions:(AgoraEduMediaOptions *)options;
@end

NS_ASSUME_NONNULL_END
