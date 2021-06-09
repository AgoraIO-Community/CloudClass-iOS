//
//  AgoraRTESyncRoomSession.h
//  EduSDK
//
//  Created by SRS on 2020/8/25.
//

#import <Foundation/Foundation.h>
#import "AgoraRTESyncRoomSessionModel.h"
#import "AgoraRTESyncRoomModel.h"
#import "AgoraRTESyncUserModel.h"
#import "AgoraRTESyncStreamModel.h"
#import "AgoraRTEChannelMsgRoomCourse.h"
#import "AgoraRTEChannelMsgRoomMute.h"
#import "AgoraRTEChannelMsgUsersProperty.h"
#import "AgoraRTEChannelMsgUserInfo.h"

typedef NS_ENUM(NSUInteger, AgoraRTESessionState) {
    AgoraRTESessionStateNone,
    AgoraRTESessionStateCreate,
    AgoraRTESessionStateDelete,
};
NS_ASSUME_NONNULL_BEGIN

@protocol AgoraRTESyncRoomSessionProtocol <NSObject>
// classroom
- (void)onRoomUpdateFrom:(AgoraRTESyncRoomModel *)originalRoom
                      to:(AgoraRTESyncRoomModel *)currentRoom
                   model:(id)model;

// remote user
- (void)onRemoteUserInit:(NSArray *)users;
- (void)onRemoteUserInOut:(NSArray *)users state:(AgoraRTESessionState)state;
- (void)onRemoteUserUpdateFrom:(id)originalUser
                            to:(id)currentUser
                         model:(AgoraRTEChannelMsgUsersProperty *)model;

// local user
- (void)onLocalUserInOut:(id)user state:(AgoraRTESessionState)state;
- (void)onLocalUserUpdateFrom:(id)originalUser
                           to:(id)currentUser
                        model:(id)model;

// remote stream
- (void)onRemoteStreamInit:(NSArray *)streams;
- (void)onRemoteStreamInOut:(NSArray *)streams state:(AgoraRTESessionState)state;
- (void)onRemoteStreamUpdateFrom:(NSArray *)originalStreams to:(NSArray *)currentStreams;

// local stream
- (void)onLocalStreamInit:(NSArray *)streams;
- (void)onLocalStreamInOut:(NSArray *)streams state:(AgoraRTESessionState)state;
- (void)onLocalStreamUpdateFrom:(NSArray *)originalStreams to:(NSArray *)currentStreams;

// other
- (void)onOtherUpdate:(id)obj;

@end

@interface AgoraRTESyncRoomSession<RoomT: AgoraRTESyncRoomModel *,
                            UserT: AgoraRTESyncUserModel *,
                            StreamT : AgoraRTESyncStreamModel *> : NSObject

@property (nonatomic, weak) id<AgoraRTESyncRoomSessionProtocol> delegate;

@property (nonatomic, strong) RoomT room;
@property (nonatomic, strong) UserT localUser;
@property (nonatomic, strong) NSMutableArray<UserT> *users;
@property (nonatomic, strong) NSMutableArray<StreamT> *streams;

@property (nonatomic, assign, readonly) NSInteger currentMaxSeq;

@property (nonatomic, copy) void (^fetchMessageList)(NSInteger nextId, NSInteger count);

- (instancetype)initWithUserUuid:(NSString *)userUuid roomClass:(Class)roomClass useClass:(Class)userClass streamClass:(Class)streamClass;

- (void)syncSnapshot:(NSDictionary *)syncData complete:(void (^) (void))block;

// course/chat/property
- (void)updateRoom:(id)obj sequence:(NSInteger)sequence cause:(NSDictionary * _Nullable )cause;
// users[inout、chat]/property
- (void)updateUser:(id)obj sequence:(NSInteger)sequence cause:(NSDictionary *)cause;
- (void)updateStream:(NSArray<StreamT> *)streams sequence:(NSInteger)sequence;
- (void)updateOther:(id)value sequence:(NSInteger)sequence;

- (void)getStreamsInQueue:(void (^) (NSArray<StreamT> *))block;
- (void)getUsersInQueue:(void (^) (NSArray<UserT> *))block;
- (void)getRoomInQueue:(void (^) (RoomT))block;
@end

NS_ASSUME_NONNULL_END
