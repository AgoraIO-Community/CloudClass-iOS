//
//  EMMessageCell.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/25.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMMessageCell.h"

#import "EMMessageStatusView.h"

#import "EMMsgTextBubbleView.h"
#import "EMMsgImageBubbleView.h"
#import "ChatWidget+Localizable.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface EMMessageCell()

@property (nonatomic, strong) UIImageView *avatarView;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) EMMessageStatusView *statusView;

@property (nonatomic, strong) UIButton *readReceiptBtn;//阅读回执按钮

@property (nonatomic, strong) UITextField *roleTag;
@end

@implementation EMMessageCell

- (instancetype)initWithDirection:(EMMessageDirection)aDirection
                             type:(EMMessageType)aType
{
    NSString *identifier = [EMMessageCell cellIdentifierWithDirection:aDirection type:aType];
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    if (self) {
        _direction = aDirection;
        [self _setupViewsWithType:aType];
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

#pragma mark - Class Methods

+ (NSString *)cellIdentifierWithDirection:(EMMessageDirection)aDirection
                                     type:(EMMessageType)aType
{
    NSString *identifier = @"EMMsgCellDirectionSend";
    if (aDirection == EMMessageDirectionReceive) {
        identifier = @"EMMsgCellDirectionRecv";
    }
    
    if (aType == EMMessageTypeText || aType == EMMessageTypeExtCall) {
        identifier = [NSString stringWithFormat:@"%@Text", identifier];
    } else if (aType == EMMessageTypeImage) {
        identifier = [NSString stringWithFormat:@"%@Image", identifier];
    } else if (aType == EMMessageTypeVoice) {
        identifier = [NSString stringWithFormat:@"%@Voice", identifier];
    } else if (aType == EMMessageTypeVideo) {
        identifier = [NSString stringWithFormat:@"%@Video", identifier];
    } else if (aType == EMMessageTypeLocation) {
        identifier = [NSString stringWithFormat:@"%@Location", identifier];
    } else if (aType == EMMessageTypeFile) {
        identifier = [NSString stringWithFormat:@"%@File", identifier];
    } else if (aType == EMMessageTypeExtGif) {
        identifier = [NSString stringWithFormat:@"%@ExtGif", identifier];
    }
    
    return identifier;
}

#pragma mark - Subviews

- (void)_setupViewsWithType:(EMMessageType)aType
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    
    _avatarView = [[UIImageView alloc] init];
    _avatarView.contentMode = UIViewContentModeScaleAspectFit;
    _avatarView.backgroundColor = [UIColor clearColor];
    _avatarView.userInteractionEnabled = YES;
    [self.contentView addSubview:_avatarView];
    
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.font = [UIFont systemFontOfSize:13];
    _nameLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:_nameLabel];
    _avatarView.image = [UIImage imageNamed:@"user_avatar_me"];
    
    _roleTag = [[UITextField alloc] init];
    _roleTag.font = [UIFont systemFontOfSize:12];
    _roleTag.textColor = [UIColor colorWithRed:88/255.0 green:99/255.0 blue:118/255.0 alpha:1.0];
    _roleTag.layer.cornerRadius = 8;
    _roleTag.layer.borderWidth = 1;
    _roleTag.layer.borderColor = [UIColor colorWithRed:236/255.0 green:236/255.0 blue:241/255.0 alpha:1.0].CGColor;
    _roleTag.hidden = YES;
    _roleTag.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 0)];
    _roleTag.leftViewMode = UITextFieldViewModeAlways;
    _roleTag.rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 0)];
    _roleTag.rightViewMode = UITextFieldViewModeAlways;
    _roleTag.text = [ChatWidget LocalizedString:@"ChatTeacher"];
    _roleTag.enabled = NO;
    [self.contentView addSubview:_roleTag];
    
    if (self.direction == EMMessageDirectionSend) {
        [_avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(5);
            make.right.equalTo(self.contentView).offset(-10);
            make.width.height.equalTo(@28);
        }];
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.avatarView);
            make.right.equalTo(_avatarView.mas_left).offset(-6);
        }];
        _nameLabel.textAlignment = NSTextAlignmentRight;
        [_roleTag mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.avatarView);
            make.right.equalTo(_nameLabel.mas_left).offset(-6);
        }];
    } else {
        [_avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(5);
            make.left.equalTo(self.contentView).offset(10);
            make.width.height.equalTo(@28);
        }];
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.avatarView);
            make.left.equalTo(self.avatarView.mas_right).offset(6);
        }];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        [_roleTag mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.avatarView);
            make.left.equalTo(_nameLabel.mas_right).offset(6);
        }];
    }
    
    _bubbleView = [self _getBubbleViewWithType:aType];
    _bubbleView.userInteractionEnabled = YES;
    _bubbleView.clipsToBounds = YES;
    _bubbleView.layer.cornerRadius = 4;
    [self.contentView addSubview:_bubbleView];
    if (self.direction == EMMessageDirectionSend) {
        [_bubbleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.avatarView.mas_bottom).offset(8);
            make.bottom.equalTo(self.contentView).offset(-15);
            make.left.greaterThanOrEqualTo(self.contentView).offset(46);
            make.right.equalTo(self.contentView).offset(-12);
        }];
    } else {
        [_bubbleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.avatarView.mas_bottom).offset(8);
            make.bottom.equalTo(self.contentView).offset(-15);
            make.left.equalTo(self.contentView).offset(12);
            make.right.lessThanOrEqualTo(self.contentView).offset(-46);
        }];
    }

    _statusView = [[EMMessageStatusView alloc] init];
    [self.contentView addSubview:_statusView];
    if (self.direction == EMMessageDirectionSend) {
        [_statusView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.bubbleView.mas_centerY);
            make.right.equalTo(self.bubbleView.mas_left).offset(-8);
            make.height.equalTo(@20);
        }];
        __weak typeof(self) weakself = self;
        [_statusView setResendCompletion:^{
            if (weakself.delegate && [weakself.delegate respondsToSelector:@selector(messageCellDidResend:)]) {
                [weakself.delegate messageCellDidResend:weakself.model];
            }
        }];
    } else {
        _statusView.backgroundColor = [UIColor redColor];
        _statusView.clipsToBounds = YES;
        _statusView.layer.cornerRadius = 4;
        [_statusView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.bubbleView).offset(5);
            make.left.equalTo(self.bubbleView.mas_right).offset(5);
            make.width.height.equalTo(@8);
        }];
    }
    
    [self setCellIsReadReceipt];
    
}

- (void)setCellIsReadReceipt{
    _readReceiptBtn = [[UIButton alloc]init];
    _readReceiptBtn.layer.cornerRadius = 5;
    _readReceiptBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    _readReceiptBtn.backgroundColor = [UIColor lightGrayColor];
    [_readReceiptBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _readReceiptBtn.titleLabel.font = [UIFont systemFontOfSize: 10.0];
    [_readReceiptBtn addTarget:self action:@selector(readReceiptDetilAction) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_readReceiptBtn];
    if(self.direction == EMMessageDirectionSend) {
        [_readReceiptBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.bubbleView.mas_bottom).offset(2);
            make.right.equalTo(self.bubbleView.mas_right);
            make.height.equalTo(@15);
        }];
    }
}

- (EMMessageBubbleView *)_getBubbleViewWithType:(EMMessageType)aType
{
    EMMessageBubbleView *bubbleView = nil;
    switch (aType) {
        case EMMessageTypeText:
        case EMMessageTypeExtCall:
            bubbleView = [[EMMsgTextBubbleView alloc] initWithDirection:self.direction type:aType];
            break;
        case EMMessageTypeImage:
            bubbleView = [[EMMsgImageBubbleView alloc] initWithDirection:self.direction type:aType];
            break;
        default:
            break;
    }
    if (bubbleView) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bubbleViewTapAction:)];
        [bubbleView addGestureRecognizer:tap];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(bubbleViewLongPressAction:)];
        [bubbleView addGestureRecognizer:longPress];
    }
    
    return bubbleView;
}

#pragma mark - Setter

- (void)setModel:(EMMessageModel *)model
{
    _model = model;
    self.bubbleView.model = model;
    self.nameLabel.text = model.emModel.from;
    NSDictionary*ext = model.emModel.ext;
    NSString* nickName = [ext objectForKey:@"nickName"];
    NSString* avartarUrl = [ext objectForKey:@"avatarUrl"];
    NSNumber* role = [ext objectForKey:@"role"];
    if(nickName.length > 0) {
        self.nameLabel.text = nickName;
    }
    if(avartarUrl.length > 0) {
        NSURL * url = [NSURL URLWithString:avartarUrl];
        if(url) {
            [self.avatarView sd_setImageWithURL:url completed:nil];
        }
    }
    if(role.longValue == 1 || role.longValue == 3) {
        self.roleTag.text = role.longValue == 1?[ChatWidget LocalizedString:@"ChatTeacher" ] : [ChatWidget LocalizedString:@"ChatAssistant"];
        self.roleTag.hidden = NO;
    }else{
        self.roleTag.hidden = YES;
    }
    
    if (model.direction == EMMessageDirectionSend) {
        
        [self.statusView setSenderStatus:model.emModel.status isReadAcked:model.emModel.isReadAcked];
    }
    if(model.emModel.isNeedGroupAck) {
        self.readReceiptBtn.hidden = NO;
        [self.readReceiptBtn setTitle:_model.readReceiptCount forState:UIControlStateNormal];
    }else{
        self.readReceiptBtn.hidden = YES;
    }
}

#pragma mark - Action

- (void)readReceiptDetilAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(messageReadReceiptDetil:)]) {
        [self.delegate messageReadReceiptDetil:self];
    }
}

- (void)bubbleViewTapAction:(UITapGestureRecognizer *)aTap
{
    if (aTap.state == UIGestureRecognizerStateEnded) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(messageCellDidSelected:)]) {
            [self.delegate messageCellDidSelected:self];
        }
    }
}

- (void)bubbleViewLongPressAction:(UILongPressGestureRecognizer *)aLongPress
{
    if (aLongPress.state == UIGestureRecognizerStateBegan) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(messageCellDidLongPress:)]) {
            [self.delegate messageCellDidLongPress:self];
        }
    }
}

@end
