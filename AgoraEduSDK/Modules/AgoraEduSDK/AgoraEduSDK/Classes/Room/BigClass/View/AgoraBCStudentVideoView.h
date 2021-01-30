//
//  EEStudentVideoView.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/10/25.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AgoraRoomProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface AgoraBCStudentVideoView : UIView
@property (weak, nonatomic) id<AgoraRoomProtocol> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *defaultImageView;
@property (weak, nonatomic) IBOutlet UIView *studentRenderView;

@property (assign, nonatomic) BOOL hasVideo;
@property (assign, nonatomic) BOOL hasAudio;

- (void)setButtonEnabled:(BOOL)enabled;
- (void)updateVideoImageWithMuted:(BOOL)muted;
- (void)updateAudioImageWithMuted:(BOOL)muted;

@end

NS_ASSUME_NONNULL_END
