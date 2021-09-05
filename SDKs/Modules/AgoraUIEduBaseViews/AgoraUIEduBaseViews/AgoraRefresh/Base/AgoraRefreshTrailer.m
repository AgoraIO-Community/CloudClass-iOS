//
//  AgoraRefreshTrailer.m
//  AgoraRefresh
//
//  Created by kinarobin on 2020/5/3.
//  Copyright © 2020 小码哥. All rights reserved.
//

#import "AgoraRefreshTrailer.h"

@interface AgoraRefreshTrailer()
@property (assign, nonatomic) NSInteger lastRefreshCount;
@property (assign, nonatomic) CGFloat lastRightDelta;
@end

@implementation AgoraRefreshTrailer

#pragma mark - 构造方法
+ (instancetype)trailerWithRefreshingBlock:(AgoraRefreshComponentAction)refreshingBlock {
    AgoraRefreshTrailer *cmp = [[self alloc] init];
    cmp.refreshingBlock = refreshingBlock;
    return cmp;
}

+ (instancetype)trailerWithRefreshingTarget:(id)target refreshingAction:(SEL)action {
    AgoraRefreshTrailer *cmp = [[self alloc] init];
    [cmp setRefreshingTarget:target refreshingAction:action];
    return cmp;
}

- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change {
    [super scrollViewContentOffsetDidChange:change];
    
    // 如果正在刷新，直接返回
    if (self.state == AgoraRefreshStateRefreshing) return;
    
    _scrollViewOriginalInset = self.scrollView.agora_inset;
    
    // 当前的contentOffset
    CGFloat currentOffsetX = self.scrollView.agora_offsetX;
    // 尾部控件刚好出现的offsetX
    CGFloat happenOffsetX = [self happenOffsetX];
    // 如果是向右滚动到看不见右边控件，直接返回
    if (currentOffsetX <= happenOffsetX) return;
    
    CGFloat pullingPercent = (currentOffsetX - happenOffsetX) / self.agora_refresh_w;
    
    // 如果已全部加载，仅设置pullingPercent，然后返回
    if (self.state == AgoraRefreshStateNoMoreData) {
        self.pullingPercent = pullingPercent;
        return;
    }
    
    if (self.scrollView.isDragging) {
        self.pullingPercent = pullingPercent;
        // 普通 和 即将刷新 的临界点
        CGFloat normal2pullingOffsetX = happenOffsetX + self.agora_refresh_w;
        
        if (self.state == AgoraRefreshStateIdle && currentOffsetX > normal2pullingOffsetX) {
            self.state = AgoraRefreshStatePulling;
        } else if (self.state == AgoraRefreshStatePulling && currentOffsetX <= normal2pullingOffsetX) {
            // 转为普通状态
            self.state = AgoraRefreshStateIdle;
        }
    } else if (self.state == AgoraRefreshStatePulling) {// 即将刷新 && 手松开
        // 开始刷新
        [self beginRefreshing];
    } else if (pullingPercent < 1) {
        self.pullingPercent = pullingPercent;
    }
}

- (void)setState:(AgoraRefreshState)state {
    AgoraRefreshCheckState
    // 根据状态来设置属性
    if (state == AgoraRefreshStateNoMoreData || state == AgoraRefreshStateIdle) {
        // 刷新完毕
        if (AgoraRefreshStateRefreshing == oldState) {
            [UIView animateWithDuration:AgoraRefreshSlowAnimationDuration animations:^{
                if (self.endRefreshingAnimationBeginAction) {
                    self.endRefreshingAnimationBeginAction();
                }
                
                self.scrollView.agora_insetR -= self.lastRightDelta;
                // 自动调整透明度
                if (self.isAutomaticallyChangeAlpha) self.alpha = 0.0;
            } completion:^(BOOL finished) {
                self.pullingPercent = 0.0;
                
                if (self.endRefreshingCompletionBlock) {
                    self.endRefreshingCompletionBlock();
                }
            }];
        }
        
        CGFloat deltaW = [self widthForContentBreakView];
        // 刚刷新完毕
        if (AgoraRefreshStateRefreshing == oldState && deltaW > 0 && self.scrollView.agora_totalDataCount != self.lastRefreshCount) {
            self.scrollView.agora_offsetX = self.scrollView.agora_offsetX;
        }
    } else if (state == AgoraRefreshStateRefreshing) {
        // 记录刷新前的数量
        self.lastRefreshCount = self.scrollView.agora_totalDataCount;
        
        [UIView animateWithDuration:AgoraRefreshFastAnimationDuration animations:^{
            CGFloat right = self.agora_refresh_w + self.scrollViewOriginalInset.right;
            CGFloat deltaW = [self widthForContentBreakView];
            if (deltaW < 0) { // 如果内容宽度小于view的宽度
                right -= deltaW;
            }
            self.lastRightDelta = right - self.scrollView.agora_insetR;
            self.scrollView.agora_insetR = right;
            
            // 设置滚动位置
            CGPoint offset = self.scrollView.contentOffset;
            offset.x = [self happenOffsetX] + self.agora_refresh_w;
            [self.scrollView setContentOffset:offset animated:NO];
        } completion:^(BOOL finished) {
            [self executeRefreshingCallback];
        }];
    }
}

- (void)scrollViewContentSizeDidChange:(NSDictionary *)change {
    [super scrollViewContentSizeDidChange:change];
    
    // 内容的宽度
    CGFloat contentWidth = self.scrollView.agora_contentW + self.ignoredScrollViewContentInsetRight;
    // 表格的宽度
    CGFloat scrollWidth = self.scrollView.agora_refresh_w - self.scrollViewOriginalInset.left - self.scrollViewOriginalInset.right + self.ignoredScrollViewContentInsetRight;
    // 设置位置和尺寸
    self.agora_refresh_x = MAX(contentWidth, scrollWidth);
}

- (void)placeSubviews {
    [super placeSubviews];
    
    self.agora_refresh_h = _scrollView.agora_refresh_h;
    // 设置自己的宽度
    self.agora_refresh_w = AgoraRefreshTrailWidth;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    if (newSuperview) {
        // 设置支持水平弹簧效果
        _scrollView.alwaysBounceHorizontal = YES;
        _scrollView.alwaysBounceVertical = NO;
    }
}

#pragma mark 刚好看到上拉刷新控件时的contentOffset.x
- (CGFloat)happenOffsetX {
    CGFloat deltaW = [self widthForContentBreakView];
    if (deltaW > 0) {
        return deltaW - self.scrollViewOriginalInset.left;
    } else {
        return - self.scrollViewOriginalInset.left;
    }
}

#pragma mark 获得scrollView的内容 超出 view 的宽度
- (CGFloat)widthForContentBreakView {
    CGFloat w = self.scrollView.frame.size.width - self.scrollViewOriginalInset.right - self.scrollViewOriginalInset.left;
    return self.scrollView.contentSize.width - w;
}

@end
