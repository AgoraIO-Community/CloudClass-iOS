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
@interface BoardInfoConfiguration : NSObject
@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *roomUuid;
@property (nonatomic, copy) NSString *userToken;
@property (nonatomic, copy) NSString *userUuid;
@property (nonatomic, copy) NSString *token;
@end

// RecordInfo
@interface RecordInfoConfiguration : NSObject
@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *roomUuid;
@property (nonatomic, copy) NSString *userUuid;
@property (nonatomic, copy) NSString *token;
@end

// AssignGroupInfo
@interface RoleConfiguration : NSObject
@property (nonatomic, assign) NSInteger limit;
@property (nonatomic, assign) NSInteger verifyType;//default:0
@property (nonatomic, assign) NSInteger subscribe;//default:1
@end
@interface AssignGroupInfoConfiguration : NSObject
@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *userUuid;
@property (nonatomic, copy) NSString *roomUuid;
@property (nonatomic, copy) NSString *userToken;
@property (nonatomic, copy) NSString *token;

@property (nonatomic, assign) NSInteger memberLimit;
@property (nonatomic, strong) RoleConfiguration *host;
@property (nonatomic, strong) RoleConfiguration *assistant;
@property (nonatomic, strong) RoleConfiguration *broadcaster;
@end

// RoomConfiguration
@interface RoomConfiguration : NSObject
@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *userUuid;
@property (nonatomic, copy) NSString *token;
@end

// RoomState
@interface RoomStateConfiguration : NSObject
@property (nonatomic, copy) NSString *appId;

@property (nonatomic, copy) NSString *roomUuid;
@property (nonatomic, copy) NSString *roomName;
@property (nonatomic, assign) EduSceneType roomType;

@property (nonatomic, copy) NSString *userUuid;
@property (nonatomic, assign) EduRoleType role;

@property (nonatomic, copy) NSString *token;
@end

// RoomState
@interface RoomChatConfiguration : NSObject
@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *roomUuid;
@property (nonatomic, copy) NSString *userUuid;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, assign) NSInteger type;//类型 1文本

@property (nonatomic, copy) NSString *userToken;
@property (nonatomic, copy) NSString *token;
@end

// HandUp
@interface HandUpConfiguration : NSObject
@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *roomUuid;
@property (nonatomic, copy) NSString *toUserUuid;
@property (nonatomic, copy) NSString *payload;

@property (nonatomic, copy) NSString *userToken;
@property (nonatomic, copy) NSString *userUuid;
@property (nonatomic, copy) NSString *token;
@end

NS_ASSUME_NONNULL_END
