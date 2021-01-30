//
//  AgoraRTEUser.h
//  Demo
//
//  Created by SRS on 2020/6/17.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AgoraRTEEnumerates.h"
#import "AgoraRTEBaseTypes.h"

@class AgoraRTEStream;

NS_ASSUME_NONNULL_BEGIN

@interface AgoraRTEBaseUser : NSObject
@property (nonatomic, strong, readonly) NSString *userUuid;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, assign) AgoraRTERoleType role;

- (instancetype)initWithUserUuid:(NSString *)userUuid;
@end

@interface AgoraRTEUser : AgoraRTEBaseUser
@property (nonatomic, strong, readonly) NSString *streamUuid;
@property (nonatomic, assign) BOOL isChatAllowed;
@property (nonatomic, strong) NSDictionary *userProperties;

- (instancetype)initWithUserUuid:(NSString *)userUuid streamUuid:(NSString *)streamUuid;
@end

@interface AgoraRTELocalUser : AgoraRTEUser
@property (nonatomic, strong, readonly) NSString *userToken;
@property (nonatomic, strong) NSArray<AgoraRTEStream *> *streams;
@end

@interface AgoraRTEUserEvent : NSObject
@property (nonatomic, strong, readonly) AgoraRTEUser *modifiedUser;
@property (nonatomic, strong, readonly) AgoraRTEBaseUser * _Nullable operatorUser;
@end

NS_ASSUME_NONNULL_END
