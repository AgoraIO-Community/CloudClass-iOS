//
//  EduSyncRoomModel.h
//  EduSDK
//
//  Created by SRS on 2020/8/31.
//

#import <Foundation/Foundation.h>
#import "EduClassroom.h"
#import "SyncRoomSessionModel.h"
#import "EduUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface EduSyncRoomInfoModel : NSObject
@property (nonatomic, strong) NSString *roomUuid;
@property (nonatomic, strong) NSString *roomName;
@end

@interface EduSyncRoomStateModel : NSObject
@property (nonatomic, assign) NSInteger courseState;
@property (nonatomic, assign) NSInteger startTime;
@property (nonatomic, assign) BOOL isStudentChatAllowed;
@property (nonatomic, assign) NSInteger onlineUserCount;

@property (nonatomic, strong) BaseUserModel * _Nullable operator;
@end

@interface EduSyncRoomModel : BaseSnapshotRoomModel
@property (nonatomic, strong) NSDictionary *roomProperties;
@property (nonatomic, strong) EduSyncRoomInfoModel *roomInfo;
@property (nonatomic, strong) EduSyncRoomStateModel *roomState;

- (EduClassroom *)mapEduClassroom:(NSInteger)count;
- (EduUser * _Nullable)mapOpratorEduUser;

@end

@interface EduSyncRoomPropertiesModel : BaseSnapshotRoomModel

@property (nonatomic, assign) NSInteger action;//1 upsert 2.delete
@property (nonatomic, strong) NSDictionary *changeProperties;
@property (nonatomic, strong) NSDictionary *cause;
//@property (nonatomic, strong) EduBaseUser *operator;

@end

NS_ASSUME_NONNULL_END
