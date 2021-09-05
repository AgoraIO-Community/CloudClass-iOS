//  代码地址: https://github.com/CoderMJLee/AgoraRefresh
//  AgoraRefreshFooter.m
//  AgoraRefreshExample
//
//  Created by MJ Lee on 15/3/5.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "AgoraRefreshFooter.h"
#include "UIScrollView+AgoraRefresh.h"

@interface AgoraRefreshFooter()

@end

@implementation AgoraRefreshFooter
#pragma mark - 构造方法
+ (instancetype)footerWithRefreshingBlock:(AgoraRefreshComponentAction)refreshingBlock
{
    AgoraRefreshFooter *cmp = [[self alloc] init];
    cmp.refreshingBlock = refreshingBlock;
    return cmp;
}
+ (instancetype)footerWithRefreshingTarget:(id)target refreshingAction:(SEL)action
{
    AgoraRefreshFooter *cmp = [[self alloc] init];
    [cmp setRefreshingTarget:target refreshingAction:action];
    return cmp;
}

#pragma mark - 重写父类的方法
- (void)prepare
{
    [super prepare];
    
    // 设置自己的高度
    self.agora_refresh_h = AgoraRefreshFooterHeight;
    
    // 默认不会自动隐藏
//    self.automaticallyHidden = NO;
}

#pragma mark - 公共方法
- (void)endRefreshingWithNoMoreData
{
    AgoraRefreshDispatchAsyncOnMainQueue(self.state = AgoraRefreshStateNoMoreData;)
}

- (void)noticeNoMoreData
{
    [self endRefreshingWithNoMoreData];
}

- (void)resetNoMoreData
{
    AgoraRefreshDispatchAsyncOnMainQueue(self.state = AgoraRefreshStateIdle;)
}

- (void)setAutomaticallyHidden:(BOOL)automaticallyHidden
{
    _automaticallyHidden = automaticallyHidden;
}
@end
