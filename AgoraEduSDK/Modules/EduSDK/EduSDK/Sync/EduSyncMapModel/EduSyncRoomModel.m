//
//  EduSyncRoomModel.m
//  EduSDK
//
//  Created by SRS on 2020/8/31.
//

#import "EduSyncRoomModel.h"
#import "EduConstants.h"
#import <YYModel/YYModel.h>

@implementation EduSyncRoomInfoModel
@end

@implementation EduSyncRoomStateModel
- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    
    NSDictionary *muteChat = dic[@"muteChat"];
    NSNumber *state = dic[@"state"];
//    NSNumber *operator = dic[@"operator"];
    if ([muteChat isKindOfClass:[NSDictionary class]]) {
        
        NSNumber *muteBroadcaster = muteChat[kServiceRoleBroadcaster];
        NSNumber *muteAudience = muteChat[kServiceRoleAudience];
        _isStudentChatAllowed = YES;
        if ([muteBroadcaster isKindOfClass:[NSNumber class]]) {
            _isStudentChatAllowed = !muteBroadcaster.boolValue;
        }
        if ([muteAudience isKindOfClass:[NSNumber class]]) {
            _isStudentChatAllowed = !muteAudience.boolValue;
        }
    }
    if ([state isKindOfClass:[NSNumber class]]) {
        _courseState = state.integerValue;
    }
    
    if ([muteChat isKindOfClass:[NSDictionary class]]
        || [state isKindOfClass:[NSNumber class]]) {
        return YES;
    }
    
    return NO;
}
@end

@implementation EduSyncRoomModel

- (EduClassroom *)mapEduClassroom:(NSInteger)count {
    self.roomState.onlineUserCount = count;
    EduClassroom *user = [EduClassroom new];
    id userObj = [self yy_modelToJSONObject];
    [user yy_modelSetWithJSON:userObj];
    return user;
}

- (EduUser * _Nullable)mapOpratorEduUser {
    if(self.roomState.operator != nil){
        EduUser *user = [EduUser new];
        id userObj = [self.roomState.operator yy_modelToJSONObject];
        [user yy_modelSetWithJSON:userObj];
        return user;
    }
    return nil;
}

@end


@implementation EduSyncRoomPropertiesModel
@end
