//
//  AgoraRefreshAutoNormalFooter.m
//  AgoraRefreshExample
//
//  Created by MJ Lee on 15/4/24.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "AgoraRefreshAutoNormalFooter.h"

@interface AgoraRefreshAutoNormalFooter()
@property (weak, nonatomic) UIActivityIndicatorView *loadingView;
@end

@implementation AgoraRefreshAutoNormalFooter
#pragma mark - 懒加载子控件
- (UIActivityIndicatorView *)loadingView
{
    if (!_loadingView) {
        UIActivityIndicatorView *loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:_activityIndicatorViewStyle];
        loadingView.hidesWhenStopped = YES;
        [self addSubview:_loadingView = loadingView];
    }
    return _loadingView;
}

- (void)setActivityIndicatorViewStyle:(UIActivityIndicatorViewStyle)activityIndicatorViewStyle
{
    _activityIndicatorViewStyle = activityIndicatorViewStyle;
    
    [self.loadingView removeFromSuperview];
    self.loadingView = nil;
    [self setNeedsLayout];
}
#pragma mark - 重写父类的方法
- (void)prepare
{
    [super prepare];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
    if (@available(iOS 13.0, *)) {
        _activityIndicatorViewStyle = UIActivityIndicatorViewStyleMedium;
        return;
    }
#endif
        
    _activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
}

- (void)placeSubviews
{
    [super placeSubviews];
    
    if (self.loadingView.constraints.count) return;
    
    // 圈圈
    CGFloat loadingCenterX = self.agora_refresh_w * 0.5;
    if (!self.isRefreshingTitleHidden) {
        loadingCenterX -= self.stateLabel.agora_textWidth * 0.5 + self.labelLeftInset;
    }
    CGFloat loadingCenterY = self.agora_refresh_h * 0.5;
    self.loadingView.center = CGPointMake(loadingCenterX, loadingCenterY);
}

- (void)setState:(AgoraRefreshState)state
{
    AgoraRefreshCheckState
    
    // 根据状态做事情
    if (state == AgoraRefreshStateNoMoreData || state == AgoraRefreshStateIdle) {
        [self.loadingView stopAnimating];
    } else if (state == AgoraRefreshStateRefreshing) {
        [self.loadingView startAnimating];
    }
}

@end
