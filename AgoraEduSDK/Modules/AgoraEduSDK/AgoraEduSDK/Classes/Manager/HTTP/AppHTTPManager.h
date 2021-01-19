//
//  HTTPManager.h
//  AgoraEducation
//
//  Created by SRS on 2020/8/2.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "HTTPConfiguration.h"
#import "BoardModel.h"
#import "RecordModel.h"
#import "AssignGroupModel.h"
#import "SchduleModel.h"
#import "HttpAppModel.h"

// GET /edu/apps/{appId}/v2/configs
#define HTTP_APP_CONFIG @"%@/edu/apps/%@/v2/configs"

// PUT /edu/apps/{appId}/v2/rooms/{roomUuid}/users/{userUuid}
#define HTTP_APP_ROOM_STATE @"%@/edu/apps/%@/v2/rooms/%@/users/%@"

// POST /edu/apps/{appId}/v2/rooms/{roomUuid}/from/{userUuid}/chat
#define HTTP_APP_ROOM_CHAT @"%@/edu/apps/%@/v2/rooms/%@/from/%@/chat"

// POST /edu/apps/{appId}/v2/rooms/{roomUuid}/handup/{toUserUuid}
#define HTTP_APP_HANDUP @"%@/edu/apps/%@/v2/rooms/%@/handup/%@"

//==============================================================
// /scene/apps/{appId}/v1/rooms/{roomUuid}/config
#define HTTP_SCHDULE_CLASS @"%@/scene/apps/%@/v1/rooms/%@/config"

// /grouping/apps/{appId}/v1/rooms/{roomUuid}/groups
#define HTTP_BREAKOUT_GROUP_ROOM @"%@/grouping/apps/%@/v1/rooms/%@/groups"

// /board/apps/{appId}/v1/rooms/{roomUuid}
#define HTTP_BOARD_INFO @"%@/board/apps/%@/v1/rooms/%@"

// /recording/apps/{appId}/v1/rooms/{roomId}/records
#define HTTP_RECORD_INFO @"%@/recording/apps/%@/v1/rooms/%@/records"

typedef void(^OnHttpFailureBlock)(NSError * _Nonnull error, NSInteger statusCode);
typedef void(^OnHttpSuccessBlock)(id _Nonnull model);

// BoardInfo
typedef void(^OnBoardInfoGetSuccessBlock)(BoardModel * _Nonnull boardModel);
// RecordInfo
typedef void(^OnRecordInfoGetSuccessBlock)(RecordModel * _Nonnull recordModel);
// AssignGroupInfo
typedef void(^OnAssignBreakOutGroupSuccessBlock)(AssignGroupModel * _Nonnull assignGroupModel);
// SchduleClassInfo
typedef void(^OnSchduleClassSuccessBlock)(SchduleModel * _Nonnull schduleModel);

NS_ASSUME_NONNULL_BEGIN

@interface AppHTTPManager : NSObject
#pragma mark Config
+ (void)setBaseURL:(NSString *)url;

#pragma mark App
+ (void)getConfig:(RoomConfiguration *)config success:(OnConfigSuccessBlock)successBlock failure:(OnHttpFailureBlock)failureBlock;
+ (void)roomStateWithConfig:(RoomStateConfiguration *)config  success:(OnRoomStateSuccessBlock)successBlock failure:(OnHttpFailureBlock)failureBlock;
+ (void)roomChatWithConfig:(RoomChatConfiguration *)config  success:(OnRoomChatSuccessBlock)successBlock failure:(OnHttpFailureBlock)failureBlock;
+ (void)handUpWithConfig:(HandUpConfiguration *)config  success:(OnHandUpSuccessBlock)successBlock failure:(OnHttpFailureBlock)failureBlock;

#pragma mark Module
+ (void)getBoardInfoWithConfig:(BoardInfoConfiguration *)config  success:(OnBoardInfoGetSuccessBlock)successBlock failure:(OnHttpFailureBlock)failureBlock;

+ (void)getRecordInfoWithConfig:(RecordInfoConfiguration *)config  success:(OnRecordInfoGetSuccessBlock)successBlock failure:(OnHttpFailureBlock)failureBlock;

+ (void)assignBreakOutGroupWithConfig:(AssignGroupInfoConfiguration *)config  success:(OnAssignBreakOutGroupSuccessBlock)successBlock failure:(OnHttpFailureBlock)failureBlock;

@end

NS_ASSUME_NONNULL_END
