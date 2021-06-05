//
//  AgoraRTEUserDelegate.h
//  EduSDK
//
//  Created by SRS on 2020/7/9.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AgoraRTEUser.h"
#import "AgoraRTEStream.h"
#import "AgoraRTEBaseTypes.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AgoraRTEMediaStreamDelegate <NSObject>
@optional
- (void)localVideoStream:(NSString *)streamId rendererOutputFrameRate:(NSInteger)rate;
- (void)remoteVideoStream:(NSString *)streamId rendererOutputFrameRate:(NSInteger)rate;

- (void)didChangeOfLocalAudioStream:(NSString *)streamId
        withState:(AgoraRTEStreamState)state;

- (void)didChangeOfLocalVideoStream:(NSString *)streamId
        withState:(AgoraRTEStreamState)state;

- (void)audioVolumeIndicationOfLocalStream:(NSString *)streamId
                                withVolume:(NSUInteger)volume;

- (void)didChangeOfRemoteAudioStream:(NSString *)streamId
        withState:(AgoraRTEStreamState)state;

- (void)didChangeOfRemoteVideoStream:(NSString *)streamId
        withState:(AgoraRTEStreamState)state;

- (void)audioVolumeIndicationOfRemoteStream:(NSString *)streamId
                                withVolume:(NSUInteger)volume;
@end

@protocol AgoraRTEUserDelegate <NSObject>
@optional
// user
- (void)localUserLeft:(AgoraRTEUserEvent*)event leftType:(AgoraRTEUserLeftType)type;
// stream
- (void)localStreamAdded:(AgoraRTEStreamEvent*)event;
- (void)localStreamRemoved:(AgoraRTEStreamEvent*)event;
- (void)localStreamUpdated:(AgoraRTEStreamEvent*)event;
// state
- (void)localUserStateUpdated:(AgoraRTEUserEvent*)event changeType:(AgoraRTEUserStateChangeType)changeType;
// property
- (void)localUserPropertyUpdated:(NSDictionary *)changedProperties
                            user:(AgoraRTEUser *)user
                           cause:(NSDictionary * _Nullable)cause
                    operatorUser:(AgoraRTEBaseUser *)operatorUser;

@end

@protocol AgoraRTEStudentDelegate <AgoraRTEUserDelegate>
@end

@protocol AgoraRTETeacherDelegate <AgoraRTEUserDelegate>
@end

@protocol AgoraRTEAssistantDelegate <AgoraRTEUserDelegate>
@end

NS_ASSUME_NONNULL_END
