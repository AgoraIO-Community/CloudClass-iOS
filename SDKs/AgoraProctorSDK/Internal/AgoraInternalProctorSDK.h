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
#import "AgoraProctorSDK.h"
#import "AgoraProctorObjects.h"

NS_ASSUME_NONNULL_BEGIN

@interface AgoraProctorLaunchConfig (Internal)
- (BOOL)isLegal;
@end

#pragma mark - Model translation
@interface AgoraProctorSDK (Internal)
- (AgoraEduCorePuppetLaunchConfig *)getPuppetLaunchConfig:(AgoraProctorLaunchConfig *)config;
- (AgoraEduCorePuppetMediaOptions *)getPuppetMediaOptions:(AgoraProctorMediaOptions *)options;
@end

NS_ASSUME_NONNULL_END
