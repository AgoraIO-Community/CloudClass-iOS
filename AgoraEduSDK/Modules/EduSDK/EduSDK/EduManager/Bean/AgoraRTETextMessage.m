//
//  AgoraRTETextMessage.m
//  Demo
//
//  Created by SRS on 2020/6/19.
//  Copyright © 2020 agora. All rights reserved.
//

#import "AgoraRTETextMessage.h"

@interface AgoraRTETextMessage()
@property (nonatomic, strong) AgoraRTEUser *fromUser;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, assign) NSInteger timestamp;
@end

@implementation AgoraRTETextMessage

//- (void)setMessage:(NSString * _Nonnull)message {
//    _message = message;
//}
//- (void)setFromUser:(AgoraRTEUser * _Nonnull)fromUser {
//    _fromUser = fromUser;
//}
//- (void)setTimestamp:(NSInteger)timestamp {
//    _timestamp = timestamp;
//}
@end
