//
//  AgoraRTEUser+ConvenientInit.h
//  EduSDK
//
//  Created by SRS on 2020/7/21.
//  Copyright © 2020 agora. All rights reserved.
//
#import "AgoraRTEUser.h"

NS_ASSUME_NONNULL_BEGIN
@interface AgoraRTEUserEvent (ConvenientInit)
- (instancetype)initWithModifiedUser:(AgoraRTEUser *)modifiedUser operatorUser:(AgoraRTEBaseUser * _Nullable)operatorUser;
@end

NS_ASSUME_NONNULL_END
