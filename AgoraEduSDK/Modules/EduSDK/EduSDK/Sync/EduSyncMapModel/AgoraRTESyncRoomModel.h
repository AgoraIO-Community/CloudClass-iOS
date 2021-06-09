//
//  AgoraRTESyncRoomModel.h
//  EduSDK
//
//  Created by SRS on 2020/8/31.
//

#import <Foundation/Foundation.h>
#import "AgoraRTEClassroom.h"
#import "AgoraRTESyncRoomSessionModel.h"
#import "AgoraRTEUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface AgoraRTESyncRoomInfoModel : NSObject
@property (nonatomic, strong) NSString *roomUuid;
@property (nonatomic, strong) NSString *roomName;
@end

@interface AgoraRTESyncRoomStateModel : NSObject
@property (nonatomic, assign) NSInteger courseState;
@property (nonatomic, assign) NSInteger startTime;
@property (nonatomic, assign) BOOL isStudentChatAllowed;
@property (nonatomic, assign) NSInteger onlineUserCount;

@property (nonatomic, strong) AgoraRTEBaseUserModel * _Nullable operator;
@end

@interface AgoraRTESyncRoomModel : AgoraRTEBaseSnapshotRoomModel
@property (nonatomic, strong) NSDictionary *roomProperties;
@property (nonatomic, strong) AgoraRTESyncRoomInfoModel *roomInfo;
@property (nonatomic, strong) AgoraRTESyncRoomStateModel *roomState;

- (AgoraRTEClassroom *)mapAgoraRTEClassroom:(NSInteger)count;
- (AgoraRTEUser * _Nullable)mapOpratorAgoraRTEUser;

@end

@interface AgoraRTESyncRoomPropertiesModel : AgoraRTEBaseSnapshotRoomModel

@property (nonatomic, assign) NSInteger action;//1 upsert 2.delete
@property (nonatomic, strong) NSDictionary *changeProperties;
@property (nonatomic, strong) NSDictionary *cause;
@property (nonatomic, strong) AgoraRTEBaseUser *operator;

@end

NS_ASSUME_NONNULL_END
