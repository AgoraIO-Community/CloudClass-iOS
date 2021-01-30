//
//  AgoraRTEChannelMsgUsersInOut.h
//  EduSDK
//
//  Created by SRS on 2020/7/22.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AgoraRTESyncUserModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AgoraRTEChannelMsgUsersInOut : NSObject
@property (nonatomic, assign) NSInteger total;
@property (nonatomic, strong) NSArray<AgoraRTESyncUserModel*> *onlineUsers;
@property (nonatomic, strong) NSArray<AgoraRTESyncUserModel*> *offlineUsers;
@end

NS_ASSUME_NONNULL_END
