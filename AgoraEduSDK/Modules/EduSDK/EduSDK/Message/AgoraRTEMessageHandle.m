//
//  AgoraRTEMessageHandle.m
//  EduSDK
//
//  Created by SRS on 2020/7/22.
//  Copyright © 2020 agora. All rights reserved.
//

#import "AgoraRTEMessageHandle.h"
#import "AgoraRTELogService.h"

@implementation AgoraRTEMessageHandle

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
    NSString *classStr = NSStringFromClass(self.class);
    [AgoraRTELogService logMessageWithDescribe:@"AgoraRTEMessageHandle dealloc:" message:@{@"ClassType":classStr, @"roomUuid":self.roomUuid == nil ? @"nil" : self.roomUuid}];
}

@end
