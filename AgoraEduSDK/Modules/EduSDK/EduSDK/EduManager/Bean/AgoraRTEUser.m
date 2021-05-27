//
//  AgoraRTEUser.m
//  Demo
//
//  Created by SRS on 2020/6/17.
//  Copyright © 2020 agora. All rights reserved.
//

#import "AgoraRTEUser.h"
#import "AgoraRTEConstants.h"
#import "AgoraRTEStream.h"

@interface AgoraRTEBaseUser ()
@property (nonatomic, strong) NSString *userUuid;
@end
@implementation AgoraRTEBaseUser
- (instancetype)initWithUserUuid:(NSString *)userUuid {
    self = [super init];
    if (self) {
        self.userUuid = userUuid;
    }
    return self;
}
- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    NSString *role = dic[@"role"];
    if ([role isKindOfClass:[NSString class]]) {
        if ([role isEqualToString:kAgoraRTEServiceRoleBroadcaster] || [role isEqualToString:kAgoraRTEServiceRoleAudience]) {
            _role = AgoraRTERoleTypeStudent;
        } else if ([role isEqualToString:kAgoraRTEServiceRoleHost]) {
            _role = AgoraRTERoleTypeTeacher;
        } else if ([role isEqualToString:kAgoraRTEServiceRoleAssistant]) {
            _role = AgoraRTERoleTypeAssistant;
        }
    }

    if ([role isKindOfClass:[NSString class]]) {
        return YES;
    }
    return NO;
}
@end

@interface AgoraRTEUser ()
@property (nonatomic, strong) NSString *streamUuid;
@end
@implementation AgoraRTEUser
- (instancetype)initWithUserUuid:(NSString *)userUuid streamUuid:(NSString *)streamUuid {
    self = [super init];
    if (self) {
        self.userUuid = userUuid;
        self.streamUuid = streamUuid;
    }
    return self;
}
- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    
    BOOL baseTransform = [super modelCustomTransformFromDictionary:dic];

    NSNumber *muteChat = dic[@"muteChat"];
    if ([muteChat isKindOfClass:[NSNumber class]]) {
        _isChatAllowed = !muteChat.boolValue;
    }
    
    if (baseTransform || [muteChat isKindOfClass:[NSNumber class]]) {
        return YES;
    }
    
    return NO;
}
@end

@interface AgoraRTELocalUser ()
@property (nonatomic, strong) NSString *userToken;
@end

@implementation AgoraRTELocalUser
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"streams" : [AgoraRTEStream class]};
}
@end

@interface AgoraRTEUserEvent ()
@property (nonatomic, strong) AgoraRTEUser *modifiedUser;
@property (nonatomic, strong) AgoraRTEBaseUser * _Nullable operatorUser;
@end

@implementation AgoraRTEUserEvent
@end
