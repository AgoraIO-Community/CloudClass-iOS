//
//  AgoraRecordModel.m
//  AgoraEducation
//
//  Created by SRS on 2020/8/4.
//  Copyright © 2020 Agora. All rights reserved.
//

#import "AgoraRecordModel.h"

@implementation AgoraRecordDetailsModel
@end

@implementation AgoraRecordInfoModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"recordDetails" : [AgoraRecordDetailsModel class]};
}
@end

@implementation AgoraRecordDataModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"list" : [AgoraRecordInfoModel class]};
}
@end

@implementation AgoraRecordModel
@end
