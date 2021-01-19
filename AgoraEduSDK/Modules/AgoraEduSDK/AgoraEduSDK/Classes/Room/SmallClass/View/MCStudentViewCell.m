//
//  MCStudentViewCell.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/15.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "MCStudentViewCell.h"

@interface MCStudentViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *micButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLeftCon;

@end

@implementation MCStudentViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization cod
    self.muteVideoButton.selected = YES;
    self.muteAudioButton.selected = YES;
    self.muteWhiteButton.selected = NO;
    
    [self.muteAudioButton addTarget:self action:@selector(muteAudio:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.muteVideoButton addTarget:self action:@selector(muteVideo:) forControlEvents:(UIControlEventTouchUpInside)];
    
    [self.muteVideoButton setImage:AgoraEduImageWithName(@"roomCameraOff") forState:(UIControlStateNormal)];
    [self.muteAudioButton setImage:AgoraEduImageWithName(@"icon-speaker") forState:(UIControlStateNormal)];
    [self.muteWhiteButton setImage:AgoraEduImageWithName(@"icon-white-disconnect") forState:(UIControlStateNormal)];
    [self.muteWhiteButton setImage:AgoraEduImageWithName(@"icon-white-connect") forState:(UIControlStateSelected)];
}

- (void)muteAudio:(UIButton *)sender {
    
    if (self.stream.streamState == 1 && [self.stream.userUuid isEqualToString:self.userUuid]) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(muteAudioStream:)]) {
            [self.delegate muteAudioStream:sender.selected];
        }
        
        sender.selected = !sender.selected;
    }
}

- (void)muteVideo:(UIButton *)sender {
    
    if (self.stream.streamState == 1 && [self.stream.userUuid isEqualToString:self.userUuid]) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(muteVideoStream:)]) {
            [self.delegate muteVideoStream:sender.selected];
        }
        
        sender.selected = !sender.selected;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)updateEnableButtons:(NSString *)userUuid {
    self.muteVideoButton.userInteractionEnabled = NO;
    self.muteAudioButton.userInteractionEnabled = NO;
    self.muteWhiteButton.userInteractionEnabled = NO;
    if ([userUuid isEqualToString:self.userUuid]) {
        self.muteVideoButton.userInteractionEnabled = YES;
        self.muteAudioButton.userInteractionEnabled = YES;
        self.muteWhiteButton.userInteractionEnabled = YES;
    }
}

- (void)setStream:(MCStreamInfo *)stream {
    _stream = stream;
    
    self.nameLeftCon.constant = 10;

    NSString *string = stream.userName;
    if (stream.userState == 0) {
        string = [string stringByAppendingString:AgoraEduLocalizedString(@"OffLineText", nil)];
        [self.nameLabel setText:string];
        self.nameLeftCon.constant = -20;
    } else {
        [self.nameLabel setText:string];
    }
    
    NSString *offVideoImageName;
    NSString *onVideoImageName;
    // self covideo
    if (stream.streamState == 1 && [stream.userUuid isEqualToString:self.userUuid]) {
        onVideoImageName = @"icon-video-blue";
        offVideoImageName = @"icon-videooff-blue";
    } else {
        onVideoImageName = @"roomCameraOn";
        offVideoImageName = @"roomCameraOff";
    }
    
    [self.muteVideoButton setImage:AgoraEduImageWithName(offVideoImageName) forState:(UIControlStateNormal)];
    [self.muteVideoButton setImage:AgoraEduImageWithName(onVideoImageName) forState:(UIControlStateSelected)];
    self.muteVideoButton.selected = stream.hasVideo ? YES : NO;
    
    NSString *onAudioImageName;
    NSString *offAudioImageName;
    // self covideo
    if (stream.streamState == 1 && [stream.userUuid isEqualToString:self.userUuid]) {
        
        onAudioImageName = @"icon-speaker-blue";
        offAudioImageName = @"icon-speakeroff-blue";
        
    } else {
        onAudioImageName = @"icon-speaker";
        offAudioImageName = @"icon-speaker-off";
    }
    
    [self.muteAudioButton setImage:AgoraEduImageWithName(offAudioImageName) forState:(UIControlStateNormal)];
    [self.muteAudioButton setImage:AgoraEduImageWithName(onAudioImageName) forState:(UIControlStateSelected)];
    self.muteAudioButton.selected = stream.hasAudio ? YES : NO;
}

@end
