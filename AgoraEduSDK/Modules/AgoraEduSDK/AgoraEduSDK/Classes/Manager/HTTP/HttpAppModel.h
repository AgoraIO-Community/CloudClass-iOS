//
//  HttpAppModel.h
//  AgoraEduSDK
//
//  Created by SRS on 2021/1/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface AppBaseModel : NSObject
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, strong) NSString *msg;

@property (nonatomic, strong) NSString *message;
@end

@interface AppRoomStateBoardModel : NSObject
@property (nonatomic, strong) NSString *boardId;
@property (nonatomic, strong) NSString *boardToken;
@end
@interface AppRoomStateInfoModel : NSObject
@property (nonatomic, assign) NSInteger state;//0未开始 1开始 2结束
@property (nonatomic, assign) NSInteger recordState;//录制状态 1录制中 0未录制
@property (nonatomic, assign) NSInteger muteChat;//禁用聊天 1是 0否
@property (nonatomic, strong) AppRoomStateBoardModel *board;
@end
@interface AppRoomStateModel : AppBaseModel
@property (nonatomic, strong) AppRoomStateInfoModel *data;
@end

@interface AppBoardConfigInfoModel : NSObject
@property (nonatomic, strong) NSString *appId;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSDictionary *oss;
@end
@interface AppConfigInfoModel : NSObject
@property (nonatomic, strong) AppBoardConfigInfoModel *netless;
@end
@interface AppConfigModel : AppBaseModel
@property (nonatomic, strong) AppConfigInfoModel *data;
@end

@interface AppHandUpModel : AppBaseModel
@property (nonatomic, assign) NSInteger data;
@end

typedef void(^OnRoomStateSuccessBlock)(AppRoomStateModel * _Nonnull model);
typedef void(^OnRoomChatSuccessBlock)(AppBaseModel * _Nonnull model);
typedef void(^OnConfigSuccessBlock)(AppConfigModel * _Nonnull model);
typedef void(^OnHandUpSuccessBlock)(AppHandUpModel * _Nonnull model);

NS_ASSUME_NONNULL_END
