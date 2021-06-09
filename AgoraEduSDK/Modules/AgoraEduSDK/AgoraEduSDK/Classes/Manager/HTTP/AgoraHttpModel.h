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
@property (nonatomic, assign) NSInteger ts;

// router
@property (nonatomic, strong) NSString *message;
@end

@interface AgoraRoomStateAgoraBoardModel : NSObject
@property (nonatomic, strong) NSString *boardId;
@property (nonatomic, strong) NSString *boardToken;
@end
@interface AgoraRoomStateInfoModel : NSObject
@property (nonatomic, assign) NSInteger state;//0未开始 1开始 2结束
@property (nonatomic, assign) NSInteger startTime; // 开始时间(ms)
@property (nonatomic, assign) NSInteger duration; // 持续多长时间(s)
@property (nonatomic, assign) NSInteger closeDelay; // 结束后延迟关闭教室（秒）
@property (nonatomic, assign) NSInteger recordState;//录制状态 1录制中 0未录制
@property (nonatomic, assign) NSInteger lastMessageId;//历史消息最新的lastMessageId
@property (nonatomic, assign) NSInteger muteChat;//禁用聊天 1是 0否
@property (nonatomic, strong) AgoraRoomStateAgoraBoardModel *board;
@end
@interface AgoraRoomStateModel : AgoraBaseModel
@property (nonatomic, strong) AgoraRoomStateInfoModel *data;
@end

@interface AgoraChatModel : AgoraBaseModel
@property (nonatomic, assign) NSInteger messageId;
@property (nonatomic, strong) NSString *peerMessageId;
@property (nonatomic, strong) NSArray<NSString *> *sensitiveWords;
@end

@interface AgoraBoardConfigInfoModel : NSObject
@property (nonatomic, strong) NSString *appId;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSDictionary *oss;
@end
@interface AgoraConfigInfoModel : NSObject
@property (nonatomic, strong) AgoraBoardConfigInfoModel *netless;
@property (nonatomic, assign) SInt32 vid;
@end
@interface AgoraConfigModel : AgoraBaseModel
@property (nonatomic, strong) AgoraConfigInfoModel *data;
@end

@interface AgoraHandUpModel : AgoraBaseModel
@property (nonatomic, assign) NSInteger data;
@end

typedef void(^OnRoomStateSuccessBlock)(AgoraRoomStateModel * _Nonnull model);
typedef void(^OnRoomChatSuccessBlock)(AgoraChatModel * _Nonnull model);
typedef void(^OnConfigSuccessBlock)(AgoraConfigModel * _Nonnull model);
typedef void(^OnHandUpSuccessBlock)(AgoraHandUpModel * _Nonnull model);

NS_ASSUME_NONNULL_END
