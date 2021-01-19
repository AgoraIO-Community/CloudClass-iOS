//
//  EduClassroomDelegate.h
//  Demo
//
//  Created by SRS on 2020/6/17.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EduUser.h"
#import "EduStream.h"
#import "EduClassroom.h"
#import "EduTextMessage.h"
#import "EduEnumerates.h"
#import "EduBaseTypes.h"

NS_ASSUME_NONNULL_BEGIN

@protocol EduClassroomDelegate <NSObject>

@optional

// User
- (void)classroom:(EduClassroom *)classroom remoteUsersInit:(NSArray<EduUser*> *)users;
- (void)classroom:(EduClassroom *)classroom remoteUsersJoined:(NSArray<EduUser*> *)users;
- (void)classroom:(EduClassroom *)classroom remoteUsersLeft:(NSArray<EduUserEvent*> *)events leftType:(EduUserLeftType)type;

- (void)classroom:(EduClassroom *)classroom remoteUserStateUpdated:(EduUserEvent *)event changeType:(EduUserStateChangeType)changeType;

// message
- (void)classroom:(EduClassroom *)classroom roomChatMessageReceived:(EduTextMessage *)textMessage;
- (void)classroom:(EduClassroom *)classroom roomMessageReceived:(EduTextMessage *)textMessage;

// stream
- (void)classroom:(EduClassroom *)classroom remoteStreamsInit:(NSArray<EduStream*> *)streams;
- (void)classroom:(EduClassroom *)classroom remoteStreamsAdded:(NSArray<EduStreamEvent*> *)events;
- (void)classroom:(EduClassroom *)classroom remoteStreamsRemoved:(NSArray<EduStreamEvent*> *)events;

- (void)classroom:(EduClassroom *)classroom remoteStreamUpdated:(NSArray<EduStreamEvent*> *)events;

// class room
- (void)classroom:(EduClassroom *)classroom stateUpdated:(EduClassroomChangeType)changeType operatorUser:(EduBaseUser *)user;

- (void)classroom:(EduClassroom *)classroom networkQualityChanged:(NetworkQuality)quality user:(EduBaseUser *)user;

- (void)classroom:(EduClassroom *)classroom connectionStateChanged:(ConnectionState)state;

// property
- (void)classroomPropertyUpdated:(EduClassroom *)classroom cause:(NSDictionary * _Nullable)cause;

@end

NS_ASSUME_NONNULL_END
