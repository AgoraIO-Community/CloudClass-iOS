//
//  StudentVideoViewCell.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/8/13.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "AgoraMCStudentVideoCell.h"
#import "AgoraFLAnimatedImage.h"

#define FUN_REWORD

@implementation StudentVideoStream
@end

@interface AgoraMCStudentVideoCell ()
@property (nonatomic, weak) UIImageView *backImageView;
@property (nonatomic, weak) UILabel *nameLable;
@property (nonatomic, weak) UILabel *rewardLabel;
@property (nonatomic, weak) UIImageView *starImageView;
@property (nonatomic, weak) UIImageView *volumeImageView;
@property (nonatomic, strong) AgoraFLAnimatedImageView *imageView;
@end

@implementation AgoraMCStudentVideoCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpView];
#ifdef FUN_REWORD
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(showRewardEffect:) name:Agora_Notice_Reward_Effect object:nil];
#endif
    }
    return self;
}

- (void)showRewardEffect:(NSNotification*)notification {
    
    NSString *userUuid = [notification object];
    if(![userUuid isKindOfClass:NSString.class]) {
        return;
    }
    
    if (self.userModel && [self.userModel.userInfo.userUuid isEqualToString:userUuid]) {
        self.imageView.hidden = NO;
    }
}

- (void)setUserModel:(AgoraRTEStream *)userModel {
    _userModel = userModel;
    self.nameLable.text = userModel.userInfo.userName;
    self.backImageView.hidden = userModel.hasVideo ? YES : NO;
    NSString *audioImageName = userModel.hasAudio ? @"icon-speaker-white" : @"icon-speakeroff-white";
    [self.volumeImageView setImage:AgoraEduImageWithName(audioImageName)];
    
    self.rewardLabel.hidden = YES;
    self.starImageView.hidden = YES;
    
#ifdef FUN_REWORD
    if([userModel isKindOfClass:StudentVideoStream.class]) {

        self.rewardLabel.hidden = NO;
        self.starImageView.hidden = NO;
        
        CGSize contentSize = self.contentView.bounds.size;
        
        NSInteger num = ((StudentVideoStream*)userModel).totalReward;
        self.rewardLabel.text = [NSString stringWithFormat:@"%ld", (long)num];
        [self.rewardLabel sizeToFit];
        CGSize rewardSize = self.rewardLabel.frame.size;
        self.rewardLabel.frame = CGRectMake(contentSize.width - rewardSize.width - 5, contentSize.height - 20, rewardSize.width, 20);
        
        self.starImageView.frame = CGRectMake(contentSize.width - rewardSize.width - 18, contentSize.height - 17, 14, 14);
        
        CGFloat nameMaxWidth = self.starImageView.frame.origin.x - 30;
        [self.nameLable sizeToFit];
        CGSize nameSize = self.nameLable.frame.size;
        if (nameSize.width > nameMaxWidth) {
            self.nameLable.frame = CGRectMake(5, contentSize.height - 20, nameMaxWidth, 20);
        } else {
            self.nameLable.frame = CGRectMake(5, contentSize.height - 20, nameSize.width, 20);
        }
        self.volumeImageView.frame = CGRectMake(self.nameLable.frame.size.width + self.nameLable.frame.origin.x + 3, contentSize.height - 17, 14, 14);
    }
#endif
}

- (void)setUpView {
    UIView *videoCanvasView = [[UIView alloc] init];
    videoCanvasView.frame = self.contentView.bounds;
    [self.contentView addSubview:videoCanvasView];
    self.videoCanvasView = videoCanvasView;

    UIImageView *backImageView = [[UIImageView alloc] init];
    backImageView.frame = self.contentView.bounds;
    [self.contentView addSubview:backImageView];
    backImageView.image = AgoraEduImageWithName(@"icon-student");
    backImageView.contentMode = UIViewContentModeScaleAspectFit;
    backImageView.backgroundColor = [UIColor colorWithHexString:@"DBE2E5"];
    self.backImageView = backImageView;

    UIView *labelView = [[UIView alloc] initWithFrame:CGRectMake(0, self.contentView.bounds.size.height - 20, self.contentView.bounds.size.width, 20)];
    
    labelView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    [self.contentView addSubview:labelView];
    
    {
        UILabel *label = [self getRewardLabel];
        label.hidden = YES;
        [self.contentView addSubview:label];
        self.rewardLabel = label;
    }
    
    {
        UIImageView *imgView = [self getStarImageView];
        imgView.hidden = YES;
        [self.contentView addSubview:imgView];
        self.starImageView = imgView;
    }
    
    {
        UILabel *label = [self getNameLabel];
        [self.contentView addSubview:label];
        self.nameLable = label;
    }

    UIImageView *volumeImageView = [[UIImageView alloc] init];
    volumeImageView.frame = CGRectMake(self.contentView.bounds.size.width - 20, self.contentView.bounds.size.height - 20, 20, 20);
    [self.contentView addSubview:volumeImageView];
    [volumeImageView setImage:AgoraEduImageWithName(@"icon-speaker-white")];
    self.volumeImageView = volumeImageView;
    
    // show effect
    NSURL *url = [AgoraEduBundle URLForResource:@"reward_stars_effect" withExtension:@"gif"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    AgoraFLAnimatedImage *animatedImage = [AgoraFLAnimatedImage animatedImageWithGIFData:data];
    
    self.imageView = [[AgoraFLAnimatedImageView alloc] init];
    self.imageView.animatedImage = animatedImage;
    WEAK(self);
    self.imageView.loopCompletionBlock = ^(NSUInteger loopCountRemaining) {
        weakself.imageView.hidden = YES;
    };
    self.imageView.frame = self.contentView.bounds;
    [self.contentView addSubview:self.imageView];
    self.imageView.hidden = YES;
}

- (UILabel *)getNameLabel {
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.frame = CGRectMake(5, self.contentView.bounds.size.height - 20, self.contentView.bounds.size.width - 30, 20);
    
    nameLabel.backgroundColor = UIColor.clearColor;
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.font = [UIFont systemFontOfSize:10.f];
    return nameLabel;
}
- (UIImageView *)getMicImageView {
    UIImageView *imgView = [[UIImageView alloc] initWithImage:AgoraEduImageWithName(@"reward_star_gray")];
    imgView.frame = CGRectMake(0, 3, 14, 14);
    return imgView;
}
- (UILabel *)getRewardLabel {
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(5, self.contentView.bounds.size.height - 20, self.contentView.bounds.size.width - 30, 20);
    label.backgroundColor = UIColor.clearColor;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:10.f];
    return label;
}
- (UIImageView *)getStarImageView {
    UIImageView *imgView = [[UIImageView alloc] initWithImage:AgoraEduImageWithName(@"reward_star_gray")];
    imgView.frame = CGRectMake(0, 3, 14, 14);
    return imgView;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}
@end
