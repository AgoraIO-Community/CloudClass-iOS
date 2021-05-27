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
- (void)onAddConversationMessage:(AgoraEduContextChatInfo *)chatInfo {
    [self.eventDispatcher onAddConversationMessage:chatInfo];
}
- (void)updateRoomChatState:(BOOL)muteChat {
    [self.eventDispatcher onUpdateChatPermission:!muteChat];
}

- (void)updateLocalChatState:(BOOL)muteChat
                          to:(AgoraEduContextUserInfo *)userInfo
                          by:(AgoraEduContextUserInfo *)operator {
    [self.eventDispatcher onUpdateLocalChatPermission:!muteChat
                                               toUser:userInfo
                                         operatorUser:operator];
}

- (void)updateRemoteChatState:(BOOL)muteChat
                           to:(AgoraEduContextUserInfo *)userInfo
                           by:(AgoraEduContextUserInfo *)operator {
    [self.eventDispatcher onUpdateRemoteChatPermission:!muteChat
                                                toUser:userInfo
                                          operatorUser:operator];
}
- (void)updatePeerChatStateFrom:(AgoraEduContextUserDetailInfo *)userInfo state:(BOOL)muteChat {
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
    
    AgoraEduContextChatInfo *chatInfo = [self.chatVM sendMessage:message
                                                           messageId:0
                                                                mode:AgoraChatModeRoom
                                                        successBlock:^(AgoraEduContextChatInfo *info) {
        [weakself.eventDispatcher onSendRoomMessageResult:nil
                                                     info:info];
    } failureBlock:^(AgoraEduContextError *error, AgoraEduContextChatInfo *info) {
        [weakself.eventDispatcher onSendRoomMessageResult:error
                                                     info:info];
    }];
    [self.eventDispatcher onAddRoomMessage:chatInfo];
}

- (void)sendConversationMessage:(NSString *)message {
    AgoraWEAK(self);
    
    AgoraEduContextChatInfo *chatInfo = [self.chatVM sendMessage:message
                                                           messageId:0
                                                                mode:AgoraChatModeConversation
                                                        successBlock:^(AgoraEduContextChatInfo *info) {
        [weakself.eventDispatcher onSendConversationMessageResult:nil
                                                             info:info];
    } failureBlock:^(AgoraEduContextError *error, AgoraEduContextChatInfo *info) {
        [weakself.eventDispatcher onSendConversationMessageResult:error
                                                             info:info];
    }];
    [self.eventDispatcher onAddConversationMessage:chatInfo];
}

- (void)resendRoomMessage:(NSString *)message
                messageId:(NSString *)messageId {
    AgoraWEAK(self);
    AgoraEduContextChatInfo *chatInfo = [self.chatVM resendMessage:message
                                                             messageId:messageId
                                                              mode:AgoraChatModeRoom
                                                          successBlock:^(AgoraEduContextChatInfo *info) {
        [weakself.eventDispatcher onSendRoomMessageResult:nil
                                                     info:info];
    } failureBlock:^(AgoraEduContextError *error, AgoraEduContextChatInfo *info) {
        [weakself.eventDispatcher onSendRoomMessageResult:error
                                                     info:info];
    }];
    
    [self.eventDispatcher onAddRoomMessage:chatInfo];
}
- (void)resendConversationMessage:(NSString *)message
                messageId:(NSString *)messageId {
    AgoraWEAK(self);
    AgoraEduContextChatInfo *chatInfo = [self.chatVM resendMessage:message
                                                             messageId:messageId
                                                                  mode:AgoraChatModeConversation
                                                          successBlock:^(AgoraEduContextChatInfo *info) {
        [weakself.eventDispatcher onSendConversationMessageResult:nil
                                                             info:info];
    } failureBlock:^(AgoraEduContextError *error, AgoraEduContextChatInfo *info) {
        [weakself.eventDispatcher onSendConversationMessageResult:error
                                                             info:info];
    }];
    
    [self.eventDispatcher onAddConversationMessage:chatInfo];
}

- (void)fetchHistoryMessages:(NSString *)startId
                       count:(NSInteger)count {
    AgoraWEAK(self);
    [self.chatVM fetchHistoryMessages:startId
                                count:count
                                 sort:0
                                 mode:AgoraChatModeRoom
                         successBlock:^(NSArray<AgoraEduContextChatInfo *> *infos) {
        [weakself.eventDispatcher onFetchHistoryMessagesResult:nil
                                                          list:infos];
    } failureBlock:^(AgoraEduContextError *error) {
        [weakself.eventDispatcher onFetchHistoryMessagesResult:error
                                                          list:nil];
    }];
}

- (void)fetchConversationHistoryMessages:(NSString *)startId
                                   count:(NSInteger)count {
    AgoraWEAK(self);
    [self.chatVM fetchHistoryMessages:startId
                                count:count
                                 sort:0
                                 mode:AgoraChatModeConversation
                         successBlock:^(NSArray<AgoraEduContextChatInfo *> *infos) {
        [weakself.eventDispatcher onFetchConversationHistoryMessagesResult:nil
                                                                      list:infos];
    } failureBlock:^(AgoraEduContextError *error) {
        [weakself.eventDispatcher onFetchConversationHistoryMessagesResult:error
                                                                      list:nil];
    }];
}

// 事件监听
- (void)registerEventHandler:(id<AgoraEduMessageHandler>)handler {
    //添加数组里面
    [self.eventDispatcher registerWithObject:handler];
}

@end


