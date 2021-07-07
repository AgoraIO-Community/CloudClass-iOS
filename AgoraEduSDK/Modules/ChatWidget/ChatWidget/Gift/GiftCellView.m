//
//  GiftCellView.m
//  AgoraEducation
//
//  Created by lixiaoming on 2021/5/18.
//  Copyright © 2021 Agora. All rights reserved.
//

#import "GiftCellView.h"
#import <SDWebImage/UIButton+WebCache.h>

@interface GiftCellView ()
// 背景
@property (nonatomic,strong) UIView* backView;
// 礼物图片
@property (nonatomic,strong) UIButton* giftButton;
// 礼物描述
@property (nonatomic,strong) UILabel* giftDescription;
// 学分描述
@property (nonatomic,strong) UILabel* creditLable;
// 赠送
@property (nonatomic,strong) UIButton* sendButton;
@end

@implementation GiftCellView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame type:(GiftType)giftType
{
    self = [super initWithFrame:frame];
    if(self) {
        self.giftType = giftType;
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews
{
    self.giftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.giftButton.frame = CGRectMake(self.bounds.size.width/2-25, 10, 48, 48);
    [self addSubview:self.giftButton];
    [self.giftButton addTarget:self action:@selector(selectGiftAction) forControlEvents:UIControlEventTouchUpInside];
    
    self.giftDescription = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, self.bounds.size.width, 28)];
    self.giftDescription.textAlignment = NSTextAlignmentCenter;
    self.giftDescription.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    [self.giftDescription setFont:[UIFont systemFontOfSize:13]];
    [self addSubview:self.giftDescription];
    
    self.creditLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 90, self.bounds.size.width, 18)];
    self.creditLable.textAlignment = NSTextAlignmentCenter;
    self.creditLable.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
    [self.creditLable setFont:[UIFont systemFontOfSize:11]];
    [self addSubview:self.creditLable];
    
    self.sendButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.sendButton.frame = CGRectMake(0, 80, self.bounds.size.width, 30);
    [self.sendButton setTitle:@"赠送" forState:UIControlStateNormal];
    [self.sendButton setBackgroundColor:[UIColor colorWithRed:0/255.0 green:152/255.0 blue:255/255.0 alpha:1.0]];
    [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self addSubview:self.sendButton];
    self.sendButton.layer.cornerRadius = 3;
    [self.sendButton addTarget:self action:@selector(sendGiftAction) forControlEvents:UIControlEventTouchUpInside];
    
    self.backView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, self.bounds.size.width, 70)];
    self.backView.backgroundColor = [UIColor grayColor];
    self.backView.alpha = 0.1;
    [self addSubview:self.backView];
    
    [self updateGift];
    [self setGiftSelected:NO];
    
    
}

- (void)updateGift
{
    NSNumber* credit = [[GiftCellView giftCredits] objectAtIndex:self.giftType];
    self.credit = [credit integerValue];
    self.giftDescription.text = [[GiftCellView giftNames] objectAtIndex:self.giftType];
    self.creditLable.text = [NSString stringWithFormat:@"%ld学分",self.credit];
    NSString* urlStr = [[GiftCellView giftUrls] objectAtIndex:self.giftType];
    if(urlStr.length > 0 ){
        NSURL* url = [NSURL URLWithString:urlStr];
        if(url) {
            [self.giftButton sd_setImageWithURL:url forState:UIControlStateNormal completed:nil];
        }
        
    }
}

- (void)setGiftSelected:(BOOL)aIsSelected
{
    if(aIsSelected) {
        self.sendButton.hidden = NO;
        self.creditLable.frame = CGRectMake(0, 60, self.bounds.size.width, 18);
        self.giftDescription.hidden = YES;
        self.backView.hidden = NO;
        if(self.delegate) {
            [self.delegate giftDidSelected:self];
        }
    }else{
        self.sendButton.hidden = YES;
        self.giftDescription.hidden = NO;
        self.backView.hidden = YES;
        self.creditLable.frame = CGRectMake(0, 90, self.bounds.size.width, 18);
    }
}

- (void)sendGiftAction
{
    if(self.delegate) {
        [self.delegate sendGift:self];
    }
}

- (void)selectGiftAction
{
    
    [self setGiftSelected:YES];
}

+ (NSArray<NSString*>*)giftDescriptions
{
    return @[@"呐～这朵鲜花送给你",@"老师好棒，我是你的铁粉",@"讲的好，加鸡腿",@"一起干了这杯82年的可乐",@"老师辛苦了，润润喉",@"给老师回回血",@"神仙老师，浑身都是优点",];
}
+ (NSArray<NSNumber*>*)giftCredits
{
    return @[@50,@100,@200,@200,@200,@500,@500];
}

+ (NSArray<NSString*>*)giftNames
{
    return @[@"鲜花",@"比心",@"鸡腿",@"可乐",@"润喉糖",@"回血",@"火箭"];
}

+ (NSArray<NSString*>*)giftUrls
{
    return @[@"https://lanhu.oss-cn-beijing.aliyuncs.com/SketchPng00ac5efe8c1d9a682b605523806cba0a7663025682aceda8973fd30f4e9d25aa",@"https://lanhu.oss-cn-beijing.aliyuncs.com/SketchPnga261018b5c2d2d1b0fb81d42ea8149f2bed327c2b06afeedcba7d0dd1bc70613",@"https://lanhu.oss-cn-beijing.aliyuncs.com/SketchPngb457abd9d2e7f4561a59d22a51db8f6622a9fcec37ed6b8d0d1e239c73da65e6",@"https://lanhu.oss-cn-beijing.aliyuncs.com/SketchPngebbd7053ac2c14d970abc8f73d84d3c24183ef6a6872bf1f64125b43d0dbdfd1",@"https://lanhu.oss-cn-beijing.aliyuncs.com/SketchPngbb46fbcc43fbbf8e1bd4cbbbf9039c6f145a0238e0db2b5c422d94d4d51c5ffc",@"https://lanhu.oss-cn-beijing.aliyuncs.com/SketchPng8001de704f6f6b801a88bdfa4c36765c1e7b162eee0dbc57d82ecd1ae9385aec",@"https://lanhu.oss-cn-beijing.aliyuncs.com/SketchPnge79dd141528e728de3f138525972396633e0d925aae12eb311f566bc8eb8ee9e"];
}

@end
