//
//  AgoraRefreshAutoGifFooter.m
//  AgoraRefreshExample
//
//  Created by MJ Lee on 15/4/24.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "AgoraRefreshAutoGifFooter.h"

@interface AgoraRefreshAutoGifFooter()
{
    __unsafe_unretained UIImageView *_gifView;
}
/** 所有状态对应的动画图片 */
@property (strong, nonatomic) NSMutableDictionary *stateImages;
/** 所有状态对应的动画时间 */
@property (strong, nonatomic) NSMutableDictionary *stateDurations;
@end

@implementation AgoraRefreshAutoGifFooter
#pragma mark - 懒加载
- (UIImageView *)gifView
{
    if (!_gifView) {
        UIImageView *gifView = [[UIImageView alloc] init];
        [self addSubview:_gifView = gifView];
    }
    return _gifView;
}

- (NSMutableDictionary *)stateImages
{
    if (!_stateImages) {
        self.stateImages = [NSMutableDictionary dictionary];
    }
    return _stateImages;
}

- (NSMutableDictionary *)stateDurations
{
    if (!_stateDurations) {
        self.stateDurations = [NSMutableDictionary dictionary];
    }
    return _stateDurations;
}

#pragma mark - 公共方法
- (void)setImages:(NSArray *)images duration:(NSTimeInterval)duration forState:(AgoraRefreshState)state
{
    if (images == nil) return;
    
    self.stateImages[@(state)] = images;
    self.stateDurations[@(state)] = @(duration);
    
    /* 根据图片设置控件的高度 */
    UIImage *image = [images firstObject];
    if (image.size.height > self.agora_refresh_h) {
        self.agora_refresh_h = image.size.height;
    }
}

- (void)setImages:(NSArray *)images forState:(AgoraRefreshState)state
{
    [self setImages:images duration:images.count * 0.1 forState:state];
}

#pragma mark - 实现父类的方法
- (void)prepare
{
    [super prepare];
    
    // 初始化间距
    self.labelLeftInset = 20;
}

- (void)placeSubviews
{
    [super placeSubviews];
    
    if (self.gifView.constraints.count) return;
    
    self.gifView.frame = self.bounds;
    if (self.isRefreshingTitleHidden) {
        self.gifView.contentMode = UIViewContentModeCenter;
    } else {
        self.gifView.contentMode = UIViewContentModeRight;
        self.gifView.agora_refresh_w = self.agora_refresh_w * 0.5 - self.labelLeftInset - self.stateLabel.agora_textWidth * 0.5;
    }
}

- (void)setState:(AgoraRefreshState)state
{
    AgoraRefreshCheckState
    
    // 根据状态做事情
    if (state == AgoraRefreshStateRefreshing) {
        NSArray *images = self.stateImages[@(state)];
        if (images.count == 0) return;
        [self.gifView stopAnimating];
        
        self.gifView.hidden = NO;
        if (images.count == 1) { // 单张图片
            self.gifView.image = [images lastObject];
        } else { // 多张图片
            self.gifView.animationImages = images;
            self.gifView.animationDuration = [self.stateDurations[@(state)] doubleValue];
            [self.gifView startAnimating];
        }
    } else if (state == AgoraRefreshStateNoMoreData || state == AgoraRefreshStateIdle) {
        [self.gifView stopAnimating];
        self.gifView.hidden = YES;
    }
}
@end

