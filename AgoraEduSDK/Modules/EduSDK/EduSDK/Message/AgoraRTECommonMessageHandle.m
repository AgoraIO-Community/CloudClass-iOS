//
//  AgoraRTECommonMessageHandle.m
//  EduSDK
//
//  Created by SRS on 2020/8/31.
//

#import "AgoraRTECommonMessageHandle.h"
#import "AgoraRTETextMessage+ConvenientInit.h"
#import "AgoraRTEPeerMessageModel.h"
#import "AgoraRTEMsgAction.h"
#import "AgoraRTEActionMessage.h"

#define WEAK(object) __weak typeof(object) weak##object = object

@interface AgoraRTECommonMessageHandle()
@property (nonatomic, assign) BOOL syncIncrementing;
@property (nonatomic, assign) BOOL startReconnect;

@property (nonatomic, assign) AgoraRTEConnectionState currentState;

@property (nonatomic, copy) void (^block) (AgoraRTEConnectionState state);
@end

@implementation AgoraRTECommonMessageHandle
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
- (AgoraRTEMessageHandleCode)didReceivedPeerMsg:(NSString *)text {
    AgoraRTEPeerMessageModel *msgModel = [AgoraRTEPeerMessageModel yy_modelWithJSON:text];
    if (msgModel.version != AGORA_RTE_MESSAGE_VERSION) {
        return AgoraRTEMessageHandleCodeVersionError;
    }
    
    if (msgModel.cmd == AgoraRTEPeerMessageCmdChat) {
        [self messagePeerChat:msgModel];
    } else if (msgModel.cmd == AgoraRTEPeerMessageCmdApplyOrInvitation) {
        [self messagePeerAction:msgModel];
    } else if (msgModel.cmd == AgoraRTEPeerMessageCmdExtention) {
        [self messagePeerExtention:msgModel];
    } else {
        return AgoraRTEMessageHandleCodeCMDError;
    }
    
    return AgoraRTEMessageHandleCodeDone;
}

- (void)messagePeerAction:(AgoraRTEPeerMessageModel *)msgModel {
    
    AgoraRTEMsgAction *model = [AgoraRTEMsgAction yy_modelWithDictionary:msgModel.data];
    id obj = [model yy_modelToJSONObject];
    
    AgoraRTEActionMessage *actionMessage = [AgoraRTEActionMessage new];
    [actionMessage yy_modelSetWithJSON:obj];
}

- (void)messagePeerExtention:(AgoraRTEPeerMessageModel *)msgModel {
    
    AgoraRTEMsgChat *model = [AgoraRTEMsgChat yy_modelWithDictionary:msgModel.data];
    AgoraRTETextMessage *textMessage = [[AgoraRTETextMessage alloc] initWithUser:model.fromUser message:model.message timestamp:msgModel.ts];

    if ([self.agoraDelegate respondsToSelector:@selector(userMessageReceived:)]) {
        [self.agoraDelegate userMessageReceived:textMessage];
    }
}

- (void)messagePeerChat:(AgoraRTEPeerMessageModel *)msgModel {
    
    AgoraRTEMsgChat *model = [AgoraRTEMsgChat yy_modelWithDictionary:msgModel.data];
    AgoraRTETextMessage *textMessage = [[AgoraRTETextMessage alloc] initWithUser:model.fromUser message:model.message timestamp:msgModel.ts];

    if ([self.agoraDelegate respondsToSelector:@selector(userChatMessageReceived:)]) {
        [self.agoraDelegate userChatMessageReceived:textMessage];
    }
}

- (void)didReceivedConnectionStateChanged:(AgoraRTEConnectionState)state complete:(void (^) (AgoraRTEConnectionState state))block {
    
    self.block = block;
    
    if(self.syncIncrementing) {
        return;
    }
    
    // reconnect
    if(state == AgoraRTEConnectionStateConnected) {
        
        if(self.startReconnect) {
            self.syncIncrementing = YES;

            self.currentState = state;
            [NSNotificationCenter.defaultCenter postNotificationName:NOTICE_KEY_START_RECONNECT object:nil];
            return;
        }
        
    } else if(state == AgoraRTEConnectionStateReconnecting) {
        self.startReconnect = YES;
    } else if(state == AgoraRTEConnectionStateDisconnected) {
        self.startReconnect = NO;
    }
    
    if (self.block) {
        self.block(state);
    }
}

@end
