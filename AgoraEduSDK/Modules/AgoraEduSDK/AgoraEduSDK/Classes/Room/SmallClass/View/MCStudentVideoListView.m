//
//  MCStudentVideoListView.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/14.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "MCStudentVideoListView.h"
#import "MCStudentVideoCell.h"
#import "NSArray+Copy.h"

@interface MCStudentVideoListView ()<UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic, strong) UICollectionView *videoListView;
@property (nonatomic, strong) NSLayoutConstraint *collectionViewLeftCon;
@property (nonatomic, strong) NSArray<EduStream*> *studentArray;
@end

@implementation MCStudentVideoListView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.itemSize = CGSizeMake(95, 70);
    if(IsPad){
        self.itemSize = CGSizeMake(146, 108);
    }

    [self setUpView];
    self.studentArray = [NSArray array];
}

- (void)setUpView {
    [self addSubview:self.videoListView];
    self.layer.masksToBounds = YES;
    _videoListView.translatesAutoresizingMaskIntoConstraints = NO;
    self.collectionViewLeftCon = [_videoListView.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:0];
      NSLayoutConstraint *rightCon = [_videoListView.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:0];
    NSLayoutConstraint *heightCon = [NSLayoutConstraint constraintWithItem:_videoListView attribute:(NSLayoutAttributeHeight) relatedBy:(NSLayoutRelationEqual) toItem:self attribute:(NSLayoutAttributeHeight) multiplier:1 constant:0];
    NSLayoutConstraint *topCon = [_videoListView.topAnchor constraintEqualToAnchor:self.topAnchor constant:0];
    [NSLayoutConstraint activateConstraints:@[topCon,self.collectionViewLeftCon,rightCon,heightCon]];

}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 1, 0, 1);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 1;
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MCStudentVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"VideoCell" forIndexPath:indexPath];
    
    EduStream *currentModel = self.studentArray[indexPath.row];
    cell.userModel = currentModel;
    if (self.studentVideoList) {
        self.studentVideoList(cell, currentModel);
    }

    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.studentArray.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    return self.itemSize;
}

- (void)updateStudentArray:(NSArray<EduStream*> *)studentArray {

    if(studentArray.count == 0 || self.studentArray.count != studentArray.count) {
        self.studentArray = [studentArray deepCopy];
        [self.videoListView reloadData];
    } else {
        NSMutableArray<NSIndexPath *> *indexPaths = [NSMutableArray array];

        NSInteger count = studentArray.count;
        for(NSInteger i = 0; i < count; i++) {
            EduStream *sourceModel = [self.studentArray objectAtIndex:i];
            EduStream *currentModel = [studentArray objectAtIndex:i];
            if (sourceModel.hasAudio != currentModel.hasAudio ||
               sourceModel.hasVideo != currentModel.hasVideo) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                [indexPaths addObject:indexPath];
                
            } else if ([sourceModel isKindOfClass:StudentVideoStream.class] && [currentModel isKindOfClass:StudentVideoStream.class] && ((StudentVideoStream*)sourceModel).totalReward != ((StudentVideoStream*)currentModel).totalReward) {
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                [indexPaths addObject:indexPath];
            }
        }

        self.studentArray = [studentArray deepCopy];
        if(indexPaths.count > 0){
            [self.videoListView reloadItemsAtIndexPaths:indexPaths];
        }
    }
}

#pragma mark  ----  lazy ------
- (UICollectionView *)videoListView {
    if (!_videoListView) {
        UICollectionViewFlowLayout *listLayout = [[UICollectionViewFlowLayout alloc] init];
        _videoListView = [[UICollectionView alloc] initWithFrame:self.frame collectionViewLayout:listLayout];
        _videoListView.dataSource = self;
        _videoListView.delegate = self;
        listLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        listLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _videoListView.backgroundColor = [UIColor whiteColor];
        [_videoListView registerClass:[MCStudentVideoCell class] forCellWithReuseIdentifier:@"VideoCell"];
    }
    return _videoListView;
}

- (void)dealloc {
    
}
@end
