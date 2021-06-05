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

#import "AgoraRTEClassroom+ConvenientInit.h"
#import "AgoraRTEUser+ConvenientInit.h"
#import "AgoraRTEStream+ConvenientInit.h"

#import "AgoraRTESyncStreamModel.h"
#import "AgoraRTESyncRoomModel.h"
#import "AgoraRTESyncUserModel.h"

#import "AgoraRTELogService.h"

#import "AgoraRTERoomModel.h"
#import "AgoraRTEConstants.h"

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
        
    } else if(msgModel.cmd == AgoraRTEChannelMessageCmdUserProperty || msgModel.cmd == AgoraRTEChannelMessageCmdUserProperties) {
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
    model.chatAllowed = ([model.muteChat broadcaster] == 1 || [model.muteChat audience] == 1) ? NO : YES;
    
    [self.syncRoomSession updateRoom:model sequence:channelMsgModel.sequence cause:nil];
}

- (void)messageRoomCourse:(AgoraRTEChannelMessageModel *)channelMsgModel {
    AgoraRTEChannelMsgRoomCourse *model = [AgoraRTEChannelMsgRoomCourse yy_modelWithDictionary:channelMsgModel.data];
    [self.syncRoomSession updateRoom:model sequence:channelMsgModel.sequence cause:nil];
}

- (void)messageRoomProperties:(AgoraRTEChannelMessageModel *)channelMsgModel {
    AgoraRTESyncRoomPropertiesModel *model = [AgoraRTESyncRoomPropertiesModel yy_modelWithDictionary:channelMsgModel.data];
    [self.syncRoomSession updateRoom:model sequence:channelMsgModel.sequence cause:model.cause];
}

- (void)messageUserProperties:(AgoraRTEChannelMessageModel *)channelMsgModel {
    AgoraRTEChannelMsgUsersProperty *model = [AgoraRTEChannelMsgUsersProperty yy_modelWithDictionary:channelMsgModel.data];
    [self.syncRoomSession updateUser:model sequence:channelMsgModel.sequence cause:model.cause];
}
- (void)messageUserInfoUpdate:(AgoraRTEChannelMessageModel *)channelMsgModel {
    
    AgoraRTEChannelMsgUserInfo *model = [AgoraRTEChannelMsgUserInfo yy_modelWithDictionary:channelMsgModel.data];
    [self.syncRoomSession updateUser:model sequence:channelMsgModel.sequence cause:nil];
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

    [self.syncRoomSession updateUser:array sequence:channelMsgModel.sequence cause:nil];
}

#pragma mark AgoraRTESyncRoomSessionProtocol
- (void)onRoomUpdateFrom:(AgoraRTESyncRoomModel *)originalRoom
                      to:(AgoraRTESyncRoomModel *)currentRoom
                   model:(id)model {

    AgoraRTESyncRoomPropertiesModel *propertiesModel = nil;
    NSDictionary *cause = nil;
    if ([model isKindOfClass:AgoraRTESyncRoomPropertiesModel.class]) {
        propertiesModel = model;
        cause = propertiesModel.cause;
    }
    
    // check room state
    AgoraRTEClassroom *_originalRoom = [originalRoom mapAgoraRTEClassroom:self.syncRoomSession.users.count];
    AgoraRTEClassroom *_currentRoom = [currentRoom mapAgoraRTEClassroom:self.syncRoomSession.users.count];
    AgoraRTEBaseUser *_opr = [currentRoom mapOpratorAgoraRTEUser];
    
    [AgoraRTELogService logMessageWithDescribe:@"MessageHandle onRoomUpdate:"
                                    message:@{@"roomUuid":(currentRoom != nil && currentRoom.roomInfo != nil) ? AgoraRTENoNullString(currentRoom.roomInfo.roomUuid) : @"nil",
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
    
    if (propertiesModel != nil) {
        
        if ([self.roomDelegate respondsToSelector:@selector(classroomPropertyUpdated:classroom:cause:operatorUser:)]) {
            [self.roomDelegate classroomPropertyUpdated:propertiesModel.changeProperties classroom:_currentRoom cause:cause operatorUser:propertiesModel.operator];
        }
    }
}
- (void)onRemoteUserInit:(NSArray<AgoraRTESyncUserModel *> *)users {
    NSArray<AgoraRTEUser *> *eduUsers = [self eduUsers:users];
    AgoraRTEClassroom *room = [self eduClassroom];

    [AgoraRTELogService logMessageWithDescribe:@"MessageHandle onRemoteUserInit:" message:@{@"roomUuid":(room != nil && room.roomInfo != nil) ? AgoraRTENoNullString(room.roomInfo.roomUuid) : @"nil", @"users":eduUsers}];

    if ([self.roomDelegate respondsToSelector:@selector(classroom:remoteUsersInit:)]) {
        [self.roomDelegate classroom:room remoteUsersInit:eduUsers];
    }
}
- (void)onRemoteUserInOut:(NSArray<AgoraRTESyncUserModel *> *)users state:(AgoraRTESessionState)state {
    
    NSArray<AgoraRTEUserEvent *> *events = [self eduUserEvents:users];
    NSArray<AgoraRTEUser *> *eduUsers = [self eduUsers:users];
    
    AgoraRTEClassroom *room = [self eduClassroom];

    [AgoraRTELogService logMessageWithDescribe:@"MessageHandle onRemoteUserInOut:" message:@{@"roomUuid":(room != nil && room.roomInfo != nil) ? AgoraRTENoNullString(room.roomInfo.roomUuid) : @"nil", @"users":eduUsers}];
  
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

- (void)onRemoteUserUpdateFrom:(AgoraRTESyncUserModel *)originalUser
                            to:(AgoraRTESyncUserModel *)currentUser
                         model:(AgoraRTEChannelMsgUsersProperty *)model {
    
    AgoraRTEClassroom *room = [self eduClassroom];
    
    [AgoraRTELogService logMessageWithDescribe:@"MessageHandle onRemoteUserUpdateFrom:" message:@{@"roomUuid":(room != nil && room.roomInfo != nil) ? AgoraRTENoNullString(room.roomInfo.roomUuid) : @"nil", @"originalUser":originalUser, @"currentUser":currentUser}];
    
    if(originalUser.isChatAllowed != currentUser.isChatAllowed) {
        NSArray<AgoraRTEUserEvent *> *events = [self eduUserEvents:@[currentUser]];
        if ([self.roomDelegate respondsToSelector:@selector(classroom:remoteUserStateUpdated:changeType:)]) {
            [self.roomDelegate classroom:room remoteUserStateUpdated:events.firstObject changeType:AgoraRTEUserStateChangeTypeChat];
        }
    }
    
    if(![originalUser.userProperties yy_modelIsEqual: currentUser.userProperties]) {
        NSArray<AgoraRTEUser *> *events = [self eduUsers:@[currentUser]];
        if ([self.roomDelegate respondsToSelector:@selector(classroom:remoteUserPropertyUpdated:user:cause:operatorUser:)]) {
            [self.roomDelegate classroom:room remoteUserPropertyUpdated:model.changeProperties user:events.firstObject cause:model.cause operatorUser:model.operator];
        }
    }
}
- (void)onLocalUserInOut:(AgoraRTESyncUserModel *)user state:(AgoraRTESessionState)state {
    
    AgoraRTEClassroom *room = [self eduClassroom];
    [AgoraRTELogService logMessageWithDescribe:@"MessageHandle onLocalUserInOut:" message:@{@"roomUuid":(room != nil && room.roomInfo != nil) ? AgoraRTENoNullString(room.roomInfo.roomUuid) : @"nil", @"user":user == nil ? @"nil" : user, @"state":@(state)}];
 
    if (state == AgoraRTESessionStateDelete) {
        NSArray<AgoraRTEUserEvent *> *events = [self eduUserEvents:@[user]];
        if ([self.userDelegate respondsToSelector:@selector(localUserLeft:leftType:)]) {
            [self.userDelegate localUserLeft:events.firstObject leftType:user.type];
        }
    }
}

- (void)onLocalUserUpdateFrom:(AgoraRTESyncUserModel *)originalUser
                            to:(AgoraRTESyncUserModel *)currentUser
                         model:(id)model {
    
    AgoraRTEClassroom *room = [self eduClassroom];
    [AgoraRTELogService logMessageWithDescribe:@"MessageHandle onLocalUserUpdateFrom:" message:@{@"roomUuid":(room != nil && room.roomInfo != nil) ? AgoraRTENoNullString(room.roomInfo.roomUuid) : @"nil", @"originalUser":originalUser == nil ? @"nil" : originalUser, @"currentUser":currentUser == nil ? @"nil" : currentUser}];
    
    if(originalUser.isChatAllowed != currentUser.isChatAllowed) {
        NSArray<AgoraRTEUserEvent *> *events = [self eduUserEvents:@[currentUser]];
        if ([self.userDelegate respondsToSelector:@selector(localUserStateUpdated:changeType:)]) {
            [self.userDelegate localUserStateUpdated:events.firstObject changeType:AgoraRTEUserStateChangeTypeChat];
        }
    }
    
    if ([model isKindOfClass:AgoraRTEChannelMsgUsersProperty.class]) {
        AgoraRTEChannelMsgUsersProperty *propertyModel = (AgoraRTEChannelMsgUsersProperty*)model;
        NSArray<AgoraRTEUser *> *events = [self eduUsers:@[currentUser]];
        if ([self.userDelegate respondsToSelector:@selector(localUserPropertyUpdated:user:cause:operatorUser:)]) {
            [self.userDelegate localUserPropertyUpdated:propertyModel.changeProperties user:events.firstObject cause:propertyModel.cause operatorUser:propertyModel.operator];
        }
    }
}
- (void)onRemoteStreamInit:(NSArray<AgoraRTESyncStreamModel *> *)streams {
    
    NSArray<AgoraRTEStream *> *eduStreams = [self eduStreams:streams];
    AgoraRTEClassroom *room = [self eduClassroom];
    
    [AgoraRTELogService logMessageWithDescribe:@"MessageHandle onRemoteStreamInit:" message:@{@"roomUuid":(room != nil && room.roomInfo != nil) ? AgoraRTENoNullString(room.roomInfo.roomUuid) : @"nil", @"streams":streams}];
    
    if(self.checkAutoSubscribe != nil){
        self.checkAutoSubscribe(eduStreams, 1);
    }
    
    if ([self.roomDelegate respondsToSelector:@selector(classroom:remoteStreamsInit:)]) {
        [self.roomDelegate classroom:room remoteStreamsInit:eduStreams];
    }
}
- (void)onRemoteStreamUpdateFrom:(NSArray<AgoraRTESyncStreamModel *> *)originalStreams to:(NSArray<AgoraRTESyncStreamModel *> *)currentStreams {
    
    AgoraRTEClassroom *room = [self eduClassroom];
    [AgoraRTELogService logMessageWithDescribe:@"MessageHandle onRemoteStreamUpdate:" message:@{@"roomUuid":(room != nil && room.roomInfo != nil) ? AgoraRTENoNullString(room.roomInfo.roomUuid) : @"nil"}];
    
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
    [AgoraRTELogService logMessageWithDescribe:@"MessageHandle onRemoteStreamInOut:" message:@{@"roomUuid":(room != nil && room.roomInfo != nil) ? AgoraRTENoNullString(room.roomInfo.roomUuid) : @"nil", @"streams":streams, @"state":@(state)}];
    
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
    [AgoraRTELogService logMessageWithDescribe:@"MessageHandle onLocalStreamInit:" message:@{@"roomUuid":(room != nil && room.roomInfo != nil) ? AgoraRTENoNullString(room.roomInfo.roomUuid) : @"nil", @"streams":streams}];
    
    if(self.checkStreamPublish != nil){
        self.checkStreamPublish(eduEvents.firstObject.modifiedStream, AgoraRTEStreamCreate);
    }
    
    if ([self.userDelegate respondsToSelector:@selector(localStreamAdded:)]) {
        [self.userDelegate localStreamAdded:eduEvents.firstObject];
    }
}
- (void)onLocalStreamInOut:(NSArray<AgoraRTESyncStreamModel *> *)streams state:(AgoraRTESessionState)state {
    
    AgoraRTEClassroom *room = [self eduClassroom];
    [AgoraRTELogService logMessageWithDescribe:@"MessageHandle onLocalStreamInOut:" message:@{@"roomUuid":(room != nil && room.roomInfo != nil) ? AgoraRTENoNullString(room.roomInfo.roomUuid) : @"nil", @"streams":streams, @"state":@(state)}];
    
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
    
    [AgoraRTELogService logMessageWithDescribe:@"MessageHandle onLocalStreamUpdate:" message:@{@"roomUuid":(room != nil && room.roomInfo != nil) ? AgoraRTENoNullString(room.roomInfo.roomUuid) : @"nil"}];
    
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
    [AgoraRTELogService logMessageWithDescribe:@"MessageHandle onOtherUpdate:" message:@{@"roomUuid":(room != nil && room.roomInfo != nil) ? AgoraRTENoNullString(room.roomInfo.roomUuid) : @"nil", @"onOtherUpdate":obj == nil ? @"nil" : obj}];
    
    if([obj isKindOfClass:AgoraRTEChannelMessageModel.class]) {
        AgoraRTEChannelMessageModel *channelMsgModel = obj;
        if(channelMsgModel.cmd == AgoraRTEChannelMessageCmdChat ||
           channelMsgModel.cmd == AgoraRTEChannelMessageCmdMessageExtention ) {
            
            AgoraRTEMsgChat *model = [AgoraRTEMsgChat yy_modelWithDictionary:channelMsgModel.data];
            // 自己发出的
            if([model.fromUser.userUuid isEqualToString:self.syncRoomSession.localUser.userUuid]){
                return;
            }
        
            AgoraRTETextMessage *textMessage = [AgoraRTETextMessage new];
            textMessage.type = model.type;
            textMessage.message = model.message;
            textMessage.messageId = model.messageId;
            textMessage.timestamp = model.sendTime;
            textMessage.sensitiveWords = model.sensitiveWords;
            textMessage.fromUser = model.fromUser;

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
