//
//  AgoraEEChatTextFiled.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/10/25.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "AgoraEEChatTextFiled.h"

@implementation AgoraEEChatTextFiled

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [AgoraEduBundle loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
        [self addSubview:self.chatTextFiled];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.chatTextFiled.frame = self.bounds;

    self.chatBgView.layer.cornerRadius = 17;
    self.chatBgView.layer.masksToBounds = YES;
    self.chatBgView.layer.borderWidth = 1.f;
    self.chatBgView.layer.borderColor = [UIColor colorWithHexString:@"DBE2E5"].CGColor;
    
    self.layer.borderWidth = 1.f;
    self.layer.borderColor = [UIColor colorWithHexString:@"DBE2E5"].CGColor;
}
@end
