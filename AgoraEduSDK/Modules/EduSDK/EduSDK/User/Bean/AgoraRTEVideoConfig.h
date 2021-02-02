//
//  AgoraRTEVideoConfig.h
//  EduSDK
//
//  Created by SRS on 2020/7/9.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AgoraRTEEnumerates.h"

NS_ASSUME_NONNULL_BEGIN

@interface AgoraRTEVideoConfig : NSObject

@property (nonatomic, assign) NSUInteger videoDimensionWidth;
@property (nonatomic, assign) NSUInteger videoDimensionHeight;
@property (nonatomic, assign) NSUInteger frameRate;
@property (nonatomic, assign) NSUInteger bitrate;
@property (nonatomic, assign) AgoraRTEVideoOutputOrientationMode orientationMode;
@property (nonatomic, assign) AgoraRTEDegradationPreference degradationPreference;

+ (instancetype)defaultVideoConfig;

@end

NS_ASSUME_NONNULL_END
