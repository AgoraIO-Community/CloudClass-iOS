//
//  EMMessageStatusView.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/25.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMMessageStatusView.h"
#import <Masonry/Masonry.h>

@interface EMMessageStatusView()

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIButton *failButton;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@end

@implementation EMMessageStatusView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.hidden = YES;
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

#pragma mark - Subviews

- (UILabel *)label
{
    if (_label == nil) {
        _label = [[UILabel alloc] init];
        _label.textColor = [UIColor grayColor];
        _label.font = [UIFont systemFontOfSize:13];
    }
    
    return _label;
}

- (UIButton *)failButton
{
    if (_failButton == nil) {
        _failButton = [[UIButton alloc] init];
        [_failButton setImage:[UIImage imageNamed:@"msg_fail"] forState:UIControlStateNormal];
        [_failButton addTarget:self action:@selector(failButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _failButton;
}

- (UIActivityIndicatorView *)activityView
{
    if (_activityView == nil) {
        _activityView = [[UIActivityIndicatorView alloc] init];
        _activityView.color = [UIColor blueColor];
    }
    
    return _activityView;
}

#pragma mark - Public

- (void)setSenderStatus:(EMMessageStatus)aStatus
            isReadAcked:(BOOL)aIsReadAcked
{
    if (aStatus == EMMessageStatusDelivering) {
        self.hidden = NO;
        [_label removeFromSuperview];
        [_failButton removeFromSuperview];
        
        [self addSubview:self.activityView];
        [self.activityView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
            make.width.equalTo(@20);
        }];
        [self.activityView startAnimating];
    } else if (aStatus == EMMessageStatusFailed) {
        self.hidden = NO;
        [_label removeFromSuperview];
        
        [_activityView stopAnimating];
        [_activityView removeFromSuperview];
        
        [self addSubview:self.failButton];
        [self.failButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
            make.width.equalTo(@20);
        }];
    } else if (aStatus == EMMessageStatusSucceed) {
        self.hidden = NO;
        [_failButton removeFromSuperview];
        
        [_activityView stopAnimating];
        [_activityView removeFromSuperview];
        
        self.label.text = aIsReadAcked ? @"已读" : nil;
        [self addSubview:self.label];
        [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    } else {
        self.hidden = YES;
        [_label removeFromSuperview];
        [_failButton removeFromSuperview];
        
        [_activityView stopAnimating];
        [_activityView removeFromSuperview];
    }
}

#pragma mark - Action

- (void)failButtonAction
{
    if (self.resendCompletion) {
        self.resendCompletion();
    }
}

@end
