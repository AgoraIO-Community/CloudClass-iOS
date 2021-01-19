//
//  EduUserDelegate.h
//  EduSDK
//
//  Created by SRS on 2020/7/9.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EduUser.h"
#import "EduStream.h"
#import "EduBaseTypes.h"

NS_ASSUME_NONNULL_BEGIN

@protocol EduMediaStreamDelegate <NSObject>
@optional
- (void)didChangeOfLocalAudioStream:(NSString *)streamId
        withState:(EduStreamState)state;

- (void)didChangeOfLocalVideoStream:(NSString *)streamId
        withState:(EduStreamState)state;

- (void)didChangeOfRemoteAudioStream:(NSString *)streamId
        withState:(EduStreamState)state;

- (void)didChangeOfRemoteVideoStream:(NSString *)streamId
        withState:(EduStreamState)state;
@end

@protocol EduUserDelegate <NSObject>
@optional
// user
- (void)localUserLeft:(EduUserEvent*)event leftType:(EduUserLeftType)type;
// stream
- (void)localStreamAdded:(EduStreamEvent*)event;
- (void)localStreamRemoved:(EduStreamEvent*)event;
- (void)localStreamUpdated:(EduStreamEvent*)event;
// state
- (void)localUserStateUpdated:(EduUserEvent*)event changeType:(EduUserStateChangeType)changeType;
@end

@protocol EduStudentDelegate <EduUserDelegate>
@end

@protocol EduTeacherDelegate <EduUserDelegate>
@end

@protocol EduAssistantDelegate <EduUserDelegate>
@end

NS_ASSUME_NONNULL_END
