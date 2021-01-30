//
//  AgoraRTEStudentService.m
//  Demo
//
//  Created by SRS on 2020/6/19.
//  Copyright © 2020 agora. All rights reserved.
//

#import "AgoraRTEStudentService.h"
#import "AgoraRTEConstants.h"
#import "AgoraRTEMessageHandle.h"
#import "AgoraRTEStream+ConvenientInit.h"
#import "AgoraRTEChannelMessageHandle.h"

@interface AgoraRTEStudentService ()
@property (nonatomic, strong) AgoraRTEChannelMessageHandle *messageHandle;
@end

@implementation AgoraRTEStudentService

- (void)setDelegate:(id<AgoraRTEStudentDelegate>)delegate {
    _delegate = delegate;
    self.messageHandle.userDelegate = delegate;
}

@end
