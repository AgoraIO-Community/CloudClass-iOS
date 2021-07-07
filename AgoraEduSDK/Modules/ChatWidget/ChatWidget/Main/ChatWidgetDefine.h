//
//  ChatWidgetDefine.h
//  AgoraEducation
//
//  Created by lixiaoming on 2021/5/17.
//  Copyright © 2021 Agora. All rights reserved.
//

#ifndef ChatWidgetDefine_h
#define ChatWidgetDefine_h

typedef NS_ENUM(NSUInteger, ChatMsgType) {
    ChatMsgTypeCommon = 0,
    ChatMsgTypeAsk,
    ChatMsgAnswer,
};

typedef NS_ENUM(NSUInteger, ChatRoomState) {
    ChatRoomStateLogin = 0,
    ChatRoomStateLogined,
    ChatRoomStateLoginFailed,
    ChatRoomStateJoining,
    ChatRoomStateJoined,
    ChatRoomStateJoinFail,
};


#endif /* ChatWidgetDefine_h */
