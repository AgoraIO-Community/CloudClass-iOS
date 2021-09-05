//
//  AgoraRefreshStateTrailer.h
//  AgoraRefreshExample
//
//  Created by kinarobin on 2020/5/3.
//  Copyright © 2020 小码哥. All rights reserved.
//

#import "AgoraRefreshTrailer.h"

NS_ASSUME_NONNULL_BEGIN


@interface AgoraRefreshStateTrailer : AgoraRefreshTrailer

#pragma mark - 状态相关
/** 显示刷新状态的label */
@property (weak, nonatomic, readonly) UILabel *stateLabel;
/** 设置state状态下的文字 */
- (void)setTitle:(NSString *)title forState:(AgoraRefreshState)state;

@end

NS_ASSUME_NONNULL_END
