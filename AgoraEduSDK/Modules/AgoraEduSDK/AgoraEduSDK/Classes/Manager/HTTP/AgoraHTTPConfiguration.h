//
//  HTTPConfiguration.h
//  AgoraEducation
//
//  Created by SRS on 2020/10/5.
//  Copyright © 2020 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EduSDK/EduSDK.h>

NS_ASSUME_NONNULL_BEGIN

// BoardInfo
@interface AgoraBoardInfoConfiguration : NSObject
@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *roomUuid;
@property (nonatomic, copy) NSString *userToken;
@property (nonatomic, copy) NSString *userUuid;
@property (nonatomic, copy) NSString *token;
@end

// RecordInfo
@interface AgoraRecordInfoConfiguration : NSObject
@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *roomUuid;
@property (nonatomic, copy) NSString *userUuid;
@property (nonatomic, copy) NSString *token;
@end

// AssignGroupInfo
@interface AgoraRoleConfiguration : NSObject
@property (nonatomic, assign) NSInteger limit;
@property (nonatomic, assign) NSInteger verifyType;//default:0
@property (nonatomic, assign) NSInteger subscribe;//default:1
@end

@interface AgoraAssignGroupInfoConfiguration : NSObject
@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *userUuid;
@property (nonatomic, copy) NSString *roomUuid;
@property (nonatomic, copy) NSString *userToken;
@property (nonatomic, copy) NSString *token;

@property (nonatomic, assign) NSInteger memberLimit;
@property (nonatomic, strong) AgoraRoleConfiguration *host;
@property (nonatomic, strong) AgoraRoleConfiguration *assistant;
@property (nonatomic, strong) AgoraRoleConfiguration *broadcaster;
@end

// AgoraRoomConfiguration
@interface AgoraRoomConfiguration : NSObject
@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *userUuid;
@property (nonatomic, copy) NSString *token;
@end

// RoomState
@interface AgoraRoomStateConfiguration : NSObject
@property (nonatomic, copy) NSString *appId;

@property (nonatomic, copy) NSString *roomUuid;
@property (nonatomic, copy) NSString *roomName;
@property (nonatomic, assign) AgoraRTESceneType roomType;

@property (nonatomic, copy) NSString *userUuid;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, assign) AgoraRTERoleType role;

@property (nonatomic, strong) NSNumber *startTime;//ms
@property (nonatomic, strong) NSNumber *duration;//s

@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy,nullable) NSDictionary<NSString *,NSString *> *userProperties;
@end

// RoomState
@interface AgoraRoomChatConfiguration : NSObject
@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *roomUuid;
@property (nonatomic, copy) NSString *userUuid;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, assign) NSInteger type;//类型 1文本

@property (nonatomic, copy) NSString *token;
@end

// HandUp
@interface AgoraHandUpConfiguration : NSObject
@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *roomUuid;
@property (nonatomic, copy) NSString *toUserUuid;
@property (nonatomic, copy) NSString *payload;

@property (nonatomic, copy) NSString *userToken;
@property (nonatomic, copy) NSString *userUuid;
@property (nonatomic, copy) NSString *token;
@end

NS_ASSUME_NONNULL_END
