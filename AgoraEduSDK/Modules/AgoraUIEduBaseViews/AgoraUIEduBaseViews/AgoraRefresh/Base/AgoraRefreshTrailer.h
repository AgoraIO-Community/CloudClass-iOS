//
//  AgoraRefreshTrailer.h
//  AgoraRefresh
//
//  Created by kinarobin on 2020/5/3.
//  Copyright © 2020 小码哥. All rights reserved.
//

#import "AgoraRefreshComponent.h"

NS_ASSUME_NONNULL_BEGIN

@interface AgoraRefreshTrailer : AgoraRefreshComponent

/** 创建trailer*/
+ (instancetype)trailerWithRefreshingBlock:(AgoraRefreshComponentAction)refreshingBlock;
/** 创建trailer */
+ (instancetype)trailerWithRefreshingTarget:(id)target refreshingAction:(SEL)action;

/** 忽略多少scrollView的contentInset的right */
@property (assign, nonatomic) CGFloat ignoredScrollViewContentInsetRight;


@end

NS_ASSUME_NONNULL_END
