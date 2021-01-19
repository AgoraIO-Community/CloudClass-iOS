//
//  WhiteBoardPageControlView.m
//  AgoraWhiteBoard
//
//  Created by SRS on 2020/7/14.
//  Copyright © 2020 agora. All rights reserved.
//

#import "WhiteBoardPageControlView.h"
#import "WhiteBoardUtil.h"

@interface WhiteBoardPageControlView()

//@property (strong, nonatomic) IBOutlet UIView *pageControlView;
@property (weak, nonatomic) IBOutlet UILabel *pageCountLabel;
@property (nonatomic, assign) NSInteger sceneIndex;
@property (nonatomic, assign) NSInteger sceneCount;

@end

@implementation WhiteBoardPageControlView
- (void)awakeFromNib {
    
    [super awakeFromNib];
    self.layer.borderWidth = 1.f;

    self.layer.borderColor = ColorWithHex(0xDBE2E5, 1).CGColor;
    self.layer.shadowColor = ColorWithHex(0x000000, 1).CGColor;
    self.layer.shadowOffset = CGSizeMake(0.f, 2.f);
    self.layer.shadowOpacity = 2.f;
    self.layer.shadowRadius = 4.f;
    self.layer.borderWidth = 1.f;
    self.layer.cornerRadius = 6.f;
    self.layer.masksToBounds = YES;
}

- (IBAction)buttonClick:(UIButton *)sender {
    if ([sender.restorationIdentifier isEqualToString:@"previousPage"]) {
        [self previousPage];
    } else if ([sender.restorationIdentifier isEqualToString:@"firstPage"]) {
        [self firstPage];
    } else if ([sender.restorationIdentifier isEqualToString:@"nextPage"]) {
        [self nextPage];
    } else if ([sender.restorationIdentifier isEqualToString:@"lastPage"]) {
        [self lastPage];
    }
}

#pragma mark EEPageControlDelegate
- (void)previousPage {
    if (self.sceneIndex > 0) {
        self.sceneIndex--;
        WEAK(self);
        [self setWhiteSceneIndex:self.sceneIndex completionSuccessBlock:^{
            [weakself.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%ld", (long)(weakself.sceneIndex + 1), (long)weakself.sceneCount]];
        }];
    }
}

- (void)nextPage {
    if (self.sceneIndex < self.sceneCount - 1  && self.sceneCount > 0) {
        self.sceneIndex ++;
        
        WEAK(self);
        [self setWhiteSceneIndex:self.sceneIndex completionSuccessBlock:^{
            [weakself.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%ld", (long)(weakself.sceneIndex + 1), (long)weakself.sceneCount]];
        }];
    }
}

- (void)lastPage {
    self.sceneIndex = self.sceneCount - 1;
    
    WEAK(self);
    [self setWhiteSceneIndex:self.sceneIndex completionSuccessBlock:^{
        [weakself.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%ld", (long)(weakself.sceneIndex + 1), (long)weakself.sceneCount]];
    }];
}

- (void)firstPage {
    self.sceneIndex = 0;
    WEAK(self);
    [self setWhiteSceneIndex:self.sceneIndex completionSuccessBlock:^{
        [weakself.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%ld", (long)(weakself.sceneIndex + 1), (long)weakself.sceneCount]];
    }];
}

-(void)setWhiteSceneIndex:(NSInteger)sceneIndex completionSuccessBlock:(void (^ _Nullable)(void ))successBlock {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectPageIndex:completeBlock:)]) {
        [self.delegate selectPageIndex:sceneIndex completeBlock:^(BOOL isSuccess, NSError * _Nonnull error) {
            if(isSuccess && successBlock) {
                successBlock();
            }
        }];
    }
}


- (void)setPageIndex:(NSInteger)sceneIndex pageCount:(NSInteger)sceneCount {
    self.sceneIndex = sceneIndex;
    self.sceneCount = sceneCount;
    [self.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%ld", (long)(sceneIndex + 1), (long)sceneCount]];
}

@end
