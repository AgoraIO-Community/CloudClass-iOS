//
//  AgoraRTEStream.m
//  Demo
//
//  Created by SRS on 2020/6/17.
//  Copyright © 2020 agora. All rights reserved.
//

#import "AgoraRTEStream.h"
#import "AgoraRTEUser.h"

@interface AgoraRTEStream()
@property (nonatomic, strong) NSString *streamUuid;
@property (nonatomic, strong) AgoraRTEBaseUser *userInfo;
@end

@implementation AgoraRTEStream
- (instancetype)initWithStreamUuid:(NSString *)streamUuid userInfo:(AgoraRTEBaseUser *)userInfo {
    self = [super init];
    if (self) {
        self.streamUuid = streamUuid;
        self.userInfo = userInfo;
    }
    return self;
}
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
        @"sourceType": @"videoSourceType",
        @"userInfo"  : @"fromUser"
    };
}

//sourceType
- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    NSNumber *videoState = dic[@"videoState"];
    NSNumber *audioState = dic[@"audioState"];

    if ([videoState isKindOfClass:[NSNumber class]]) {
        _hasVideo = (videoState.integerValue == 1) ? YES : NO;
    }
    if ([audioState isKindOfClass:[NSNumber class]]) {
        _hasAudio = (audioState.integerValue == 1) ? YES : NO;
    }
    
    if ([videoState isKindOfClass:[NSNumber class]]
        || [audioState isKindOfClass:[NSNumber class]]) {
        return YES;
    }

    return NO;
}
@end


@interface AgoraRTEStreamEvent ()
@property (nonatomic, strong) AgoraRTEStream *modifiedStream;
@property (nonatomic, strong) AgoraRTEBaseUser * _Nullable operatorUser;
@end

@implementation AgoraRTEStreamEvent
@end

