//
//  EduStream+ConvenientInit.m
//  EduSDK
//
//  Created by SRS on 2020/7/21.
//  Copyright © 2020 agora. All rights reserved.
//

#import "EduStream+ConvenientInit.h"
@implementation EduStream (ConvenientInit)

- (instancetype)initWithStreamUuid:(NSString *)streamUuid streamName:(NSString *)streamName sourceType:(EduVideoSourceType)sourceType hasVideo:(BOOL)hasVideo hasAudio:(BOOL)hasAudio user:(EduBaseUser *)userInfo {
    self = [super init];
    if (self) {
        [self updateWithStream:streamUuid streamName:streamName sourceType:sourceType hasVideo:hasVideo hasAudio:hasAudio user:userInfo];
    }
    return self;
}

- (void)updateWithStream:(NSString *)streamUuid streamName:(NSString *)streamName sourceType:(EduVideoSourceType)sourceType hasVideo:(BOOL)hasVideo hasAudio:(BOOL)hasAudio user:(EduBaseUser *)userInfo {
    if (streamUuid) {
        [self setValue:streamUuid forKey:@"streamUuid"];
    }
    if (streamName) {
        [self setValue:streamName forKey:@"streamName"];
    }
    [self setValue:@(sourceType) forKey:@"sourceType"];
    [self setValue:@(hasVideo) forKey:@"hasVideo"];
    [self setValue:@(hasAudio) forKey:@"hasAudio"];
    [self setValue:userInfo forKey:@"userInfo"];
}

- (void)updateWithStream:(EduStream *)stream {
    [self updateWithStream:stream.streamUuid streamName:stream.streamName sourceType:stream.sourceType hasVideo:stream.hasVideo hasAudio:stream.hasAudio user:stream.userInfo];
}

@end

@implementation EduStreamEvent (ConvenientInit)
- (instancetype)initWithModifiedStream:(EduStream *)modifiedStream operatorUser:(EduBaseUser * _Nullable)operatorUser {
    
    self = [super init];
    if (self) {
        [self setValue:modifiedStream forKey:@"modifiedStream"];
        if (operatorUser) {
            [self setValue:operatorUser forKey:@"operatorUser"];
        }
    }
    return self;
}
@end
