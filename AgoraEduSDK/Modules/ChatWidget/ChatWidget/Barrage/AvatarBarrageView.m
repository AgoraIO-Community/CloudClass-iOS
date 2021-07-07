//
//  AvatarBarrageView.m
//  AgoraEducation
//
//  Created by lixiaoming on 2021/5/12.
//  Copyright © 2021 Agora. All rights reserved.
//

#import "AvatarBarrageView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <BarrageRenderer/UIView+BarrageView.h>

@interface AvatarBarrageView ()
@property(nonatomic,strong)UIImageView *imageView;
@property(nonatomic,strong)UIImageView *giftView;
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,assign)NSTimeInterval time;
@property(nonatomic,strong)NSArray *titles;
@end

@implementation AvatarBarrageView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self loadSubviews];
    }
    return self;
}

- (void)loadSubviews
{
    self.backgroundColor = [UIColor colorWithRed:0.3 green:0.8 blue:0.2 alpha:0.2];
    self.layer.cornerRadius = 8;
    _imageView = [[UIImageView alloc] init];
    self.imageView.image = [UIImage imageNamed:@"icon_gift"];
    [self addSubview:self.imageView];
    
    _titleLabel = [[UILabel alloc] init];
    self.titleLabel.textColor = [UIColor purpleColor];
    self.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    [self addSubview:self.titleLabel];
    
    _giftView = [[UIImageView alloc] init];
    self.giftView.image = [UIImage imageNamed:@"icon_gift"];
    [self addSubview:self.giftView];
}

- (void)layoutSubviews
{
    self.backgroundColor = [UIColor colorWithRed:0.3 green:0.8 blue:0.2 alpha:0.2];
    CGFloat const imageWidth = 30.0f;
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(0, 0, imageWidth, imageWidth);
    self.titleLabel.frame = CGRectMake(imageWidth+5, 0, self.bounds.size.width-imageWidth-40, self.bounds.size.height);
    self.giftView.frame = CGRectMake(self.bounds.size.width-30, 0, imageWidth, imageWidth);
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGFloat const imageWidth = 30.0f;
    UILabel *prototypeLabel = self.titleLabel;
    CGFloat maxWidth = 0;
    CGFloat maxHeight = 0;
    for (NSString *title in self.titles) {
        prototypeLabel.text = title;
        CGSize titleSize = [prototypeLabel sizeThatFits:CGSizeMake(10000, 10)];
        if (titleSize.width>maxWidth) {
            maxWidth = titleSize.width;
        }
        if (titleSize.height>maxHeight) {
            maxHeight = titleSize.height;
        }
    }
    if (imageWidth>maxHeight) {
        maxHeight = imageWidth;
    }
    maxWidth+= imageWidth + 10 + imageWidth;
    return CGSizeMake(maxWidth, maxHeight);
}

#pragma mark - BarrageViewProtocol

- (void)configureWithParams:(NSDictionary *)params
{
    [super configureWithParams:params];
    self.titles = params[@"titles"];
    self.titleLabel.text = [self.titles firstObject];
    NSString* avatarUrl = params[@"avatarUrl"];
    if(avatarUrl.length > 0) {
        NSURL* url =  [NSURL URLWithString:avatarUrl];
        if(url)
            [self.imageView sd_setImageWithURL:url];
    }
    NSString* giftUrl = params[@"giftUrl"];
    if(giftUrl.length > 0) {
        NSURL* url =  [NSURL URLWithString:giftUrl];
        if(url)
            [self.giftView sd_setImageWithURL:url];
    }
    
}

- (void)updateWithTime:(NSTimeInterval)time
{
    _time = time;
    [self updateTexts];
    [self setNeedsLayout];
}

- (void)updateTexts
{
    if (!self.titles.count) {
        return;
    }
    NSInteger frame = ((NSInteger)floor(self.time*5)) % self.titles.count;
    self.titleLabel.text = self.titles[frame];
}

@end
