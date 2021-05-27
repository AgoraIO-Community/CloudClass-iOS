//
//  ReplayNoVideoViewController.h
//  AgoraEducation
//
//  Created by SRS on 2019/12/17.
//  Copyright © 2019 Agora. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <AgoraReplay/AgoraReplay.h>

@protocol AgoraReplayVCDelegate <NSObject>
@optional
- (void)onReplayDismiss;
@end

NS_ASSUME_NONNULL_BEGIN

@interface AgoraReplayViewController : UIViewController

@property (nonatomic, strong) AgoraReplayConfiguration *config;
@property (nonatomic, copy) NSDictionary *configParams;
@property (nonatomic, weak) id<AgoraReplayVCDelegate> _Nullable replayDelegate;
@end

NS_ASSUME_NONNULL_END

