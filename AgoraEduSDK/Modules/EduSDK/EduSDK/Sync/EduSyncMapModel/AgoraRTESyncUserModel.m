//
//  AgoraRTESyncUserModel.m
//  EduSDK
//
//  Created by SRS on 2020/8/31.
//

#import "AgoraRTESyncUserModel.h"
#import "AgoraRTEConstants.h"
#import <YYModel/YYModel.h>
#import "AgoraRTEUser+ConvenientInit.h"

@implementation AgoraRTESyncUserModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isChatAllowed = YES;
    }
    return self;
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
        @"streams" : [AgoraRTESyncStreamModel class]
    };
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    
    NSNumber *muteChat = dic[@"muteChat"];
    if ([muteChat isKindOfClass:[NSNumber class]]) {
        _isChatAllowed = !muteChat.boolValue;
        return YES;
    }
   
    return NO;
}

- (AgoraRTEUser *)mapAgoraRTEUser {
    AgoraRTEUser *user = [AgoraRTEUser new];
    id userObj = [self yy_modelToJSONObject];
    [user yy_modelSetWithJSON:userObj];
    return user;
}

- (AgoraRTEBaseUser *)mapAgoraRTEBaseUser {
    AgoraRTEBaseUser *user = [AgoraRTEBaseUser new];
    id userObj = [self yy_modelToJSONObject];
    [user yy_modelSetWithJSON:userObj];
    return user;
}

- (AgoraRTELocalUser *)mapAgoraRTELocalUser {
    AgoraRTELocalUser *user = [AgoraRTELocalUser new];
    id userObj = [self yy_modelToJSONObject];
    [user yy_modelSetWithJSON:userObj];
    return user;
}

- (AgoraRTEUserEvent *)mapAgoraRTEUserEvent {
    AgoraRTEUser *user = [self mapAgoraRTEUser];
    
    AgoraRTEBaseUser *opr = nil;
    if(self.operator != nil){
        opr = [AgoraRTEBaseUser new];
        id oprObj = [self.operator yy_modelToJSONObject];
        [opr yy_modelSetWithJSON:oprObj];
    }
    
    AgoraRTEUserEvent *event = [[AgoraRTEUserEvent alloc] initWithModifiedUser:user operatorUser:opr];
    return event;
}
@end
