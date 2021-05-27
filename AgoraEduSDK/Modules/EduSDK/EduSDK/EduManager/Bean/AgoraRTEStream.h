//
//  AgoraRTEStream.h
//  Demo
//
//  Created by SRS on 2020/6/17.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AgoraRTEEnumerates.h"

@class AgoraRTEBaseUser;

NS_ASSUME_NONNULL_BEGIN

@interface AgoraRTEStream : NSObject
@property (nonatomic, strong, readonly) NSString *streamUuid;
@property (nonatomic, strong) NSString *streamName;
@property (nonatomic, assign) AgoraRTEVideoSourceType sourceType;
@property (nonatomic, assign) BOOL hasVideo;
@property (nonatomic, assign) BOOL hasAudio;

@property (nonatomic, strong, readonly) AgoraRTEBaseUser *userInfo;

- (instancetype)initWithStreamUuid:(NSString *)streamUuid userInfo:(AgoraRTEBaseUser *)userInfo;
@end


@interface AgoraRTEStreamEvent : NSObject
@property (nonatomic, strong, readonly) AgoraRTEStream *modifiedStream;
@property (nonatomic, strong, readonly) AgoraRTEBaseUser * _Nullable operatorUser;
@end

NS_ASSUME_NONNULL_END
