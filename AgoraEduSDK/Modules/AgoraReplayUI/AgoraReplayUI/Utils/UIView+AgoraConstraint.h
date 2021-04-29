//
//  UIView+Constraint.h
//  AgoraEducation
//
//  Created by SRS on 2020/5/3.
//  Copyright © 2020 Agora. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (AgoraConstraint)

- (void)agora_EqualTo:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
