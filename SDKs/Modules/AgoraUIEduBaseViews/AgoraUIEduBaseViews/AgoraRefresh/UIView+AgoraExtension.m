//  代码地址: https://github.com/CoderMJLee/AgoraRefresh
//  UIView+Extension.m
//  AgoraRefreshExample
//
//  Created by MJ Lee on 14-5-28.
//  Copyright (c) 2014年 小码哥. All rights reserved.
//

#import "UIView+AgoraExtension.h"

@implementation UIView (AgoraExtension)
- (void)setAgora_refresh_x:(CGFloat)agora_refresh_x
{
    CGRect frame = self.frame;
    frame.origin.x = agora_refresh_x;
    self.frame = frame;
}

- (CGFloat)agora_refresh_x
{
    return self.frame.origin.x;
}

- (void)setAgora_refresh_y:(CGFloat)agora_refresh_y
{
    CGRect frame = self.frame;
    frame.origin.y = agora_refresh_y;
    self.frame = frame;
}

- (CGFloat)agora_refresh_y
{
    return self.frame.origin.y;
}

- (void)setAgora_refresh_w:(CGFloat)agora_refresh_w
{
    CGRect frame = self.frame;
    frame.size.width = agora_refresh_w;
    self.frame = frame;
}

- (CGFloat)agora_refresh_w
{
    return self.frame.size.width;
}

- (void)setAgora_refresh_h:(CGFloat)agora_refresh_h
{
    CGRect frame = self.frame;
    frame.size.height = agora_refresh_h;
    self.frame = frame;
}

- (CGFloat)agora_refresh_h
{
    return self.frame.size.height;
}

- (void)setAgora_refresh_size:(CGSize)agora_refresh_size
{
    CGRect frame = self.frame;
    frame.size = agora_refresh_size;
    self.frame = frame;
}

- (CGSize)agora_refresh_size
{
    return self.frame.size;
}

- (void)setAgora_refresh_origin:(CGPoint)agora_refresh_origin
{
    CGRect frame = self.frame;
    frame.origin = agora_refresh_origin;
    self.frame = frame;
}

- (CGPoint)agora_refresh_origin
{
    return self.frame.origin;
}
@end
