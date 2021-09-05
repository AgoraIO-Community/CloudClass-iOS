//
//  InputingView.m
//  ChatWidget
//
//  Created by lixiaoming on 2021/7/7.
//

#import "InputingView.h"
#import "EmojiKeyboardView.h"
#import "UIImage+ChatExt.h"
#import "ChatWidget+Localizable.h"

#define CONTAINVIEW_HEIGHT 40
#define SENDBUTTON_HEIGHT 30
#define SENDBUTTON_WIDTH 60
#define INPUT_WIDTH 120
#define EMOJIBUTTON_WIDTH 40
#define GAP 60

@interface InputingView ()<UITextFieldDelegate,EmojiKeyboardDelegate>
@property (nonatomic,strong) EmojiKeyboardView *emojiKeyBoardView;
@end

@implementation InputingView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self) {
        [self setupSubViews];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupSubViews
{
    self.sendButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.sendButton setTitle:[ChatWidget LocalizedString:@"ChatSendText"]
                     forState:UIControlStateNormal];
    [self addSubview:self.sendButton];
    self.sendButton.backgroundColor = [UIColor colorWithRed:53/255.0 green:123/255.0 blue:246/255.0 alpha:1.0];
    self.sendButton.layer.cornerRadius = 16;
    [self.sendButton setTitleColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0] forState:UIControlStateNormal];
    self.sendButton.frame = CGRectMake(self.bounds.size.width - SENDBUTTON_WIDTH-GAP,
                                       CONTAINVIEW_HEIGHT-SENDBUTTON_HEIGHT-5,
                                       SENDBUTTON_WIDTH,
                                       SENDBUTTON_HEIGHT);
    [self.sendButton addTarget:self
                        action:@selector(sendButtonAction)
              forControlEvents:UIControlEventTouchUpInside];
    
    self.backgroundColor = [UIColor colorWithRed:236/255.0 green:236/255.0 blue:241/255.0 alpha:1.0];
    self.inputField = [[UITextField alloc] initWithFrame:CGRectMake(GAP,5,self.bounds.size.width - EMOJIBUTTON_WIDTH - SENDBUTTON_WIDTH - GAP*2-20,
                                                                    CONTAINVIEW_HEIGHT-10)];
    self.inputField.layer.backgroundColor = [UIColor whiteColor].CGColor;
    self.inputField.layer.cornerRadius = 16;
    self.inputField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 16, 0)];
    self.inputField.leftView.userInteractionEnabled = NO;
    self.inputField.leftViewMode = UITextFieldViewModeAlways;
    self.inputField.backgroundColor = [UIColor whiteColor];
    self.inputField.placeholder = [ChatWidget LocalizedString:@"ChatPlaceholderText"];
    //self.inputField.layer.cornerRadius = 15;
    self.inputField.returnKeyType = UIReturnKeySend;
    self.inputField.delegate = self;
    self.inputField.inputAssistantItem.leadingBarButtonGroups = [NSArray array];
    self.inputField.inputAssistantItem.trailingBarButtonGroups = [NSArray array];
    [self addSubview:self.inputField];
    
    self.emojiButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.emojiButton setImage:[UIImage imageNamedFromBundle:@"icon_emoji"]
                      forState:UIControlStateNormal];
    [self.emojiButton setImage:[UIImage imageNamedFromBundle:@"icon_keyboard"]
                      forState:UIControlStateSelected];
    self.emojiButton.contentMode = UIViewContentModeScaleAspectFit;
    self.emojiButton.frame = CGRectMake(self.bounds.size.width - EMOJIBUTTON_WIDTH - SENDBUTTON_WIDTH - GAP,
                                        8,
                                        24,
                                        24);
    [self addSubview:self.emojiButton];
    [self.emojiButton addTarget:self
                         action:@selector(emojiButtonAction)
               forControlEvents:UIControlEventTouchUpInside];
    
    self.emojiKeyBoardView = [[EmojiKeyboardView alloc] initWithFrame:CGRectMake(0,0,self.bounds.size.width,176)];
    self.emojiKeyBoardView.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillChangeFrame:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
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

- (void)sendMsg
{
    self.hidden = YES;
    self.exitInputButton.hidden = YES;
    NSString* sendText = self.inputField.text;
        if(sendText.length > 0) {
            [self.delegate msgWillSend:sendText];
        }
    self.inputField.text = @"";
    [self.inputField resignFirstResponder];
}

- (void)sendButtonAction
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(sendMsg) object:nil];
    [self performSelector:@selector(sendMsg) withObject:nil afterDelay:0.1];
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
        CGRect rect=[self convertRect: self.bounds toView:window];    //获取控件view的相对坐标
        {
            CGRect lastframe = self.frame;
            self.frame = CGRectMake(lastframe.origin.x, lastframe.origin.y - (rect.origin.y - keyboardFrame.origin.y) - CONTAINVIEW_HEIGHT, lastframe.size.width, CONTAINVIEW_HEIGHT);
            
        }
        
    }];
}


#pragma mark --键盘收回
- (void)keyboardDidHide:(NSNotification *)notification{
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:duration animations:^{
        if(duration>0.000001)
        {
            self.hidden = YES;
            self.exitInputButton.hidden = YES;
        }
        [self.delegate keyBoardDidHide:self.inputField.text];
    }];
}

- (void)emojiButtonAction
{
    [self.inputField becomeFirstResponder];
    [self.emojiButton setSelected:!self.emojiButton.isSelected];
    [self changeKeyBoardType];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
