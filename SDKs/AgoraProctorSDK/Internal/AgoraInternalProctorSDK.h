//
//  AgoraInternalClassroom.h
//  AgoraClassroomSDK
//
//  Created by Cavan on 2021/6/30.
//  Copyright © 2021 Agora. All rights reserved.
//

#import <AgoraEduCore/AgoraEduCore-Swift.h>
#import <Foundation/Foundation.h>
#import "AgoraProctorSDK.h"
#import "AgoraProctorObjects.h"

NS_ASSUME_NONNULL_BEGIN

@interface AgoraProctorLaunchConfig (Internal)
- (BOOL)isLegal;
@end

#pragma mark - Model translation
@interface AgoraProctorSDK (Internal)
- (AgoraEduCoreLaunchConfig *)getCoreLaunchConfig:(AgoraProctorLaunchConfig *)config;
- (AgoraEduCoreMediaOptions *)getCoretMediaOptions:(AgoraProctorMediaOptions *)options;
@end

NS_ASSUME_NONNULL_END
