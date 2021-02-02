//
//  AgoraMCStreamInfo.m
//  AgoraEducation
//
//  Created by SRS on 2020/12/3.
//  Copyright © 2020 Agora. All rights reserved.
//

#import "AgoraMCStreamInfo.h"

@implementation AgoraMCStreamInfo
- (instancetype)initWithUserUuid:(NSString *)userUuid userName:(NSString *)userName hasAudio:(BOOL)hasAudio hasVideo:(BOOL)hasVideo streamState:(NSInteger)streamState userState:(NSInteger)userState {
    
    self = [super init];
    if (self) {
        self.userUuid = userUuid;
        self.userName = userName;
        self.hasAudio = hasAudio;
        self.hasVideo = hasVideo;
        self.streamState = streamState;
        self.userState = userState;
    }
    return self;
}

@end
