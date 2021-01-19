//
//  UIView+Constraint.h
//  AgoraEducation
//
//  Created by SRS on 2020/5/3.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (AgoraEduConstraint)

- (void)equalTo:(UIView *)view;
- (void)centerTo:(UIView *)view;

- (void)equalWidthTo:(CGFloat)value;
- (void)equalHightTo:(CGFloat)value;

- (void)equalLeftToView:(UIView *)view attribute:(NSLayoutAttribute)attribute  value:(CGFloat)value;
- (void)equalRightToView:(UIView *)view attribute:(NSLayoutAttribute)attribute  value:(CGFloat)value;
- (void)equalTopToView:(UIView *)view attribute:(NSLayoutAttribute)attribute  value:(CGFloat)value;
- (void)equalBottomToView:(UIView *)view attribute:(NSLayoutAttribute)attribute  value:(CGFloat)value;

@end

NS_ASSUME_NONNULL_END
