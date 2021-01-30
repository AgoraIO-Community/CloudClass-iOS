//
//  AgoraAssignGroupModel.h
//  AgoraEducation
//
//  Created by SRS on 2020/9/9.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AgoraHttpModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AgoraAssignGroupDataModel : NSObject
@property (nonatomic, strong) NSString *roomUuid;
@property (nonatomic, strong) NSString *roomName;
@property (nonatomic, assign) NSInteger memberLimit;
@end

@interface AgoraAssignGroupModel : AgoraBaseModel
@property (nonatomic, strong) AgoraAssignGroupDataModel *data;
@end

NS_ASSUME_NONNULL_END
