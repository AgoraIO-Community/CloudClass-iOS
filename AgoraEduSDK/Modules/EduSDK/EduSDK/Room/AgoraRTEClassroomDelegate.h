//
//  AgoraRTEClassroomDelegate.h
//  Demo
//
//  Created by SRS on 2020/6/17.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AgoraRTEUser.h"
#import "AgoraRTEStream.h"
#import "AgoraRTEClassroom.h"
#import "AgoraRTETextMessage.h"
#import "AgoraRTEEnumerates.h"
#import "AgoraRTEBaseTypes.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AgoraRTEClassroomDelegate <NSObject>

@optional

// User
- (void)classroom:(AgoraRTEClassroom *)classroom remoteUsersInit:(NSArray<AgoraRTEUser*> *)users;
- (void)classroom:(AgoraRTEClassroom *)classroom remoteUsersJoined:(NSArray<AgoraRTEUser*> *)users;
- (void)classroom:(AgoraRTEClassroom *)classroom remoteUsersLeft:(NSArray<AgoraRTEUserEvent*> *)events leftType:(AgoraRTEUserLeftType)type;

- (void)classroom:(AgoraRTEClassroom *)classroom remoteUserStateUpdated:(AgoraRTEUserEvent *)event changeType:(AgoraRTEUserStateChangeType)changeType;

// message
- (void)classroom:(AgoraRTEClassroom *)classroom roomChatMessageReceived:(AgoraRTETextMessage *)textMessage;
- (void)classroom:(AgoraRTEClassroom *)classroom roomMessageReceived:(AgoraRTETextMessage *)textMessage;

// stream
- (void)classroom:(AgoraRTEClassroom *)classroom remoteStreamsInit:(NSArray<AgoraRTEStream*> *)streams;
- (void)classroom:(AgoraRTEClassroom *)classroom remoteStreamsAdded:(NSArray<AgoraRTEStreamEvent*> *)events;
- (void)classroom:(AgoraRTEClassroom *)classroom remoteStreamsRemoved:(NSArray<AgoraRTEStreamEvent*> *)events;

- (void)classroom:(AgoraRTEClassroom *)classroom remoteStreamUpdated:(NSArray<AgoraRTEStreamEvent*> *)events;

// class room
- (void)classroom:(AgoraRTEClassroom *)classroom stateUpdated:(AgoraRTEClassroomChangeType)changeType operatorUser:(AgoraRTEBaseUser *)user;

- (void)classroom:(AgoraRTEClassroom *)classroom networkQualityChanged:(AgoraRTENetworkQuality)quality user:(AgoraRTEBaseUser *)user;

- (void)classroom:(AgoraRTEClassroom *)classroom connectionStateChanged:(AgoraRTEConnectionState)state;

// rtc
- (void)classroom:(AgoraRTEClassroom *)classroom remoteRTCJoinedOfStreamId:(NSString *)streamId;
- (void)classroom:(AgoraRTEClassroom *)classroom remoteRTCOfflineOfStreamId:(NSString *)streamId;

// property
- (void)classroomPropertyUpdated:(AgoraRTEClassroom *)classroom cause:(NSDictionary * _Nullable)cause;
- (void)classroom:(AgoraRTEClassroom *)classroom remoteUserPropertyUpdated:(AgoraRTEUser *)user cause:(NSDictionary * _Nullable)cause;
@end

NS_ASSUME_NONNULL_END
