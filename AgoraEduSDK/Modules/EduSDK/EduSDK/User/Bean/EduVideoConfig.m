//
//  EduVideoConfig.m
//  EduSDK
//
//  Created by SRS on 2020/7/9.
//  Copyright © 2020 agora. All rights reserved.
//

#import "EduVideoConfig.h"

@implementation EduVideoConfig
+ (instancetype)defaultVideoConfig {
    EduVideoConfig *config = [[EduVideoConfig alloc] init];

    config.videoDimensionWidth = 360;
    config.videoDimensionHeight = 360;
    config.frameRate = 15;
    config.bitrate = 0;
    config.orientationMode = EduVideoOutputOrientationModeFixedLandscape;
    config.degradationPreference = EduDegradationMaintainQuality;
    
    return config;
}
@end
