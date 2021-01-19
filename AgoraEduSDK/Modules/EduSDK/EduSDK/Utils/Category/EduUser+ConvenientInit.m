//
//  EduUser+ConvenientInit.m
//  EduSDK
//
//  Created by SRS on 2020/7/21.
//  Copyright © 2020 agora. All rights reserved.
//

#import "EduUser+ConvenientInit.h"

@implementation EduUserEvent (ConvenientInit)
- (instancetype)initWithModifiedUser:(EduUser *)modifiedUser operatorUser:(EduBaseUser * _Nullable)operatorUser {
    self = [super init];
    if (self) {
        [self setValue:modifiedUser forKey:@"modifiedUser"];
        if(operatorUser){
            [self setValue:operatorUser forKey:@"operatorUser"];
        }
    }
    return self;
}
@end
