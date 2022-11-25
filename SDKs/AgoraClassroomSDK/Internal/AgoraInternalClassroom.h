//
//  AgoraInternalClassroom.h
//  AgoraClassroomSDK
//
//  Created by Cavan on 2021/6/30.
//  Copyright © 2021 Agora. All rights reserved.
//

#import <AgoraEduCore/AgoraEduCore-Swift.h>
#import <Foundation/Foundation.h>
#import "AgoraClassroomSDK.h"
#import "AgoraEduObjects.h"

NS_ASSUME_NONNULL_BEGIN

@interface AgoraEduLaunchConfig (Internal)
- (BOOL)isLegal;
@end

#pragma mark - Model translation
@interface AgoraClassroomSDK (Internal)
+ (AgoraEduCoreLaunchConfig *)getCoreLaunchConfig:(AgoraEduLaunchConfig *)config;
+ (AgoraEduCoreMediaOptions *)getCoreMediaOptions:(AgoraEduMediaOptions *)options;
@end

NS_ASSUME_NONNULL_END
