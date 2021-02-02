//
//  AgoraBoardModel.h
//  AgoraEducation
//
//  Created by SRS on 2020/8/2.
//  Copyright © 2020 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AgoraHttpModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AgoraBoardInfoModel : NSObject
@property (nonatomic, strong) NSString *boardId;
@property (nonatomic, strong) NSString *boardToken;
@end

@interface AgoraBoardDataModel : NSObject
@property (nonatomic, strong) AgoraBoardInfoModel *info;
@end

@interface AgoraBoardModel : AgoraBaseModel
@property (nonatomic, strong) AgoraBoardDataModel *data;
@end

NS_ASSUME_NONNULL_END
