//
//  EmojiKeyboardView.m
//  AgoraEducation
//
//  Created by lixiaoming on 2021/5/12.
//  Copyright © 2021 Agora. All rights reserved.
//
#import "EmojiKeyboardView.h"
#import "EMEmojiHelper.h"
#import <Masonry/Masonry.h>
#import "UIImage+ChatExt.h"


@implementation EMEmoticonModel

- (instancetype)initWithType:(EMEmotionType)aType
{
    self = [super init];
    if (self) {
        _type = aType;
    }
    
    return self;
}

@end

@implementation EMEmoticonCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _setupSubviews];
    }
    
    return self;
}

- (void)_setupSubviews
{
    self.backgroundColor = [UIColor clearColor];
    
    self.imgView = [[UIImageView alloc] init];
    self.imgView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.imgView];
    [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.centerY.equalTo(self);
        make.width.height.equalTo(@40);
    }];
    
    self.label = [[UILabel alloc] init];
    self.label.textColor = [UIColor grayColor];
    self.label.font = [UIFont systemFontOfSize:14];
    [self addSubview:self.label];
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(5);
        make.centerX.equalTo(self);
        make.bottom.equalTo(self);
        make.height.greaterThanOrEqualTo(@14);
    }];
}

#pragma mark - Setter

- (void)setModel:(EMEmoticonModel *)model
{
    _model = model;
    
    if (model.type == EMEmotionTypeEmoji) {
        self.label.font = [UIFont fontWithName:@"AppleColorEmoji" size:29.0];
    }
    //self.label.text = model.name;
    
    if ([model.imgName length] > 0) {
        self.imgView.image = [UIImage imageNamedFromBundle:model.imgName];
    }
}

@end

@interface EmojiKeyboardView()<UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic,strong) UICollectionView* collectionView;
@property (nonatomic, strong) NSArray<EMEmoticonModel *> *dataArray;
@property (nonatomic) NSUInteger itemMargin;
@property (nonatomic, strong) UIButton *deleteBtn;
@end

@implementation EmojiKeyboardView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.itemMargin = 8;
        NSDictionary *emojis = [EMEmojiHelper sharedHelper].emojiFilesDic;
        NSMutableArray *models1 = [[NSMutableArray alloc] init];
        for (NSString *emoji in emojis) {
            EMEmoticonModel *model = [[EMEmoticonModel alloc] initWithType:EMEmotionTypeEmoji];
            model.eId = emoji;
            model.imgName = [emojis objectForKey:emoji];
            model.name = emoji;
            model.original = emoji;
            [models1 addObject:model];
        }
        EMEmoticonModel* delModel = [[EMEmoticonModel alloc] initWithType:EMEmotionTypeDel];
        delModel.eId = @"del";
        delModel.imgName = @"deleteEmoticon";
        [models1 addObject:delModel];
        self.dataArray = [models1 copy];
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height - 10) collectionViewLayout:flowLayout];
        self.collectionView.backgroundColor = [UIColor clearColor];
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        self.collectionView.showsVerticalScrollIndicator = NO;
        self.collectionView.showsHorizontalScrollIndicator = NO;
        self.collectionView.alwaysBounceHorizontal = YES;
        self.collectionView.pagingEnabled = YES;
        //    self.collectionView.userInteractionEnabled = YES;
        [self.collectionView registerClass:[EMEmoticonCell class] forCellWithReuseIdentifier:@"EMEmoticonCell"];
        [self addSubview:self.collectionView];

    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.collectionView.frame = self.frame;
}

- (void)deleteAction
{
    if (self.delegate) {
        [self.delegate emojiDidDelete];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.dataArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    EMEmoticonCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"EMEmoticonCell" forIndexPath:indexPath];
    cell.model = self.dataArray[indexPath.row];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    EMEmoticonCell *cell = (EMEmoticonCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (self.delegate) {
        if(cell.model.type == EMEmotionTypeEmoji)
            [self.delegate emojiItemDidClicked:cell.model.name];
        if(cell.model.type == EMEmotionTypeDel)
            [self.delegate emojiDidDelete];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((self.collectionView.bounds.size.width-self.itemMargin)/13-self.itemMargin, 40);
}

// 设置UIcollectionView整体的内边距（这样item不贴边显示）
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    // 上 左 下 右
    return UIEdgeInsetsMake(self.itemMargin, self.itemMargin, self.itemMargin, self.itemMargin);
}

//设置minimumLineSpacing：cell上下之间最小的距离
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return self.itemMargin;
}

// 设置minimumInteritemSpacing：cell左右之间最小的距离
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return self.itemMargin;
}

@end
