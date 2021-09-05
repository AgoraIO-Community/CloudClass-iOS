//
//  AgoraInternalClassroom.h
//  AgoraEduSDK
//
//  Created by Cavan on 2021/6/30.
//  Copyright © 2021 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AgoraClassroomSDK.h"
#import "AgoraEduObjects.h"

NS_ASSUME_NONNULL_BEGIN

@interface AgoraEduSDKConfig (Internal)
- (BOOL)isLegal;
@end

@interface AgoraEduLaunchConfig (Internal)
- (BOOL)isLegal;
@end

NS_ASSUME_NONNULL_END
