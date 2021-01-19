//
//  EduUser.h
//  Demo
//
//  Created by SRS on 2020/6/17.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EduEnumerates.h"
#import "EduBaseTypes.h"

@class EduStream;

NS_ASSUME_NONNULL_BEGIN

@interface EduBaseUser : NSObject
@property (nonatomic, strong, readonly) NSString *userUuid;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, assign) EduRoleType role;

- (instancetype)initWithUserUuid:(NSString *)userUuid;
@end

@interface EduUser : EduBaseUser
@property (nonatomic, strong, readonly) NSString *streamUuid;
@property (nonatomic, assign) BOOL isChatAllowed;
@property (nonatomic, strong) NSDictionary *userProperties;

- (instancetype)initWithUserUuid:(NSString *)userUuid streamUuid:(NSString *)streamUuid;
@end

@interface EduLocalUser : EduUser
@property (nonatomic, strong, readonly) NSString *userToken;
@property (nonatomic, strong) NSArray<EduStream *> *streams;
@end

@interface EduUserEvent : NSObject
@property (nonatomic, strong, readonly) EduUser *modifiedUser;
@property (nonatomic, strong, readonly) EduBaseUser * _Nullable operatorUser;
@end

NS_ASSUME_NONNULL_END
