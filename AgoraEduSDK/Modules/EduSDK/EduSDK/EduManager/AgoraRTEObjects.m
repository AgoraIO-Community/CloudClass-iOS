//
//  AgoraRTEObjects.m
//  AgoraEduSDK
//
//  Created by SRS on 2021/6/1.
//

#import "AgoraRTEObjects.h"

@implementation AgoraRTERenderConfig
@end

@implementation AgoraRTEVideoConfig
+ (instancetype)defaultVideoConfig {
    AgoraRTEVideoConfig *config = [[AgoraRTEVideoConfig alloc] init];

    config.videoDimensionWidth = 320;
    config.videoDimensionHeight = 240;
    config.frameRate = 15;
    config.bitrate = 200;
    config.orientationMode = AgoraRTEVideoOutputOrientationModeFixedLandscape;
    config.degradationPreference = AgoraRTEDegradationMaintainQuality;
    
    return config;
}
@end
