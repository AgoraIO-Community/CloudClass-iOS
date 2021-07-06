//
//  AgoraRTEJoinRoomModel.h
//  EduSDK
//
//  Created by SRS on 2020/7/20.
//  Copyright © 2020 agora. All rights reserved.
//

#import "AgoraRTEBaseModel.h"
#import <EduSDK/AgoraRTERoomModel.h>
#import <EduSDK/AgoraRTEUser.h>

NS_ASSUME_NONNULL_BEGIN

@interface AgoraRTEJoinUserModel : AgoraRTEUser
@property (nonatomic, strong) NSString *userToken;
@property (nonatomic, strong) NSString *rtmToken;
@property (nonatomic, strong) NSString *rtcToken;
@property (nonatomic, strong) NSArray *streams;
@end

@interface AgoraRTEJoinRoomInfoModel : NSObject
@property (nonatomic, strong) AgoraRTEJoinUserModel *user;
@property (nonatomic, strong) AgoraRTERoomDataModel *room;
@end

@interface AgoraRTEJoinRoomModel : NSObject <AgoraRTEBaseModel>
@property (nonatomic, strong) AgoraRTEJoinRoomInfoModel *data;
@property (nonatomic, assign) UInt64 ts;
@end

NS_ASSUME_NONNULL_END
