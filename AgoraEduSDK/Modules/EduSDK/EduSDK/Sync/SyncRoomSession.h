//
//  SyncRoomSession.h
//  EduSDK
//
//  Created by SRS on 2020/8/25.
//

#import <Foundation/Foundation.h>
#import "SyncRoomSessionModel.h"

typedef NS_ENUM(NSUInteger, SessionState) {
    SessionStateNone,
    SessionStateCreate,
    SessionStateDelete,
};
NS_ASSUME_NONNULL_BEGIN

@protocol SyncRoomSessionProtocol <NSObject>
// classroom
- (void)onRoomUpdateFrom:(id)originalRoom to:(id)currentRoom cause:(NSDictionary * _Nullable)cause;

// remote user
- (void)onRemoteUserInit:(NSArray *)users;
- (void)onRemoteUserInOut:(NSArray *)users state:(SessionState)state;
- (void)onRemoteUserUpdateFrom:(id)originalUser to:(id)currentUser;

// local user
- (void)onLocalUserInOut:(id)user state:(SessionState)state;
- (void)onLocalUserUpdateFrom:(id)originalUser to:(id)currentUser;

// remote stream
- (void)onRemoteStreamInit:(NSArray *)streams;
- (void)onRemoteStreamInOut:(NSArray *)streams state:(SessionState)state;
- (void)onRemoteStreamUpdateFrom:(NSArray *)originalStreams to:(NSArray *)currentStreams;

// local stream
- (void)onLocalStreamInit:(NSArray *)streams;
- (void)onLocalStreamInOut:(NSArray *)streams state:(SessionState)state;
- (void)onLocalStreamUpdateFrom:(NSArray *)originalStreams to:(NSArray *)currentStreams;

// other
- (void)onOtherUpdate:(id)obj;

@end

@interface SyncRoomSession<RoomT: BaseSnapshotRoomModel *,
                            UserT: BaseSnapshotUserModel *,
                            StreamT : BaseSnapshotStreamModel *> : NSObject

@property (nonatomic, weak) id<SyncRoomSessionProtocol> delegate;

@property (nonatomic, strong) RoomT room;
@property (nonatomic, strong) UserT localUser;
@property (nonatomic, strong) NSMutableArray<UserT> *users;
@property (nonatomic, strong) NSMutableArray<StreamT> *streams;

@property (nonatomic, assign, readonly) NSInteger currentMaxSeq;

@property (nonatomic, copy) void (^fetchMessageList)(NSInteger nextId, NSInteger count);

- (instancetype)initWithUserUuid:(NSString *)userUuid roomClass:(Class)roomClass useClass:(Class)userClass streamClass:(Class)streamClass;

- (void)syncSnapshot:(NSDictionary *)syncData complete:(void (^) (void))block;

- (void)updateRoom:(id)room sequence:(NSInteger)sequence cause:(NSDictionary * _Nullable )cause;
- (void)updateUser:(NSArray<UserT> *)users sequence:(NSInteger)sequence;
- (void)updateStream:(NSArray<StreamT> *)streams sequence:(NSInteger)sequence;
- (void)updateOther:(id)value sequence:(NSInteger)sequence;

- (void)getStreamsInQueue:(void (^) (NSArray<StreamT> *))block;
- (void)getUsersInQueue:(void (^) (NSArray<UserT> *))block;
- (void)getRoomInQueue:(void (^) (RoomT))block;
@end

NS_ASSUME_NONNULL_END
