//
//  AgoraLogFormatter.m
//  AgoraLog
//
//  Created by SRS on 2021/1/9.
//

#import "AgoraLogFormatter.h"

@interface AgoraLogFormatter ()
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@end

@implementation AgoraLogFormatter
- (instancetype)init {
    if (self = [super init]) {
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setDateFormat:@"HH:mm:ss.SSS"];
    }
    return self;
}

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage {
    NSString *mesaage = [super formatLogMessage:logMessage];
    
    if (mesaage) {
        NSString *logLevel;
        switch (logMessage->_flag) {
            case DDLogFlagError    : logLevel = @"ERROR";   break;
            case DDLogFlagWarning  : logLevel = @"WARNING"; break;
            case DDLogFlagInfo     : logLevel = @"INFO";    break;
            case DDLogFlagDebug    : logLevel = @"DEBUG";   break;
            default                : logLevel = @"V";       break;
        }
        
        NSDate *date = logMessage->_timestamp;
        NSString *dateString = [self.dateFormatter stringFromDate:date];
        return [NSString stringWithFormat:@"%@ %@ | %@", dateString, logLevel, logMessage->_message];
    } else {
        return nil;
    }
}
@end
