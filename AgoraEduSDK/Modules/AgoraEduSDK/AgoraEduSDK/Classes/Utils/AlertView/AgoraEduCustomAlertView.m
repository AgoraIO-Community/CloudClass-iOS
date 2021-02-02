//
//  AgoraEduCustomAlertView.m
//  AgoraEducation
//
//  Created by SRS on 2020/12/16.
//  Copyright © 2020 Agora. All rights reserved.
//

#import "AgoraEduCustomAlertView.h"
#import <QuartzCore/QuartzCore.h>

const static CGFloat kCustomAlertViewDefaultButtonHeight       = 50;
const static CGFloat kCustomAlertViewDefaultButtonSpacerHeight = 1;
const static CGFloat kCustomAlertViewCornerRadius              = 7;
const static CGFloat kCustomMotionEffectExtent                = 10.0;

#define BUTTON_TAG_GAP 1000

@interface AgoraEduCustomAlertView ()

@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) NSInteger currentCount;

@end

@implementation AgoraEduCustomAlertView

CGFloat agoraEduButtonHeight = 0;
CGFloat agoraEduButtonSpacerHeight = 0;

- (id)initWithParentView: (UIView *)_parentView {
    self = [self init];
    if (_parentView) {
        self.frame = _parentView.frame;
        self.parentView = _parentView;
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        
        self.useMotionEffects = false;
        self.closeOnTouchUpOutside = false;
        
        self.buttonTitles = @[@"Close"];
        
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    return self;
}

// Create the dialog view, and animate opening the dialog
- (void)showWithContainerView:(UIView *)containerView {
    
    UIView *view = [[UIView alloc] init];
    [self addSubview:view];
    self.dialogView = view;
    
    [self.dialogView addSubview:containerView];
    self.containerView = containerView;
    
    [self updateContainerView];
    
    self.dialogView.layer.shouldRasterize = YES;
    self.dialogView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    
    // Can be attached to a view or to the top most window
    // Attached to a view:
    if (self.parentView != NULL) {
        [self.parentView addSubview:self];
        
        // Attached to the top most window
    } else {
        CGSize screenSize = [self countScreenSize];
        CGSize dialogSize = [self countDialogSize];
        CGSize keyboardSize = CGSizeMake(0, 0);
        
        self.dialogView.frame = CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - keyboardSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height);
        
        [[[[UIApplication sharedApplication] windows] firstObject] addSubview:self];
    }
    
    self.dialogView.layer.opacity = 0.5f;
    self.dialogView.layer.transform = CATransform3DMakeScale(1.3f, 1.3f, 1.0);
    
    if (self.useMotionEffects) {
        [self applyMotionEffects];
    }
    
    [UIView animateWithDuration:0.2f animations:^{
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4f];
        self.dialogView.layer.opacity = 1.0f;
        self.dialogView.layer.transform = CATransform3DMakeScale(1, 1, 1);
    }];
}

// Dialog close animation then cleaning and removing the view from the parent
- (void)close {
    CATransform3D currentTransform = self.dialogView.layer.transform;
    
    self.dialogView.layer.opacity = 1.0f;
    
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone animations:^{
            
        self.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f];
        self.dialogView.layer.transform = CATransform3DConcat(currentTransform, CATransform3DMakeScale(0.6f, 0.6f, 1.0));
        self.dialogView.layer.opacity = 0.0f;
        
    } completion:^(BOOL finished) {
        
        for (UIView *v in [self subviews]) {
            [v removeFromSuperview];
        }
        [self removeFromSuperview];
    }];
}

// Creates the container view here: create the dialog, then add the custom content and buttons
- (void)updateContainerView {
    
    CGSize screenSize = [self countScreenSize];
    CGSize dialogSize = [self countDialogSize];
    
    // For the black background
    [self setFrame:CGRectMake(0, 0, screenSize.width, screenSize.height)];
    
    // This is the dialog's container; we attach the custom content and the buttons to this one
    self.dialogView.frame = CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height);
    UIView *dialogContainer = self.dialogView;
    
    // First, we style the dialog to match the iOS7 UIAlertView >>>
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = dialogContainer.bounds;
    gradient.colors = [NSArray arrayWithObjects:
                       (id)[[UIColor colorWithRed:218.0/255.0 green:218.0/255.0 blue:218.0/255.0 alpha:1.0f] CGColor],
                       (id)[[UIColor colorWithRed:233.0/255.0 green:233.0/255.0 blue:233.0/255.0 alpha:1.0f] CGColor],
                       (id)[[UIColor colorWithRed:218.0/255.0 green:218.0/255.0 blue:218.0/255.0 alpha:1.0f] CGColor],
                       nil];
    
    CGFloat cornerRadius = kCustomAlertViewCornerRadius;
    gradient.cornerRadius = cornerRadius;
    [dialogContainer.layer insertSublayer:gradient atIndex:0];
    
    dialogContainer.layer.cornerRadius = cornerRadius;
    dialogContainer.layer.borderColor = [[UIColor colorWithRed:198.0/255.0 green:198.0/255.0 blue:198.0/255.0 alpha:1.0f] CGColor];
    dialogContainer.layer.borderWidth = 1;
    dialogContainer.layer.shadowRadius = cornerRadius + 5;
    dialogContainer.layer.shadowOpacity = 0.1f;
    dialogContainer.layer.shadowOffset = CGSizeMake(0 - (cornerRadius+5)/2, 0 - (cornerRadius+5)/2);
    dialogContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    dialogContainer.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:dialogContainer.bounds cornerRadius:dialogContainer.layer.cornerRadius].CGPath;
    
    // There is a line above the button
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, dialogContainer.bounds.size.height - agoraEduButtonHeight - agoraEduButtonSpacerHeight, dialogContainer.bounds.size.width, agoraEduButtonSpacerHeight)];
    lineView.backgroundColor = [UIColor colorWithRed:198.0/255.0 green:198.0/255.0 blue:198.0/255.0 alpha:1.0f];
    [dialogContainer addSubview:lineView];
    // ^^^
    // Add the buttons too
    [self addButtonsToView:dialogContainer];
}

// Helper function: add buttons to container
- (void)addButtonsToView: (UIView *)container {
    if (self.buttonTitles == NULL) { return; }
    
    CGFloat buttonWidth = container.bounds.size.width / [self.buttonTitles count];
    
    for (NSInteger i = 0; i < [self.buttonTitles count]; i++) {
        
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [closeButton setFrame:CGRectMake(i * buttonWidth, container.bounds.size.height - agoraEduButtonHeight, buttonWidth, agoraEduButtonHeight)];
        [closeButton addTarget:self action:@selector(customDialogButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [closeButton setTag:i + BUTTON_TAG_GAP];
        
        [closeButton setTitle:[self.buttonTitles objectAtIndex:i] forState:UIControlStateNormal];
        [closeButton setTitleColor:[UIColor colorWithRed:0.0f green:0.5f blue:1.0f alpha:1.0f] forState:UIControlStateNormal];
        [closeButton setTitleColor:[UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:0.5f] forState:UIControlStateHighlighted];
        [closeButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
        closeButton.titleLabel.numberOfLines = 0;
        closeButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [closeButton.layer setCornerRadius:kCustomAlertViewCornerRadius];
        
        [container addSubview:closeButton];
    }
}

- (void)customDialogButtonTouchUpInside:(id)sender {
    if (self.onButtonTouchUpInside != NULL) {
        self.onButtonTouchUpInside(self, [sender tag] - BUTTON_TAG_GAP);
    }
}

// Helper function: count and return the dialog's size
- (CGSize)countDialogSize {
    CGFloat dialogWidth = self.containerView.frame.size.width;
    CGFloat dialogHeight = self.containerView.frame.size.height + agoraEduButtonHeight + agoraEduButtonSpacerHeight;
    
    return CGSizeMake(dialogWidth, dialogHeight);
}

// Helper function: count and return the screen's size
- (CGSize)countScreenSize {
    if (self.buttonTitles != NULL && [self.buttonTitles count] > 0) {
        agoraEduButtonHeight       = kCustomAlertViewDefaultButtonHeight;
        agoraEduButtonSpacerHeight = kCustomAlertViewDefaultButtonSpacerHeight;
    } else {
        agoraEduButtonHeight = 0;
        agoraEduButtonSpacerHeight = 0;
    }
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    return CGSizeMake(screenWidth, screenHeight);
}

// Add motion effects
- (void)applyMotionEffects {
    UIInterpolatingMotionEffect *horizontalEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    
    horizontalEffect.minimumRelativeValue = @(-kCustomMotionEffectExtent);
    horizontalEffect.maximumRelativeValue = @( kCustomMotionEffectExtent);
    
    UIInterpolatingMotionEffect *verticalEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
  
    verticalEffect.minimumRelativeValue = @(-kCustomMotionEffectExtent);
    verticalEffect.maximumRelativeValue = @(kCustomMotionEffectExtent);
    
    UIMotionEffectGroup *motionEffectGroup = [[UIMotionEffectGroup alloc] init];
    motionEffectGroup.motionEffects = @[horizontalEffect, verticalEffect];
    
    [self.dialogView addMotionEffect:motionEffectGroup];
}

- (void)dealloc {
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (self.timer != nil && [self.timer isValid]) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)startCountDown:(NSInteger)maxCount {
    
    if (self.timer != nil && [self.timer isValid]) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    self.currentCount = maxCount;
    
    WEAK(self);
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        
        weakself.currentCount -= 1;
        if (weakself.currentCount <= 0) {
            [weakself close];

            if (weakself.timer != nil && [weakself.timer isValid]) {
                [weakself.timer invalidate];
                weakself.timer = nil;
            }
            return;
        } else {
            
            NSString *text = weakself.buttonTitles.lastObject;
             text = [NSString stringWithFormat:@"%@(%ld)", text, (long)weakself.currentCount];
            
            UIButton *btn = [weakself.dialogView viewWithTag:weakself.buttonTitles.count - 1 + BUTTON_TAG_GAP];
            if (btn != nil) {
                [btn setTitle:text forState:UIControlStateNormal];
            }
        }
    }];
    
    UIButton *btn = [self.dialogView viewWithTag:self.buttonTitles.count - 1 + BUTTON_TAG_GAP];
    if (btn != nil) {
        NSString *text = [NSString stringWithFormat:@"%@(%ld)", self.buttonTitles.lastObject, (long)self.currentCount];
        [btn setTitle:text forState:UIControlStateNormal];
    }
}

// Handle device orientation changes
- (void)deviceOrientationDidChange: (NSNotification *)notification
{
    // If dialog is attached to the parent view, it probably wants to handle the orientation change itself
    if (self.parentView != NULL) {
        return;
    }
    
    [self changeOrientation:notification];
}

// Rotation changed
- (void)changeOrientation: (NSNotification *)notification {
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    [UIView animateWithDuration:0.2f animations:^{
        
        CGSize dialogSize = [self countDialogSize];
        CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        self.frame = CGRectMake(0, 0, screenWidth, screenHeight);
        self.dialogView.frame = CGRectMake((screenWidth - dialogSize.width) / 2, (screenHeight - keyboardSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height);
    }];
}

@end
