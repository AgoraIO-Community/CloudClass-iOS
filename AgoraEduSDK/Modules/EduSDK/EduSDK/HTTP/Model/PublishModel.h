//
//  PublishModel.h
//  EduSDK
//
//  Created by SRS on 2020/7/28.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PublishInfoModel : NSObject
@property (nonatomic, strong) NSString *streamUuid;
@property (nonatomic, strong) NSString *rtcToken;
@end

@interface PublishModel : NSObject <BaseModel>
@property (nonatomic, strong) PublishInfoModel *data;
@end

NS_ASSUME_NONNULL_END
