//
//  EduUser+ConvenientInit.h
//  EduSDK
//
//  Created by SRS on 2020/7/21.
//  Copyright © 2020 agora. All rights reserved.
//
#import "EduUser.h"

NS_ASSUME_NONNULL_BEGIN
@interface EduUserEvent (ConvenientInit)
- (instancetype)initWithModifiedUser:(EduUser *)modifiedUser operatorUser:(EduBaseUser * _Nullable)operatorUser;
@end

NS_ASSUME_NONNULL_END
