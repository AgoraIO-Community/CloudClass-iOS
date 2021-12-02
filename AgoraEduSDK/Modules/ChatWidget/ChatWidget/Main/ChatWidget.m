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
#import "NSTimer+Block.h"
#import <EMEmojiHelper.h>
#import "UITextView+Placeholder.h"

static const NSString* kAvatarUrl = @"avatarUrl";
static const NSString* kNickname = @"nickName";
static const NSString* kChatRoomId = @"chatroomId";

#define CONTAINVIEW_HEIGHT 50
#define SENDBUTTON_HEIGHT 30
#define SENDBUTTON_WIDTH 40
#define INPUT_WIDTH 120
#define GIFTBUTTON_WIDTH 28
#define EMOJIBUTTON_WIDTH 30

@interface BarrageTime : NSObject
@property (nonatomic,strong) NSString* identifier;
@property (nonatomic) NSTimeInterval beginTime;
@property (nonatomic) NSUInteger viewLength;
@property (nonatomic) CGFloat speed;
+ (instancetype)barrageTimeWithId:(NSString*)aId beginTime:(NSTimeInterval)aBeginTime viewLength:(NSUInteger)aViewLength speed:(CGFloat)aSpeed;
@end

@implementation BarrageTime
+ (instancetype)barrageTimeWithId:(NSString*)aId beginTime:(NSTimeInterval)aBeginTime viewLength:(NSUInteger)aViewLength speed:(CGFloat)aSpeed
{
    BarrageTime*barrageTime = [[BarrageTime alloc] init];
    if(barrageTime) {
        barrageTime.beginTime = aBeginTime;
        barrageTime.identifier = aId;
        barrageTime.viewLength = aViewLength;
        barrageTime.speed = aSpeed;
    }
    return barrageTime;
}
@end

@interface EmojiTextAttachment : NSTextAttachment
@property (nonatomic,strong) NSString* emojiStr;
@end

@implementation EmojiTextAttachment

@end

@interface ChatWidget () <ChatManagerDelegate,
                          UITextViewDelegate,
                          BarrageRendererDelegate,
                          GiftViewDelegate,
                          EmojiKeyboardDelegate,
                          AgoraUIContainerDelegate>
@property (nonatomic,strong) ChatManager* chatManager;
@property (nonatomic,strong) UITextView* inputField;
@property (nonatomic,strong) AgoraBaseUIContainer* containView;
@property (nonatomic,strong) UIButton* emojiButton;
@property (nonatomic,strong) UIButton* sendButton;
@property (nonatomic,strong) UIButton* giftButton;
@property (nonatomic,strong) BarrageRenderer * renderer;// 弹幕控制
@property (nonatomic) BOOL isShowBarrage;
@property (nonatomic,strong) EmojiKeyboardView *emojiKeyBoardView;
@property (nonatomic,strong) GiftView* giftView;
@property (nonatomic,strong) UITapGestureRecognizer *tap;
@property (nonatomic,strong) UILabel* barrageLable;
@property (nonatomic,strong) NSMutableArray<BarrageTime*>* barrageArray;
@property (nonatomic,strong) NSLock* dataLock;
@property (atomic,strong) NSMutableArray<BarrageMsgInfo*>* barrageInfoArray;
@property (nonatomic,weak) NSTimer* timerBarrage;
@property (nonatomic) NSInteger reserveBarrageCount;
@property (nonatomic,strong) NSLock* barrageLock;
@property (nonatomic,strong) NSThread* timerThread;
@property (nonatomic,strong) dispatch_semaphore_t seg;
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
    if(self.timerThread) {
        [self performSelector:@selector(closeTimer) onThread:self.timerThread withObject:nil waitUntilDone:NO];
        [self.timerThread cancel];
        self.timerThread = NULL;
    }
    
}

- (void)closeTimer
{
    if(self.timerBarrage) {
        [self.timerBarrage invalidate];
        self.timerBarrage = nil;
    }
}

#pragma mark - ChatWidget
- (void)initViews {
    self.isShowBarrage = YES;
    
    self.containView = [[AgoraBaseUIContainer alloc] initWithFrame:CGRectZero];
    self.containView.backgroundColor = [UIColor clearColor];
    self.containerView.backgroundColor = [UIColor clearColor];
    [self.containerView addSubview:self.containView];
    
    self.inputField = [[UITextView alloc] initWithFrame:CGRectZero];
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
    
    // 调整弹幕区域显示大小
    _renderer.canvasMargin = UIEdgeInsetsMake(10, 10, self.containerView.frame.size.height - 85, 10);
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
    [self.containerView addSubview:_renderer.view];
    [self.containerView sendSubviewToBack:_renderer.view];
}

- (void)startBarrage
{
    self.reserveBarrageCount = 0;
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
    size_t width = _renderer.view.frame.size.width;
    // 将字符串中的表情转换成表情图片富文本
    NSMutableAttributedString* attrString = [EMEmojiHelper convertStrings:aInfo.text];
    if(attrString.length > 50) {
        attrString = [attrString attributedSubstringFromRange:NSMakeRange(0, 50)];
        [attrString appendAttributedString:[[NSAttributedString alloc] initWithString: @"..."]];
    }
    self.barrageLable.attributedText = attrString;
    self.barrageLable.font = [UIFont systemFontOfSize:16];
    [self.barrageLable sizeToFit];
    NSInteger viewLength = self.barrageLable.bounds.size.width;
    if(aInfo.isGift)
    {
        viewLength += 80;
    }
    // 这个速度8s展示完全
    CGFloat speed = (width+viewLength)/8;
    descriptor.params[@"speed"] = [NSNumber numberWithFloat: speed];
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    // 设置delay保证不重叠
    CGFloat delay = [self getBarrageDelayByLength:viewLength speed:speed currentTime:currentTime msgId:aInfo.msgId];
    descriptor.params[@"delay"] = [NSNumber numberWithInteger:delay];

    descriptor.params[@"direction"] = @(BarrageWalkDirectionR2L);
    descriptor.params[@"side"] = @(BarrageWalkSideDefault);
    NSString* content = aInfo.text;
    if(aInfo.isGift)
    {
        descriptor.spriteName = NSStringFromClass([BarrageWalkSprite class]);
        descriptor.params[@"viewClassName"] = NSStringFromClass([AvatarBarrageView class]);
        descriptor.params[@"titles"] = @[content];
        if(aInfo.avatarUrl.length > 0)
            descriptor.params[@"avatarUrl"] = aInfo.avatarUrl;
        if(aInfo.giftUrl.length > 0){
            descriptor.params[@"giftUrl"] = aInfo.giftUrl;
        }
    }else{
        descriptor.spriteName = NSStringFromClass([BarrageWalkTextSprite class]);
        descriptor.params[@"attributedText"] = attrString;
        descriptor.params[@"textColor"] = [UIColor blueColor];
        descriptor.params[@"shadowColor"] = [UIColor blackColor];
        descriptor.params[@"shadowOffset"] = [NSValue valueWithCGSize:CGSizeMake(0, 1)];
        descriptor.params[@"fontSize"] = [NSNumber numberWithDouble:15.0];
        descriptor.params[@"fontFamily"] = @"PingFangSC-Medium";
    }

    descriptor.params[@"identifier"] = aInfo.msgId;
    descriptor.params[@"viewTm"] = [NSNumber numberWithDouble:viewLength/speed];

    return descriptor;
}

- (void)initData:(NSDictionary *)properties {
    self.seg = dispatch_semaphore_create(0);
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
    if(self.chatManager.isMuted || self.chatManager.isAllMuted)
        return;
    NSString* sendText = self.inputField.attributedText;
    __weak typeof(self) weakself = self;
    NSAttributedString*attr = self.inputField.attributedText;
    __block NSString* str = @"";
    [attr enumerateAttributesInRange:NSMakeRange(0, attr.length) options:0 usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
        EmojiTextAttachment* attachment = [attrs objectForKey:NSAttachmentAttributeName];
        if(attachment){
            NSString* fileType = attachment.emojiStr;
            str = [str stringByAppendingString:fileType];
        }else{
            NSAttributedString* tmp = [attr attributedSubstringFromRange:range];
            str = [str stringByAppendingString:tmp.string];
        }
    }];
    if(str.length > 0) {
        [self.chatManager sendCommonTextMsg:str];
    }
    self.inputField.text = @"";
    [self.inputField resignFirstResponder];
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]){
        [self sendButtonAction];
        return NO;
    }
    return YES;
}

#pragma mark - CustomKeyBoardDelegate

- (void)emojiItemDidClicked:(NSString *)item{
    if(self.chatManager.isMuted || self.chatManager.isAllMuted)
        return;
    NSRange selectedRange = [self selectedRange:self.inputField];
    NSMutableAttributedString* attrString = [self.inputField.attributedText mutableCopy];
    EmojiTextAttachment* attachMent = [[EmojiTextAttachment alloc] init];
    NSString* imageFileName = [[EMEmojiHelper sharedHelper].emojiFilesDic objectForKey:item];
    if(imageFileName.length == 0) return;
    attachMent.emojiStr = item;
    attachMent.bounds = CGRectMake(0, 0, 16, 16);
    attachMent.image = [UIImage imageNamedFromBundle:imageFileName];
    NSAttributedString *imageStr = [NSAttributedString attributedStringWithAttachment:attachMent];
    [attrString replaceCharactersInRange:selectedRange withAttributedString:imageStr];
    self.inputField.attributedText = attrString;
}

- (void)emojiDidDelete
{
    if(self.chatManager.isMuted || self.chatManager.isAllMuted)
        return;
    if ([self.inputField.attributedText length] > 0) {
        NSRange selectedRange = [self selectedRange:self.inputField];
        NSMutableAttributedString* attrString = [self.inputField.attributedText mutableCopy];
        if(selectedRange.length > 0)
        {
            [attrString deleteCharactersInRange:selectedRange];
        }else{
            if(selectedRange.location > 0)
                [attrString deleteCharactersInRange:NSMakeRange(selectedRange.location-1, 1)];
        }

        self.inputField.attributedText = attrString;
    }
}

- (NSRange)selectedRange:(UITextField*)textField
{
    UITextRange* range = [textField selectedTextRange];
    UITextPosition* beginning = textField.beginningOfDocument;
    UITextPosition* selectionStart = range.start;
    UITextPosition* selectionEnd = range.end;
    const NSInteger location = [textField offsetFromPosition:beginning toPosition:selectionStart];
    const NSInteger length = [textField offsetFromPosition:selectionStart toPosition:selectionEnd];

    return NSMakeRange(location, length);
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
            self.inputField.frame = CGRectMake(20, 10, self.containView.bounds.size.width - SENDBUTTON_WIDTH - EMOJIBUTTON_WIDTH - 30, CONTAINVIEW_HEIGHT-20);
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
                    [weakself pushBarrageMsgInfos:msg];
                }
            }
        }
    });
    
}

- (void)barrageMessageDidSend:(BarrageMsgInfo*)aInfo
{
    if(self.isShowBarrage) {
        if(aInfo.msgId.length > 0 && aInfo.text.length > 0)
            [self pushBarrageMsgInfos:aInfo];
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

#pragma mark - BarrageMsgInfo
- (void)pushBarrageMsgInfos:(BarrageMsgInfo*)barrage
{
    [self.barrageLock lock];
    [self.barrageInfoArray addObject:barrage];
    [self.barrageLock unlock];
    if(!self.timerThread) {
        __weak typeof(self) weakself = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            weakself.timerThread = [NSThread currentThread];
            if(!weakself.timerBarrage) {
                weakself.timerBarrage = [NSTimer block_scheduledTimerWithTimeInterval:0.5 block:^{
                    [weakself showBarrage];
                } repeats:YES];
                NSRunLoop* runloop = [NSRunLoop currentRunLoop];
                [runloop addTimer:weakself.timerBarrage forMode:NSDefaultRunLoopMode];
                [runloop run];
            }
            dispatch_semaphore_signal(weakself.seg);
        });
        dispatch_semaphore_wait(weakself.seg, 2.0*NSEC_PER_SEC);
        
    }
}

- (BarrageMsgInfo*)popBarrageMsgInfo
{
    if(self.barrageInfoArray.count == 0)
        return nil;
    [self.barrageLock lock];
    BarrageMsgInfo* msgInfo = [self.barrageInfoArray firstObject];
    [self.barrageInfoArray removeObjectAtIndex:0];
    [self.barrageLock unlock];
    return msgInfo;
}

- (void)showBarrage
{
    if(self.reserveBarrageCount >= 3 || !self.isShowBarrage)
        return;
    BarrageMsgInfo* barrageMsgInfo = nil;
    while(barrageMsgInfo = [self popBarrageMsgInfo]) {
        __weak typeof(self) weakself = self;
        
        if(barrageMsgInfo) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself.renderer receive:[self buildBarrageDescriptor:barrageMsgInfo]];
                weakself.reserveBarrageCount++;
            });
        }
    }
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

- (void)barrageRenderer:(BarrageRenderer *)renderer spriteStage:(BarrageSpriteStage)stage spriteParams:(NSDictionary *)params
{
    if(stage == BarrageSpriteStageEnd) {
        NSString* msgId = [params objectForKey:@"identifier"];
        if(msgId.length > 0) {
            [self.dataLock lock];
            for (BarrageTime* bt in self.barrageArray) {
                if([msgId isEqualToString:bt.identifier]) {
                    [self.barrageArray removeObject:bt];
                    break;
                }
            }
            [self.dataLock unlock];
        }
    }
    if(stage == BarrageSpriteStageBegin) {
        NSNumber* viewTm = [params objectForKey:@"viewTm"];
        if(viewTm) {
            __weak typeof(self) weakself = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, viewTm.doubleValue * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                if(self.reserveBarrageCount > 0)
                    self.reserveBarrageCount--;
            });
        }else{
            if(self.reserveBarrageCount > 0)
                self.reserveBarrageCount--;
        }
        
    }
}

- (UILabel*)barrageLable
{
    if(!_barrageLable) {
        _barrageLable = [[UILabel alloc] init];
    }
    return _barrageLable;
}

- (NSMutableArray<BarrageTime*>*)barrageArray
{
    if(!_barrageArray) {
        _barrageArray = [NSMutableArray<BarrageTime*> array];
    }
    return _barrageArray;
}

- (NSMutableArray<BarrageMsgInfo*>*)barrageInfoArray
{
    if(!_barrageInfoArray) {
        _barrageInfoArray = [NSMutableArray<BarrageMsgInfo*> array];
    }
    return _barrageInfoArray;
}

- (CGFloat)getBarrageDelayByLength:(NSUInteger)aViewLength speed:(CGFloat)aSpeed currentTime:(NSTimeInterval)aCurrentTime msgId:(NSString*)msgId
{
    [self.dataLock lock];
    // 最多显示3行弹幕，如果增加需要修改
    if(self.barrageArray.count >= 3) {
        NSTimeInterval minBeginTimeInterval = 0;
        NSMutableArray* arr = [NSMutableArray array];
        NSUInteger index = 0;
        NSUInteger minIndex = 0;
        for(BarrageTime* info in self.barrageArray) {
            // 该弹幕全部显示到该行的时间
            NSTimeInterval tmAllShow = info.beginTime + aViewLength/aSpeed;
            // 计算恰好与该弹幕不重叠的时间,留800ms的余量
            NSTimeInterval tmToBegin = 0;
            if(aSpeed <= info.speed) {
                tmToBegin = tmAllShow+0.8;
            }else{
                CGFloat width = self.renderer.view.bounds.size.width;
                CGFloat t1 = width * (1-info.speed/aSpeed)/info.speed;
                tmToBegin = tmAllShow+t1+0.8;
            }
            [arr addObject:[NSNumber numberWithDouble:tmToBegin]];
            if(minBeginTimeInterval < 1 || minBeginTimeInterval>tmToBegin) {
                minBeginTimeInterval = tmToBegin;
                minIndex = index;
            }
            index++;
        }
        if(minBeginTimeInterval < aCurrentTime)
            minBeginTimeInterval = aCurrentTime;
        BarrageTime* bt = [BarrageTime barrageTimeWithId:msgId beginTime:minBeginTimeInterval viewLength:aViewLength speed:aSpeed];
        [self.barrageArray replaceObjectAtIndex:minIndex withObject:bt];
        [self.dataLock unlock];
        return minBeginTimeInterval-aCurrentTime;
    }else{
        BarrageTime* bt = [BarrageTime barrageTimeWithId:msgId beginTime:aCurrentTime viewLength:aViewLength speed:aSpeed];
        [self.barrageArray addObject:bt];
        [self.dataLock unlock];
        return 0;
    }
}

-(NSLock*)dataLock
{
    if(!_dataLock) {
        _dataLock = [[NSLock alloc] init];
    }
    return _dataLock;
}

-(NSLock*)barrageLock
{
    if(!_barrageLock) {
        _barrageLock = [[NSLock alloc] init];
    }
    return _barrageLock;
}

@end
