//
//  BaseEducationManager+NSArray_copy.m
//  AgoraEducation
//
//  Created by SRS on 2020/4/24.
//  Copyright © 2020 Agora. All rights reserved.
//

#import "NSArray+Copy.h"
#import <YYModel/YYModel.h>

@implementation NSArray (Copy)
- (NSArray *)deepCopy {
    NSMutableArray *array = [NSMutableArray array];
    for (NSObject *obj in self) {
        [array addObject: obj.yy_modelCopy];
    }
    return array;
}
@end
