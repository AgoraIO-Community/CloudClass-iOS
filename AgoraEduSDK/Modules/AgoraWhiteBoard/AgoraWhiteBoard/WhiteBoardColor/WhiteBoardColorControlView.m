//
//  WhiteBoardColorControlView.m
//  AgoraWhiteBoard
//
//  Created by SRS on 2020/7/14.
//  Copyright © 2020 agora. All rights reserved.
//

#import "WhiteBoardColorControlView.h"
#import "WhiteBoardColorCell.h"
#import "WhiteBoardUtil.h"

@interface WhiteBoardColorControlView ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *pickerLabel;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *colorFlowLayout;
@property (weak, nonatomic) IBOutlet UICollectionView *colorCollectionView;

@property (nonatomic,strong) NSMutableArray<NSNumber *> *colorArray;

@property (nonatomic, weak) WhiteBoardColorCell *temCell;
@end


@implementation WhiteBoardColorControlView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.colorArray = [NSMutableArray arrayWithObjects:@(0xFF0D19),@(0xFF8F00),@(0xFFCA00),@(0x00DD52),@(0x007CFF),@(0xC455DF),@(0xFFFFFF),@(0xEEEEEE),@(0xCCCCCC),@(0x666666),@(0x333333),@(0x000000), nil];

    self.layer.borderWidth = 1.f;
    self.layer.borderColor = [UIColor colorWithRed:219/255.0 green:226/255.0 blue:229/255.0 alpha:1.0].CGColor;

    self.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
    self.layer.cornerRadius = 6;
    self.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.1].CGColor;
    self.layer.shadowOffset = CGSizeMake(0,2);
    self.layer.shadowOpacity = 2;
    self.layer.shadowRadius = 4;
    self.colorCollectionView.delegate = self;
    self.colorCollectionView.dataSource = self;
    [self.colorCollectionView registerClass:[WhiteBoardColorCell class] forCellWithReuseIdentifier:@"ColorCell"];
    self.pickerLabel.text = [WhiteBoardUtil localizedString:@"ColorPickerText"];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.colorArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WhiteBoardColorCell *Cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ColorCell" forIndexPath:indexPath];
    Cell.outColorView.hidden = YES;
    NSInteger iColor = [self.colorArray[indexPath.row] integerValue];
    Cell.colorView.backgroundColor = ColorWithHex(iColor, 1);
    return Cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    WhiteBoardColorCell *cell = (WhiteBoardColorCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (self.temCell) {
        self.temCell.outColorView.hidden = YES;
    }
    cell.outColorView.hidden = NO;
    self.temCell = cell;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(onSelectColor:)]) {
        NSInteger iColor = [self.colorArray[indexPath.row] integerValue];
        [self.delegate onSelectColor: ColorWithHex(iColor, 1)];
    }
}

@end
