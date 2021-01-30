//
//  AgoraRTEChannelMsgUserInfo.h
//  EduSDK
//
//  Created by SRS on 2020/7/26.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AgoraRTESyncRoomSessionModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AgoraRTEChannelMsgUserInfo : AgoraRTEBaseSnapshotUserModel
@property (nonatomic, assign) NSInteger muteChat;
@property (nonatomic, strong) AgoraRTEBaseUserModel *opr;
@end

NS_ASSUME_NONNULL_END
