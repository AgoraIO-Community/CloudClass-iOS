//
//  AgoraRefreshStateHeader.m
//  AgoraRefreshExample
//
//  Created by MJ Lee on 15/4/24.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "AgoraRefreshStateHeader.h"

@interface AgoraRefreshStateHeader()
{
    /** 显示上一次刷新时间的label */
    __unsafe_unretained UILabel *_lastUpdatedTimeLabel;
    /** 显示刷新状态的label */
    __unsafe_unretained UILabel *_stateLabel;
}
/** 所有状态对应的文字 */
@property (strong, nonatomic) NSMutableDictionary *stateTitles;
@end

@implementation AgoraRefreshStateHeader
#pragma mark - 懒加载
- (NSMutableDictionary *)stateTitles
{
    if (!_stateTitles) {
        self.stateTitles = [NSMutableDictionary dictionary];
    }
    return _stateTitles;
}

- (UILabel *)stateLabel
{
    if (!_stateLabel) {
        [self addSubview:_stateLabel = [UILabel agora_label]];
    }
    return _stateLabel;
}

- (UILabel *)lastUpdatedTimeLabel
{
    if (!_lastUpdatedTimeLabel) {
        [self addSubview:_lastUpdatedTimeLabel = [UILabel agora_label]];
    }
    return _lastUpdatedTimeLabel;
}

#pragma mark - 公共方法
- (void)setTitle:(NSString *)title forState:(AgoraRefreshState)state
{
    if (title == nil) return;
    self.stateTitles[@(state)] = title;
    self.stateLabel.text = self.stateTitles[@(self.state)];
}

#pragma mark key的处理
- (void)setLastUpdatedTimeKey:(NSString *)lastUpdatedTimeKey
{
    [super setLastUpdatedTimeKey:lastUpdatedTimeKey];
    
    // 如果label隐藏了，就不用再处理
    if (self.lastUpdatedTimeLabel.hidden) return;
    
    NSDate *lastUpdatedTime = [[NSUserDefaults standardUserDefaults] objectForKey:lastUpdatedTimeKey];
    
    // 如果有block
    if (self.lastUpdatedTimeText) {
        self.lastUpdatedTimeLabel.text = self.lastUpdatedTimeText(lastUpdatedTime);
        return;
    }
    
    if (lastUpdatedTime) {
        // 1.获得年月日
        NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
        NSUInteger unitFlags = NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
        NSDateComponents *cmp1 = [calendar components:unitFlags fromDate:lastUpdatedTime];
        NSDateComponents *cmp2 = [calendar components:unitFlags fromDate:[NSDate date]];
        
        // 2.格式化日期
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        BOOL isToday = NO;
        if ([cmp1 day] == [cmp2 day]) { // 今天
            formatter.dateFormat = @" HH:mm";
            isToday = YES;
        } else if ([cmp1 year] == [cmp2 year]) { // 今年
            formatter.dateFormat = @"MM-dd HH:mm";
        } else {
            formatter.dateFormat = @"yyyy-MM-dd HH:mm";
        }
        NSString *time = [formatter stringFromDate:lastUpdatedTime];
        
        // 3.显示日期
        self.lastUpdatedTimeLabel.text = [NSString stringWithFormat:@"%@%@%@",
                                          [NSBundle agora_localizedStringForKey:AgoraRefreshHeaderLastTimeText],
                                          isToday ? [NSBundle agora_localizedStringForKey:AgoraRefreshHeaderDateTodayText] : @"",
                                          time];
    } else {
        self.lastUpdatedTimeLabel.text = [NSString stringWithFormat:@"%@%@",
                                          [NSBundle agora_localizedStringForKey:AgoraRefreshHeaderLastTimeText],
                                          [NSBundle agora_localizedStringForKey:AgoraRefreshHeaderNoneLastDateText]];
    }
}

#pragma mark - 覆盖父类的方法
- (void)prepare
{
    [super prepare];
    
    // 初始化间距
    self.labelLeftInset = AgoraRefreshLabelLeftInset;
    
    // 初始化文字
    [self setTitle:[NSBundle agora_localizedStringForKey:AgoraRefreshHeaderIdleText] forState:AgoraRefreshStateIdle];
    [self setTitle:[NSBundle agora_localizedStringForKey:AgoraRefreshHeaderPullingText] forState:AgoraRefreshStatePulling];
    [self setTitle:[NSBundle agora_localizedStringForKey:AgoraRefreshHeaderRefreshingText] forState:AgoraRefreshStateRefreshing];
}

- (void)placeSubviews
{
    [super placeSubviews];
    
    if (self.stateLabel.hidden) return;
    
    BOOL noConstrainsOnStatusLabel = self.stateLabel.constraints.count == 0;
    
    if (self.lastUpdatedTimeLabel.hidden) {
        // 状态
        if (noConstrainsOnStatusLabel) self.stateLabel.frame = self.bounds;
    } else {
        CGFloat stateLabelH = self.agora_refresh_h * 0.5;
        // 状态
        if (noConstrainsOnStatusLabel) {
            self.stateLabel.agora_refresh_x = 0;
            self.stateLabel.agora_refresh_y = 0;
            self.stateLabel.agora_refresh_w = self.agora_refresh_w;
            self.stateLabel.agora_refresh_h = stateLabelH;
        }
        
        // 更新时间
        if (self.lastUpdatedTimeLabel.constraints.count == 0) {
            self.lastUpdatedTimeLabel.agora_refresh_x = 0;
            self.lastUpdatedTimeLabel.agora_refresh_y = stateLabelH;
            self.lastUpdatedTimeLabel.agora_refresh_w = self.agora_refresh_w;
            self.lastUpdatedTimeLabel.agora_refresh_h = self.agora_refresh_h - self.lastUpdatedTimeLabel.agora_refresh_y;
        }
    }
}

- (void)setState:(AgoraRefreshState)state
{
    AgoraRefreshCheckState
    
    // 设置状态文字
    self.stateLabel.text = self.stateTitles[@(state)];
    
    // 重新设置key（重新显示时间）
    self.lastUpdatedTimeKey = self.lastUpdatedTimeKey;
}
@end
