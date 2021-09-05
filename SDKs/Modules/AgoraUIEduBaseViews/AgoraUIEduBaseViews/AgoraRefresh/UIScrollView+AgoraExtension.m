//  代码地址: https://github.com/CoderMJLee/AgoraRefresh
//  UIScrollView+Extension.m
//  AgoraRefreshExample
//
//  Created by MJ Lee on 14-5-28.
//  Copyright (c) 2014年 小码哥. All rights reserved.
//

#import "UIScrollView+AgoraExtension.h"
#import <objc/runtime.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability-new"

@implementation UIScrollView (AgoraExtension)

static BOOL respondsToAdjustedContentInset_;

+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        respondsToAdjustedContentInset_ = [self instancesRespondToSelector:@selector(adjustedContentInset)];
    });
}

- (UIEdgeInsets)agora_inset
{
#ifdef __IPHONE_11_0
    if (respondsToAdjustedContentInset_) {
        return self.adjustedContentInset;
    }
#endif
    return self.contentInset;
}

- (void)setAgora_insetT:(CGFloat)agora_insetT
{
    UIEdgeInsets inset = self.contentInset;
    inset.top = agora_insetT;
#ifdef __IPHONE_11_0
    if (respondsToAdjustedContentInset_) {
        inset.top -= (self.adjustedContentInset.top - self.contentInset.top);
    }
#endif
    self.contentInset = inset;
}

- (CGFloat)agora_insetT
{
    return self.agora_inset.top;
}

- (void)setAgora_insetB:(CGFloat)agora_insetB
{
    UIEdgeInsets inset = self.contentInset;
    inset.bottom = agora_insetB;
#ifdef __IPHONE_11_0
    if (respondsToAdjustedContentInset_) {
        inset.bottom -= (self.adjustedContentInset.bottom - self.contentInset.bottom);
    }
#endif
    self.contentInset = inset;
}

- (CGFloat)agora_insetB
{
    return self.agora_inset.bottom;
}

- (void)setAgora_insetL:(CGFloat)agora_insetL
{
    UIEdgeInsets inset = self.contentInset;
    inset.left = agora_insetL;
#ifdef __IPHONE_11_0
    if (respondsToAdjustedContentInset_) {
        inset.left -= (self.adjustedContentInset.left - self.contentInset.left);
    }
#endif
    self.contentInset = inset;
}

- (CGFloat)agora_insetL
{
    return self.agora_inset.left;
}

- (void)setAgora_insetR:(CGFloat)agora_insetR
{
    UIEdgeInsets inset = self.contentInset;
    inset.right = agora_insetR;
#ifdef __IPHONE_11_0
    if (respondsToAdjustedContentInset_) {
        inset.right -= (self.adjustedContentInset.right - self.contentInset.right);
    }
#endif
    self.contentInset = inset;
}

- (CGFloat)agora_insetR
{
    return self.agora_inset.right;
}

- (void)setAgora_offsetX:(CGFloat)agora_offsetX
{
    CGPoint offset = self.contentOffset;
    offset.x = agora_offsetX;
    self.contentOffset = offset;
}

- (CGFloat)agora_offsetX
{
    return self.contentOffset.x;
}

- (void)setAgora_offsetY:(CGFloat)agora_offsetY
{
    CGPoint offset = self.contentOffset;
    offset.y = agora_offsetY;
    self.contentOffset = offset;
}

- (CGFloat)agora_offsetY
{
    return self.contentOffset.y;
}

- (void)setAgora_contentW:(CGFloat)agora_contentW
{
    CGSize size = self.contentSize;
    size.width = agora_contentW;
    self.contentSize = size;
}

- (CGFloat)agora_contentW
{
    return self.contentSize.width;
}

- (void)setAgora_contentH:(CGFloat)agora_contentH
{
    CGSize size = self.contentSize;
    size.height = agora_contentH;
    self.contentSize = size;
}

- (CGFloat)agora_contentH
{
    return self.contentSize.height;
}
@end
#pragma clang diagnostic pop
