//
//  AgoraRTEChannelMsgRoomMute.h
//  EduSDK
//
//  Created by SRS on 2020/7/23.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AgoraRTEUser.h"
#import "AgoraRTESyncRoomSessionModel.h"

@class AgoraRTERoomMuteStateModel;
@class AgoraRTEBaseSnapshotUserModel;

NS_ASSUME_NONNULL_BEGIN

@interface AgoraRTEChannelMsgRoomMute : NSObject
@property (nonatomic, strong) AgoraRTERoomMuteStateModel *muteChat;
@property (nonatomic, strong) AgoraRTERoomMuteStateModel *muteVideo;
@property (nonatomic, strong) AgoraRTERoomMuteStateModel *muteAudio;
@property (nonatomic, strong) AgoraRTEBaseSnapshotUserModel *opr;
@end

NS_ASSUME_NONNULL_END
