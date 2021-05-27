//
//  AgoraRTESyncRoomModel.m
//  EduSDK
//
//  Created by SRS on 2020/8/31.
//

#import "AgoraRTESyncRoomModel.h"
#import "AgoraRTEConstants.h"
#import <YYModel/YYModel.h>

@implementation AgoraRTESyncRoomInfoModel
@end

@implementation AgoraRTESyncRoomStateModel
- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    
    NSDictionary *muteChat = dic[@"muteChat"];
    NSNumber *state = dic[@"state"];
//    NSNumber *operator = dic[@"operator"];
    if ([muteChat isKindOfClass:[NSDictionary class]]) {
        
        NSNumber *muteBroadcaster = muteChat[kAgoraRTEServiceRoleBroadcaster];
        NSNumber *muteAudience = muteChat[kAgoraRTEServiceRoleAudience];
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

@implementation AgoraRTESyncRoomModel

- (AgoraRTEClassroom *)mapAgoraRTEClassroom:(NSInteger)count {
    self.roomState.onlineUserCount = count;
    AgoraRTEClassroom *user = [AgoraRTEClassroom new];
    id userObj = [self yy_modelToJSONObject];
    [user yy_modelSetWithJSON:userObj];
    return user;
}

- (AgoraRTEUser * _Nullable)mapOpratorAgoraRTEUser {
    if(self.roomState.operator != nil){
        AgoraRTEUser *user = [AgoraRTEUser new];
        id userObj = [self.roomState.operator yy_modelToJSONObject];
        [user yy_modelSetWithJSON:userObj];
        return user;
    }
    return nil;
}

@end


@implementation AgoraRTESyncRoomPropertiesModel
@end

