//
//  UIView+Constraint.m
//  AgoraEducation
//
//  Created by SRS on 2020/5/3.
//  Copyright © 2020 Agora. All rights reserved.
//

#import "UIView+AgoraEduConstraint.h"

@implementation UIView (AgoraEduConstraint)

- (void)equalTo:(UIView *)view {
    
    [self equalSelfAttribute:NSLayoutAttributeTop toView:view attribute:NSLayoutAttributeTop value:0];
    [self equalSelfAttribute:NSLayoutAttributeLeft toView:view attribute:NSLayoutAttributeLeft value:0];
    [self equalSelfAttribute:NSLayoutAttributeRight toView:view attribute:NSLayoutAttributeRight value:0];
    [self equalSelfAttribute:NSLayoutAttributeBottom toView:view attribute:NSLayoutAttributeBottom value:0];
}

- (void)centerTo:(UIView *)view {
    
    [self equalSelfAttribute:NSLayoutAttributeCenterX toView:view attribute:NSLayoutAttributeCenterX value:0];
    [self equalSelfAttribute:NSLayoutAttributeCenterY toView:view attribute:NSLayoutAttributeCenterY value:0];
}

- (void)equalLeftToView:(UIView *)view attribute:(NSLayoutAttribute)attribute  value:(CGFloat)value {
    
    [self equalSelfAttribute:NSLayoutAttributeLeft toView:view attribute:attribute value:value];
}

- (void)equalRightToView:(UIView *)view attribute:(NSLayoutAttribute)attribute  value:(CGFloat)value {
    
    [self equalSelfAttribute:NSLayoutAttributeRight toView:view attribute:attribute value:value];
}
- (void)equalTopToView:(UIView *)view attribute:(NSLayoutAttribute)attribute  value:(CGFloat)value {
    [self equalSelfAttribute:NSLayoutAttributeTop toView:view attribute:attribute value:value];
}
- (void)equalBottomToView:(UIView *)view attribute:(NSLayoutAttribute)attribute  value:(CGFloat)value {
    [self equalSelfAttribute:NSLayoutAttributeBottom toView:view attribute:attribute value:value];
}
- (void)equalWidthTo:(CGFloat)value {
    
    [self equalSelfAttribute:NSLayoutAttributeWidth toView:nil attribute:NSLayoutAttributeNotAnAttribute value:value];
}
- (void)equalHightTo:(CGFloat)value {
    [self equalSelfAttribute:NSLayoutAttributeHeight toView:nil attribute:NSLayoutAttributeNotAnAttribute value:value];
}

#pragma mark --Private
- (void)equalSelfAttribute:(NSLayoutAttribute)selfAttribute toView:(UIView *)view attribute:(NSLayoutAttribute)attribute  value:(CGFloat)value {
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:selfAttribute relatedBy:NSLayoutRelationEqual toItem:view attribute:attribute multiplier:1.0 constant:value];
    
    if (view == nil) {
        [self addConstraint:constraint];
    } else {
        [view addConstraint:constraint];
    }

//    constraint.active = YES;
}

@end
