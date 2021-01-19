//
//  RoomModel.h
//  EduSDK
//
//  Created by SRS on 2020/7/21.
//  Copyright © 2020 agora. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RoomInfoModel : NSObject
@property (nonatomic, strong) NSString *roomUuid;
@property (nonatomic, strong) NSString *roomName;
@end

@interface RoomMuteStateModel : NSObject
@property (nonatomic, assign) NSInteger administrator;
@property (nonatomic, assign) NSInteger host;
@property (nonatomic, assign) NSInteger assistant;
@property (nonatomic, assign) NSInteger broadcaster;
@property (nonatomic, assign) NSInteger audience;
@end

@interface RoomStateModel : NSObject
@property (nonatomic, assign) NSInteger state;//0未开始 1开始 2结束
@property (nonatomic, assign) NSInteger startTime;
@property (nonatomic, strong) RoomMuteStateModel *muteChat;
@property (nonatomic, strong) RoomMuteStateModel *muteAudio;
@property (nonatomic, strong) RoomMuteStateModel *muteVideo;
@end

@interface RoomDataModel : NSObject
@property (nonatomic, strong) RoomInfoModel *roomInfo;
@property (nonatomic, strong) RoomStateModel *roomState;
@property (nonatomic, strong) NSDictionary *roomProperties;
@end

@interface RoomModel : NSObject <BaseModel>
@property (nonatomic, strong) RoomDataModel *data;
@end

NS_ASSUME_NONNULL_END

