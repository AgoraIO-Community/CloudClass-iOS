//
//  EduChannelMsgUsersInOut.h
//  EduSDK
//
//  Created by SRS on 2020/7/22.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EduSyncUserModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface EduChannelMsgUsersInOut : NSObject
@property (nonatomic, assign) NSInteger total;
@property (nonatomic, strong) NSArray<EduSyncUserModel*> *onlineUsers;
@property (nonatomic, strong) NSArray<EduSyncUserModel*> *offlineUsers;
@end

NS_ASSUME_NONNULL_END
