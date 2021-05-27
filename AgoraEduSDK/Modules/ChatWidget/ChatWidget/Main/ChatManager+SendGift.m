//
//  ChatManager+SendGift.m
//  AgoraEducation
//
//  Created by lixiaoming on 2021/5/20.
//  Copyright © 2021 Agora. All rights reserved.
//

#import "ChatManager+SendGift.h"
const static NSString* kMsgType = @"msgtype";
const static NSString* kAvatarUrl = @"avatarUrl";
const static NSString* kNickName = @"nickName";
const static NSString* kRoomUuid = @"roomUuid";

@implementation ChatManager (SendGift)

- (void)sendGiftMsg:(GiftType)aGiftType
{
    NSNumber* credit = [[GiftCellView giftCredits] objectAtIndex:aGiftType];
    NSString* des = [[GiftCellView giftDescriptions] objectAtIndex:aGiftType];
    NSString* url = [[GiftCellView giftUrls] objectAtIndex:aGiftType];
    NSMutableDictionary* customExt = [@{@"number":[NSString stringWithFormat:@"%@",credit],@"des":des,@"url":url} mutableCopy];
    NSMutableDictionary* ext = [@{@"role":[NSString stringWithFormat:@"%d",2]} mutableCopy];
    if(self.user.nickname.length > 0 ){
        [ext setObject:self.user.nickname forKey:kNickName];
    }
    if(self.user.avatarurl.length > 0 ){
        [ext setObject:self.user.avatarurl forKey:kAvatarUrl];
    }
    if(self.user.roomUuid.length > 0) {
        [ext setObject:self.user.roomUuid forKey:kRoomUuid];
    }
    EMCustomMessageBody* customBody = [[EMCustomMessageBody alloc] initWithEvent:@"gift" ext:customExt];
    
    EMMessage* msg = [[EMMessage alloc] initWithConversationID:self.chatRoomId from:self.user.username to:self.chatRoomId body:customBody ext:ext];
    
    msg.chatType = EMChatTypeChatRoom;
    [[EMClient sharedClient].chatManager sendMessage:msg progress:^(int progress) {
                
            } completion:^(EMMessage *message, EMError *error) {
                if(!error) {
                    if([self.delegate respondsToSelector:@selector(barrageMessageDidSend:)]){
                        [self.delegate barrageMessageDidSend:[BarrageMsgInfo barrageInfoWithId:message.messageId text:des avatarUrl:self.user.avatarurl isGift:YES giftUrl:url]];
                    }
                }else{
                    [self.delegate exceptionDidOccur:error.errorDescription];
                }
            }];
}
@end
