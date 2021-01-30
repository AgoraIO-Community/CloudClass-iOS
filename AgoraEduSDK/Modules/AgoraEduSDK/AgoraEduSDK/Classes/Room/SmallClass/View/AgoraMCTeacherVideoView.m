//
//  AgoraMCTeacherVideoView.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/15.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "AgoraMCTeacherVideoView.h"


@interface AgoraMCTeacherVideoView ()
@property (strong, nonatomic) IBOutlet UIView *teacherVideoView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *speakerImageView;

@end

@implementation AgoraMCTeacherVideoView

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
