//
//  AgoraRTEChannelMsgRoomCourse.h
//  EduSDK
//
//  Created by SRS on 2020/7/26.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AgoraRTESyncRoomSessionModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AgoraRTEChannelMsgRoomCourse : AgoraRTEBaseSnapshotRoomModel
@property (nonatomic, assign) NSInteger state; //房间状态 1开始 0结束
@property (nonatomic, assign) NSInteger startTime;
@property (nonatomic, strong) AgoraRTEBaseSnapshotUserModel *opr;
@end

NS_ASSUME_NONNULL_END
