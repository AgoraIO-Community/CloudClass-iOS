//
//  EduChannelMessageHandle.m
//  EduSDK
//
//  Created by SRS on 2020/8/31.
//

#import "EduChannelMessageHandle.h"
#import "EduChannelMessageModel.h"
#import "EduChannelMsgUsersInOut.h"

#import "EduChannelMsgRoomMute.h"
#import "EduChannelMsgRoomCourse.h"
#import "EduChannelMsgUserInfo.h"
#import "EduChannelMsgStreamInOut.h"
#import "EduChannelMsgUsersProperty.h"

#import "EduTextMessage+ConvenientInit.h"
#import "EduClassroom+ConvenientInit.h"
#import "EduUser+ConvenientInit.h"
#import "EduStream+ConvenientInit.h"

#import "EduSyncStreamModel.h"
#import "EduSyncRoomModel.h"
#import "EduSyncUserModel.h"

#import "AgoraLogService.h"

#import "RoomModel.h"

#define NoNullString(x) ([x isKindOfClass:NSString.class] ? x : @"")
#define NoNullDictionary(x) ([x isKindOfClass:NSDictionary.class] ? x : @{})

@interface EduChannelMessageHandle ()<SyncRoomSessionProtocol>

@end

@implementation EduChannelMessageHandle

- (instancetype)initWithSyncSession:(SyncRoomSession *)syncRoomSession {
    self = [super init];
    if (self) {
        self.syncRoomSession = syncRoomSession;
        self.syncRoomSession.delegate = self;
    }
    return self;
}

#pragma mark channel
- (MessageHandleCode)didReceivedChannelMsg:(id)obj {
    
    EduChannelMessageModel *msgModel;
    
    if ([obj isKindOfClass:NSString.class]) {
        msgModel = [EduChannelMessageModel yy_modelWithJSON:obj];
        
    } else if([obj isKindOfClass:NSDictionary.class]){
        msgModel = [EduChannelMessageModel yy_modelWithDictionary:obj];
        
    } else {
        return MessageHandleCodeVersionError;
    }

    if (msgModel.version != EDU_MESSAGE_VERSION) {
        return MessageHandleCodeVersionError;
    }

    if (msgModel.cmd == ChannelMessageCmdChat) {
        [self messageChannelChat:msgModel];
        
    } else if(msgModel.cmd == ChannelMessageCmdUserInOut) {
        [self messageUserInOut:msgModel];
    } else if(msgModel.cmd == ChannelMessageCmdRoomMuteState) {
        [self messageRoomMute:msgModel];
        
    } else if(msgModel.cmd == ChannelMessageCmdRoomCourseState) {
        [self messageRoomCourse:msgModel];
        
    } else if(msgModel.cmd == ChannelMessageCmdRoomProperty || msgModel.cmd == ChannelMessageCmdRoomProperties) {
        [self messageRoomProperties:msgModel];

    } else if(msgModel.cmd == ChannelMessageCmdUserInfo) {
        [self messageUserInfoUpdate:msgModel];
        
    } else if(msgModel.cmd == ChannelMessageCmdStreamInOut || msgModel.cmd == ChannelMessageCmdStreamsInOut) {
        [self messageStreamInOutUpdate:msgModel];
        
    } else if(msgModel.cmd == ChannelMessageCmdUserProperties) {
        [self messageUserProperties:msgModel];

    } else if(msgModel.cmd == ChannelMessageCmdMessageExtention) {
        [self messageChannelExtention:msgModel];
        
    } else {
        return MessageHandleCodeCMDError;
    }

    return MessageHandleCodeDone;
}

- (void)messageRoomMute:(EduChannelMessageModel *)channelMsgModel {
    
    EduChannelMsgRoomMute *model = [EduChannelMsgRoomMute yy_modelWithDictionary:channelMsgModel.data];
    BOOL chatAllowed = ([model.muteChat broadcaster] == 1 || [model.muteChat audience] == 1) ? NO : YES;
    
    EduSyncRoomModel *classRoom = [EduSyncRoomModel new];
    id roomObj = [self.syncRoomSession.room yy_modelToJSONObject];
    [classRoom yy_modelSetWithJSON:roomObj];
    classRoom.roomState.isStudentChatAllowed = chatAllowed;
    classRoom.roomState.operator = model.opr;
    [self.syncRoomSession updateRoom:classRoom sequence:channelMsgModel.sequence cause:nil];
}

- (void)messageRoomCourse:(EduChannelMessageModel *)channelMsgModel {
    EduChannelMsgRoomCourse *model = [EduChannelMsgRoomCourse yy_modelWithDictionary:channelMsgModel.data];
    
    EduSyncRoomModel *classRoom = [EduSyncRoomModel new];
    id roomObj = [self.syncRoomSession.room yy_modelToJSONObject];
    [classRoom yy_modelSetWithJSON:roomObj];
    classRoom.roomState.courseState = model.state;
    classRoom.roomState.startTime = model.startTime;
    classRoom.roomState.operator = model.opr;
    [self.syncRoomSession updateRoom:classRoom sequence:channelMsgModel.sequence cause:nil];
}
- (void)messageRoomProperties:(EduChannelMessageModel *)channelMsgModel {
    
    EduSyncRoomModel *classRoom = [EduSyncRoomModel new];
    id roomObj = [self.syncRoomSession.room yy_modelToJSONObject];
    [classRoom yy_modelSetWithJSON:roomObj];
    
    EduSyncRoomPropertiesModel *model = [EduSyncRoomPropertiesModel yy_modelWithDictionary:channelMsgModel.data];
    
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
- (void)messageUserProperties:(EduChannelMessageModel *)channelMsgModel {

    EduChannelMsgUsersProperty *model = [EduChannelMsgUsersProperty yy_modelWithDictionary:channelMsgModel.data];
    
    NSPredicate *userPredicate = [NSPredicate predicateWithFormat:@"userUuid = %@", NoNullString(model.fromUser.userUuid)];
    NSArray<EduSyncUserModel *> *userFilters = [self.syncRoomSession.users filteredArrayUsingPredicate:userPredicate];
    if(userFilters.count == 0) {
        EduSyncUserModel *user = [EduSyncUserModel new];
        id obj = [model.fromUser yy_modelToJSONObject];
        [user yy_modelSetWithJSON:obj];
        user.userProperties = model.changeProperties;
        user.state = 1;
        user.cause = model.cause;
        [self.syncRoomSession updateUser:@[user] sequence:channelMsgModel.sequence];
        return;
    }

    EduSyncUserModel *user = [EduSyncUserModel new];
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
- (void)messageUserInfoUpdate:(EduChannelMessageModel *)channelMsgModel {
    
    EduChannelMsgUserInfo *model = [EduChannelMsgUserInfo yy_modelWithDictionary:channelMsgModel.data];
    
    NSPredicate *userPredicate = [NSPredicate predicateWithFormat:@"userUuid = %@", NoNullString(model.userUuid)];
    NSArray<EduSyncUserModel *> *userFilters = [self.syncRoomSession.users filteredArrayUsingPredicate:userPredicate];
    if(userFilters.count == 0) {
        EduSyncUserModel *user = [EduSyncUserModel new];
        id obj = [model yy_modelToJSONObject];
        [user yy_modelSetWithJSON:obj];
        user.isChatAllowed = !model.muteChat;
        user.state = 1;
        [self.syncRoomSession updateUser:@[user] sequence:channelMsgModel.sequence];
        return;
    }
    
    EduSyncUserModel *user = [EduSyncUserModel new];
    id obj = [userFilters.firstObject yy_modelToJSONObject];
    [user yy_modelSetWithJSON:obj];
    user.isChatAllowed = !model.muteChat;
    user.state = 1;
    [self.syncRoomSession updateUser:@[user] sequence:channelMsgModel.sequence];
}

- (void)messageStreamInOutUpdate:(EduChannelMessageModel *)channelMsgModel {
    
    NSMutableArray<EduChannelMsgStreamInOut *> *array = [NSMutableArray array];
    if (channelMsgModel.cmd == ChannelMessageCmdStreamInOut) {
        EduChannelMsgStreamInOut *model = [EduChannelMsgStreamInOut yy_modelWithDictionary:channelMsgModel.data];
        [array addObject:model];
        
    } else if (channelMsgModel.cmd == ChannelMessageCmdStreamsInOut) {
       
        EduChannelMsgStreamsInOut *model = [EduChannelMsgStreamsInOut yy_modelWithDictionary:channelMsgModel.data];
        for (EduChannelMsgStreamInOut *stream in model.streams) {
            stream.operator = model.operator;
            [array addObject:stream];
        }
    }
    
    [self.syncRoomSession updateStream:array sequence:channelMsgModel.sequence];
}

- (void)messageChannelExtention:(EduChannelMessageModel *)channelMsgModel {
    [self.syncRoomSession updateOther:channelMsgModel sequence:channelMsgModel.sequence];
}

- (void)messageChannelChat:(EduChannelMessageModel *)channelMsgModel {
    
    [self.syncRoomSession updateOther:channelMsgModel sequence:channelMsgModel.sequence];
}
- (void)messageUserInOut:(EduChannelMessageModel *)channelMsgModel {

    EduChannelMsgUsersInOut *inOutModel = [EduChannelMsgUsersInOut yy_modelWithDictionary:channelMsgModel.data];
    
    NSArray *array = @[];
    if (inOutModel.onlineUsers && inOutModel.onlineUsers.count > 0) {
        array = [NSArray arrayWithArray:inOutModel.onlineUsers];
    }
    
    if (inOutModel.offlineUsers && inOutModel.offlineUsers.count > 0) {
        array = [array arrayByAddingObjectsFromArray:inOutModel.offlineUsers];
    }

    [self.syncRoomSession updateUser:array sequence:channelMsgModel.sequence];
}

#pragma mark SyncRoomSessionProtocol
- (void)onRoomUpdateFrom:(EduSyncRoomModel *)originalRoom to:(EduSyncRoomModel *)currentRoom cause:(NSDictionary * _Nullable)cause {
    // check room state
    EduClassroom *_originalRoom = [originalRoom mapEduClassroom:self.syncRoomSession.users.count];
    EduClassroom *_currentRoom = [currentRoom mapEduClassroom:self.syncRoomSession.users.count];
    EduBaseUser *_opr = [currentRoom mapOpratorEduUser];
    
    [AgoraLogService logMessageWithDescribe:@"MessageHandle onRoomUpdate:"
                                    message:@{@"roomUuid":(currentRoom != nil && currentRoom.roomInfo != nil) ? NoNullString(currentRoom.roomInfo.roomUuid) : @"nil",
                                              @"originalRoom":_originalRoom == nil ? @"nil" : _originalRoom,
                                              @"currentRoom":_currentRoom == nil ? @"nil" : _currentRoom,
                                              @"opr":_opr == nil ? @"nil" : _opr,
                                              @"cause":cause == nil ? @"nil" : cause
                                    }];
    
    if (_originalRoom.roomState.courseState != _currentRoom.roomState.courseState) {
        if ([self.roomDelegate respondsToSelector:@selector(classroom:stateUpdated:operatorUser:)]) {
            [self.roomDelegate classroom:_currentRoom stateUpdated:EduClassroomChangeTypeCourseState operatorUser:_opr];
        }
    }
    
    if (_originalRoom.roomState.isStudentChatAllowed != _currentRoom.roomState.isStudentChatAllowed) {
        if ([self.roomDelegate respondsToSelector:@selector(classroom:stateUpdated:operatorUser:)]) {
            [self.roomDelegate classroom:_currentRoom stateUpdated:EduClassroomChangeTypeAllStudentsChat operatorUser:_opr];
        }
    }
    
    if (![_originalRoom.roomProperties yy_modelIsEqual:_currentRoom.roomProperties]) {
        
        if ([self.roomDelegate respondsToSelector:@selector(classroomPropertyUpdated:cause:)]) {
            [self.roomDelegate classroomPropertyUpdated:_currentRoom cause:cause];
        }
    }
}
- (void)onRemoteUserInit:(NSArray<EduSyncUserModel *> *)users {
    NSArray<EduUser *> *eduUsers = [self eduUsers:users];
    EduClassroom *room = [self eduClassroom];

    [AgoraLogService logMessageWithDescribe:@"MessageHandle onRemoteUserInit:" message:@{@"roomUuid":(room != nil && room.roomInfo != nil) ? NoNullString(room.roomInfo.roomUuid) : @"nil", @"users":eduUsers}];

    if ([self.roomDelegate respondsToSelector:@selector(classroom:remoteUsersInit:)]) {
        [self.roomDelegate classroom:room remoteUsersInit:eduUsers];
    }
}
- (void)onRemoteUserInOut:(NSArray<EduSyncUserModel *> *)users state:(SessionState)state {
    
    NSArray<EduUserEvent *> *events = [self eduUserEvents:users];
    NSArray<EduUser *> *eduUsers = [self eduUsers:users];
    
    EduClassroom *room = [self eduClassroom];

    [AgoraLogService logMessageWithDescribe:@"MessageHandle onRemoteUserInOut:" message:@{@"roomUuid":(room != nil && room.roomInfo != nil) ? NoNullString(room.roomInfo.roomUuid) : @"nil", @"users":eduUsers}];
  
    switch (state) {
        case SessionStateCreate:
            if ([self.roomDelegate respondsToSelector:@selector(classroom:remoteUsersJoined:)]) {
                [self.roomDelegate classroom:room remoteUsersJoined:eduUsers];
            }
            break;
        case SessionStateDelete:
            if ([self.roomDelegate respondsToSelector:@selector(classroom:remoteUsersLeft:leftType:)]) {
                [self.roomDelegate classroom:room remoteUsersLeft:events leftType:users.firstObject.type];
            }
            break;
        default:
            break;
    }
    
}
- (void)onRemoteUserUpdateFrom:(EduSyncUserModel *)originalUser to:(EduSyncUserModel *)currentUser {
    
    EduClassroom *room = [self eduClassroom];
    
    [AgoraLogService logMessageWithDescribe:@"MessageHandle onRemoteUserUpdateFrom:" message:@{@"roomUuid":(room != nil && room.roomInfo != nil) ? NoNullString(room.roomInfo.roomUuid) : @"nil", @"originalUser":originalUser, @"currentUser":currentUser}];
    
    if(originalUser.isChatAllowed != currentUser.isChatAllowed) {
        NSArray<EduUserEvent *> *events = [self eduUserEvents:@[currentUser]];
        if ([self.roomDelegate respondsToSelector:@selector(classroom:remoteUserStateUpdated:changeType:)]) {
            [self.roomDelegate classroom:room remoteUserStateUpdated:events.firstObject changeType:EduUserStateChangeTypeChat];
        }
    }
    
//    if(![originalUser.userProperties yy_modelIsEqual: currentUser.userProperties]) {
//        NSArray<EduUser *> *events = [self eduUsers:@[currentUser]];
//        if ([self.roomDelegate respondsToSelector:@selector(classroom:remoteUserPropertyUpdated:cause:)]) {
//            [self.roomDelegate classroom:room remoteUserPropertyUpdated:events.firstObject cause:currentUser.cause];
//        }
//    }
}
- (void)onLocalUserInOut:(EduSyncUserModel *)user state:(SessionState)state {
    
    EduClassroom *room = [self eduClassroom];
    [AgoraLogService logMessageWithDescribe:@"MessageHandle onLocalUserInOut:" message:@{@"roomUuid":(room != nil && room.roomInfo != nil) ? NoNullString(room.roomInfo.roomUuid) : @"nil", @"user":user == nil ? @"nil" : user, @"state":@(state)}];
 
    if(state == SessionStateDelete) {
        NSArray<EduUserEvent *> *events = [self eduUserEvents:@[user]];
        if ([self.userDelegate respondsToSelector:@selector(localUserLeft:leftType:)]) {
            [self.userDelegate localUserLeft:events.firstObject leftType:user.type];
        }
    }
}
- (void)onLocalUserUpdateFrom:(EduSyncUserModel *)originalUser to:(EduSyncUserModel *)currentUser {
    
    EduClassroom *room = [self eduClassroom];
    [AgoraLogService logMessageWithDescribe:@"MessageHandle onLocalUserUpdateFrom:" message:@{@"roomUuid":(room != nil && room.roomInfo != nil) ? NoNullString(room.roomInfo.roomUuid) : @"nil", @"originalUser":originalUser == nil ? @"nil" : originalUser, @"currentUser":currentUser == nil ? @"nil" : currentUser}];
    
    if(originalUser.isChatAllowed != currentUser.isChatAllowed) {
        NSArray<EduUserEvent *> *events = [self eduUserEvents:@[currentUser]];
        if ([self.userDelegate respondsToSelector:@selector(localUserStateUpdated:changeType:)]) {
            [self.userDelegate localUserStateUpdated:events.firstObject changeType:EduUserStateChangeTypeChat];
        }
    }
    
//    if(![originalUser.userProperties yy_modelIsEqual: currentUser.userProperties]) {
//        NSArray<EduUser *> *events = [self eduUsers:@[currentUser]];
//        if ([self.userDelegate respondsToSelector:@selector(localUserPropertyUpdated:cause:)]) {
//            [self.userDelegate localUserPropertyUpdated:events.firstObject cause:currentUser.cause];
//        }
//    }
}
- (void)onRemoteStreamInit:(NSArray<EduSyncStreamModel *> *)streams {
    
    NSArray<EduStream *> *eduStreams = [self eduStreams:streams];
    EduClassroom *room = [self eduClassroom];
    
    [AgoraLogService logMessageWithDescribe:@"MessageHandle onRemoteStreamInit:" message:@{@"roomUuid":(room != nil && room.roomInfo != nil) ? NoNullString(room.roomInfo.roomUuid) : @"nil", @"streams":streams}];
    
    if(self.checkAutoSubscribe != nil){
        self.checkAutoSubscribe(eduStreams, 1);
    }
    
    if ([self.roomDelegate respondsToSelector:@selector(classroom:remoteStreamsInit:)]) {
        [self.roomDelegate classroom:room remoteStreamsInit:eduStreams];
    }
}
- (void)onRemoteStreamUpdateFrom:(NSArray<EduSyncStreamModel *> *)originalStreams to:(NSArray<EduSyncStreamModel *> *)currentStreams {
    
    EduClassroom *room = [self eduClassroom];
    [AgoraLogService logMessageWithDescribe:@"MessageHandle onRemoteStreamUpdate:" message:@{@"roomUuid":(room != nil && room.roomInfo != nil) ? NoNullString(room.roomInfo.roomUuid) : @"nil"}];
    
    NSArray<EduStreamEvent *> *events = [self eduStreamEvents:currentStreams];
    if ([self.roomDelegate respondsToSelector:@selector(classroom:remoteStreamUpdated:)]) {
        
        [self.roomDelegate classroom:room remoteStreamUpdated:events];
        
//        if (originalStream.videoState != currentStream.videoState && originalStream.audioState != currentStream.audioState) {
//            [self.roomDelegate classroom:room remoteStreamUpdated:events.firstObject changeType:EduStreamStateChangeTypeVideo_Audio];
//
//        } else if (originalStream.videoState != currentStream.videoState) {
//            [self.roomDelegate classroom:room remoteStreamUpdated:events.firstObject changeType:EduStreamStateChangeTypeVideo];
//
//        } else if (originalStream.audioState != currentStream.audioState) {
//            [self.roomDelegate classroom:room remoteStreamUpdated:events.firstObject changeType:EduStreamStateChangeTypeAudio];
//        }
    }
}

- (void)onRemoteStreamInOut:(NSArray<EduSyncStreamModel *> *)streams state:(SessionState)state {

    EduClassroom *room = [self eduClassroom];
    [AgoraLogService logMessageWithDescribe:@"MessageHandle onRemoteStreamInOut:" message:@{@"roomUuid":(room != nil && room.roomInfo != nil) ? NoNullString(room.roomInfo.roomUuid) : @"nil", @"streams":streams, @"state":@(state)}];
    
    if(state == SessionStateNone) {
        return;
    }

    NSArray<EduStreamEvent *> *events = [self eduStreamEvents:streams];
    NSArray<EduStream *> *strams = [self eduStreams:streams];
    
    if(self.checkAutoSubscribe != nil){
        self.checkAutoSubscribe(strams, (state == SessionStateDelete) ? 0 : 1);
    }

    switch (state) {
        case SessionStateCreate:
        if ([self.roomDelegate respondsToSelector:@selector(classroom:remoteStreamsAdded:)]) {
            [self.roomDelegate classroom:room remoteStreamsAdded:events];
        }
            break;
        case SessionStateDelete:
        if ([self.roomDelegate respondsToSelector:@selector(classroom:remoteStreamsRemoved:)]) {
            [self.roomDelegate classroom:room remoteStreamsRemoved:events];
        }
            break;
        default:
            break;
    }
}
- (void)onLocalStreamInit:(NSArray<EduSyncStreamModel *> *)streams {
    NSArray<EduStreamEvent *> *eduEvents = [self eduStreamEvents:streams];

    EduClassroom *room = [self eduClassroom];
    [AgoraLogService logMessageWithDescribe:@"MessageHandle onLocalStreamInit:" message:@{@"roomUuid":(room != nil && room.roomInfo != nil) ? NoNullString(room.roomInfo.roomUuid) : @"nil", @"streams":streams}];
    
    if(self.checkStreamPublish != nil){
        self.checkStreamPublish(eduEvents.firstObject.modifiedStream, StreamCreate);
    }
    
    if ([self.userDelegate respondsToSelector:@selector(localStreamAdded:)]) {
        [self.userDelegate localStreamAdded:eduEvents.firstObject];
    }
}
- (void)onLocalStreamInOut:(NSArray<EduSyncStreamModel *> *)streams state:(SessionState)state {
    
    EduClassroom *room = [self eduClassroom];
    [AgoraLogService logMessageWithDescribe:@"MessageHandle onLocalStreamInOut:" message:@{@"roomUuid":(room != nil && room.roomInfo != nil) ? NoNullString(room.roomInfo.roomUuid) : @"nil", @"streams":streams, @"state":@(state)}];
    
    if(state == SessionStateNone){
        return;
    }
    
    NSArray<EduStreamEvent *> *events = [self eduStreamEvents:streams];

    switch (state) {
        case SessionStateCreate:
        if (self.checkStreamPublish != nil) {
            self.checkStreamPublish(events.firstObject.modifiedStream, StreamCreate);
        }
        if ([self.userDelegate respondsToSelector:@selector(localStreamAdded:)]) {
           [self.userDelegate localStreamAdded:events.firstObject];
        }
            break;
        case SessionStateDelete:
        if (self.checkStreamPublish != nil) {
            self.checkStreamPublish(events.firstObject.modifiedStream, StreamDelete);
        }
        if ([self.userDelegate respondsToSelector:@selector(localStreamRemoved:)]) {
           [self.userDelegate localStreamRemoved:events.firstObject];
        }
            break;
        default:
            break;
    }
}
- (void)onLocalStreamUpdateFrom:(NSArray<EduSyncStreamModel *> *)originalStreams to:(NSArray<EduSyncStreamModel*> *)currentStreams {
    
    EduClassroom *room = [self eduClassroom];
    
    [AgoraLogService logMessageWithDescribe:@"MessageHandle onLocalStreamUpdate:" message:@{@"roomUuid":(room != nil && room.roomInfo != nil) ? NoNullString(room.roomInfo.roomUuid) : @"nil"}];
    
    NSArray<EduStreamEvent *> *events = [self eduStreamEvents:currentStreams];
    
    if (self.checkStreamPublish != nil) {
        self.checkStreamPublish(events.firstObject.modifiedStream, StreamUpdate);
    }
    
    if ([self.userDelegate respondsToSelector:@selector(localStreamUpdated:)]) {
        
        [self.userDelegate localStreamUpdated:events.firstObject];
//
//        if (originalStream.videoState != currentStream.videoState) {
//            [self.userDelegate localStreamUpdated:events.firstObject changeType:EduStreamStateChangeTypeVideo];
//
//        }
//
//        if (originalStream.audioState != currentStream.audioState) {
//            [self.userDelegate localStreamUpdated:events.firstObject changeType:EduStreamStateChangeTypeVideo];
//        }
    }
}

- (void)onOtherUpdate:(id)obj {
    
    EduClassroom *room = [self eduClassroom];
    [AgoraLogService logMessageWithDescribe:@"MessageHandle onOtherUpdate:" message:@{@"roomUuid":(room != nil && room.roomInfo != nil) ? NoNullString(room.roomInfo.roomUuid) : @"nil", @"onOtherUpdate":obj == nil ? @"nil" : obj}];
    
    if([obj isKindOfClass:EduChannelMessageModel.class]) {
        EduChannelMessageModel *channelMsgModel = obj;
        if(channelMsgModel.cmd == ChannelMessageCmdChat ||
           channelMsgModel.cmd == ChannelMessageCmdMessageExtention ) {
            
            EduMsgChat *model = [EduMsgChat yy_modelWithDictionary:channelMsgModel.data];
            // 自己发出的
            if([model.fromUser.userUuid isEqualToString:self.syncRoomSession.localUser.userUuid]){
                return;
            }
        
            EduTextMessage *textMessage = [[EduTextMessage alloc] initWithUser:model.fromUser message:model.message timestamp:channelMsgModel.ts];
            
            if (channelMsgModel.cmd == ChannelMessageCmdChat && [self.roomDelegate respondsToSelector:@selector(classroom:roomChatMessageReceived:)]) {
                
                EduSyncRoomModel *room = self.syncRoomSession.room;
                [self.roomDelegate classroom:[room mapEduClassroom:self.syncRoomSession.users.count] roomChatMessageReceived:textMessage];
                
            } else if (channelMsgModel.cmd == ChannelMessageCmdMessageExtention && [self.roomDelegate respondsToSelector:@selector(classroom:roomMessageReceived:)]) {
                
                EduSyncRoomModel *room = self.syncRoomSession.room;
                [self.roomDelegate classroom:[room mapEduClassroom:self.syncRoomSession.users.count] roomMessageReceived:textMessage];
            }
        }
    }
}

#pragma mark private

- (EduClassroom *)eduClassroom {
    EduSyncRoomModel *syncRoom = self.syncRoomSession.room;
    return [syncRoom mapEduClassroom: self.syncRoomSession.users.count];
}
- (NSArray<EduStreamEvent *> *)eduStreamEvents:(NSArray<EduSyncStreamModel *> *)streams {
    
     NSMutableArray *events = [NSMutableArray arrayWithCapacity:streams.count];
    for(EduSyncStreamModel *model in streams) {
        EduStreamEvent *event = [model mapEduStreamEvent];
        [events addObject:event];
    }
    return events;
}
- (NSArray<EduStream *> *)eduStreams:(NSArray<EduSyncStreamModel *> *)streams {
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:streams.count];
    for(EduSyncStreamModel *model in streams) {
        EduStream *event = [model mapEduStream];
        [array addObject:event];
    }
    return array;
}
- (NSArray<EduUserEvent *> *)eduUserEvents:(NSArray<EduSyncUserModel *> *)users {
    
    NSMutableArray *events = [NSMutableArray arrayWithCapacity:users.count];
    for(EduSyncUserModel *model in users) {
        EduUserEvent *event = [model mapEduUserEvent];
        [events addObject:event];
    }
    return events;
}
- (NSArray<EduUser *> *)eduUsers:(NSArray<EduSyncUserModel *> *)users {
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:users.count];
    for(EduSyncUserModel *model in users) {
        EduUser *event = [model mapEduUser];
        [array addObject:event];
    }
    return array;
}

@end
