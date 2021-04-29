//  代码地址: https://github.com/CoderMJLee/AgoraRefresh
//  UIScrollView+AgoraRefresh.h
//  AgoraRefreshExample
//
//  Created by MJ Lee on 15/3/4.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//  给ScrollView增加下拉刷新、上拉刷新、 左滑刷新的功能

#import <UIKit/UIKit.h>
#import "AgoraRefreshConst.h"

@class AgoraRefreshHeader, AgoraRefreshFooter, AgoraRefreshTrailer;

NS_ASSUME_NONNULL_BEGIN

@interface UIScrollView (AgoraRefresh)
/** 下拉刷新控件 */
@property (strong, nonatomic, nullable) AgoraRefreshHeader *agora_header;
@property (strong, nonatomic, nullable) AgoraRefreshHeader *header AgoraRefreshDeprecated("使用agora_header");
/** 上拉刷新控件 */
@property (strong, nonatomic, nullable) AgoraRefreshFooter *agora_footer;
@property (strong, nonatomic, nullable) AgoraRefreshFooter *footer AgoraRefreshDeprecated("使用agora_footer");

/** 左滑刷新控件 */
@property (strong, nonatomic, nullable) AgoraRefreshTrailer *agora_trailer;

#pragma mark - other
- (NSInteger)agora_totalDataCount;

@end

NS_ASSUME_NONNULL_END
