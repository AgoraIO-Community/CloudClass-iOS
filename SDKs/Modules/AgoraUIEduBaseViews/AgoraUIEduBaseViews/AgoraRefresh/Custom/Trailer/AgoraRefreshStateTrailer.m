//
//  AgoraRefreshStateTrailer.m
//  AgoraRefreshExample
//
//  Created by kinarobin on 2020/5/3.
//  Copyright © 2020 小码哥. All rights reserved.
//

#import "AgoraRefreshStateTrailer.h"

@interface AgoraRefreshStateTrailer() {
    /** 显示刷新状态的label */
    __unsafe_unretained UILabel *_stateLabel;
}
/** 所有状态对应的文字 */
@property (strong, nonatomic) NSMutableDictionary *stateTitles;
@end

@implementation AgoraRefreshStateTrailer
#pragma mark - 懒加载
- (NSMutableDictionary *)stateTitles {
    if (!_stateTitles) {
        self.stateTitles = [NSMutableDictionary dictionary];
    }
    return _stateTitles;
}

- (UILabel *)stateLabel {
    if (!_stateLabel) {
        UILabel *stateLabel = [UILabel agora_label];
        stateLabel.numberOfLines = 0;
        [self addSubview:_stateLabel = stateLabel];
    }
    return _stateLabel;
}

#pragma mark - 公共方法
- (void)setTitle:(NSString *)title forState:(AgoraRefreshState)state {
    if (title == nil) return;
    self.stateTitles[@(state)] = title;
}

#pragma mark - 覆盖父类的方法
- (void)prepare {
    [super prepare];
    
    // 初始化文字
    [self setTitle:[NSBundle agora_localizedStringForKey:AgoraRefreshTrailerIdleText] forState:AgoraRefreshStateIdle];
    [self setTitle:[NSBundle agora_localizedStringForKey:AgoraRefreshTrailerPullingText] forState:AgoraRefreshStatePulling];
    [self setTitle:[NSBundle agora_localizedStringForKey:AgoraRefreshTrailerPullingText] forState:AgoraRefreshStateRefreshing];
}

- (void)setState:(AgoraRefreshState)state {
    AgoraRefreshCheckState
    // 设置状态文字
    self.stateLabel.text = self.stateTitles[@(state)];
}

- (void)placeSubviews {
    [super placeSubviews];
    
    if (self.stateLabel.hidden) return;
    
    BOOL noConstrainsOnStatusLabel = self.stateLabel.constraints.count == 0;
    CGFloat stateLabelW = ceil(self.stateLabel.font.pointSize);
    // 状态
    if (noConstrainsOnStatusLabel) {
        self.stateLabel.center = CGPointMake(self.agora_refresh_w * 0.5, self.agora_refresh_h * 0.5);
        self.stateLabel.agora_refresh_size = CGSizeMake(stateLabelW, self.agora_refresh_h) ;
    }
}

@end
