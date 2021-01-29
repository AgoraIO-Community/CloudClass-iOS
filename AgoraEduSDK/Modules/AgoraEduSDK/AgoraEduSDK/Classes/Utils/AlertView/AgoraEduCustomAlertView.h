//
//  AgoraEduCustomAlertView.h
//  AgoraEducation
//
//  Created by SRS on 2020/12/16.
//  Copyright © 2020 Agora. All rights reserved.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface AgoraEduCustomAlertView : UIView

@property (nonatomic, weak) UIView *parentView;    // The parent view this 'dialog' is attached to
@property (nonatomic, weak) UIView *dialogView;    // Dialog's container view
@property (nonatomic, weak) UIView *containerView; // Container within the dialog (place your ui elements here)

@property (nonatomic, strong) NSArray *buttonTitles;
@property (nonatomic, assign) BOOL useMotionEffects;
@property (nonatomic, assign) BOOL closeOnTouchUpOutside;       // Closes the AlertView when finger is lifted outside the bounds.

@property (nonatomic, copy) void (^onButtonTouchUpInside)(AgoraEduCustomAlertView *alertView, NSInteger buttonIndex) ;

/*!
 DEPRECATED: Use the [CustomIOSAlertView init] method without passing a parent view.
 */
- (id)initWithParentView: (UIView *)_parentView __attribute__ ((deprecated));

- (void)showWithContainerView:(UIView *)containerView;
- (void)startCountDown:(NSInteger)maxCount;
- (void)close;

- (void)deviceOrientationDidChange: (NSNotification *)notification;

@end



NS_ASSUME_NONNULL_END
