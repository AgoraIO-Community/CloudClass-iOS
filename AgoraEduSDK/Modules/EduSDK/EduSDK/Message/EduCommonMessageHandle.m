//
//  EduCommonMessageHandle.m
//  EduSDK
//
//  Created by SRS on 2020/8/31.
//

#import "EduCommonMessageHandle.h"
#import "EduTextMessage+ConvenientInit.h"
#import "EduPeerMessageModel.h"
#import "EduMsgAction.h"
#import "EduActionMessage.h"

#define WEAK(object) __weak typeof(object) weak##object = object

@interface EduCommonMessageHandle()
@property (nonatomic, assign) BOOL syncIncrementing;
@property (nonatomic, assign) BOOL startReconnect;

@property (nonatomic, assign) ConnectionState currentState;

@property (nonatomic, copy) void (^block) (ConnectionState state);
@end

@implementation EduCommonMessageHandle
- (instancetype)initWithUserUuid:(NSString *)userUuid
{
    self = [super init];
    if (self) {
        self.syncIncrementing = NO;
        self.startReconnect = NO;
        
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onSyncComplete) name:NOTICE_KEY_END_RECONNECT object:nil];
    }
    return self;
}

- (void)onSyncComplete {
    self.startReconnect = NO;
    self.syncIncrementing = NO;
    if(self.block){
        self.block(self.currentState);
    }
}

#pragma mark peer
- (MessageHandleCode)didReceivedPeerMsg:(NSString *)text {
    EduPeerMessageModel *msgModel = [EduPeerMessageModel yy_modelWithJSON:text];
    if (msgModel.version != EDU_MESSAGE_VERSION) {
        return MessageHandleCodeVersionError;
    }
    
    if (msgModel.cmd == PeerMessageCmdChat) {
        [self messagePeerChat:msgModel];
    } else if (msgModel.cmd == PeerMessageCmdApplyOrInvitation) {
        [self messagePeerAction:msgModel];
    } else if (msgModel.cmd == PeerMessageCmdExtention) {
        [self messagePeerExtention:msgModel];
    } else {
        return MessageHandleCodeCMDError;
    }
    
    return MessageHandleCodeDone;
}

- (void)messagePeerAction:(EduPeerMessageModel *)msgModel {
    
    EduMsgAction *model = [EduMsgAction yy_modelWithDictionary:msgModel.data];
    id obj = [model yy_modelToJSONObject];
    
    EduActionMessage *actionMessage = [EduActionMessage new];
    [actionMessage yy_modelSetWithJSON:obj];
}

- (void)messagePeerExtention:(EduPeerMessageModel *)msgModel {
    
    EduMsgChat *model = [EduMsgChat yy_modelWithDictionary:msgModel.data];
    EduTextMessage *textMessage = [[EduTextMessage alloc] initWithUser:model.fromUser message:model.message timestamp:msgModel.ts];

    if ([self.agoraDelegate respondsToSelector:@selector(userMessageReceived:)]) {
        [self.agoraDelegate userMessageReceived:textMessage];
    }
}

- (void)messagePeerChat:(EduPeerMessageModel *)msgModel {
    
    EduMsgChat *model = [EduMsgChat yy_modelWithDictionary:msgModel.data];
    EduTextMessage *textMessage = [[EduTextMessage alloc] initWithUser:model.fromUser message:model.message timestamp:msgModel.ts];

    if ([self.agoraDelegate respondsToSelector:@selector(userChatMessageReceived:)]) {
        [self.agoraDelegate userChatMessageReceived:textMessage];
    }
}

- (void)didReceivedConnectionStateChanged:(ConnectionState)state complete:(void (^) (ConnectionState state))block {
    
    self.block = block;
    
    if(self.syncIncrementing) {
        return;
    }
    
    // reconnect
    if(state == ConnectionStateConnected) {
        
        if(self.startReconnect) {
            self.syncIncrementing = YES;

            self.currentState = state;
            [NSNotificationCenter.defaultCenter postNotificationName:NOTICE_KEY_START_RECONNECT object:nil];
            return;
        }
        
    } else if(state == ConnectionStateReconnecting) {
        self.startReconnect = YES;
    } else if(state == ConnectionStateDisconnected) {
        self.startReconnect = NO;
    }
    
    if (self.block) {
        self.block(state);
    }
}

@end
