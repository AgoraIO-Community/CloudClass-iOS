//
//  CustomBadgeView.m
//  ChatWidget
//
//  Created by lixiaoming on 2021/7/7.
//

#import "CustomBadgeView.h"
const static NSInteger BADGE_SIZE = 8;

@implementation CustomBadgeView

- (instancetype)init
{
    self = [super init];
    if(self) {
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews
{
    self.badgeSize = BADGE_SIZE;
    self.layer.cornerRadius = BADGE_SIZE/2;
    self.backgroundColor = [UIColor redColor];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
