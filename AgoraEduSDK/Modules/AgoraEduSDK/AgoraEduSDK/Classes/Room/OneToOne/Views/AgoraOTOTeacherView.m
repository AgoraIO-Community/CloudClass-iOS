
//
//  AgoraOTOTeacherView.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/13.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "AgoraOTOTeacherView.h"


@interface AgoraOTOTeacherView ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *speakerImageView;
@property (strong, nonatomic) IBOutlet UIView *teacherView;
@end

@implementation AgoraOTOTeacherView
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [AgoraEduBundle loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
        [self addSubview:self.teacherView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.teacherView.frame = self.bounds;
    
    [self.defaultImageView setImage:AgoraEduImageWithName(@"icon-teacher")];
    [self.speakerImageView setImage:AgoraEduImageWithName(@"icon-speakeroff-white")];
}

- (void)updateSpeakerEnabled:(BOOL)enable{
     NSString *imageName = !enable ? @"icon-speakeroff-white" : @"icon-speaker-white";
    [self.speakerImageView setImage:AgoraEduImageWithName(imageName)];
}

- (void)updateUserName:(NSString *)name {
    [self.nameLabel setText:name];
}
@end
