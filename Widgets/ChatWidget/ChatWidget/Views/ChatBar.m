//
//  ChatBar.m
//  ChatWidget
//
//  Created by lixiaoming on 2021/7/5.
//

#import "ChatBar.h"
#import "UIImage+ChatExt.h"
#import "InputingView.h"
#import "ChatWidget+Localizable.h"


#define CONTAINVIEW_HEIGHT 40
#define SENDBUTTON_HEIGHT 30
#define SENDBUTTON_WIDTH 40
#define INPUT_WIDTH 120
#define EMOJIBUTTON_WIDTH 40

@interface ChatBar ()<InputingViewDelegate>
@property (nonatomic,strong) UIButton* inputButton;
@property (nonatomic,strong) UIButton* emojiButton;
@property (nonatomic,strong) InputingView* inputingView;
@property (nonatomic,strong) UIButton* exitInputButton;
@property (nonatomic) CGRect oldframe;
@end

@implementation ChatBar
- (instancetype)init
{
    self = [super init];
    if(self) {
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews
{
    self.backgroundColor = [UIColor colorWithRed:236/255.0 green:236/255.0 blue:241/255.0 alpha:1.0];
    self.inputButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.inputButton setTitle:[ChatWidget LocalizedString:@"ChatPlaceholderText"] forState:UIControlStateNormal] ;
    self.inputButton.backgroundColor = [UIColor clearColor];
    [self.inputButton setTitleColor:[UIColor colorWithRed:125/255.0 green:135/255.0 blue:152/255.0 alpha:1.0] forState:UIControlStateNormal];
    [self.inputButton addTarget:self action:@selector(InputAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.inputButton];
    self.inputButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.inputButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    self.emojiButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.emojiButton setImage:[UIImage imageNamedFromBundle:@"icon_emoji"]
                      forState:UIControlStateNormal];
    [self.emojiButton setImage:[UIImage imageNamedFromBundle:@"icon_keyboard"]
                      forState:UIControlStateSelected];
    self.emojiButton.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.emojiButton];
    [self.emojiButton addTarget:self
                         action:@selector(emojiButtonAction)
               forControlEvents:UIControlEventTouchUpInside];
    
    UIWindow * window=[[[UIApplication sharedApplication] delegate] window];
    self.inputingView = [[InputingView alloc] initWithFrame:CGRectMake(0, 100, window.frame.size.width, 40)];
    self.inputingView.delegate = self;
    self.exitInputButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.exitInputButton.frame = window.frame;
    [self.exitInputButton addTarget:self action:@selector(ExitInputAction) forControlEvents:UIControlEventTouchUpInside];
    [window addSubview:self.exitInputButton];
    [window bringSubviewToFront:self.inputingView];
    [window addSubview:self.inputingView];
    self.inputingView.exitInputButton = self.exitInputButton;
    self.inputingView.hidden = YES;
    self.exitInputButton.hidden = YES;
}

- (void)ExitInputAction
{
    [self.inputingView.inputField resignFirstResponder];
    self.inputingView.hidden = YES;
    self.exitInputButton.hidden = YES;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.oldframe = self.frame;
    
    self.inputButton.frame = CGRectMake(10,0,self.bounds.size.width - EMOJIBUTTON_WIDTH - SENDBUTTON_WIDTH - 10,
                                           CONTAINVIEW_HEIGHT);
    
    self.emojiButton.frame = CGRectMake(self.bounds.size.width - EMOJIBUTTON_WIDTH,
                                        8,
                                        24,
                                        24);
}

- (void)InputAction
{
    self.inputingView.hidden = NO;
    self.exitInputButton.hidden = NO;
    if([self.inputingView.inputField isFirstResponder])
        [self.inputingView.inputField resignFirstResponder];
    [self.inputingView.inputField becomeFirstResponder];
}
- (void)emojiButtonAction
{
    [self InputAction];
    [self.inputingView.emojiButton setSelected:YES];
    [self.inputingView changeKeyBoardType];
}

#pragma mark - setter
- (void)setIsMuted:(BOOL)isMuted
{
    _isMuted = isMuted;
    [self updateMuteState];
}

- (void)setIsAllMuted:(BOOL)isAllMuted
{
    _isAllMuted = isAllMuted;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateMuteState];
    });
}

- (void)updateMuteState
{
    if(self.isAllMuted) {
        [self.inputButton setTitle:[ChatWidget LocalizedString:@"ChatAllMute"] forState:UIControlStateNormal];
        [self.inputButton setEnabled:NO];
        self.emojiButton.enabled = NO;
        
    }else{
        if(self.isMuted){
            [self.inputButton setTitle:[ChatWidget LocalizedString:@"ChatMute"] forState:UIControlStateNormal];
            [self.inputButton setEnabled:NO];
            self.emojiButton.enabled = NO;
        }else{
            [self.inputButton setTitle:[ChatWidget LocalizedString:@"ChatPlaceholderText"] forState:UIControlStateNormal];
            [self.inputButton setEnabled:YES];
            self.emojiButton.enabled = YES;
        }
    }
}

#pragma mark - InputingViewDelegate
- (void)msgWillSend:(NSString *)aMsgText
{
    [self.delegate msgWillSend:aMsgText];
}

- (void)keyBoardDidHide:(NSString*)aText
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(aText.length > 0) {
            [self.inputButton setTitle:aText forState:UIControlStateNormal];
        }else{
            if(!self.isMuted && !self.isAllMuted)
                [self.inputButton setTitle:[ChatWidget LocalizedString:@"ChatPlaceholderText"] forState:UIControlStateNormal];
        }
    });
    
}


@end
