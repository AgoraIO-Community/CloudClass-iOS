//
//  HTTPManager.h
//  AgoraEducation
//
//  Created by SRS on 2020/8/2.
//  Copyright © 2020 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AgoraHTTPConfiguration.h"
#import "AgoraBoardModel.h"
#import "AgoraRecordModel.h"
#import "AgoraAssignGroupModel.h"
#import "AgoraSchduleModel.h"
#import "AgoraHttpModel.h"

typedef NS_ENUM(NSInteger, HttpType) {
    HttpTypeGet            = 0,
    HttpTypePost,
    HttpTypePut,
    HttpTypeDelete,
    HttpTypeDeleteBody,
};

// GET /edu/apps/{appId}/v2/configs
#define HTTP_APP_CONFIG @"%@/edu/apps/%@/v2/configs"

// PUT /edu/apps/{appId}/v2/rooms/{roomUuid}/users/{userUuid}
#define HTTP_APP_ROOM_STATE @"%@/edu/apps/%@/v2/rooms/%@/users/%@"

// POST /edu/apps/{appId}/v2/rooms/{roomUuid}/from/{userUuid}/chat
#define HTTP_APP_ROOM_CHAT @"%@/edu/apps/%@/v2/rooms/%@/from/%@/chat"

// POST /edu/apps/{appId}/v2/rooms/{roomUuid}/conversation/students/{studentUuid}/messages
#define HTTP_APP_CONVERSATION_CHAT @"%@/edu/apps/%@/v2/rooms/%@/conversation/students/%@/messages"

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
typedef void(^OnBoardInfoGetSuccessBlock)(AgoraBoardModel * _Nonnull boardModel);
// RecordInfo
typedef void(^OnRecordInfoGetSuccessBlock)(AgoraRecordModel * _Nonnull recordModel);
// AssignGroupInfo
typedef void(^OnAssignBreakOutGroupSuccessBlock)(AgoraAssignGroupModel * _Nonnull assignGroupModel);
// SchduleClassInfo
typedef void(^OnSchduleClassSuccessBlock)(AgoraSchduleModel * _Nonnull schduleModel);

NS_ASSUME_NONNULL_BEGIN

@interface AgoraHTTPManager : NSObject
#pragma mark Config
+ (void)setBaseURL:(NSString *)url;
+ (NSString *)getBaseURL;

#pragma mark App
+ (void)getConfig:(AgoraRoomConfiguration *)config
          success:(OnConfigSuccessBlock)successBlock
          failure:(OnHttpFailureBlock)failureBlock;

+ (void)roomStateWithConfig:(AgoraRoomStateConfiguration *)config
                    success:(OnRoomStateSuccessBlock)successBlock
                    failure:(OnHttpFailureBlock)failureBlock;

+ (void)roomChatWithConfig:(AgoraRoomChatConfiguration *)config
                   success:(OnRoomChatSuccessBlock)successBlock
                   failure:(OnHttpFailureBlock)failureBlock;

+ (void)conversationChatWithConfig:(AgoraRoomChatConfiguration *)config
                           success:(OnRoomChatSuccessBlock)successBlock
                           failure:(OnHttpFailureBlock)failureBlock;

+ (void)handUpWithConfig:(AgoraHandUpConfiguration *)config
                 success:(OnHandUpSuccessBlock)successBlock
                 failure:(OnHttpFailureBlock)failureBlock;

#pragma mark Module
+ (void)getBoardInfoWithConfig:(AgoraBoardInfoConfiguration *)config
                       success:(OnBoardInfoGetSuccessBlock)successBlock
                       failure:(OnHttpFailureBlock)failureBlock;

+ (void)getRecordInfoWithConfig:(AgoraRecordInfoConfiguration *)config
                        success:(OnRecordInfoGetSuccessBlock)successBlock
                        failure:(OnHttpFailureBlock)failureBlock;

+ (void)assignBreakOutGroupWithConfig:(AgoraAssignGroupInfoConfiguration *)config
                              success:(OnAssignBreakOutGroupSuccessBlock)successBlock
                              failure:(OnHttpFailureBlock)failureBlock;

#pragma mark Common
+ (NSDictionary *)headersWithUId:(NSString *)uId
                       userToken:(NSString *)userToken
                           token:(NSString *)token;

+ (void)fetchDispatch:(HttpType)type
                  url:(NSString *)url
           parameters:(NSDictionary *)parameters
              headers:(NSDictionary *)headers
           parseClass:(Class)classType
              success:(OnHttpSuccessBlock)successBlock
              failure:(OnHttpFailureBlock)failureBlock;
@end

NS_ASSUME_NONNULL_END
