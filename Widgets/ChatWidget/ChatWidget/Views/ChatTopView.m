//
//  ChatTopView.m
//  AgoraEducation
//
//  Created by lixiaoming on 2021/6/21.
//

#import "ChatTopView.h"
#import "UIImage+ChatExt.h"
#import <Masonry/Masonry.h>
#import "ChatWidget+Localizable.h"
const static NSInteger TAG_BASE = 1000;

@interface ChatTopView ()
@property (nonatomic,strong) UIButton* chatButton;
@property (nonatomic,strong) UIButton* hideButton;
@property (nonatomic,strong) UIButton* announcementButton;
@property (nonatomic,strong) UIView* tabView;
@property (nonatomic,strong) UIView* selLine;
@end

@implementation ChatTopView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self) {
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews
{
    self.backgroundColor = [UIColor whiteColor];
    self.layer.borderWidth = 1;
    self.layer.borderColor = [UIColor colorWithRed:236/255.0 green:236/255.0 blue:241/255.0 alpha:1.0].CGColor;
    self.layer.cornerRadius = 5;
    
    int width = 16;
    self.hideButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.hideButton.tag = TAG_BASE + 2;
    [self.hideButton setImage:[UIImage imageNamedFromBundle:@"icon_hide"] forState:UIControlStateNormal];
    [self.hideButton addTarget:self action:@selector(hideAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.hideButton];
    [self.hideButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).with.offset(-14);
        make.centerY.equalTo(self);
        make.height.equalTo(@(width));
        make.width.equalTo(@(width));
    }];
    
    self.tabView = [[UIView alloc] init];
    [self addSubview:self.tabView];
    [self.tabView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.right.equalTo(self.hideButton.mas_left);
        make.height.equalTo(self);
        make.top.equalTo(self);
    }];
    
    self.chatButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.chatButton setTitle:[ChatWidget LocalizedString:@"ChatText"] forState:UIControlStateNormal];
    [self.chatButton setTitleColor:[UIColor colorWithRed:25/255.0 green:25/255.0 blue:25/255.0 alpha:1.0] forState:UIControlStateNormal];
    self.chatButton.tag = TAG_BASE;
    self.chatButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [self.chatButton addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.tabView addSubview:self.chatButton];
    [self.chatButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.top.equalTo(self.tabView);
        make.height.equalTo(self.tabView);
        make.width.equalTo(self.tabView).multipliedBy(0.5);
    }];
    
    self.badgeView = [[CustomBadgeView alloc] init];
    self.announcementbadgeView = [[CustomBadgeView alloc] init];
    [self addSubview:self.badgeView];
    [self addSubview:self.announcementbadgeView];
    self.badgeView.hidden = YES;
    self.announcementbadgeView.hidden = YES;
    [self.badgeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(10);
        make.width.height.equalTo(@(self.badgeView.badgeSize));
        make.centerX.equalTo(self.chatButton).offset(20);
    }];
    
    self.announcementButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.announcementButton setTitle:[ChatWidget LocalizedString:@"ChatAnnouncement"] forState:UIControlStateNormal];
    self.announcementButton.tag = TAG_BASE + 1;
    self.announcementButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [self.announcementButton addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.announcementButton setTitleColor:[UIColor colorWithRed:123/255.0 green:136/255.0 blue:160/255.0 alpha:1.0] forState:UIControlStateNormal];
    [self.tabView addSubview:self.announcementButton];
    [self.announcementButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.chatButton.mas_right);
        make.top.equalTo(self.tabView);
        make.height.equalTo(self.tabView);
        make.width.equalTo(self.tabView).multipliedBy(0.5);
    }];
    [self.announcementbadgeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(10);
        make.width.height.equalTo(@(self.badgeView.badgeSize));
        make.centerX.equalTo(self.announcementButton).offset(20);
    }];
    
    self.selLine = [[UIView alloc] init];
    self.selLine.backgroundColor = [UIColor colorWithRed:53/255.0 green:123/255.0 blue:246/255.0 alpha:1.0];
    [self.tabView addSubview:self.selLine];
    
    [self.selLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.tabView);
        make.bottom.equalTo(self.tabView);
        make.height.equalTo(@2);
        make.width.equalTo(self.tabView).multipliedBy(0.5);
    }];
    
    self.currentTab = 0;
    [self noticeSelectedTab];
}

- (void)clickAction:(UIButton*)button
{
    self.currentTab = button.tag - TAG_BASE;
}

- (void)hideAction
{
    if(self.delegate) {
        [self.delegate chatTopViewDidClickHide];
    }
}

- (void)setCurrentTab:(NSInteger)currentTab
{
    if(_currentTab != currentTab) {
        _currentTab = currentTab;
        if(_currentTab == 0) {
            self.isShowRedNotice = NO;
            [self.selLine mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.chatButton);
                make.bottom.equalTo(self.tabView);
                make.height.equalTo(@2);
                make.width.equalTo(self.tabView).multipliedBy(0.5);
            }];
            [self.chatButton setTitleColor:[UIColor colorWithRed:25/255.0 green:25/255.0 blue:25/255.0 alpha:1.0] forState:UIControlStateNormal];
            [self.announcementButton setTitleColor:[UIColor colorWithRed:123/255.0 green:136/255.0 blue:160/255.0 alpha:1.0] forState:UIControlStateNormal];
        }else{
            self.isShowAnnouncementRedNotice = NO;
            [self.selLine mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.announcementButton);
                make.bottom.equalTo(self.tabView);
                make.height.equalTo(@2);
                make.width.equalTo(self.tabView).multipliedBy(0.5);
            }];
            [self.announcementButton setTitleColor:[UIColor colorWithRed:25/255.0 green:25/255.0 blue:25/255.0 alpha:1.0] forState:UIControlStateNormal];
            [self.chatButton setTitleColor:[UIColor colorWithRed:123/255.0 green:136/255.0 blue:160/255.0 alpha:1.0] forState:UIControlStateNormal];
        }
        [self noticeSelectedTab];
    }
}

- (void)noticeSelectedTab
{
    if(self.delegate) {
        [self.delegate chatTopViewDidSelectedChanged:self.currentTab];
    }
}

- (void)setIsShowRedNotice:(BOOL)isShowRedNotice
{
    _isShowRedNotice = isShowRedNotice;
    if(isShowRedNotice){
        self.badgeView.hidden = NO;
    }else{
        self.badgeView.hidden = YES;
    }
}

- (void)setIsShowAnnouncementRedNotice:(BOOL)isShowAnnouncementRedNotice
{
    _isShowAnnouncementRedNotice = isShowAnnouncementRedNotice;
    if(isShowAnnouncementRedNotice){
        self.announcementbadgeView.hidden = NO;
    }else{
        self.announcementbadgeView.hidden = YES;
    }
}

@end
