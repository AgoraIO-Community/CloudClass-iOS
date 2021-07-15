//
//  AgoraRTEObjects.h
//  AgoraEduSDK
//
//  Created by SRS on 2021/6/1.
//

#import <Foundation/Foundation.h>
#import "AgoraRTEEnumerates.h"

NS_ASSUME_NONNULL_BEGIN

@interface AgoraRTERenderConfig : NSObject
@property (nonatomic, assign) AgoraRTERenderMode renderMode;
@end

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
