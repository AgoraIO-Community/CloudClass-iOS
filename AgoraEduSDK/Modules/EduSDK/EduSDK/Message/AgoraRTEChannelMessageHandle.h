//
//  AgoraRTEChannelMessageHandle.h
//  EduSDK
//
//  Created by SRS on 2020/8/31.
//

#import <Foundation/Foundation.h>
#import "AgoraRTEMessageHandle.h"

typedef NS_ENUM(NSUInteger, AgoraRTEStreamAction) {
    AgoraRTEStreamCreate,
    AgoraRTEStreamUpdate,
    AgoraRTEStreamDelete,
};

NS_ASSUME_NONNULL_BEGIN

@interface AgoraRTEChannelMessageHandle : AgoraRTEMessageHandle

@property (nonatomic, strong) AgoraRTESyncRoomSession *syncRoomSession;

@property (nonatomic, weak) id<AgoraRTEUserDelegate> userDelegate;
@property (nonatomic, weak) id<AgoraRTEClassroomDelegate> roomDelegate;

// state:0=remove 1=add/update
@property (nonatomic, copy) void (^checkAutoSubscribe)(NSArray<AgoraRTEStream *> *streams, BOOL state);
@property (nonatomic, copy) void (^checkStreamPublish)(AgoraRTEStream *stream, AgoraRTEStreamAction action);

- (instancetype)initWithSyncSession:(AgoraRTESyncRoomSession *)syncRoomSession;

- (AgoraRTEMessageHandleCode)didReceivedChannelMsg:(id)obj;

@end

NS_ASSUME_NONNULL_END
