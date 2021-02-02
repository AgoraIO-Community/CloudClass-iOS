//
//  AgoraRTEManagerDelegate.h
//  EduSDK
//
//  Created by SRS on 2020/8/28.
//

#import <Foundation/Foundation.h>
#import "AgoraRTEClassroom.h"
#import "AgoraRTETextMessage.h"
#import "AgoraRTEActionMessage.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AgoraRTEManagerDelegate <NSObject>

@optional
// chat
- (void)userChatMessageReceived:(AgoraRTETextMessage*)textMessage;

// message
- (void)userMessageReceived:(AgoraRTETextMessage*)textMessage;

@end

NS_ASSUME_NONNULL_END
