//
//  ChatWidget.m
//  AgoraEducation
//
//  Created by lixiaoming on 2021/5/12.
//  Copyright © 2021 Agora. All rights reserved.
//

#import "ChatWidget+Localizable.h"
#import "ChatManager.h"
#import <AgoraUIBaseViews/AgoraUIBaseViews-Swift.h>
#import <WHToast/WHToast.h>
#import "UIImage+ChatExt.h"
#import "ChatTopView.h"
#import "AnnouncementView.h"
#import "ChatView.h"
#import "CustomBadgeView.h"

static const NSString* kAvatarUrl = @"avatarUrl";
static const NSString* kNickname = @"nickName";
static const NSString* kChatRoomId = @"chatroomId";

#define TOP_HEIGHT 34
#define MINIBUTTON_SIZE 40

@interface ChatWidget () <ChatManagerDelegate,
                          UITextFieldDelegate,
                          AgoraUIContainerDelegate,
                          ChatTopViewDelegate,
                          ChatViewDelegate>
@property (nonatomic,strong) ChatManager* chatManager;
@property (nonatomic,strong) ChatTopView* chatTopView;
@property (nonatomic,strong) AnnouncementView* announcementView;
@property (nonatomic,strong) ChatView* chatView;
@property (nonatomic,strong) AgoraBaseUIContainer* containView;
@property (nonatomic,strong) UITapGestureRecognizer *tap;
//@property (nonatomic,strong) UIButton* miniButton;
@property (nonatomic,strong) CustomBadgeView* badgeView;
@end

@implementation ChatWidget
- (instancetype)initWithWidgetInfo:(AgoraWidgetInfo *)info {
    self = [super initWithWidgetInfo:info];
    
    if (self) {
        self.view.delegate = self;
        [self initViews];
        [self initData:info.properties];
    }
    
    return self;
}
- (void)containerLayoutSubviews {
    [self layoutViews];
}

- (void)onMessageReceived:(NSString *)message
{
    if([message isEqualToString:@"min"]) {
        [self chatTopViewDidClickHide];
    } else if([message isEqualToString:@"max"]) {
        [self showView];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.chatManager logout];
}

#pragma mark - ChatWidget
- (void)initViews {
    
    self.containView = [[UIView alloc] initWithFrame:CGRectZero];
    self.containView.backgroundColor = [UIColor clearColor];
    self.containView.layer.borderWidth = 1;
    self.containView.layer.borderColor = [UIColor colorWithRed:236/255.0 green:236/255.0 blue:241/255.0 alpha:1.0].CGColor;
    self.containView.layer.cornerRadius = 5;
    [self.view addSubview:self.containView];
    
    self.chatTopView = [[ChatTopView alloc] initWithFrame:CGRectZero];
    self.chatTopView.delegate = self;
    [self.containView addSubview:self.chatTopView];
    
    self.announcementView = [[AnnouncementView alloc] initWithFrame:CGRectZero];
    
    self.chatView = [[ChatView alloc] initWithFrame:CGRectZero];
    self.chatView.delegate = self;
    [self.containView addSubview:self.chatView];
    
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                       action:@selector(handleTapAction:)];
    [self.containView addGestureRecognizer:self.tap];
    
//    self.miniButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.miniButton setImage:[UIImage imageNamedFromBundle:@"icon_chat"] forState:UIControlStateNormal];
//    self.miniButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
//    [self.miniButton setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
//    self.miniButton.layer.cornerRadius = MINIBUTTON_SIZE/2;
//    self.miniButton.layer.borderWidth = 1;
//    self.miniButton.layer.borderColor = [UIColor colorWithRed:47/255.0 green:65/255.0 blue:146/255.0 alpha:0.15].CGColor;
//    [self.miniButton addTarget:self action:@selector(showView) forControlEvents:UIControlEventTouchUpInside];
//    self.miniButton.backgroundColor = UIColor.whiteColor;
//    [self.containerView addSubview:self.miniButton];
//    self.miniButton.hidden = YES;
    
    self.badgeView = [[CustomBadgeView alloc] init];
    [self.view addSubview:self.badgeView];
    self.badgeView.hidden = YES;
}

- (void)layoutViews {
    self.containView.frame = CGRectMake(0,
                                        0,
                                        self.view.bounds.size.width,
                                        self.view.bounds.size.height);
    self.chatTopView.frame = CGRectMake(0, 0, self.containView.bounds.size.width, TOP_HEIGHT);
    
    self.announcementView.frame = CGRectMake(0,TOP_HEIGHT,self.containView.bounds.size.width,self.containView.bounds.size.height - TOP_HEIGHT);
    
    self.chatView.frame = CGRectMake(0,TOP_HEIGHT,self.containView.bounds.size.width,self.containView.bounds.size.height - TOP_HEIGHT);
    
//    self.miniButton.frame = CGRectMake(10, self.containerView.bounds.size.height - MINIBUTTON_SIZE - 10, MINIBUTTON_SIZE, MINIBUTTON_SIZE);
    
    self.badgeView.frame = CGRectMake(10 + MINIBUTTON_SIZE*4/5, self.view.bounds.size.height - MINIBUTTON_SIZE - 10, self.badgeView.badgeSize, self.badgeView.badgeSize);
}

- (void)handleTapAction:(UITapGestureRecognizer *)aTap
{
    if (aTap.state == UIGestureRecognizerStateEnded) {
        [self.containView endEditing:YES];
    }
}

- (void)recallMsg:(NSString*)msgId
{
}

- (void)initData:(NSDictionary *)properties {
    ChatUserConfig* user = [[ChatUserConfig alloc] init];
    
    user.avatarurl = properties[@"avatarurl"];
    user.username = [properties[@"userUuid"] lowercaseString];
    user.nickname = properties[@"userName"];
    user.roomUuid = properties[@"roomUuid"];
    user.role = 2;
    
    kChatRoomId =  properties[@"chatRoomId"];
    
    NSString *appKey = properties[@"appkey"];
    NSString *password = properties[@"password"];
    
    ChatManager *manager = [[ChatManager alloc] initWithUserConfig:user
                                                            appKey:appKey
                                                          password:password
                                                        chatRoomId:kChatRoomId];
    
    manager.delegate = self;
    self.chatManager = manager;
    self.chatView.chatManager = self.chatManager;
    
    [self.chatManager launch];
}

#pragma mark - ChatManagerDelegate
- (void)chatMessageDidReceive
{
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray<EMMessage*>* array = [weakself.chatManager msgArray];
        [self.chatView updateMsgs:array];
        if(array.count > 0) {
            if([self.containView isHidden]) {
                // 最小化了
                self.badgeView.hidden = NO;
            }
            if(self.chatTopView.currentTab != 0) {
                // 显示红点
                self.chatTopView.isShowRedNotice = YES;
            }
        }
    });
    
}

- (void)chatMessageDidSend:(EMMessage*)aInfo
{
    [self.chatView updateMsgs:@[aInfo]];
}

- (void)exceptionDidOccur:(NSString*)aErrorDescription
{
    [WHToast showErrorWithMessage:aErrorDescription duration:2 finishHandler:^{
            
    }];
}

- (void)mutedStateDidChanged
{
    self.chatView.chatBar.isAllMuted = self.chatManager.isAllMuted;
    self.chatView.chatBar.isMuted = self.chatManager.isMuted;
}

- (void)chatMessageDidRecall:(NSString*)aMessageId
{
    if(aMessageId.length > 0) {
        [self recallMsg:aMessageId];
    }
}

- (void)roomStateDidChanged:(ChatRoomState)aState
{
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (aState) {
            case ChatRoomStateLogin:
                
                break;
            case ChatRoomStateLoginFailed:
                [WHToast showErrorWithMessage:[ChatWidget LocalizedString:@"ChatLoginFaild"] duration:2 finishHandler:^{
                        
                }];
                break;
            case ChatRoomStateLogined:
                
                break;
            case ChatRoomStateJoining:
                
                break;
            case ChatRoomStateJoined:
                
                break;
            case ChatRoomStateJoinFail:
                [WHToast showErrorWithMessage:[ChatWidget LocalizedString:@"ChatJoinFaild"] duration:2 finishHandler:^{
                        
                }];
                break;
            default:
                break;
        }
    });
}

- (void)announcementDidChanged:(NSString *)aAnnouncement isFirst:(BOOL)aIsFirst
{
    self.chatView.announcement = aAnnouncement;
    self.announcementView.announcement = aAnnouncement;
    if(!aIsFirst) {
        if([self.containView isHidden]) {
            // 最小化了
            self.badgeView.hidden = NO;
        }
        if(self.chatTopView.currentTab != 1) {
            // 显示红点
            self.chatTopView.isShowAnnouncementRedNotice = YES;
        }
    }
}

#pragma mark - ChatTopViewDelegate
- (void)chatTopViewDidSelectedChanged:(NSUInteger)nSelected
{
    if(nSelected == 0){
        [self.announcementView removeFromSuperview];
        [self.containView addSubview:self.chatView];
    }else{
        [self.chatView removeFromSuperview];
        [self.containView addSubview:self.announcementView];
    }
}

- (void)chatTopViewDidClickHide
{
    self.containView.hidden = YES;
//    self.miniButton.hidden = NO;
    self.badgeView.hidden = self.chatTopView.badgeView.hidden && self.chatTopView.announcementbadgeView.hidden;
    self.view.agora_width = 50;
    [self sendMessage:@"min"];
}

- (void)showView
{
    self.containView.hidden = NO;
//    self.miniButton.hidden = YES;
    if(self.chatTopView.currentTab == 0) {
        self.chatTopView.badgeView.hidden = YES;
        [self.chatView scrollToBottomRow];
    }
    if(self.chatTopView.currentTab == 1) {
        self.chatTopView.announcementbadgeView.hidden = YES;
    }
    self.badgeView.hidden = YES;
    if([[UIDevice currentDevice].model isEqualToString:@"iPad"]) {
        self.view.agora_width = 300;
    }else
        self.view.agora_width = 200;
    
    [self sendMessage:@"max"];
}

#pragma mark - ChatViewDelegate
- (void)chatViewDidClickAnnouncement
{
    self.chatTopView.currentTab = 1;
}

- (void)msgWillSend:(NSString *)aMsgText
{
    [self.chatManager sendCommonTextMsg:aMsgText];
}
@end
