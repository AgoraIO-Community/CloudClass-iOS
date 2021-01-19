//
//  MCTeacherVideoView.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/15.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "MCTeacherVideoView.h"


@interface MCTeacherVideoView ()
@property (strong, nonatomic) IBOutlet UIView *teacherVideoView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *speakerImageView;

@end

@implementation MCTeacherVideoView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [AgoraEduBundle loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
        [self addSubview:self.teacherVideoView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.teacherVideoView.frame = self.bounds;
    
    [self.defaultImageView setImage:AgoraEduImageWithName(@"icon-teacher")];
    [self.speakerImageView setImage:AgoraEduImageWithName(@"icon-speakeroff-white")];
}

- (void)updateUserName:(NSString *)userName {
    [self.nameLabel setText:userName];
}

- (void)updateSpeakerImageName:(NSString *)name {
    [self.speakerImageView setImage:AgoraEduImageWithName(name)];
}

@end
