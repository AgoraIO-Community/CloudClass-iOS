//
//  EduTextMessage+ConvenientInit.h
//  EduSDK
//
//  Created by SRS on 2020/7/22.
//  Copyright © 2020 agora. All rights reserved.
//

#import "EduTextMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface EduTextMessage (ConvenientInit)
- (instancetype)initWithUser:(EduUser *)fromUser message:(NSString *)message timestamp:(NSInteger)timestamp;
@end



NS_ASSUME_NONNULL_END
