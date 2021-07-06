//
//  AgoraRTERoomModel.h
//  EduSDK
//
//  Created by SRS on 2020/7/21.
//  Copyright © 2020 agora. All rights reserved.
//

#import "AgoraRTEBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AgoraRTERoomInfoModel : NSObject
@property (nonatomic, strong) NSString *roomUuid;
@property (nonatomic, strong) NSString *roomName;
@end

@interface AgoraRTERoomMuteStateModel : NSObject
@property (nonatomic, assign) NSInteger administrator;
@property (nonatomic, assign) NSInteger host;
@property (nonatomic, assign) NSInteger assistant;
@property (nonatomic, assign) NSInteger broadcaster;
@property (nonatomic, assign) NSInteger audience;
@end

@interface AgoraRTERoomStateModel : NSObject
@property (nonatomic, assign) NSInteger state;//0未开始 1开始 2结束
@property (nonatomic, assign) NSInteger startTime;
@property (nonatomic, assign) UInt64 createTime;
@property (nonatomic, strong) AgoraRTERoomMuteStateModel *muteChat;
@property (nonatomic, strong) AgoraRTERoomMuteStateModel *muteAudio;
@property (nonatomic, strong) AgoraRTERoomMuteStateModel *muteVideo;
@end

@interface AgoraRTERoomDataModel : NSObject
@property (nonatomic, strong) AgoraRTERoomInfoModel *roomInfo;
@property (nonatomic, strong) AgoraRTERoomStateModel *roomState;
@property (nonatomic, strong) NSDictionary *roomProperties;
@end

@interface AgoraRTERoomModel : NSObject <AgoraRTEBaseModel>
@property (nonatomic, strong) AgoraRTERoomDataModel *data;
@end

NS_ASSUME_NONNULL_END

