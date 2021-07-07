//
//  EMMessageTimeCell.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/2/20.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMMessageStringCell.h"
#import <Masonry/Masonry.h>

@implementation EMMessageStringCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];
        self.contentView.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:252/255.0 alpha:1.0];
        
        _stringLabel = [[UILabel alloc] init];
        _stringLabel.font = [UIFont systemFontOfSize:14];
        _stringLabel.textColor = [UIColor grayColor];
        _stringLabel.backgroundColor = [UIColor clearColor];
        _stringLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_stringLabel];
        [_stringLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
            make.height.equalTo(@30);
        }];
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
