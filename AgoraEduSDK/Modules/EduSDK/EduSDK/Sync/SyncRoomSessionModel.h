//
//  SyncRoomSessionModel.h
//  EduSDK
//
//  Created by SRS on 2020/8/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseUserModel : NSObject
@property (nonatomic, strong) NSString *userUuid;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *role;
@end

@interface BaseSnapshotUserModel : BaseUserModel
@property (nonatomic, assign) NSInteger state;
@property (nonatomic, strong) NSArray *streams;
@end

@interface BaseSnapshotStreamModel : NSObject
@property (nonatomic, strong) NSString *streamUuid;
@property (nonatomic, assign) NSInteger state;
@property (nonatomic, strong) BaseUserModel *fromUser;
@end

@interface BaseSnapshotRoomModel : NSObject
@end

@interface SnapshotModel : NSObject
@property (nonatomic, strong) NSDictionary *room;
@property (nonatomic, strong) NSArray *users;
@end
 
@interface RoomSessionDataModel : NSObject
@property (nonatomic, assign) NSInteger sequence;
@property (nonatomic, strong) SnapshotModel *snapshot;
@end

@interface CacheRoomSessionModel : NSObject
@property (nonatomic, assign) NSInteger sequence;
@property (nonatomic, strong) id value;
@property (nonatomic, strong) NSDictionary *_Nullable cause;
@end

NS_ASSUME_NONNULL_END
