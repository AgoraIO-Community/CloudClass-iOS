//
//  LogModel.m
//  AgoraEducation
//
//  Created by SRS on 2020/1/8.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "LogModel.h"
#define NoNullString(x) ([x isKindOfClass:NSString.class] ? x : @"")

@implementation LogInfoModel

@end

@implementation LogModel

+ (LogModel *)initWithObject:(id)dictionary {
    
    LogModel *model = [LogModel new];
    if(dictionary == nil || ![dictionary isKindOfClass:NSDictionary.class]){
        return model;
    }
    
    model.msg = dictionary[@"msg"];
    model.code = [dictionary[@"code"] integerValue];
    
    NSDictionary *dataDic = dictionary[@"data"];
    if(dataDic != nil && [dataDic isKindOfClass:NSDictionary.class]){
        LogInfoModel *infoModel = [LogInfoModel new];
        infoModel.bucketName = dataDic[@"bucketName"];
        infoModel.ossKey = dataDic[@"ossKey"];
        infoModel.callbackBody = dataDic[@"callbackBody"];
        infoModel.callbackContentType = dataDic[@"callbackContentType"];
        infoModel.ossEndpoint = dataDic[@"ossEndpoint"];
        infoModel.accessKeyId = dataDic[@"accessKeyId"];
        infoModel.accessKeySecret = dataDic[@"accessKeySecret"];
        infoModel.securityToken = dataDic[@"securityToken"];
        model.data = infoModel;
    }
    return model;
}

@end
