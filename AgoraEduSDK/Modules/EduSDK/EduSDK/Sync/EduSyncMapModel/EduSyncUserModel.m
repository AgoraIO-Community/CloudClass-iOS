//
//  EduSyncUserModel.m
//  EduSDK
//
//  Created by SRS on 2020/8/31.
//

#import "EduSyncUserModel.h"
#import "EduConstants.h"
#import <YYModel/YYModel.h>
#import "EduUser+ConvenientInit.h"

@implementation EduSyncUserModel

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
        @"streams" : [EduSyncStreamModel class]
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

- (EduUser *)mapEduUser {
    EduUser *user = [EduUser new];
    id userObj = [self yy_modelToJSONObject];
    [user yy_modelSetWithJSON:userObj];
    return user;
}

- (EduBaseUser *)mapEduBaseUser {
    EduBaseUser *user = [EduBaseUser new];
    id userObj = [self yy_modelToJSONObject];
    [user yy_modelSetWithJSON:userObj];
    return user;
}

- (EduLocalUser *)mapEduLocalUser {
    EduLocalUser *user = [EduLocalUser new];
    id userObj = [self yy_modelToJSONObject];
    [user yy_modelSetWithJSON:userObj];
    return user;
}

- (EduUserEvent *)mapEduUserEvent {
    EduUser *user = [self mapEduUser];
    
    EduBaseUser *opr = nil;
    if(self.operator != nil){
        opr = [EduBaseUser new];
        id oprObj = [self.operator yy_modelToJSONObject];
        [opr yy_modelSetWithJSON:oprObj];
    }
    
    EduUserEvent *event = [[EduUserEvent alloc] initWithModifiedUser:user operatorUser:opr];
    return event;
}
@end
