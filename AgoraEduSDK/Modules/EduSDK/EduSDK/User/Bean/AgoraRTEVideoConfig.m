//
//  AgoraRTEVideoConfig.m
//  EduSDK
//
//  Created by SRS on 2020/7/9.
//  Copyright © 2020 agora. All rights reserved.
//

#import "AgoraRTEVideoConfig.h"

@implementation AgoraRTEVideoConfig
+ (instancetype)defaultVideoConfig {
    AgoraRTEVideoConfig *config = [[AgoraRTEVideoConfig alloc] init];

    config.videoDimensionWidth = 360;
    config.videoDimensionHeight = 360;
    config.frameRate = 15;
    config.bitrate = 0;
    config.orientationMode = AgoraRTEVideoOutputOrientationModeFixedLandscape;
    config.degradationPreference = AgoraRTEDegradationMaintainQuality;
    
    return config;
}
@end
