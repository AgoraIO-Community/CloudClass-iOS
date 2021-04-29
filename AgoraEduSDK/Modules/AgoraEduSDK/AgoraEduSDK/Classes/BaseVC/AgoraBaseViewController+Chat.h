//
//  AgoraBaseViewController+Chat.h
//  AgoraEduSDK
//
//  Created by SRS on 2021/3/14.
//

#import "AgoraBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface AgoraBaseViewController (Chat) <AgoraEduMessageContext>
- (void)onAddRoomMessage:(AgoraEduContextChatInfo *)chatInfo;
- (void)updateRoomChatState:(BOOL)muteChat;
- (void)onShowChatTips:(NSString *)message;
@end

NS_ASSUME_NONNULL_END
