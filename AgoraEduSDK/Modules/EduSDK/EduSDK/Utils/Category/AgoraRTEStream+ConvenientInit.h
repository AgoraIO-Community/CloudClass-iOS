//
//  AgoraRTEStream+ConvenientInit.h
//  EduSDK
//
//  Created by SRS on 2020/7/21.
//  Copyright © 2020 agora. All rights reserved.
//

#import "AgoraRTEStream.h"

NS_ASSUME_NONNULL_BEGIN

@interface AgoraRTEStream (ConvenientInit)
- (instancetype)initWithStreamUuid:(NSString *)streamUuid streamName:(NSString *)streamName sourceType:(AgoraRTEVideoSourceType)sourceType hasVideo:(BOOL)hasVideo hasAudio:(BOOL)hasAudio user:(AgoraRTEBaseUser *)userInfo;

- (void)updateWithStream:(NSString *)streamUuid streamName:(NSString *)streamName sourceType:(AgoraRTEVideoSourceType)sourceType hasVideo:(BOOL)hasVideo hasAudio:(BOOL)hasAudio user:(AgoraRTEBaseUser *)userInfo;

- (void)updateWithStream:(AgoraRTEStream *)stream;

@end

@interface AgoraRTEStreamEvent (ConvenientInit)
- (instancetype)initWithModifiedStream:(AgoraRTEStream *)modifiedStream operatorUser:(AgoraRTEBaseUser * _Nullable)operatorUser;
@end

NS_ASSUME_NONNULL_END
