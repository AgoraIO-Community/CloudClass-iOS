//
//  URL.h
//  AgoraEducation
//
//  Created by SRS on 2020/4/16.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

// /apps/{appId}/v1/users/{userUuid}/login
#define HTTP_LOGIN @"%@/apps/%@/v1/users/%@/login"

// /apps/{appId}/v1/rooms/{roomUuid}/users/{userUuid}/entry
#define HTTP_JOIN_ROOM @"%@/apps/%@/v1/rooms/%@/users/%@/entry"

// /apps/{appId}/v1/rooms/{roomUuid}/snapshot
#define HTTP_SYNC_TOTAL_ROOM @"%@/apps/%@/v1/rooms/%@/snapshot"

// /apps/{appId}/v1/rooms/{roomUuid}/sequences
#define HTTP_SYNC_INCREASE_ROOM @"%@/apps/%@/v1/rooms/%@/sequences"

// /apps/{appId}/v1/rooms/{roomUuid}/config
#define HTTP_GET_ROOM_INFO @"%@/apps/%@/v1/rooms/%@/config"

// apps/{appId}/v1/rooms/{roomUuid}/users
#define HTTP_GET_USER @"%@/apps/%@/v1/rooms/%@/users"

// apps/{appId}/v1/rooms/{roomUuid}/users/streams
#define HTTP_GET_STREAM @"%@/apps/%@/v1/rooms/%@/users/streams"

// apps/{appId}/v1/rooms/{roomUuid}/users/userStreams
#define HTTP_GET_USER_STREAM @"%@/apps/%@/v1/rooms/%@/users/userStreams"

// apps/{appId}/v1/rooms/{roomUuid}/users/{userUuid}/streams/{streamUuid}
#define HTTP_UPSET_STREAM @"%@/apps/%@/v1/rooms/%@/users/%@/streams/%@"

// apps/{appId}/v1/rooms/{roomUuid}/streams
#define HTTP_UPSET_STREAMS @"%@/apps/%@/v1/rooms/%@/streams"

// apps/{appId}/v1/rooms/{roomUuid}/users/{userUuid}/streams/{streamUuid}
#define HTTP_DELETE_STREAM @"%@/apps/%@/v1/rooms/%@/users/%@/streams/%@"

// apps/{appId}/v1/rooms/{roomUuid}/streams
#define HTTP_DELETE_STREAMS @"%@/apps/%@/v1/rooms/%@/streams"

// apps/{appId}/v1/rooms/{roomUuid}/chat/channel
#define HTTP_ROOM_CHAT @"%@/apps/%@/v1/rooms/%@/chat/channel"

// apps/{appId}/v1/rooms/{roomUuid}/users/{toUserUuid}/chat/peer
#define HTTP_USER_CHAT @"%@/apps/%@/v1/rooms/%@/users/%@/chat/peer"

// apps/{appId}/v1/rooms/{roomUuid}/users/{userUuid}
#define HTTP_USER_STATE @"%@/apps/%@/v1/rooms/%@/users/%@"

// apps/{appId}/v1/rooms/{roomUUid}/states/{state}
#define HTTP_ROOM_START_STOP @"%@/apps/%@/v1/rooms/%@/states/%@"

// apps/{appId}/v1/rooms/{roomUUid}/roles/mute
#define HTTP_ROOM_MUTE @"%@/apps/%@/v1/rooms/%@/roles/mute"

// apps/{appId}/v1/rooms/{roomUuid}/message/channel
#define HTTP_ROOM_MESSAGE @"%@/apps/%@/v1/rooms/%@/message/channel"

// apps/{appId}/v1/rooms/{roomUuid}/users/{toUserUuid}/messages/peer
#define HTTP_USER_MESSAGE @"%@/apps/%@/v1/rooms/%@/users/%@/messages/peer"

// apps/{appId}/v1/process/{processUuid}/start
#define HTTP_START_ACTION_PROCESS @"%@/apps/%@/v1/process/%@/start"

// apps/{appId}/v1/process/{processUuid}/stop
#define HTTP_STOP_ACTION_PROCESS @"%@/apps/%@/v1/process/%@/stop"

// apps/{appId}/v1/rooms/{roomUuid}/properties
#define HTTP_ROOM_PROPERTIES @"%@/apps/%@/v1/rooms/%@/properties"

// apps/{appId}/v1/rooms/{roomUuid}/users/{userUuid}/properties/{key}
#define HTTP_USER_PROPERTIES @"%@/apps/%@/v1/rooms/%@/users/%@/properties/%@"

// /apps/{appId}/v1/rooms/{roomUuid}/users/{userUuid}/exit
#define HTTP_LEAVE_ROOM @"%@/apps/%@/v1/rooms/%@/users/%@/exit"


