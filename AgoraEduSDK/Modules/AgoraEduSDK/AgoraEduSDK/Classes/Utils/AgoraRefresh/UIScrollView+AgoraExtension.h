//  代码地址: https://github.com/CoderMJLee/AgoraRefresh
//  UIScrollView+Extension.h
//  AgoraRefreshExample
//
//  Created by MJ Lee on 14-5-28.
//  Copyright (c) 2014年 小码哥. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIScrollView (AgoraExtension)
@property (readonly, nonatomic) UIEdgeInsets agora_inset;

@property (assign, nonatomic) CGFloat agora_insetT;
@property (assign, nonatomic) CGFloat agora_insetB;
@property (assign, nonatomic) CGFloat agora_insetL;
@property (assign, nonatomic) CGFloat agora_insetR;

@property (assign, nonatomic) CGFloat agora_offsetX;
@property (assign, nonatomic) CGFloat agora_offsetY;

@property (assign, nonatomic) CGFloat agora_contentW;
@property (assign, nonatomic) CGFloat agora_contentH;
@end

NS_ASSUME_NONNULL_END
