//
//  WhiteBoardToolControlView.m
//  AgoraWhiteBoard
//
//  Created by SRS on 2020/7/14.
//  Copyright © 2020 agora. All rights reserved.
//

#import "WhiteBoardToolControlView.h"
#import "WhiteBoardUtil.h"

@interface WhiteBoardToolControlView()

@property (weak, nonatomic) IBOutlet UIView *bgView;

@property (weak, nonatomic) UIButton *selectButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint3;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint4;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint5;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftConstraint1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftConstraint2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftConstraint3;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftConstraint4;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftConstraint5;


@end

@implementation WhiteBoardToolControlView
- (void)awakeFromNib {
    [super awakeFromNib];
    self.bgView.layer.cornerRadius = 8;
    self.bgView.layer.masksToBounds = YES;
    self.bgView.layer.borderColor = ColorWithHex(0xffffff, 0.4).CGColor;
    self.bgView.layer.borderWidth = 1;
}

- (IBAction)onButtonClicked:(UIButton *)sender {
    
    if (self.selectButton != nil) {
        self.selectButton.backgroundColor = ColorWithHex(0x565656, 1);
    }
    if (sender.tag == 204 && self.selectButton.tag == 204) {
        self.selectButton = nil;
    } else {
        sender.backgroundColor = ColorWithHex(0x141414, 1);
        self.selectButton = sender;
    }
    
//    if (self.selectButton != nil) {
//         [self.selectButton setSelected:NO];
//    }
//
//    BOOL isSelected = self.selectButton.isSelected;
//    self.selectButton = sender;
//    [self.selectButton setSelected:!isSelected];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(onSelectToolType:)]) {
        [self.delegate onSelectToolType:sender.tag - 200];
    }
}

- (void)setToolDirection: (WihteBoardToolDirectionType)type {
    if(type == WihteBoardToolDirectionTypePortrait) {
        self.topConstraint1.constant = 46;
        self.topConstraint2.constant = 88;
        self.topConstraint3.constant = 130;
        self.topConstraint4.constant = 172;
        
        self.leftConstraint1.constant = 4;
        self.leftConstraint2.constant = 4;
        self.leftConstraint3.constant = 4;
        self.leftConstraint4.constant = 4;
    } else {
        self.topConstraint1.constant = 4;
        self.topConstraint2.constant = 4;
        self.topConstraint3.constant = 4;
        self.topConstraint4.constant = 4;
        
        self.leftConstraint1.constant = 46;
        self.leftConstraint2.constant = 88;
        self.leftConstraint3.constant = 130;
        self.leftConstraint4.constant = 172;
    }
}

- (void)setToolStyle: (WihteBoardToolStyle)style {
    
    //    ColorWithHex(0xE9EFF4)
//    self.bgView.layer.borderColor = [UIColor colorWithHexString:@"E9EFF4"].CGColor;
}

@end
