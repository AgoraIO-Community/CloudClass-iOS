//
//  AgoraRefreshBackStateFooter.h
//  AgoraRefreshExample
//
//  Created by MJ Lee on 15/6/13.
//  Copyright © 2015年 小码哥. All rights reserved.
//

#import "AgoraRefreshBackFooter.h"

NS_ASSUME_NONNULL_BEGIN

@interface AgoraRefreshBackStateFooter : AgoraRefreshBackFooter
/** 文字距离圈圈、箭头的距离 */
@property (assign, nonatomic) CGFloat labelLeftInset;
/** 显示刷新状态的label */
@property (weak, nonatomic, readonly) UILabel *stateLabel;
/** 设置state状态下的文字 */
- (void)setTitle:(NSString *)title forState:(AgoraRefreshState)state;

/** 获取state状态下的title */
- (NSString *)titleForState:(AgoraRefreshState)state;
@end

NS_ASSUME_NONNULL_END
