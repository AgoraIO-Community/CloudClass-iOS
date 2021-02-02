//
//  AgoraHttpModel.h
//  AgoraEduSDK
//
//  Created by SRS on 2021/1/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface AgoraBaseModel : NSObject
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, strong) NSString *msg;

@property (nonatomic, strong) NSString *message;
@end

@interface AgoraRoomStateAgoraBoardModel : NSObject
@property (nonatomic, strong) NSString *boardId;
@property (nonatomic, strong) NSString *boardToken;
@end
@interface AgoraRoomStateInfoModel : NSObject
@property (nonatomic, assign) NSInteger state;//0未开始 1开始 2结束
@property (nonatomic, assign) NSInteger recordState;//录制状态 1录制中 0未录制
@property (nonatomic, assign) NSInteger muteChat;//禁用聊天 1是 0否
@property (nonatomic, strong) AgoraRoomStateAgoraBoardModel *board;
@end
@interface AgoraRoomStateModel : AgoraBaseModel
@property (nonatomic, strong) AgoraRoomStateInfoModel *data;
@end

@interface AgoraBoardConfigInfoModel : NSObject
@property (nonatomic, strong) NSString *appId;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSDictionary *oss;
@end
@interface AgoraConfigInfoModel : NSObject
@property (nonatomic, strong) AgoraBoardConfigInfoModel *netless;
@end
@interface AgoraConfigModel : AgoraBaseModel
@property (nonatomic, strong) AgoraConfigInfoModel *data;
@end

@interface AgoraHandUpModel : AgoraBaseModel
@property (nonatomic, assign) NSInteger data;
@end

typedef void(^OnRoomStateSuccessBlock)(AgoraRoomStateModel * _Nonnull model);
typedef void(^OnRoomChatSuccessBlock)(AgoraBaseModel * _Nonnull model);
typedef void(^OnConfigSuccessBlock)(AgoraConfigModel * _Nonnull model);
typedef void(^OnHandUpSuccessBlock)(AgoraHandUpModel * _Nonnull model);

NS_ASSUME_NONNULL_END
