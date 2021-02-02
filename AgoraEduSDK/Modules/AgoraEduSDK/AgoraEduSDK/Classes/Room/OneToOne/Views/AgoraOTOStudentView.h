//
//  AgoraOTOStudentView.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/13.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AgoraRoomProtocol.h"


NS_ASSUME_NONNULL_BEGIN

@interface AgoraOTOStudentView : UIView
@property (nonatomic, weak) id <AgoraRoomProtocol> delegate;
@property (weak, nonatomic) IBOutlet UIView *videoRenderView;
@property (weak, nonatomic) IBOutlet UIImageView *defaultImageView;

- (void)updateUserName:(NSString *)name;
- (void)updateVideoImageWithMuted:(BOOL)muted;
- (void)updateAudioImageWithMuted:(BOOL)muted;

- (BOOL)hasVideo;
- (BOOL)hasAudio;

@end

NS_ASSUME_NONNULL_END
