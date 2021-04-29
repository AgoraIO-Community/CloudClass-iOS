//
//  AgoraBaseViewController+Chat.m
//  AgoraEduSDK
//
//  Created by SRS on 2021/3/14.
//

#import "AgoraBaseViewController+Chat.h"

@implementation AgoraBaseViewController (Chat)

#pragma mark VCProcessDelegate
- (void)onAddRoomMessage:(AgoraEduContextChatInfo *)chatInfo {
    [self.eventDispatcher onAddRoomMessage:chatInfo];
}
- (void)updateRoomChatState:(BOOL)muteChat {
    [self.eventDispatcher onUpdateChatPermission:!muteChat];
}
- (void)onShowChatTips:(NSString *)message {
    if (message == nil || message.length == 0) {
        return;
    }
    [self.eventDispatcher onShowChatTips:message];
}

#pragma mark AgoraEduMessageContext
- (void)sendRoomMessage:(NSString *)message {
    
    AgoraWEAK(self);
    AgoraEduContextChatInfo *chatInfo = [self.chatVM sendRoomMessage:message messageId:0 successBlock:^(AgoraEduContextChatInfo *info) {
        [weakself.eventDispatcher onSendRoomMessageResult:nil info:info];
    } failureBlock:^(AgoraEduContextError *error, AgoraEduContextChatInfo *info) {
        [weakself.eventDispatcher onSendRoomMessageResult:error info:info];
    }];
    [self.eventDispatcher onAddRoomMessage:chatInfo];
}
- (void)resendRoomMessage:(NSString *)message messageId:(NSInteger)messageId {
    
    AgoraWEAK(self);
    AgoraEduContextChatInfo *chatInfo = [self.chatVM resendRoomMessage:message messageId:messageId successBlock:^(AgoraEduContextChatInfo *info) {
        [weakself.eventDispatcher onSendRoomMessageResult:nil info:info];
    } failureBlock:^(AgoraEduContextError *error, AgoraEduContextChatInfo *info) {
        [weakself.eventDispatcher onSendRoomMessageResult:error info:info];
    }];
    [self.eventDispatcher onAddRoomMessage:chatInfo];
}
- (void)fetchHistoryMessages:(NSInteger)startId count:(NSInteger)count {
    
    AgoraWEAK(self);
    [self.chatVM fetchHistoryMessages:startId count:count sort:0 successBlock:^(NSArray<AgoraEduContextChatInfo *> *infos) {
            
        [weakself.eventDispatcher onFetchHistoryMessagesResult:nil list:infos];
        
    } failureBlock:^(AgoraEduContextError *error) {
        
        [weakself.eventDispatcher onFetchHistoryMessagesResult:error list:nil];
        
    }];
}

// 事件监听
- (void)registerEventHandler:(id<AgoraEduMessageHandler>)handler {
    //添加数组里面
    [self.eventDispatcher registerWithObject:handler];
}

@end


