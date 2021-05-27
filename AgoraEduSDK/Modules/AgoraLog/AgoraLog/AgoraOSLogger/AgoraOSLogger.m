//
//  AgoraOSLogger.m
//  AgoraLog
//
//  Created by SRS on 2020/10/25.
//  Copyright © 2020 agora. All rights reserved.
//

#import "AgoraOSLogger.h"

@implementation AgoraOSLogger
- (void)logMessage:(DDLogMessage *)logMessage {
    if (self.consoleState == 0 || self.content != logMessage.context) {
        return;
    }
    [super logMessage:logMessage];
}
@end
