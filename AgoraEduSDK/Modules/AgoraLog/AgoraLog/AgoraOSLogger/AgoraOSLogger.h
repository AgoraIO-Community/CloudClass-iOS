//
//  AgoraOSLogger.h
//  AgoraLog
//
//  Created by SRS on 2020/10/25.
//  Copyright © 2020 agora. All rights reserved.
//

#import <CocoaLumberjack/CocoaLumberjack.h>

NS_ASSUME_NONNULL_BEGIN

@interface AgoraOSLogger : DDOSLogger
@property (nonatomic, assign) NSInteger consoleState;
@property (nonatomic, assign) NSInteger content;
@end

NS_ASSUME_NONNULL_END
