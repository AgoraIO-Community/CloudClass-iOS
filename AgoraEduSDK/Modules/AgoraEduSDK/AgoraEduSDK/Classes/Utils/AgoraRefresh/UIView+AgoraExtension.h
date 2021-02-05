// 代码地址: https://github.com/CoderMJLee/AgoraRefresh
//  UIView+Extension.h
//  AgoraRefreshExample
//
//  Created by MJ Lee on 14-5-28.
//  Copyright (c) 2014年 小码哥. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (AgoraExtension)
@property (assign, nonatomic) CGFloat agora_refresh_x;
@property (assign, nonatomic) CGFloat agora_refresh_y;
@property (assign, nonatomic) CGFloat agora_refresh_w;
@property (assign, nonatomic) CGFloat agora_refresh_h;
@property (assign, nonatomic) CGSize agora_refresh_size;
@property (assign, nonatomic) CGPoint agora_refresh_origin;
@end

NS_ASSUME_NONNULL_END
