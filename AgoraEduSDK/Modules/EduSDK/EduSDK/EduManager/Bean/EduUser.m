//
//  EduUser.m
//  Demo
//
//  Created by SRS on 2020/6/17.
//  Copyright © 2020 agora. All rights reserved.
//

#import "EduUser.h"
#import "EduConstants.h"
#import "EduStream.h"

@interface EduBaseUser ()
@property (nonatomic, strong) NSString *userUuid;
@end
@implementation EduBaseUser
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
        if ([role isEqualToString:kServiceRoleBroadcaster] || [role isEqualToString:kServiceRoleAudience]) {
            _role = EduRoleTypeStudent;
        } else if ([role isEqualToString:kServiceRoleHost]) {
            _role = EduRoleTypeTeacher;
        } else if ([role isEqualToString:kServiceRoleAssistant]) {
            _role = EduRoleTypeAssistant;
        }
    }

    if ([role isKindOfClass:[NSString class]]) {
        return YES;
    }
    return NO;
}
@end

@interface EduUser ()
@property (nonatomic, strong) NSString *streamUuid;
@end
@implementation EduUser
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

@interface EduLocalUser ()
@property (nonatomic, strong) NSString *userToken;
@end

@implementation EduLocalUser
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"streams" : [EduStream class]};
}
@end

@interface EduUserEvent ()
@property (nonatomic, strong) EduUser *modifiedUser;
@property (nonatomic, strong) EduBaseUser * _Nullable operatorUser;
@end

@implementation EduUserEvent
@end
