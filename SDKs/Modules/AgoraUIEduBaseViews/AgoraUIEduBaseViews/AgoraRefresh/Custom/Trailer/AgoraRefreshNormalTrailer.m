//
//  AgoraRefreshNormalTrailer.m
//  AgoraRefreshExample
//
//  Created by kinarobin on 2020/5/3.
//  Copyright © 2020 小码哥. All rights reserved.
//

#import "AgoraRefreshNormalTrailer.h"
#import "NSBundle+AgoraRefresh.h"

@interface AgoraRefreshNormalTrailer() {
    __unsafe_unretained UIImageView *_arrowView;
}
@end

@implementation AgoraRefreshNormalTrailer
#pragma mark - 懒加载子控件
- (UIImageView *)arrowView {
    if (!_arrowView) {
        UIImageView *arrowView = [[UIImageView alloc] initWithImage:[NSBundle agora_trailArrowImage]];
        [self addSubview:_arrowView = arrowView];
    }
    return _arrowView;
}

- (void)placeSubviews {
    [super placeSubviews];

    CGSize arrowSize = self.arrowView.image.size;
    // 箭头的中心点
    CGPoint selfCenter = CGPointMake(self.agora_refresh_w * 0.5, self.agora_refresh_h * 0.5);
    CGPoint arrowCenter = CGPointMake(arrowSize.width * 0.5 + 5, self.agora_refresh_h * 0.5);
    BOOL stateHidden = self.stateLabel.isHidden;
    
    if (self.arrowView.constraints.count == 0) {
        self.arrowView.agora_refresh_size = self.arrowView.image.size;
        self.arrowView.center = stateHidden ?  selfCenter : arrowCenter ;
    }
    self.arrowView.tintColor = self.stateLabel.textColor;
    
    if (stateHidden) return;
    
    BOOL noConstrainsOnStatusLabel = self.stateLabel.constraints.count == 0;
    CGFloat stateLabelW = ceil(self.stateLabel.font.pointSize);
    // 状态
    if (noConstrainsOnStatusLabel) {
        BOOL arrowHidden = self.arrowView.isHidden;
        CGFloat stateCenterX = (self.agora_refresh_w + arrowSize.width) * 0.5;
        self.stateLabel.center = arrowHidden ? selfCenter : CGPointMake(stateCenterX, self.agora_refresh_h * 0.5);
        self.stateLabel.agora_refresh_size = CGSizeMake(stateLabelW, self.agora_refresh_h) ;
    }
}

- (void)setState:(AgoraRefreshState)state {
    AgoraRefreshCheckState
    // 根据状态做事情
    if (state == AgoraRefreshStateIdle) {
        if (oldState == AgoraRefreshStateRefreshing) {
            [UIView animateWithDuration:AgoraRefreshFastAnimationDuration animations:^{
                self.arrowView.transform = CGAffineTransformMakeRotation(M_PI);
            } completion:^(BOOL finished) {
                self.arrowView.transform = CGAffineTransformIdentity;
            }];
        } else {
            [UIView animateWithDuration:AgoraRefreshFastAnimationDuration animations:^{
                self.arrowView.transform = CGAffineTransformIdentity;
            }];
        }
    } else if (state == AgoraRefreshStatePulling) {
        [UIView animateWithDuration:AgoraRefreshFastAnimationDuration animations:^{
            self.arrowView.transform = CGAffineTransformMakeRotation(M_PI);
        }];
    }
}



@end
