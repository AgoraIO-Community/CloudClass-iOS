//
//  ReplayVideoView.m
//  AFNetworking
//
//  Created by SRS on 2020/8/12.
//

#import "ReplayVideoView.h"
#import <AVFoundation/AVFoundation.h>


@implementation ReplayVideoView

+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

- (void)setAVPlayer:(AVPlayer *)player;
{
    AVPlayerLayer *avplayerLayer = (AVPlayerLayer *)self.layer;
    dispatch_async(dispatch_get_main_queue(), ^{
        [avplayerLayer setPlayer:player];
        [avplayerLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    });
}

@end
