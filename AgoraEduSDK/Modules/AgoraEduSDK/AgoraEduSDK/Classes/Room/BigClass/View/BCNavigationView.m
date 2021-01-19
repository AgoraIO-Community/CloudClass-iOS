//
//  EENavigationView.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/10/24.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "BCNavigationView.h"
#import "UIView+AgoraEduToast.h"
#import "AgoraEduAlertViewUtil.h"
#import "AgoraEduTopVC.h"

@interface BCNavigationView ()
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *uploadLogBtn;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;
@end

@implementation BCNavigationView
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [AgoraEduBundle loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
        self.navigationView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.navigationView];
        
        NSLayoutConstraint *viewTopConstraint = [NSLayoutConstraint constraintWithItem:self.navigationView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
        NSLayoutConstraint *viewLeftConstraint = [NSLayoutConstraint constraintWithItem:self.navigationView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
        NSLayoutConstraint *viewRightConstraint = [NSLayoutConstraint constraintWithItem:self.navigationView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
        NSLayoutConstraint *viewBottomConstraint = [NSLayoutConstraint constraintWithItem:self.navigationView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
        [self addConstraints:@[viewTopConstraint, viewLeftConstraint, viewRightConstraint, viewBottomConstraint]];
        
        self.loadingView.hidden = YES;
        
        self.wifiSignalImage.image = AgoraEduImageWithName(@"icon-signal3");
        [self.closeButton setImage:AgoraEduImageWithName(@"icon-close") forState:UIControlStateNormal];
        [self.uploadLogBtn setImage:AgoraEduImageWithName(@"upload-log") forState:UIControlStateNormal];
    }
    return self;
}

- (void)updateClassName:(NSString *)name {
    [self.titleLabel setText:name];
}

- (void)updateSignalImageName:(NSString *)name {
    [self.wifiSignalImage setImage:[UIImage imageNamed:name]];
}
- (IBAction)colseRoom:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(closeRoom)]) {
        [self.delegate closeRoom];
    }
}

- (IBAction)onUploadLog:(id)sender {
    self.uploadLogBtn.hidden = YES;
    self.loadingView.hidden = NO;
    [self.loadingView startAnimating];
    
    WEAK(self);
    [AgoraEduManager.shareManager uploadDebugItemSuccess:^(NSString * _Nonnull serialNumber) {
        
        weakself.uploadLogBtn.hidden = NO;
        weakself.loadingView.hidden = YES;
        [weakself.loadingView stopAnimating];
        
        [AgoraEduAlertViewUtil showAlertWithController:AgoraEduTopVC.topVC title:AgoraEduLocalizedString(@"UploadLogSuccessText", nil) message:serialNumber cancelText:nil sureText:AgoraEduLocalizedString(@"OKText", nil) cancelHandler:nil sureHandler:nil];
    } failure:^(NSError * error) {
        weakself.uploadLogBtn.hidden = NO;
        weakself.loadingView.hidden = YES;
        [weakself.loadingView stopAnimating];
        [[UIApplication sharedApplication].windows.firstObject makeToast:error.localizedDescription];
    }];
}

@end
