//
//  EduChannelMessageHandle.h
//  EduSDK
//
//  Created by SRS on 2020/8/31.
//

#import <Foundation/Foundation.h>
#import "EduMessageHandle.h"

typedef NS_ENUM(NSUInteger, StreamAction) {
    StreamCreate,
    StreamUpdate,
    StreamDelete,
};

NS_ASSUME_NONNULL_BEGIN

@interface EduChannelMessageHandle : EduMessageHandle

@property (nonatomic, strong) SyncRoomSession *syncRoomSession;

@property (nonatomic, weak) id<EduUserDelegate> userDelegate;
@property (nonatomic, weak) id<EduClassroomDelegate> roomDelegate;

// state:0=remove 1=add/update
@property (nonatomic, copy) void (^checkAutoSubscribe)(NSArray<EduStream *> *streams, BOOL state);
@property (nonatomic, copy) void (^checkStreamPublish)(EduStream *stream, StreamAction action);

- (instancetype)initWithSyncSession:(SyncRoomSession *)syncRoomSession;

- (MessageHandleCode)didReceivedChannelMsg:(id)obj;

@end

NS_ASSUME_NONNULL_END
