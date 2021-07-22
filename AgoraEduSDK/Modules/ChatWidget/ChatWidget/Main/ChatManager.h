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

@protocol ChatManagerDelegate <NSObject>

// 需要展示接收消息
- (void)chatMessageDidReceive;
// 需要展示发送消息
- (void)chatMessageDidSend:(EMMessage*)aMessage;
// 发生异常
- (void)exceptionDidOccur:(NSString*)aErrorDescription;
// 需要撤回消息
- (void)chatMessageDidRecall:(NSString*)aMessageId;
// 禁言状态改变
- (void)mutedStateDidChanged;
// 状态发生改变
- (void)roomStateDidChanged:(ChatRoomState)aState;
// 公告发生变更
- (void)announcementDidChanged:(NSString*)aAnnouncement isFirst:(BOOL)aIsFirst;

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
// 接收的消息
- (NSArray<EMMessage*> *)msgArray;
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
