//
//  AgoraRTEChannelMessageHandle.m
//  EduSDK
//
//  Created by SRS on 2020/8/31.
//

#import "AgoraRTEChannelMessageHandle.h"
#import "AgoraRTEChannelMessageModel.h"
#import "AgoraRTEChannelMsgUsersInOut.h"

#import "AgoraRTEChannelMsgRoomMute.h"
#import "AgoraRTEChannelMsgRoomCourse.h"
#import "AgoraRTEChannelMsgUserInfo.h"
#import "AgoraRTEChannelMsgStreamInOut.h"
#import "AgoraRTEChannelMsgUsersProperty.h"

#import "AgoraRTETextMessage+ConvenientInit.h"
#import "AgoraRTEClassroom+ConvenientInit.h"
#import "AgoraRTEUser+ConvenientInit.h"
#import "AgoraRTEStream+ConvenientInit.h"

#import "AgoraRTESyncStreamModel.h"
#import "AgoraRTESyncRoomModel.h"
#import "AgoraRTESyncUserModel.h"

#import "AgoraRTELogService.h"

#import "AgoraRTERoomModel.h"

#define NoNullString(x) ([x isKindOfClass:NSString.class] ? x : @"")
#define NoNullDictionary(x) ([x isKindOfClass:NSDictionary.class] ? x : @{})

@interface AgoraRTEChannelMessageHandle ()<AgoraRTESyncRoomSessionProtocol>

@end

@implementation AgoraRTEChannelMessageHandle

- (instancetype)initWithSyncSession:(AgoraRTESyncRoomSession *)syncRoomSession {
    self = [super init];
    if (self) {
        self.syncRoomSession = syncRoomSession;
        self.syncRoomSession.delegate = self;
    }
    return self;
}

#pragma mark channel
- (AgoraRTEMessageHandleCode)didReceivedChannelMsg:(id)obj {
    
    AgoraRTEChannelMessageModel *msgModel;
    
    if ([obj isKindOfClass:NSString.class]) {
        msgModel = [AgoraRTEChannelMessageModel yy_modelWithJSON:obj];
        
    } else if([obj isKindOfClass:NSDictionary.class]){
        msgModel = [AgoraRTEChannelMessageModel yy_modelWithDictionary:obj];
        
    } else {
        return AgoraRTEMessageHandleCodeVersionError;
    }

    if (msgModel.version != AGORA_RTE_MESSAGE_VERSION) {
        return AgoraRTEMessageHandleCodeVersionError;
    }

    if (msgModel.cmd == AgoraRTEChannelMessageCmdChat) {
        [self messageChannelChat:msgModel];
        
    } else if(msgModel.cmd == AgoraRTEChannelMessageCmdUserInOut) {
        [self messageUserInOut:msgModel];
    } else if(msgModel.cmd == AgoraRTEChannelMessageCmdRoomMuteState) {
        [self messageRoomMute:msgModel];
        
    } else if(msgModel.cmd == AgoraRTEChannelMessageCmdRoomCourseState) {
        [self messageRoomCourse:msgModel];
        
    } else if(msgModel.cmd == AgoraRTEChannelMessageCmdRoomProperty || msgModel.cmd == AgoraRTEChannelMessageCmdRoomProperties) {
        [self messageRoomProperties:msgModel];

    } else if(msgModel.cmd == AgoraRTEChannelMessageCmdUserInfo) {
        [self messageUserInfoUpdate:msgModel];
        
    } else if(msgModel.cmd == AgoraRTEChannelMessageCmdStreamInOut || msgModel.cmd == AgoraRTEChannelMessageCmdStreamsInOut) {
        [self messageStreamInOutUpdate:msgModel];
        
    } else if(msgModel.cmd == AgoraRTEChannelMessageCmdUserProperties) {
        [self messageUserProperties:msgModel];

    } else if(msgModel.cmd == AgoraRTEChannelMessageCmdMessageExtention) {
        [self messageChannelExtention:msgModel];
        
    } else {
        return AgoraRTEMessageHandleCodeCMDError;
    }

    return AgoraRTEMessageHandleCodeDone;
}

- (void)messageRoomMute:(AgoraRTEChannelMessageModel *)channelMsgModel {
    
    AgoraRTEChannelMsgRoomMute *model = [AgoraRTEChannelMsgRoomMute yy_modelWithDictionary:channelMsgModel.data];
    BOOL chatAllowed = ([model.muteChat broadcaster] == 1 || [model.muteChat audience] == 1) ? NO : YES;
    
    AgoraRTESyncRoomModel *classRoom = [AgoraRTESyncRoomModel new];
    id roomObj = [self.syncRoomSession.room yy_modelToJSONObject];
    [classRoom yy_modelSetWithJSON:roomObj];
    classRoom.roomState.isStudentChatAllowed = chatAllowed;
    classRoom.roomState.operator = model.opr;
    [self.syncRoomSession updateRoom:classRoom sequence:channelMsgModel.sequence cause:nil];
}

- (void)messageRoomCourse:(AgoraRTEChannelMessageModel *)channelMsgModel {
    AgoraRTEChannelMsgRoomCourse *model = [AgoraRTEChannelMsgRoomCourse yy_modelWithDictionary:channelMsgModel.data];
    
    AgoraRTESyncRoomModel *classRoom = [AgoraRTESyncRoomModel new];
    id roomObj = [self.syncRoomSession.room yy_modelToJSONObject];
    [classRoom yy_modelSetWithJSON:roomObj];
    classRoom.roomState.courseState = model.state;
    classRoom.roomState.startTime = model.startTime;
    classRoom.roomState.operator = model.opr;
    [self.syncRoomSession updateRoom:classRoom sequence:channelMsgModel.sequence cause:nil];
}
- (void)messageRoomProperties:(AgoraRTEChannelMessageModel *)channelMsgModel {
    
    AgoraRTESyncRoomModel *classRoom = [AgoraRTESyncRoomModel new];
    id roomObj = [self.syncRoomSession.room yy_modelToJSONObject];
    [classRoom yy_modelSetWithJSON:roomObj];
    
    AgoraRTESyncRoomPropertiesModel *model = [AgoraRTESyncRoomPropertiesModel yy_modelWithDictionary:channelMsgModel.data];
    
    if (classRoom.roomProperties == nil) {
        classRoom.roomProperties = [NSMutableDictionary dictionary];
    } else {
        classRoom.roomProperties = [NSMutableDictionary dictionaryWithDictionary:classRoom.roomProperties];
    }
    
    for (NSString *keyPath in model.changeProperties.allKeys) {
        NSArray<NSString *> *keys = [keyPath componentsSeparatedByString:@"."];
        
        //1 upsert 2.delete
        if (model.action == 1) {
            NSMutableDictionary *currentLevelDictionary = classRoom.roomProperties;
            for (NSInteger index = 0; index < keys.count; index++) {
                NSString *key = keys[index];
                
                if (index == keys.count - 1) {
                    [currentLevelDictionary setValue:model.changeProperties[keyPath] forKey:key];
                    
         
                } else {
                    NSString *key = keys[index];
                    if (![currentLevelDictionary[key] isKindOfClass:NSDictionary.class]) {
                        // add
                        currentLevelDictionary[key] = [NSMutableDictionary dictionary];
                    }
                    currentLevelDictionary[key] = [NSMutableDictionary dictionaryWithDictionary:currentLevelDictionary[key]];
                    currentLevelDictionary = currentLevelDictionary[key];
                }
            }
            
        } else if (model.action == 2) {
            
            NSMutableDictionary *currentLevelDictionary = classRoom.roomProperties;
            for (NSInteger index = 0; index < keys.count; index++) {
                NSString *key = keys[index];
                
                if (index == keys.count - 1) {
                    [currentLevelDictionary removeObjectForKey:key];
                } else {
                    NSString *key = keys[index];
                    if (![currentLevelDictionary[key] isKindOfClass:NSDictionary.class]) {
                        break;
                    }
                    currentLevelDictionary[key] = [NSMutableDictionary dictionaryWithDictionary:currentLevelDictionary[key]];
                    currentLevelDictionary = currentLevelDictionary[key];
                }
            }
        }
    }
    [self.syncRoomSession updateRoom:classRoom sequence:channelMsgModel.sequence cause:model.cause];
}
- (void)messageUserProperties:(AgoraRTEChannelMessageModel *)channelMsgModel {

    AgoraRTEChannelMsgUsersProperty *model = [AgoraRTEChannelMsgUsersProperty yy_modelWithDictionary:channelMsgModel.data];
    
    NSPredicate *userPredicate = [NSPredicate predicateWithFormat:@"userUuid = %@", NoNullString(model.fromUser.userUuid)];
    NSArray<AgoraRTESyncUserModel *> *userFilters = [self.syncRoomSession.users filteredArrayUsingPredicate:userPredicate];
    if(userFilters.count == 0) {
        AgoraRTESyncUserModel *user = [AgoraRTESyncUserModel new];
        id obj = [model.fromUser yy_modelToJSONObject];
        [user yy_modelSetWithJSON:obj];
        user.userProperties = model.changeProperties;
        user.state = 1;
        user.cause = model.cause;
        [self.syncRoomSession updateUser:@[user] sequence:channelMsgModel.sequence];
        return;
    }

    AgoraRTESyncUserModel *user = [AgoraRTESyncUserModel new];
    [user yy_modelSetWithJSON:userFilters.firstObject];
    id obj = [userFilters.firstObject yy_modelToJSONObject];
    [user yy_modelSetWithJSON:obj];
    user.cause = model.cause;
    for (NSString *key in model.changeProperties.allKeys) {
        //1 upsert 2.delete
        if (model.action == 1) {
            if (user.userProperties == nil) {
                user.userProperties = [NSMutableDictionary dictionary];
            } else {
                user.userProperties = [NSMutableDictionary dictionaryWithDictionary:user.userProperties];
            }
            NSString *value = model.changeProperties[key];
            [user.userProperties setValue:value forKey:key];
        } else if (model.action == 2) {
            if(user.userProperties == nil) {
                user.userProperties = [NSMutableDictionary dictionary];
            }
            NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithDictionary:user.userProperties];
            [tempDic removeObjectForKey:key];
            user.userProperties = tempDic;
        }
    }
    [self.syncRoomSession updateUser:@[user] sequence:channelMsgModel.sequence];
}
- (void)messageUserInfoUpdate:(AgoraRTEChannelMessageModel *)channelMsgModel {
    
    AgoraRTEChannelMsgUserInfo *model = [AgoraRTEChannelMsgUserInfo yy_modelWithDictionary:channelMsgModel.data];
    
    NSPredicate *userPredicate = [NSPredicate predicateWithFormat:@"userUuid = %@", NoNullString(model.userUuid)];
    NSArray<AgoraRTESyncUserModel *> *userFilters = [self.syncRoomSession.users filteredArrayUsingPredicate:userPredicate];
    if(userFilters.count == 0) {
        AgoraRTESyncUserModel *user = [AgoraRTESyncUserModel new];
        id obj = [model yy_modelToJSONObject];
        [user yy_modelSetWithJSON:obj];
        user.isChatAllowed = !model.muteChat;
        user.state = 1;
        [self.syncRoomSession updateUser:@[user] sequence:channelMsgModel.sequence];
        return;
    }
    
    AgoraRTESyncUserModel *user = [AgoraRTESyncUserModel new];
    id obj = [userFilters.firstObject yy_modelToJSONObject];
    [user yy_modelSetWithJSON:obj];
    user.isChatAllowed = !model.muteChat;
    user.state = 1;
    [self.syncRoomSession updateUser:@[user] sequence:channelMsgModel.sequence];
}

- (void)messageStreamInOutUpdate:(AgoraRTEChannelMessageModel *)channelMsgModel {
    
    NSMutableArray<AgoraRTEChannelMsgStreamInOut *> *array = [NSMutableArray array];
    if (channelMsgModel.cmd == AgoraRTEChannelMessageCmdStreamInOut) {
        AgoraRTEChannelMsgStreamInOut *model = [AgoraRTEChannelMsgStreamInOut yy_modelWithDictionary:channelMsgModel.data];
        [array addObject:model];
        
    } else if (channelMsgModel.cmd == AgoraRTEChannelMessageCmdStreamsInOut) {
       
        AgoraRTEChannelMsgStreamsInOut *model = [AgoraRTEChannelMsgStreamsInOut yy_modelWithDictionary:channelMsgModel.data];
        for (AgoraRTEChannelMsgStreamInOut *stream in model.streams) {
            stream.operator = model.operator;
            [array addObject:stream];
        }
    }
    
    [self.syncRoomSession updateStream:array sequence:channelMsgModel.sequence];
}

- (void)messageChannelExtention:(AgoraRTEChannelMessageModel *)channelMsgModel {
    [self.syncRoomSession updateOther:channelMsgModel sequence:channelMsgModel.sequence];
}

- (void)messageChannelChat:(AgoraRTEChannelMessageModel *)channelMsgModel {
    
    [self.syncRoomSession updateOther:channelMsgModel sequence:channelMsgModel.sequence];
}
- (void)messageUserInOut:(AgoraRTEChannelMessageModel *)channelMsgModel {

    AgoraRTEChannelMsgUsersInOut *inOutModel = [AgoraRTEChannelMsgUsersInOut yy_modelWithDictionary:channelMsgModel.data];
    
    NSArray *array = @[];
    if (inOutModel.onlineUsers && inOutModel.onlineUsers.count > 0) {
        array = [NSArray arrayWithArray:inOutModel.onlineUsers];
    }
    
    if (inOutModel.offlineUsers && inOutModel.offlineUsers.count > 0) {
        array = [array arrayByAddingObjectsFromArray:inOutModel.offlineUsers];
    }

    [self.syncRoomSession updateUser:array sequence:channelMsgModel.sequence];
}

#pragma mark AgoraRTESyncRoomSessionProtocol
- (void)onRoomUpdateFrom:(AgoraRTESyncRoomModel *)originalRoom to:(AgoraRTESyncRoomModel *)currentRoom cause:(NSDictionary * _Nullable)cause {
    // check room state
    AgoraRTEClassroom *_originalRoom = [originalRoom mapAgoraRTEClassroom:self.syncRoomSession.users.count];
    AgoraRTEClassroom *_currentRoom = [currentRoom mapAgoraRTEClassroom:self.syncRoomSession.users.count];
    AgoraRTEBaseUser *_opr = [currentRoom mapOpratorAgoraRTEUser];
    
    [AgoraRTELogService logMessageWithDescribe:@"MessageHandle onRoomUpdate:"
                                    message:@{@"roomUuid":(currentRoom != nil && currentRoom.roomInfo != nil) ? NoNullString(currentRoom.roomInfo.roomUuid) : @"nil",
                                              @"originalRoom":_originalRoom == nil ? @"nil" : _originalRoom,
                                              @"currentRoom":_currentRoom == nil ? @"nil" : _currentRoom,
                                              @"opr":_opr == nil ? @"nil" : _opr,
                                              @"cause":cause == nil ? @"nil" : cause
                                    }];
    
    if (_originalRoom.roomState.courseState != _currentRoom.roomState.courseState) {
        if ([self.roomDelegate respondsToSelector:@selector(classroom:stateUpdated:operatorUser:)]) {
            [self.roomDelegate classroom:_currentRoom stateUpdated:AgoraRTEClassroomChangeTypeCourseState operatorUser:_opr];
        }
    }
    
    if (_originalRoom.roomState.isStudentChatAllowed != _currentRoom.roomState.isStudentChatAllowed) {
        if ([self.roomDelegate respondsToSelector:@selector(classroom:stateUpdated:operatorUser:)]) {
            [self.roomDelegate classroom:_currentRoom stateUpdated:AgoraRTEClassroomChangeTypeAllStudentsChat operatorUser:_opr];
        }
    }
    
    if (![_originalRoom.roomProperties yy_modelIsEqual:_currentRoom.roomProperties]) {
        
        if ([self.roomDelegate respondsToSelector:@selector(classroomPropertyUpdated:cause:)]) {
            [self.roomDelegate classroomPropertyUpdated:_currentRoom cause:cause];
        }
    }
}
- (void)onRemoteUserInit:(NSArray<AgoraRTESyncUserModel *> *)users {
    NSArray<AgoraRTEUser *> *eduUsers = [self eduUsers:users];
    AgoraRTEClassroom *room = [self eduClassroom];

    [AgoraRTELogService logMessageWithDescribe:@"MessageHandle onRemoteUserInit:" message:@{@"roomUuid":(room != nil && room.roomInfo != nil) ? NoNullString(room.roomInfo.roomUuid) : @"nil", @"users":eduUsers}];

    if ([self.roomDelegate respondsToSelector:@selector(classroom:remoteUsersInit:)]) {
        [self.roomDelegate classroom:room remoteUsersInit:eduUsers];
    }
}
- (void)onRemoteUserInOut:(NSArray<AgoraRTESyncUserModel *> *)users state:(AgoraRTESessionState)state {
    
    NSArray<AgoraRTEUserEvent *> *events = [self eduUserEvents:users];
    NSArray<AgoraRTEUser *> *eduUsers = [self eduUsers:users];
    
    AgoraRTEClassroom *room = [self eduClassroom];

    [AgoraRTELogService logMessageWithDescribe:@"MessageHandle onRemoteUserInOut:" message:@{@"roomUuid":(room != nil && room.roomInfo != nil) ? NoNullString(room.roomInfo.roomUuid) : @"nil", @"users":eduUsers}];
  
    switch (state) {
        case AgoraRTESessionStateCreate:
            if ([self.roomDelegate respondsToSelector:@selector(classroom:remoteUsersJoined:)]) {
                [self.roomDelegate classroom:room remoteUsersJoined:eduUsers];
            }
            break;
        case AgoraRTESessionStateDelete:
            if ([self.roomDelegate respondsToSelector:@selector(classroom:remoteUsersLeft:leftType:)]) {
                [self.roomDelegate classroom:room remoteUsersLeft:events leftType:users.firstObject.type];
            }
            break;
        default:
            break;
    }
    
}
- (void)onRemoteUserUpdateFrom:(AgoraRTESyncUserModel *)originalUser to:(AgoraRTESyncUserModel *)currentUser {
    
    AgoraRTEClassroom *room = [self eduClassroom];
    
    [AgoraRTELogService logMessageWithDescribe:@"MessageHandle onRemoteUserUpdateFrom:" message:@{@"roomUuid":(room != nil && room.roomInfo != nil) ? NoNullString(room.roomInfo.roomUuid) : @"nil", @"originalUser":originalUser, @"currentUser":currentUser}];
    
    if(originalUser.isChatAllowed != currentUser.isChatAllowed) {
        NSArray<AgoraRTEUserEvent *> *events = [self eduUserEvents:@[currentUser]];
        if ([self.roomDelegate respondsToSelector:@selector(classroom:remoteUserStateUpdated:changeType:)]) {
            [self.roomDelegate classroom:room remoteUserStateUpdated:events.firstObject changeType:AgoraRTEUserStateChangeTypeChat];
        }
    }
    
//    if(![originalUser.userProperties yy_modelIsEqual: currentUser.userProperties]) {
//        NSArray<AgoraRTEUser *> *events = [self eduUsers:@[currentUser]];
//        if ([self.roomDelegate respondsToSelector:@selector(classroom:remoteUserPropertyUpdated:cause:)]) {
//            [self.roomDelegate classroom:room remoteUserPropertyUpdated:events.firstObject cause:currentUser.cause];
//        }
//    }
}
- (void)onLocalUserInOut:(AgoraRTESyncUserModel *)user state:(AgoraRTESessionState)state {
    
    AgoraRTEClassroom *room = [self eduClassroom];
    [AgoraRTELogService logMessageWithDescribe:@"MessageHandle onLocalUserInOut:" message:@{@"roomUuid":(room != nil && room.roomInfo != nil) ? NoNullString(room.roomInfo.roomUuid) : @"nil", @"user":user == nil ? @"nil" : user, @"state":@(state)}];
 
    if(state == AgoraRTESessionStateDelete) {
        NSArray<AgoraRTEUserEvent *> *events = [self eduUserEvents:@[user]];
        if ([self.userDelegate respondsToSelector:@selector(localUserLeft:leftType:)]) {
            [self.userDelegate localUserLeft:events.firstObject leftType:user.type];
        }
    }
}
- (void)onLocalUserUpdateFrom:(AgoraRTESyncUserModel *)originalUser to:(AgoraRTESyncUserModel *)currentUser {
    
    AgoraRTEClassroom *room = [self eduClassroom];
    [AgoraRTELogService logMessageWithDescribe:@"MessageHandle onLocalUserUpdateFrom:" message:@{@"roomUuid":(room != nil && room.roomInfo != nil) ? NoNullString(room.roomInfo.roomUuid) : @"nil", @"originalUser":originalUser == nil ? @"nil" : originalUser, @"currentUser":currentUser == nil ? @"nil" : currentUser}];
    
    if(originalUser.isChatAllowed != currentUser.isChatAllowed) {
        NSArray<AgoraRTEUserEvent *> *events = [self eduUserEvents:@[currentUser]];
        if ([self.userDelegate respondsToSelector:@selector(localUserStateUpdated:changeType:)]) {
            [self.userDelegate localUserStateUpdated:events.firstObject changeType:AgoraRTEUserStateChangeTypeChat];
        }
    }
    
//    if(![originalUser.userProperties yy_modelIsEqual: currentUser.userProperties]) {
//        NSArray<AgoraRTEUser *> *events = [self eduUsers:@[currentUser]];
//        if ([self.userDelegate respondsToSelector:@selector(localUserPropertyUpdated:cause:)]) {
//            [self.userDelegate localUserPropertyUpdated:events.firstObject cause:currentUser.cause];
//        }
//    }
}
- (void)onRemoteStreamInit:(NSArray<AgoraRTESyncStreamModel *> *)streams {
    
    NSArray<AgoraRTEStream *> *eduStreams = [self eduStreams:streams];
    AgoraRTEClassroom *room = [self eduClassroom];
    
    [AgoraRTELogService logMessageWithDescribe:@"MessageHandle onRemoteStreamInit:" message:@{@"roomUuid":(room != nil && room.roomInfo != nil) ? NoNullString(room.roomInfo.roomUuid) : @"nil", @"streams":streams}];
    
    if(self.checkAutoSubscribe != nil){
        self.checkAutoSubscribe(eduStreams, 1);
    }
    
    if ([self.roomDelegate respondsToSelector:@selector(classroom:remoteStreamsInit:)]) {
        [self.roomDelegate classroom:room remoteStreamsInit:eduStreams];
    }
}
- (void)onRemoteStreamUpdateFrom:(NSArray<AgoraRTESyncStreamModel *> *)originalStreams to:(NSArray<AgoraRTESyncStreamModel *> *)currentStreams {
    
    AgoraRTEClassroom *room = [self eduClassroom];
    [AgoraRTELogService logMessageWithDescribe:@"MessageHandle onRemoteStreamUpdate:" message:@{@"roomUuid":(room != nil && room.roomInfo != nil) ? NoNullString(room.roomInfo.roomUuid) : @"nil"}];
    
    NSArray<AgoraRTEStreamEvent *> *events = [self eduStreamEvents:currentStreams];
    if ([self.roomDelegate respondsToSelector:@selector(classroom:remoteStreamUpdated:)]) {
        
        [self.roomDelegate classroom:room remoteStreamUpdated:events];
        
//        if (originalStream.videoState != currentStream.videoState && originalStream.audioState != currentStream.audioState) {
//            [self.roomDelegate classroom:room remoteStreamUpdated:events.firstObject changeType:AgoraRTEStreamStateChangeTypeVideo_Audio];
//
//        } else if (originalStream.videoState != currentStream.videoState) {
//            [self.roomDelegate classroom:room remoteStreamUpdated:events.firstObject changeType:AgoraRTEStreamStateChangeTypeVideo];
//
//        } else if (originalStream.audioState != currentStream.audioState) {
//            [self.roomDelegate classroom:room remoteStreamUpdated:events.firstObject changeType:AgoraRTEStreamStateChangeTypeAudio];
//        }
    }
}

- (void)onRemoteStreamInOut:(NSArray<AgoraRTESyncStreamModel *> *)streams state:(AgoraRTESessionState)state {

    AgoraRTEClassroom *room = [self eduClassroom];
    [AgoraRTELogService logMessageWithDescribe:@"MessageHandle onRemoteStreamInOut:" message:@{@"roomUuid":(room != nil && room.roomInfo != nil) ? NoNullString(room.roomInfo.roomUuid) : @"nil", @"streams":streams, @"state":@(state)}];
    
    if(state == AgoraRTESessionStateNone) {
        return;
    }

    NSArray<AgoraRTEStreamEvent *> *events = [self eduStreamEvents:streams];
    NSArray<AgoraRTEStream *> *strams = [self eduStreams:streams];
    
    if(self.checkAutoSubscribe != nil){
        self.checkAutoSubscribe(strams, (state == AgoraRTESessionStateDelete) ? 0 : 1);
    }

    switch (state) {
        case AgoraRTESessionStateCreate:
        if ([self.roomDelegate respondsToSelector:@selector(classroom:remoteStreamsAdded:)]) {
            [self.roomDelegate classroom:room remoteStreamsAdded:events];
        }
            break;
        case AgoraRTESessionStateDelete:
        if ([self.roomDelegate respondsToSelector:@selector(classroom:remoteStreamsRemoved:)]) {
            [self.roomDelegate classroom:room remoteStreamsRemoved:events];
        }
            break;
        default:
            break;
    }
}
- (void)onLocalStreamInit:(NSArray<AgoraRTESyncStreamModel *> *)streams {
    NSArray<AgoraRTEStreamEvent *> *eduEvents = [self eduStreamEvents:streams];

    AgoraRTEClassroom *room = [self eduClassroom];
    [AgoraRTELogService logMessageWithDescribe:@"MessageHandle onLocalStreamInit:" message:@{@"roomUuid":(room != nil && room.roomInfo != nil) ? NoNullString(room.roomInfo.roomUuid) : @"nil", @"streams":streams}];
    
    if(self.checkStreamPublish != nil){
        self.checkStreamPublish(eduEvents.firstObject.modifiedStream, AgoraRTEStreamCreate);
    }
    
    if ([self.userDelegate respondsToSelector:@selector(localStreamAdded:)]) {
        [self.userDelegate localStreamAdded:eduEvents.firstObject];
    }
}
- (void)onLocalStreamInOut:(NSArray<AgoraRTESyncStreamModel *> *)streams state:(AgoraRTESessionState)state {
    
    AgoraRTEClassroom *room = [self eduClassroom];
    [AgoraRTELogService logMessageWithDescribe:@"MessageHandle onLocalStreamInOut:" message:@{@"roomUuid":(room != nil && room.roomInfo != nil) ? NoNullString(room.roomInfo.roomUuid) : @"nil", @"streams":streams, @"state":@(state)}];
    
    if(state == AgoraRTESessionStateNone){
        return;
    }
    
    NSArray<AgoraRTEStreamEvent *> *events = [self eduStreamEvents:streams];

    switch (state) {
        case AgoraRTESessionStateCreate:
        if (self.checkStreamPublish != nil) {
            self.checkStreamPublish(events.firstObject.modifiedStream, AgoraRTEStreamCreate);
        }
        if ([self.userDelegate respondsToSelector:@selector(localStreamAdded:)]) {
           [self.userDelegate localStreamAdded:events.firstObject];
        }
            break;
        case AgoraRTESessionStateDelete:
        if (self.checkStreamPublish != nil) {
            self.checkStreamPublish(events.firstObject.modifiedStream, AgoraRTEStreamDelete);
        }
        if ([self.userDelegate respondsToSelector:@selector(localStreamRemoved:)]) {
           [self.userDelegate localStreamRemoved:events.firstObject];
        }
            break;
        default:
            break;
    }
}
- (void)onLocalStreamUpdateFrom:(NSArray<AgoraRTESyncStreamModel *> *)originalStreams to:(NSArray<AgoraRTESyncStreamModel*> *)currentStreams {
    
    AgoraRTEClassroom *room = [self eduClassroom];
    
    [AgoraRTELogService logMessageWithDescribe:@"MessageHandle onLocalStreamUpdate:" message:@{@"roomUuid":(room != nil && room.roomInfo != nil) ? NoNullString(room.roomInfo.roomUuid) : @"nil"}];
    
    NSArray<AgoraRTEStreamEvent *> *events = [self eduStreamEvents:currentStreams];
    
    if (self.checkStreamPublish != nil) {
        self.checkStreamPublish(events.firstObject.modifiedStream, AgoraRTEStreamUpdate);
    }
    
    if ([self.userDelegate respondsToSelector:@selector(localStreamUpdated:)]) {
        
        [self.userDelegate localStreamUpdated:events.firstObject];
//
//        if (originalStream.videoState != currentStream.videoState) {
//            [self.userDelegate localStreamUpdated:events.firstObject changeType:AgoraRTEStreamStateChangeTypeVideo];
//
//        }
//
//        if (originalStream.audioState != currentStream.audioState) {
//            [self.userDelegate localStreamUpdated:events.firstObject changeType:AgoraRTEStreamStateChangeTypeVideo];
//        }
    }
}

- (void)onOtherUpdate:(id)obj {
    
    AgoraRTEClassroom *room = [self eduClassroom];
    [AgoraRTELogService logMessageWithDescribe:@"MessageHandle onOtherUpdate:" message:@{@"roomUuid":(room != nil && room.roomInfo != nil) ? NoNullString(room.roomInfo.roomUuid) : @"nil", @"onOtherUpdate":obj == nil ? @"nil" : obj}];
    
    if([obj isKindOfClass:AgoraRTEChannelMessageModel.class]) {
        AgoraRTEChannelMessageModel *channelMsgModel = obj;
        if(channelMsgModel.cmd == AgoraRTEChannelMessageCmdChat ||
           channelMsgModel.cmd == AgoraRTEChannelMessageCmdMessageExtention ) {
            
            AgoraRTEMsgChat *model = [AgoraRTEMsgChat yy_modelWithDictionary:channelMsgModel.data];
            // 自己发出的
            if([model.fromUser.userUuid isEqualToString:self.syncRoomSession.localUser.userUuid]){
                return;
            }
        
            AgoraRTETextMessage *textMessage = [[AgoraRTETextMessage alloc] initWithUser:model.fromUser message:model.message timestamp:channelMsgModel.ts];
            
            if (channelMsgModel.cmd == AgoraRTEChannelMessageCmdChat && [self.roomDelegate respondsToSelector:@selector(classroom:roomChatMessageReceived:)]) {
                
                AgoraRTESyncRoomModel *room = self.syncRoomSession.room;
                [self.roomDelegate classroom:[room mapAgoraRTEClassroom:self.syncRoomSession.users.count] roomChatMessageReceived:textMessage];
                
            } else if (channelMsgModel.cmd == AgoraRTEChannelMessageCmdMessageExtention && [self.roomDelegate respondsToSelector:@selector(classroom:roomMessageReceived:)]) {
                
                AgoraRTESyncRoomModel *room = self.syncRoomSession.room;
                [self.roomDelegate classroom:[room mapAgoraRTEClassroom:self.syncRoomSession.users.count] roomMessageReceived:textMessage];
            }
        }
    }
}

#pragma mark private

- (AgoraRTEClassroom *)eduClassroom {
    AgoraRTESyncRoomModel *syncRoom = self.syncRoomSession.room;
    return [syncRoom mapAgoraRTEClassroom: self.syncRoomSession.users.count];
}
- (NSArray<AgoraRTEStreamEvent *> *)eduStreamEvents:(NSArray<AgoraRTESyncStreamModel *> *)streams {
    
     NSMutableArray *events = [NSMutableArray arrayWithCapacity:streams.count];
    for(AgoraRTESyncStreamModel *model in streams) {
        AgoraRTEStreamEvent *event = [model mapAgoraRTEStreamEvent];
        [events addObject:event];
    }
    return events;
}
- (NSArray<AgoraRTEStream *> *)eduStreams:(NSArray<AgoraRTESyncStreamModel *> *)streams {
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:streams.count];
    for(AgoraRTESyncStreamModel *model in streams) {
        AgoraRTEStream *event = [model mapAgoraRTEStream];
        [array addObject:event];
    }
    return array;
}
- (NSArray<AgoraRTEUserEvent *> *)eduUserEvents:(NSArray<AgoraRTESyncUserModel *> *)users {
    
    NSMutableArray *events = [NSMutableArray arrayWithCapacity:users.count];
    for(AgoraRTESyncUserModel *model in users) {
        AgoraRTEUserEvent *event = [model mapAgoraRTEUserEvent];
        [events addObject:event];
    }
    return events;
}
- (NSArray<AgoraRTEUser *> *)eduUsers:(NSArray<AgoraRTESyncUserModel *> *)users {
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:users.count];
    for(AgoraRTESyncUserModel *model in users) {
        AgoraRTEUser *event = [model mapAgoraRTEUser];
        [array addObject:event];
    }
    return array;
}

@end
