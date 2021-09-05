//
//  EMMessageTimeCell.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/2/20.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMMessageStringCell.h"
#import <Masonry/Masonry.h>
#import "UIImage+ChatExt.h"

@interface EMMessageStringCell ()
@property (nonatomic,strong) UIView* containerView;
@end

@implementation EMMessageStringCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];
        //self.contentView.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:252/255.0 alpha:1.0];
        self.containerView = [[UIView alloc] init];
        self.containerView.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:252/255.0 alpha:1.0];
        self.containerView.layer.cornerRadius = 4;
        [self.contentView addSubview:self.containerView];
        [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.contentView);
            make.width.equalTo(self.contentView).offset(-28);
            make.height.equalTo(self.contentView).offset(-8);
        }];
        
        _stringLabel = [[UILabel alloc] init];
        _stringLabel.font = [UIFont systemFontOfSize:13];
        _stringLabel.backgroundColor = [UIColor clearColor];
        _stringLabel.textAlignment = NSTextAlignmentLeft;
        _stringLabel.numberOfLines = 0;
        [self.containerView addSubview:_stringLabel];
        [_stringLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.containerView);
            make.centerX.equalTo(self.containerView).offset(9);
            make.height.equalTo(self.containerView).offset(-8);
            make.width.lessThanOrEqualTo(self.containerView).offset(-50);
        }];
        
        [_stringLabel sizeToFit];
        self.preImageView = [[UIImageView alloc] init];
        self.preImageView.image = [UIImage imageNamedFromBundle:@"icon_caution"];
        [self.containerView addSubview:self.preImageView];
        [self.preImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@18);
            make.height.equalTo(@20);
            make.right.equalTo(self.stringLabel.mas_left).offset(-5);
            make.centerY.equalTo(self.containerView);
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

- (void)updatetext:(NSString*)aText
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:aText];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:5];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [aText length])];
        self.stringLabel.attributedText = attributedString;
}

@end
