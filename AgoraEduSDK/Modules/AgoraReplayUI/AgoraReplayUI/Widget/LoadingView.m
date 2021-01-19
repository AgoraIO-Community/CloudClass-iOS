//
//  LoadingView.m
//  AgoraEducation
//
//  Created by SRS on 2019/12/17.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "LoadingView.h"

@interface LoadingView()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;

@end


@implementation LoadingView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initView];
}

-(void)initView {
    self.layer.cornerRadius = 8;
    self.loadingLabel.text = @"loading...";
}

-(void)showLoading {
    if(!self.superview.hidden) {
        return;
    }
    
    self.superview.hidden = NO;
    [self startAnimation];
}

-(void)hiddenLoading {
    if(self.superview.hidden) {
        return;
    }
    
    self.superview.hidden = YES;
    [self stopAnimation];
}

-(void)startAnimation {
    
    [self.imageView.layer removeAllAnimations];
    
    CABasicAnimation *rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI*2.0];
    rotationAnimation.duration = 2;
    rotationAnimation.repeatCount = HUGE_VALF;
    [self.imageView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

-(void)stopAnimation {
    [self.imageView.layer removeAllAnimations];
}

@end
