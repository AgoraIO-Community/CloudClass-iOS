//
//  VoteListCell.m
//  AgoraEducation
//  Copyright © 2021 Agora. All rights reserved.
//

#import "VoteListCell.h"

@implementation VoteListCell{
    UIView* _optionTag;
    UILabel* _titleLab0;
    UILabel* _titleLab1;
    UILabel* _percentage;
    UIView* _line;
    UIProgressView* _progress;
    UIImageView* _imgview;
    BOOL _isMulSel;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self createView1];
    }
    return self;
}

- (void)createView1{
    _isMulSel = NO;
    
    _optionTag = [[UIView alloc] init];
    _optionTag.layer.cornerRadius = 6;
    _optionTag.layer.borderWidth = 1;
    _optionTag.layer.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:252/255.0 alpha:1.0].CGColor;
    _optionTag.layer.borderColor = [UIColor colorWithRed:236/255.0 green:236/255.0 blue:241/255.0 alpha:1.0].CGColor;
    [self.contentView addSubview: _optionTag];
    _optionTag.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *tagleft = [NSLayoutConstraint constraintWithItem:_optionTag attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:10];
    NSLayoutConstraint *tagcentery = [NSLayoutConstraint constraintWithItem:_optionTag attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    NSLayoutConstraint *tagwidth= [NSLayoutConstraint constraintWithItem:_optionTag attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:12];
    NSLayoutConstraint *tagheight= [NSLayoutConstraint constraintWithItem:_optionTag attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:12];
    [self.contentView addConstraint:tagleft];
    [self.contentView addConstraint:tagcentery];
    [_optionTag addConstraint:tagwidth];
    [_optionTag addConstraint:tagheight];
    
    _imgview = [[UIImageView alloc] init];
    [self.contentView addSubview: _imgview];
    _imgview.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *imageleft = [NSLayoutConstraint constraintWithItem:_imgview attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:10];
    NSLayoutConstraint *imagecentery = [NSLayoutConstraint constraintWithItem:_imgview attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    NSLayoutConstraint *imagewidth= [NSLayoutConstraint constraintWithItem:_imgview attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:12];
    NSLayoutConstraint *imageheight= [NSLayoutConstraint constraintWithItem:_imgview attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:12];
    [self.contentView addConstraint:imageleft];
    [self.contentView addConstraint:imagecentery];
    [_imgview addConstraint:imagewidth];
    [_imgview addConstraint:imageheight];
    
    _titleLab0 = [[UILabel alloc] init];
    _titleLab0.lineBreakMode = NSLineBreakByTruncatingTail;
    _titleLab0.numberOfLines = 2;
    _titleLab0.font = [UIFont systemFontOfSize:12.0];
    _titleLab0.attributedText = [[NSMutableAttributedString alloc] initWithString:@"" attributes: @{NSForegroundColorAttributeName: [UIColor colorWithRed:25/255.0 green:25/255.0 blue:25/255.0 alpha:1.0]}];
    _titleLab0.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview: _titleLab0];
    _titleLab0.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *lab0left = [NSLayoutConstraint constraintWithItem:_titleLab0 attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_optionTag attribute:NSLayoutAttributeRight multiplier:1.0 constant:10];
    NSLayoutConstraint *lab0centery = [NSLayoutConstraint constraintWithItem:_titleLab0 attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    NSLayoutConstraint *lab0right = [NSLayoutConstraint constraintWithItem:_titleLab0 attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    [self.contentView addConstraint:lab0left];
    [self.contentView addConstraint:lab0centery];
    [self.contentView addConstraint:lab0right];
    
    _percentage = [[UILabel alloc] init];
    _percentage.font = [UIFont systemFontOfSize:12.0];
    _percentage.attributedText = [[NSMutableAttributedString alloc] initWithString:@"(0)0%" attributes: @{NSForegroundColorAttributeName: [UIColor colorWithRed:25/255.0 green:25/255.0 blue:25/255.0 alpha:1.0]}];
    _percentage.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview: _percentage];
    [_percentage sizeToFit];
    _percentage.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *percentery = [NSLayoutConstraint constraintWithItem:_percentage attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    NSLayoutConstraint *perright = [NSLayoutConstraint constraintWithItem:_percentage attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    NSLayoutConstraint *perwidth = [NSLayoutConstraint constraintWithItem:_percentage attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:50];
    [self.contentView addConstraint:percentery];
    [self.contentView addConstraint:perright];
    [_percentage addConstraint:perwidth];
    
    _titleLab1 = [[UILabel alloc] init];
    _titleLab1.lineBreakMode = NSLineBreakByTruncatingTail;
    _titleLab1.numberOfLines = 2;
    _titleLab1.font = [UIFont systemFontOfSize:12.0];
    _titleLab1.attributedText = [[NSMutableAttributedString alloc] initWithString:@"" attributes: @{NSForegroundColorAttributeName: [UIColor colorWithRed:25/255.0 green:25/255.0 blue:25/255.0 alpha:1.0]}];
    _titleLab1.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview: _titleLab1];
    _titleLab1.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *lab1left = [NSLayoutConstraint constraintWithItem:_titleLab1 attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    NSLayoutConstraint *lab1centery = [NSLayoutConstraint constraintWithItem:_titleLab1 attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    NSLayoutConstraint *lab1right = [NSLayoutConstraint constraintWithItem:_titleLab1 attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_percentage attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-10];
    [self.contentView addConstraint:lab1left];
    [self.contentView addConstraint:lab1centery];
    [self.contentView addConstraint:lab1right];
    
    
    _line = [[UIView alloc] init];
    _line.layer.cornerRadius = 1.5;
    _line.layer.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:247/255.0 alpha:1.0].CGColor;;
    [self.contentView addSubview: _line];
    _line.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *lineleft = [NSLayoutConstraint constraintWithItem:_line attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    NSLayoutConstraint *linewidth = [NSLayoutConstraint constraintWithItem:_line attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
    NSLayoutConstraint *linebottom = [NSLayoutConstraint constraintWithItem:_line attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    NSLayoutConstraint *lineheight= [NSLayoutConstraint constraintWithItem:_line attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:1];
    [self.contentView addConstraint:lineleft];
    [self.contentView addConstraint:linewidth];
    [self.contentView addConstraint:linebottom];
    [_line addConstraint:lineheight];
    
    _progress = [[UIProgressView alloc] init];
    _progress.layer.cornerRadius = 1.5;
    _progress.trackTintColor = UIColor.clearColor;
    _progress.progressTintColor = [UIColor colorWithRed:0/255.0 green:115/255.0 blue:255/255.0 alpha:1.0];
    [self.contentView addSubview: _progress];
    _progress.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *proleft = [NSLayoutConstraint constraintWithItem:_progress attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    NSLayoutConstraint *prowidth = [NSLayoutConstraint constraintWithItem:_progress attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
    NSLayoutConstraint *probottom = [NSLayoutConstraint constraintWithItem:_progress attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    NSLayoutConstraint *proheight= [NSLayoutConstraint constraintWithItem:_progress attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:3];
    [self.contentView addConstraint:proleft];
    [self.contentView addConstraint:prowidth];
    [self.contentView addConstraint:probottom];
    [_progress addConstraint:proheight];
    
    [self setTypeUI:0];
}

- (void)setIsMulSel:(BOOL)mulSel{
    _isMulSel = mulSel;
    _optionTag.hidden = _isMulSel ? YES : NO;
    _imgview.hidden = _isMulSel ? NO : YES;
}

- (void)setSelStatus:(NSString*)title seleted:(BOOL)sel{
    [self setTypeUI:0];
    _titleLab0.text = title;
    if (sel) {
        _optionTag.layer.borderWidth = 3;
        _optionTag.layer.borderColor = [UIColor colorWithRed:53/255.0 green:123/255.0 blue:246/255.0 alpha:1.0].CGColor;
        _optionTag.layer.backgroundColor = [UIColor whiteColor].CGColor;
        
        [_imgview setImage:[UIImage imageNamed:@"vt_checked"]];
    }else{
        _optionTag.layer.borderWidth = 1;
        _optionTag.layer.borderColor = [UIColor colorWithRed:236/255.0 green:236/255.0 blue:241/255.0 alpha:1.0].CGColor;
        _optionTag.layer.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:252/255.0 alpha:1.0].CGColor;
        
        [_imgview setImage:[UIImage imageNamed:@"vt_unchecked"]];
    }
}

- (void)setResStatus:(NSString*)title selNum:(NSInteger)sel percent:(float)fte{
    [self setTypeUI:1];
    _titleLab1.text = title;
    _progress.progress = fte;
    NSString* nsval = [NSString stringWithFormat:@"(%ld)%d%%", sel, (int)(fte * 100)];
    _percentage.text = nsval;
}

- (void)setTypeUI:(NSInteger)type{
    if (0 == type) {
        _optionTag.hidden = _isMulSel ? YES : NO;
        _imgview.hidden = _isMulSel ? NO : YES;
        _titleLab0.hidden = NO;
        _titleLab1.hidden = YES;
        _percentage.hidden = YES;
        _progress.hidden = YES;
        
        _line.layer.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:247/255.0 alpha:1.0].CGColor;
        for (NSLayoutConstraint *constraint in _line.constraints){
            if (constraint.firstAttribute == NSLayoutAttributeHeight) {
                constraint.constant = 1;
            }
        }
    }else{
        _optionTag.hidden = YES;
        _imgview.hidden = YES;
        _titleLab0.hidden = YES;
        _titleLab1.hidden = NO;
        _percentage.hidden = NO;
        _progress.hidden = NO;
        _line.layer.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:252/255.0 alpha:1.0].CGColor;
        for (NSLayoutConstraint *constraint in _line.constraints){
            if (constraint.firstAttribute == NSLayoutAttributeHeight) {
                constraint.constant = 3;
            }
        }
    }
}

@end
