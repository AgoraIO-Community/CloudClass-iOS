//
//  AgoraRefreshAutoFooter.m
//  AgoraRefreshExample
//
//  Created by MJ Lee on 15/4/24.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "AgoraRefreshAutoFooter.h"

@interface AgoraRefreshAutoFooter()
/** 一个新的拖拽 */
@property (nonatomic) BOOL triggerByDrag;
@property (nonatomic) NSInteger leftTriggerTimes;
@end

@implementation AgoraRefreshAutoFooter

#pragma mark - 初始化
- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    if (newSuperview) { // 新的父控件
        if (self.hidden == NO) {
            self.scrollView.agora_insetB += self.agora_refresh_h;
        }
        
        // 设置位置
        self.agora_refresh_y = _scrollView.agora_contentH;
    } else { // 被移除了
        if (self.hidden == NO) {
            self.scrollView.agora_insetB -= self.agora_refresh_h;
        }
    }
}

#pragma mark - 过期方法
- (void)setAppearencePercentTriggerAutoRefresh:(CGFloat)appearencePercentTriggerAutoRefresh
{
    self.triggerAutomaticallyRefreshPercent = appearencePercentTriggerAutoRefresh;
}

- (CGFloat)appearencePercentTriggerAutoRefresh
{
    return self.triggerAutomaticallyRefreshPercent;
}

#pragma mark - 实现父类的方法
- (void)prepare
{
    [super prepare];
    
    // 默认底部控件100%出现时才会自动刷新
    self.triggerAutomaticallyRefreshPercent = 1.0;
    
    // 设置为默认状态
    self.automaticallyRefresh = YES;
    
    self.autoTriggerTimes = 1;
}

- (void)scrollViewContentSizeDidChange:(NSDictionary *)change
{
    [super scrollViewContentSizeDidChange:change];
    
    // 设置位置
    self.agora_refresh_y = self.scrollView.agora_contentH + self.ignoredScrollViewContentInsetBottom;
}

- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change
{
    [super scrollViewContentOffsetDidChange:change];
    
    if (self.state != AgoraRefreshStateIdle || !self.automaticallyRefresh || self.agora_refresh_y == 0) return;
    
    if (_scrollView.agora_insetT + _scrollView.agora_contentH > _scrollView.agora_refresh_h) { // 内容超过一个屏幕
        // 这里的_scrollView.agora_contentH替换掉self.agora_refresh_y更为合理
        if (_scrollView.agora_offsetY >= _scrollView.agora_contentH - _scrollView.agora_refresh_h + self.agora_refresh_h * self.triggerAutomaticallyRefreshPercent + _scrollView.agora_insetB - self.agora_refresh_h) {
            // 防止手松开时连续调用
            CGPoint old = [change[@"old"] CGPointValue];
            CGPoint new = [change[@"new"] CGPointValue];
            if (new.y <= old.y) return;
            
            if (_scrollView.isDragging) {
                self.triggerByDrag = YES;
            }
            // 当底部刷新控件完全出现时，才刷新
            [self beginRefreshing];
        }
    }
}

- (void)scrollViewPanStateDidChange:(NSDictionary *)change
{
    [super scrollViewPanStateDidChange:change];
    
    if (self.state != AgoraRefreshStateIdle) return;
    
    UIGestureRecognizerState panState = _scrollView.panGestureRecognizer.state;
    
    switch (panState) {
        // 手松开
        case UIGestureRecognizerStateEnded: {
            if (_scrollView.agora_insetT + _scrollView.agora_contentH <= _scrollView.agora_refresh_h) {  // 不够一个屏幕
                if (_scrollView.agora_offsetY >= - _scrollView.agora_insetT) { // 向上拽
                    self.triggerByDrag = YES;
                    [self beginRefreshing];
                }
            } else { // 超出一个屏幕
                if (_scrollView.agora_offsetY >= _scrollView.agora_contentH + _scrollView.agora_insetB - _scrollView.agora_refresh_h) {
                    self.triggerByDrag = YES;
                    [self beginRefreshing];
                }
            }
        }
            break;
            
        case UIGestureRecognizerStateBegan: {
            [self resetTriggerTimes];
        }
            break;
            
        default:
            break;
    }
}

- (BOOL)unlimitedTrigger {
    return self.leftTriggerTimes == -1;
}

- (void)beginRefreshing
{
    if (self.triggerByDrag && self.leftTriggerTimes <= 0 && !self.unlimitedTrigger) {
        return;
    }
    
    [super beginRefreshing];
}

- (void)setState:(AgoraRefreshState)state
{
    AgoraRefreshCheckState
    
    if (state == AgoraRefreshStateRefreshing) {
        [self executeRefreshingCallback];
    } else if (state == AgoraRefreshStateNoMoreData || state == AgoraRefreshStateIdle) {
        if (self.triggerByDrag) {
            if (!self.unlimitedTrigger) {
                self.leftTriggerTimes -= 1;
            }
            self.triggerByDrag = NO;
        }
        
        if (AgoraRefreshStateRefreshing == oldState) {
            if (self.scrollView.pagingEnabled) {
                CGPoint offset = self.scrollView.contentOffset;
                offset.y -= self.scrollView.agora_insetB;
                [UIView animateWithDuration:AgoraRefreshSlowAnimationDuration animations:^{
                    self.scrollView.contentOffset = offset;
                    
                    if (self.endRefreshingAnimationBeginAction) {
                        self.endRefreshingAnimationBeginAction();
                    }
                } completion:^(BOOL finished) {
                    if (self.endRefreshingCompletionBlock) {
                        self.endRefreshingCompletionBlock();
                    }
                }];
                return;
            }
            
            if (self.endRefreshingCompletionBlock) {
                self.endRefreshingCompletionBlock();
            }
        }
    }
}

- (void)resetTriggerTimes {
    self.leftTriggerTimes = self.autoTriggerTimes;
}

- (void)setHidden:(BOOL)hidden
{
    BOOL lastHidden = self.isHidden;
    
    [super setHidden:hidden];
    
    if (!lastHidden && hidden) {
        self.state = AgoraRefreshStateIdle;
        
        self.scrollView.agora_insetB -= self.agora_refresh_h;
    } else if (lastHidden && !hidden) {
        self.scrollView.agora_insetB += self.agora_refresh_h;
        
        // 设置位置
        self.agora_refresh_y = _scrollView.agora_contentH;
    }
}

- (void)setAutoTriggerTimes:(NSInteger)autoTriggerTimes {
    _autoTriggerTimes = autoTriggerTimes;
    self.leftTriggerTimes = autoTriggerTimes;
}
@end
