//
//  EduTextMessage+ConvenientInit.m
//  EduSDK
//
//  Created by SRS on 2020/7/22.
//  Copyright © 2020 agora. All rights reserved.
//

#import "EduTextMessage+ConvenientInit.h"

@implementation EduTextMessage (ConvenientInit)
- (instancetype)initWithUser:(EduUser *)fromUser message:(NSString *)message timestamp:(NSInteger)timestamp {
    
    self = [super init];
    if (self) {
        [self setValue:fromUser forKey:@"fromUser"];
        [self setValue:message forKey:@"message"];
        [self setValue:@(timestamp) forKey:@"timestamp"];
    }
    return self;
}
@end
