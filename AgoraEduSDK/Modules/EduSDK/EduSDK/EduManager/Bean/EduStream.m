//
//  EduStream.m
//  Demo
//
//  Created by SRS on 2020/6/17.
//  Copyright © 2020 agora. All rights reserved.
//

#import "EduStream.h"
#import "EduUser.h"

@interface EduStream()
@property (nonatomic, strong) NSString *streamUuid;
@property (nonatomic, strong) EduBaseUser *userInfo;
@end

@implementation EduStream
- (instancetype)initWithStreamUuid:(NSString *)streamUuid userInfo:(EduBaseUser *)userInfo {
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


@interface EduStreamEvent ()
@property (nonatomic, strong) EduStream *modifiedStream;
@property (nonatomic, strong) EduBaseUser * _Nullable operatorUser;
@end

@implementation EduStreamEvent
@end

