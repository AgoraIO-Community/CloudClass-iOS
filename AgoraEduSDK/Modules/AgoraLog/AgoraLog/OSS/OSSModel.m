//
//  OSSModel.m
//  AgoraLog
//
//  Created by SRS on 2020/7/2.
//  Copyright © 2020 agora. All rights reserved.
//

#import "OSSModel.h"
#define NoNullString(x) ([x isKindOfClass:NSString.class] ? x : @"")

@implementation OSSModel

+ (nullable OSSModel *)initWithJsonString:(NSString *)jsonString error:(NSError **)error {
    
    NSData *jsonData = [NoNullString(jsonString) dataUsingEncoding:NSASCIIStringEncoding];

    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:error];
    if(*error != nil){
        return nil;
    }
    
    OSSModel *model = [[OSSModel alloc] init];
    model.msg = jsonObject[@"msg"];
    model.code = [jsonObject[@"code"] integerValue];
    model.data = jsonObject[@"data"];
    return model;
}

@end
