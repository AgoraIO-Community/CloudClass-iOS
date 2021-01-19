//
//  EduStream+ConvenientInit.h
//  EduSDK
//
//  Created by SRS on 2020/7/21.
//  Copyright © 2020 agora. All rights reserved.
//

#import "EduStream.h"

NS_ASSUME_NONNULL_BEGIN

@interface EduStream (ConvenientInit)
- (instancetype)initWithStreamUuid:(NSString *)streamUuid streamName:(NSString *)streamName sourceType:(EduVideoSourceType)sourceType hasVideo:(BOOL)hasVideo hasAudio:(BOOL)hasAudio user:(EduBaseUser *)userInfo;

- (void)updateWithStream:(NSString *)streamUuid streamName:(NSString *)streamName sourceType:(EduVideoSourceType)sourceType hasVideo:(BOOL)hasVideo hasAudio:(BOOL)hasAudio user:(EduBaseUser *)userInfo;

- (void)updateWithStream:(EduStream *)stream;

@end

@interface EduStreamEvent (ConvenientInit)
- (instancetype)initWithModifiedStream:(EduStream *)modifiedStream operatorUser:(EduBaseUser * _Nullable)operatorUser;
@end

NS_ASSUME_NONNULL_END
