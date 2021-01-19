//
//  EduChannelMsgUserInfo.h
//  EduSDK
//
//  Created by SRS on 2020/7/26.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SyncRoomSessionModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface EduChannelMsgUserInfo : BaseSnapshotUserModel
@property (nonatomic, assign) NSInteger muteChat;
@property (nonatomic, strong) BaseUserModel *opr;
@end

NS_ASSUME_NONNULL_END
