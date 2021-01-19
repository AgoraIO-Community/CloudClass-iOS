//
//  WhiteBoardColorCell.m
//  AgoraWhiteBoard
//
//  Created by SRS on 2020/7/14.
//  Copyright © 2020 agora. All rights reserved.
//

#import "WhiteBoardColorCell.h"
#import "WhiteBoardUtil.h"

@implementation WhiteBoardColorCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIView *outColorView = [[UIView alloc] init];
        outColorView.frame = CGRectMake(0, 0, 26, 26);
        [self addSubview:outColorView];
        
        outColorView.backgroundColor = ColorWithHex(0xDEEFFF, 1);
        outColorView.layer.borderWidth = 1.f;
        outColorView.layer.borderColor = ColorWithHex(0x44A2FC, 1).CGColor;
        outColorView.layer.cornerRadius = 13.f;
        outColorView.layer.masksToBounds = YES;
        self.outColorView = outColorView;
        
        UIView *colorView = [[UIView alloc] init];
        colorView.frame = CGRectMake(3, 3, 20, 20);
        [self addSubview:colorView];
        colorView.layer.cornerRadius = 10.f;
        colorView.layer.masksToBounds = YES;
        self.colorView = colorView;
    }
    return self;
}

@end
