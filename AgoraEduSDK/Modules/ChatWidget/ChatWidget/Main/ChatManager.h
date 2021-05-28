//
//  ChatManager.h
//  AgoraEducation
//
//  Created by lixiaoming on 2021/5/12.
//  Copyright © 2021 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatUserConfig.h"
#import "ChatWidgetDefine.h"
#import <HyphenateChat/HyphenateChat.h>

NS_ASSUME_NONNULL_BEGIN

// 弹幕信息
@interface BarrageMsgInfo : NSObject
@property (nonatomic,strong) NSString* msgId;
@property (nonatomic,strong) NSString* text;
@property (nonatomic,strong) NSString* avatarUrl;
@property (nonatomic) BOOL isGift;
@property (nonatomic,strong) NSString* giftUrl;
+ (instancetype)barrageInfoWithId:(NSString*)aMsgId text:(NSString*)aText avatarUrl:(NSString*)aAvatarUrl;
+ (instancetype)barrageInfoWithId:(NSString*)aMsgId text:(NSString*)aText avatarUrl:(NSString*)aAvatarUrl isGift:(BOOL)aIsGift giftUrl:(NSString*)aGiftUrl;
@end

@protocol ChatManagerDelegate <NSObject>

// 需要展示接收弹幕消息
- (void)barrageMessageDidReceive;
// 需要展示发送弹幕消息
- (void)barrageMessageDidSend:(BarrageMsgInfo*)aInfo;
// 发生异常
- (void)exceptionDidOccur:(NSString*)aErrorDescription;
// 需要撤回弹幕消息
- (void)barrageMessageDidRecall:(NSString*)aMessageId;
// 禁言状态改变
- (void)mutedStateDidChanged;
// 状态发生改变
- (void)roomStateDidChanged:(ChatRoomState)aState;

@end

@interface ChatManager : NSObject

// 初始化
- (instancetype)initWithUserConfig:(ChatUserConfig*)aUserConfig
                            appKey:(NSString *)appKey
                          password:(NSString *)password
                        chatRoomId:(NSString*)aChatRoomId;
// 启动
- (void)launch;
// 退出
- (void)logout;
// 发送普通聊天消息
- (void)sendCommonTextMsg:(NSString*)aText;
// 获取用户配置
- (ChatUserConfig*)userConfig;
// 接收的弹幕消息
- (NSArray<BarrageMsgInfo*> *)msgArray;
// 更新头像
- (void)updateAvatar:(NSString*)avatarUrl;
// 更新昵称
- (void)updateNickName:(NSString*)nickName;
@property (nonatomic) BOOL isAllMuted;
@property (nonatomic) BOOL isMuted;
@property (nonatomic,strong) ChatUserConfig* user;
@property (nonatomic,strong) NSString* chatRoomId;
@property (nonatomic,strong) NSString* chatroomAnnouncement;
@property (nonatomic,weak) id<ChatManagerDelegate> delegate;
@property (nonatomic) ChatRoomState state;
@end

NS_ASSUME_NONNULL_END
