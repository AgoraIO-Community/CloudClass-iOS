//  代码地址: https://github.com/CoderMJLee/AgoraRefresh
//  UIScrollView+AgoraRefresh.m
//  AgoraRefreshExample
//
//  Created by MJ Lee on 15/3/4.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "UIScrollView+AgoraRefresh.h"
#import "AgoraRefreshHeader.h"
#import "AgoraRefreshFooter.h"
#import "AgoraRefreshTrailer.h"
#import <objc/runtime.h>

@implementation UIScrollView (AgoraRefresh)

#pragma mark - header
static const char AgoraRefreshHeaderKey = '\0';
- (void)setAgora_header:(AgoraRefreshHeader *)agora_header
{
    if (agora_header != self.agora_header) {
        // 删除旧的，添加新的
        [self.agora_header removeFromSuperview];
        
        if (agora_header) {
            [self insertSubview:agora_header atIndex:0];
        }
        // 存储新的
        objc_setAssociatedObject(self, &AgoraRefreshHeaderKey,
                                 agora_header, OBJC_ASSOCIATION_RETAIN);
    }
}

- (AgoraRefreshHeader *)agora_header
{
    return objc_getAssociatedObject(self, &AgoraRefreshHeaderKey);
}

#pragma mark - footer
static const char AgoraRefreshFooterKey = '\0';
- (void)setAgora_footer:(AgoraRefreshFooter *)agora_footer
{
    if (agora_footer != self.agora_footer) {
        // 删除旧的，添加新的
        [self.agora_footer removeFromSuperview];
        if (agora_footer) {
            [self insertSubview:agora_footer atIndex:0];
        }
        // 存储新的
        objc_setAssociatedObject(self, &AgoraRefreshFooterKey,
                                 agora_footer, OBJC_ASSOCIATION_RETAIN);
    }
}

- (AgoraRefreshFooter *)agora_footer
{
    return objc_getAssociatedObject(self, &AgoraRefreshFooterKey);
}

#pragma mark - footer
static const char AgoraRefreshTrailerKey = '\0';
- (void)setAgora_trailer:(AgoraRefreshTrailer *)agora_trailer {
    if (agora_trailer != self.agora_trailer) {
        // 删除旧的，添加新的
        [self.agora_trailer removeFromSuperview];
        if (agora_trailer) {
            [self insertSubview:agora_trailer atIndex:0];
        }
        // 存储新的
        objc_setAssociatedObject(self, &AgoraRefreshTrailerKey,
                                 agora_trailer, OBJC_ASSOCIATION_RETAIN);
    }
}

- (AgoraRefreshTrailer *)agora_trailer {
    return objc_getAssociatedObject(self, &AgoraRefreshTrailerKey);
}

#pragma mark - 过期
- (void)setFooter:(AgoraRefreshFooter *)footer
{
    self.agora_footer = footer;
}

- (AgoraRefreshFooter *)footer
{
    return self.agora_footer;
}

- (void)setHeader:(AgoraRefreshHeader *)header
{
    self.agora_header = header;
}

- (AgoraRefreshHeader *)header
{
    return self.agora_header;
}

#pragma mark - other
- (NSInteger)agora_totalDataCount
{
    NSInteger totalCount = 0;
    if ([self isKindOfClass:[UITableView class]]) {
        UITableView *tableView = (UITableView *)self;

        for (NSInteger section = 0; section < tableView.numberOfSections; section++) {
            totalCount += [tableView numberOfRowsInSection:section];
        }
    } else if ([self isKindOfClass:[UICollectionView class]]) {
        UICollectionView *collectionView = (UICollectionView *)self;

        for (NSInteger section = 0; section < collectionView.numberOfSections; section++) {
            totalCount += [collectionView numberOfItemsInSection:section];
        }
    }
    return totalCount;
}

@end
