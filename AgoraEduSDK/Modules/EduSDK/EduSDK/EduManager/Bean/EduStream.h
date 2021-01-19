//
//  EduStream.h
//  Demo
//
//  Created by SRS on 2020/6/17.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EduEnumerates.h"

@class EduBaseUser;

NS_ASSUME_NONNULL_BEGIN

@interface EduStream : NSObject
@property (nonatomic, strong, readonly) NSString *streamUuid;
@property (nonatomic, strong) NSString *streamName;
@property (nonatomic, assign) EduVideoSourceType sourceType;
@property (nonatomic, assign) BOOL hasVideo;
@property (nonatomic, assign) BOOL hasAudio;

@property (nonatomic, strong, readonly) EduBaseUser *userInfo;

- (instancetype)initWithStreamUuid:(NSString *)streamUuid userInfo:(EduBaseUser *)userInfo;
@end


@interface EduStreamEvent : NSObject
@property (nonatomic, strong, readonly) EduStream *modifiedStream;
@property (nonatomic, strong, readonly) EduBaseUser * _Nullable operatorUser;
@end

NS_ASSUME_NONNULL_END
