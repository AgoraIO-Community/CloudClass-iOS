//
//  AgoraRTESyncRoomSessionModel.h
//  EduSDK
//
//  Created by SRS on 2020/8/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AgoraRTEBaseUserModel : NSObject
@property (nonatomic, strong) NSString *userUuid;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *role;
@end

@interface AgoraRTEBaseSnapshotUserModel : AgoraRTEBaseUserModel
@property (nonatomic, assign) NSInteger state;
@property (nonatomic, strong) NSArray *streams;
@end

@interface AgoraRTEBaseSnapshotStreamModel : NSObject
@property (nonatomic, strong) NSString *streamUuid;
@property (nonatomic, assign) NSInteger state;
@property (nonatomic, strong) AgoraRTEBaseUserModel *fromUser;
@end

@interface AgoraRTEBaseSnapshotRoomModel : NSObject
@end

@interface AgoraRTESnapshotModel : NSObject
@property (nonatomic, strong) NSDictionary *room;
@property (nonatomic, strong) NSArray *users;
@end
 
@interface AgoraRTERoomSessionDataModel : NSObject
@property (nonatomic, assign) NSInteger sequence;
@property (nonatomic, strong) AgoraRTESnapshotModel *snapshot;
@end

@interface AgoraRTECacheRoomSessionModel : NSObject
@property (nonatomic, assign) NSInteger sequence;
@property (nonatomic, strong) id value;
@property (nonatomic, strong) NSDictionary *_Nullable cause;
@end

NS_ASSUME_NONNULL_END
