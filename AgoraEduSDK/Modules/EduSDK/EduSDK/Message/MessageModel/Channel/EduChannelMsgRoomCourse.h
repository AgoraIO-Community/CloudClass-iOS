//
//  EduChannelMsgRoomCourse.h
//  EduSDK
//
//  Created by SRS on 2020/7/26.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SyncRoomSessionModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface EduChannelMsgRoomCourse : NSObject
@property (nonatomic, assign) NSInteger state; //房间状态 1开始 0结束
@property (nonatomic, assign) NSInteger startTime;
@property (nonatomic, strong) BaseSnapshotUserModel *opr;
@end

NS_ASSUME_NONNULL_END
