//
//  RecordModel.m
//  AgoraEducation
//
//  Created by SRS on 2020/8/4.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import "RecordModel.h"

@implementation RecordDetailsModel
@end

@implementation RecordInfoModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"recordDetails" : [RecordDetailsModel class]};
}
@end

@implementation RecordDataModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"list" : [RecordInfoModel class]};
}
@end

@implementation RecordModel
@end
