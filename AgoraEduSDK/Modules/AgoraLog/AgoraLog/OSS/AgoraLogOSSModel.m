//
//  AgoraLogOSSModel.m
//  AgoraLog
//
//  Created by SRS on 2020/7/2.
//  Copyright © 2020 agora. All rights reserved.
//

#import "AgoraLogOSSModel.h"
#define AgoraRTENoNullString(x) ([x isKindOfClass:NSString.class] ? x : @"")

@implementation AgoraLogOSSModel

+ (nullable AgoraLogOSSModel *)initWithJsonString:(NSString *)jsonString error:(NSError **)error {
    
    NSData *jsonData = [AgoraRTENoNullString(jsonString) dataUsingEncoding:NSASCIIStringEncoding];

    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:error];
    if(*error != nil){
        return nil;
    }
    
    AgoraLogOSSModel *model = [[AgoraLogOSSModel alloc] init];
    model.msg = jsonObject[@"msg"];
    model.code = [jsonObject[@"code"] integerValue];
    model.data = jsonObject[@"data"];
    return model;
}

@end
