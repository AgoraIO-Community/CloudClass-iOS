//
//  ChatWidget.m
//  AgoraEducation
//
//  Created by lixiaoming on 2021/5/12.
//  Copyright © 2021 Agora. All rights reserved.
//

#import "ChatWidget.h"
#import "ChatManager+SendGift.h"
#import <BarrageRenderer/BarrageRenderer.h>
#import <AgoraUIBaseViews/AgoraUIBaseViews-Swift.h>
#import "AvatarBarrageView.h"
#import "EmojiKeyboardView.h"
#import "GiftView.h"
#import <WHToast/WHToast.h>
#import "UIImage+ChatExt.h"

static const NSString* kAvatarUrl = @"avatarUrl";
static const NSString* kNickname = @"nickName";
static const NSString* kChatRoomId = @"chatroomId";

#define CONTAINVIEW_HEIGHT 50
#define SENDBUTTON_HEIGHT 30
#define SENDBUTTON_WIDTH 40
#define INPUT_WIDTH 120
#define GIFTBUTTON_WIDTH 28
#define EMOJIBUTTON_WIDTH 30

@interface ChatWidget () <ChatManagerDelegate,
                          UITextFieldDelegate,
                          BarrageRendererDelegate,
                          GiftViewDelegate,
                          EmojiKeyboardDelegate,
                          AgoraUIContainerDelegate>
@property (nonatomic,strong) ChatManager* chatManager;
@property (nonatomic,strong) UITextField* inputField;
@property (nonatomic,strong) AgoraBaseUIContainer* containView;
@property (nonatomic,strong) UIButton* emojiButton;
@property (nonatomic,strong) UIButton* sendButton;
@property (nonatomic,strong) UIButton* giftButton;
@property (nonatomic,strong) BarrageRenderer * renderer;// 弹幕控制
@property (nonatomic) BOOL isShowBarrage;
@property (nonatomic,strong) EmojiKeyboardView *emojiKeyBoardView;
@property (nonatomic,strong) GiftView* giftView;
@property (nonatomic,strong) UITapGestureRecognizer *tap;
@end

@implementation ChatWidget
- (instancetype)initWithWidgetId:(NSString *)widgetId
                      properties:(NSDictionary * _Nullable)properties {
    self = [super initWithWidgetId:widgetId
                        properties:properties];
    
    if (self) {
        self.containerView.delegate = self;
        [self initViews];
        [self initData:properties];
    }
    
    return self;
}

- (void)containerLayoutSubviews {
    [self layoutViews];
}

- (void)dealloc {
    [self.chatManager removeObserver:self forKeyPath:@"chatroomAnnouncement"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.chatManager logout];
}

#pragma mark - ChatWidget
- (void)initViews {
    self.isShowBarrage = YES;
    
    self.containView = [[AgoraBaseUIContainer alloc] initWithFrame:CGRectZero];
    self.containView.backgroundColor = [UIColor clearColor];
    self.containerView.backgroundColor = [UIColor clearColor];
    [self.containerView addSubview:self.containView];
    
    self.inputField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.inputField.placeholder = @"发个弹幕吧";
    self.inputField.backgroundColor = [UIColor colorWithRed:245/255.0
                                                      green:245/255.0
                                                       blue:245/255.0
                                                      alpha:1.0];
    self.inputField.layer.cornerRadius = 15;
    self.inputField.returnKeyType = UIReturnKeySend;
    self.inputField.delegate = self;
    [self.containView addSubview:self.inputField];
    
    self.giftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage* image = [UIImage imageNamedFromBundle:@"icon_gift"];
    [self.giftButton setImage:image
                     forState:UIControlStateNormal];
    [self.giftButton setImage:image
                     forState:UIControlStateDisabled];
    
    self.giftButton.contentMode = UIViewContentModeScaleAspectFit;
    [self.containView addSubview:self.giftButton];
    [self.giftButton addTarget:self
                        action:@selector(sendGiftAction)
              forControlEvents:UIControlEventTouchUpInside];
    
    self.emojiButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.emojiButton setImage:[UIImage imageNamedFromBundle:@"icon_emoji"]
                      forState:UIControlStateNormal];
    [self.emojiButton setImage:[UIImage imageNamedFromBundle:@"icon_keyboard"]
                      forState:UIControlStateSelected];
    [self.containView addSubview:self.emojiButton];
    self.emojiButton.hidden = YES;
    [self.emojiButton addTarget:self
                         action:@selector(emojiButtonAction)
               forControlEvents:UIControlEventTouchUpInside];
    
    self.sendButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.sendButton setTitle:@"发送"
                     forState:UIControlStateNormal];
    [self.containView addSubview:self.sendButton];
    self.sendButton.hidden = YES;
    [self.sendButton addTarget:self
                        action:@selector(sendButtonAction)
              forControlEvents:UIControlEventTouchUpInside];
    
    if(self.isShowBarrage)
    {
        [self setupBarrangeRender];
        [self startBarrage];
    }
    
    self.emojiKeyBoardView = [[EmojiKeyboardView alloc] initWithFrame:CGRectZero];
    self.emojiKeyBoardView.delegate = self;
    
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                       action:@selector(handleTapAction:)];
    [self.containerView addGestureRecognizer:self.tap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillChangeFrame:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)layoutViews {
    self.containView.frame = CGRectMake(0,
                                        self.containerView.bounds.size.height - CONTAINVIEW_HEIGHT,
                                        self.containerView.bounds.size.width,
                                        CONTAINVIEW_HEIGHT);
    
    self.inputField.frame = CGRectMake(self.containView.bounds.size.width-INPUT_WIDTH - 20-GIFTBUTTON_WIDTH,
                                       10,
                                       INPUT_WIDTH,
                                       CONTAINVIEW_HEIGHT-20);
    
    self.giftButton.frame = CGRectMake(self.containView.bounds.size.width-GIFTBUTTON_WIDTH,
                                       (CONTAINVIEW_HEIGHT - GIFTBUTTON_WIDTH)/2,
                                       GIFTBUTTON_WIDTH,
                                       GIFTBUTTON_WIDTH);
    
    self.emojiButton.frame = CGRectMake(self.containView.bounds.size.width - SENDBUTTON_WIDTH - EMOJIBUTTON_WIDTH-5,
                                        CONTAINVIEW_HEIGHT-EMOJIBUTTON_WIDTH-5,
                                        EMOJIBUTTON_WIDTH,
                                        EMOJIBUTTON_WIDTH);
    
    self.sendButton.frame = CGRectMake(self.containView.bounds.size.width - SENDBUTTON_WIDTH,
                                       CONTAINVIEW_HEIGHT-SENDBUTTON_HEIGHT-5,
                                       SENDBUTTON_WIDTH,
                                       SENDBUTTON_HEIGHT);
    
    self.emojiKeyBoardView.frame = CGRectMake(0,
                                              0,
                                              self.containerView.bounds.size.width,
                                              176);
}

- (void)handleTapAction:(UITapGestureRecognizer *)aTap
{
    if (aTap.state == UIGestureRecognizerStateEnded) {

        if([self.inputField isFirstResponder]) {
            [self.inputField resignFirstResponder];
        }
    }
}

- (void)setupBarrangeRender
{
    _renderer = [[BarrageRenderer alloc]init];
    _renderer.smoothness = .2f;
    _renderer.delegate = self;
    _renderer.canvasMargin = UIEdgeInsetsMake(10, 10, 10, 60);
    [self.containerView addSubview:_renderer.view];
    [self.containerView sendSubviewToBack:_renderer.view];
}

- (void)startBarrage
{
    [_renderer start];
}

- (void)stopBarrage
{
    [_renderer stop];
}

- (void)recallMsg:(NSString*)msgId
{
    if(msgId.length > 0)
        [_renderer removeSpriteWithIdentifier:msgId];
}

- (BarrageDescriptor *)buildBarrageDescriptor:(BarrageMsgInfo*)aInfo
{
    BarrageDescriptor * descriptor = [[BarrageDescriptor alloc] init];
    
    descriptor.params[@"speed"] = @(arc4random() % 30+30);
    descriptor.params[@"direction"] = @(BarrageWalkDirectionR2L);
    descriptor.params[@"side"] = @(BarrageWalkSideDefault);
    if(aInfo.isGift)
    {
        descriptor.spriteName = NSStringFromClass([BarrageWalkSprite class]);
        descriptor.params[@"viewClassName"] = NSStringFromClass([AvatarBarrageView class]);
        descriptor.params[@"titles"] = @[aInfo.text];
        if(aInfo.avatarUrl.length > 0)
            descriptor.params[@"avatarUrl"] = aInfo.avatarUrl;
        if(aInfo.giftUrl.length > 0){
            descriptor.params[@"giftUrl"] = aInfo.giftUrl;
        }
    }else{
        descriptor.spriteName = NSStringFromClass([BarrageWalkTextSprite class]);
        descriptor.params[@"text"] = aInfo.text;
        descriptor.params[@"textColor"] = [UIColor blueColor];
    }
    
    descriptor.params[@"identifier"] = aInfo.msgId;
    
    return descriptor;
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
    [self.chatManager addObserver:self forKeyPath:@"chatroomAnnouncement" options:NSKeyValueObservingOptionNew context:nil];
    
    [self.chatManager launch];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)contex
{
    if([keyPath isEqualToString:@"chatroomAnnouncement"]) {
        // 这是最新公告
        NSString* newAnnouncement = self.chatManager.chatroomAnnouncement;
        NSLog(@"newAnnouncement:%@",newAnnouncement);
    }
}

- (GiftView*)giftView
{
    if(!_giftView) {
        _giftView = [[GiftView alloc] initWithFrame:CGRectMake(0,
                                                               self.containerView.bounds.size.height - 180,
                                                               self.containerView.bounds.size.width,
                                                               180)];
        [self.containerView addSubview:_giftView];
        self.giftView.hidden = YES;
        _giftView.delegate = self;
    }
    return _giftView;
}

- (void)sendGiftAction
{
    self.giftView.hidden = NO;
    self.inputField.enabled = NO;
}

- (void)emojiButtonAction
{
    [self.emojiButton setSelected:!self.emojiButton.isSelected];
    [self changeKeyBoardType];
}

- (void)changeKeyBoardType
{
    if(self.emojiButton.isSelected) {
        self.inputField.inputView = self.emojiKeyBoardView;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.inputField reloadInputViews];
        });
    }else{
        self.inputField.inputView = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.inputField reloadInputViews];
        });
    }
}

- (void)sendButtonAction
{
    NSString* sendText = self.inputField.text;
    if(sendText.length > 0) {
        [self.chatManager sendCommonTextMsg:sendText];
    }
    self.inputField.text = @"";
    [self.inputField resignFirstResponder];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self sendButtonAction];
    return YES;
    
}
#pragma mark - CustomKeyBoardDelegate

- (void)emojiItemDidClicked:(NSString *)item{
    self.inputField.text = [self.inputField.text stringByAppendingString:item];
}

- (void)emojiDidDelete
{
    if ([self.inputField.text length] > 0) {
        NSRange range = [self.inputField.text rangeOfComposedCharacterSequenceAtIndex:self.inputField.text.length-1];
        self.inputField.text = [self.inputField.text substringToIndex:range.location];
    }
}

#pragma mark - 键盘显示
- (void)keyboardWillChangeFrame:(NSNotification *)notification{
        //取出键盘动画的时间(根据userInfo的key----UIKeyboardAnimationDurationUserInfoKey)
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];

    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    //self.emojiKeyBoardView.frame = keyboardFrame;
    //执行动画
    [UIView animateWithDuration:duration animations:^{
        UIWindow * window=[[[UIApplication sharedApplication] delegate] window];
        CGRect rect=[self.containView convertRect: self.containView.bounds toView:window];    //获取控件view的相对坐标
        {
            CGRect oldFrame = self.containView.frame;
            self.containView.frame = CGRectMake(0, oldFrame.origin.y - (rect.origin.y - keyboardFrame.origin.y) - CONTAINVIEW_HEIGHT, oldFrame.size.width, CONTAINVIEW_HEIGHT);
            self.inputField.frame = CGRectMake(20, 10, self.containView.bounds.size.width - SENDBUTTON_WIDTH - EMOJIBUTTON_WIDTH - 30, CONTAINVIEW_HEIGHT-10);
            self.giftButton.hidden = YES;
            self.sendButton.hidden = NO;
            self.emojiButton.hidden = NO;
        }
        
    }];
    
    
}


#pragma mark --键盘收回
- (void)keyboardDidHide:(NSNotification *)notification{
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:duration animations:^{
        self.containView.frame = CGRectMake(0, self.containerView.bounds.size.height - CONTAINVIEW_HEIGHT, self.containerView.bounds.size.width, CONTAINVIEW_HEIGHT);
        self.inputField.frame = CGRectMake(self.containView.bounds.size.width-INPUT_WIDTH-20-GIFTBUTTON_WIDTH, 10, INPUT_WIDTH, CONTAINVIEW_HEIGHT - 20);
        self.giftButton.hidden = NO;
        self.sendButton.hidden = YES;
        self.emojiButton.hidden = YES;
    }];
}

#pragma mark - ChatManagerDelegate
- (void)barrageMessageDidReceive
{
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if(weakself.isShowBarrage) {
            NSArray<BarrageMsgInfo*>* array = [weakself.chatManager msgArray];
            for (BarrageMsgInfo* msg in array) {
                if(msg.text.length > 0 && msg.msgId.length > 0) {
                    [weakself.renderer receive:[weakself buildBarrageDescriptor:msg]];
                }
            }
        }
    });
    
}

- (void)barrageMessageDidSend:(BarrageMsgInfo*)aInfo
{
    if(self.isShowBarrage) {
        if(aInfo.msgId.length > 0 && aInfo.text.length > 0)
            [self.renderer receive:[self buildBarrageDescriptor:aInfo]];
    }
}

- (void)exceptionDidOccur:(NSString*)aErrorDescription
{
    [WHToast showErrorWithMessage:aErrorDescription duration:2 finishHandler:^{
            
    }];
}

- (void)mutedStateDidChanged
{
    if(self.chatManager.isAllMuted) {
        self.inputField.text = @"";
        self.inputField.placeholder = @"全员禁言中";
        self.inputField.enabled = NO;
        self.giftButton.enabled = NO;
    }else{
        if(self.chatManager.isMuted) {
            self.inputField.text = @"";
            self.inputField.placeholder = @"你已被禁言";
            self.inputField.enabled = NO;
            self.giftButton.enabled = NO;
        }else{
            self.inputField.placeholder = @"发个弹幕吧";
            self.inputField.enabled = YES;
            self.giftButton.enabled = YES;
        }
    }
}

- (void)barrageMessageDidRecall:(NSString*)aMessageId
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
                self.inputField.placeholder = @"正在登录";
                break;
            case ChatRoomStateLoginFailed:
                self.inputField.placeholder = @"登录失败";
                break;
            case ChatRoomStateLogined:
                self.inputField.placeholder = @"登录成功";
                break;
            case ChatRoomStateJoining:
                self.inputField.placeholder = @"正在加入房间";
                break;
            case ChatRoomStateJoined:
                self.inputField.placeholder = @"发个弹幕吧";
                break;
            case ChatRoomStateJoinFail:
                self.inputField.placeholder = @"加入房间失败";
                break;
            default:
                break;
        }
    });
    
}

#pragma mark - GiftViewDelegate
- (void)sendGift:(GiftCellView*)giftView
{
    if(giftView) {
        [self.chatManager sendGiftMsg:giftView.giftType];
    }
}

- (void)giftViewHidden
{
    [self mutedStateDidChanged];
}

@end
