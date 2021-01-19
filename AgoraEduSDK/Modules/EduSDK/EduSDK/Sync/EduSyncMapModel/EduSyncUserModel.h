//
//  EduSyncUserModel.h
//  EduSDK
//
//  Created by SRS on 2020/8/31.
//

#import <Foundation/Foundation.h>
#import "SyncRoomSessionModel.h"
#import "EduUser.h"
#import "EduSyncStreamModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface EduSyncUserModel : BaseSnapshotUserModel

@property (nonatomic, strong) NSString *userToken;
@property (nonatomic, strong) NSString *streamUuid;
@property (nonatomic, assign) BOOL isChatAllowed;
@property (nonatomic, strong) NSDictionary *userProperties;
@property (nonatomic, strong) NSDictionary *cause;
@property (nonatomic, assign) NSInteger type;

@property (nonatomic, strong) BaseUserModel * _Nullable operator;

- (EduUser *)mapEduUser;
- (EduBaseUser *)mapEduBaseUser;
- (EduLocalUser *)mapEduLocalUser;
- (EduUserEvent *)mapEduUserEvent;

@end

NS_ASSUME_NONNULL_END
