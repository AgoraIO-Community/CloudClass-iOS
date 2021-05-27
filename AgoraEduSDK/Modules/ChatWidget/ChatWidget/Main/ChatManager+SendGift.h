//
//  ChatManager+SendGift.h
//  AgoraEducation
//
//  Created by lixiaoming on 2021/5/20.
//  Copyright © 2021 Agora. All rights reserved.
//

#import "ChatManager.h"
#import "GiftCellView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChatManager (SendGift)
// 发送礼物消息
- (void)sendGiftMsg:(GiftType)aGiftType;
@end

NS_ASSUME_NONNULL_END
