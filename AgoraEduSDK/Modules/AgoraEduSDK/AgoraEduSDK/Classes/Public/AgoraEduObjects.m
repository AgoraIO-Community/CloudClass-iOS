//
//  AgoraEduObjects.m
//  AgoraEduSDK
//
//  Created by SRS on 2021/1/7.
//

#import "AgoraEduObjects.h"

@implementation AgoraEduSDKConfig
- (instancetype)init {
    self = [super init];
    if (self) {
        self.eyeCare = NO;
    }
    return self;
}
- (instancetype)initWithAppId:(NSString *)appId {
    return [self initWithAppId:appId eyeCare:NO];
}
- (instancetype)initWithAppId:(NSString *)appId eyeCare:(BOOL)eyeCare {
    self = [super init];
    if (self) {
        self.appId = appId;
        self.eyeCare = eyeCare;
    }
    return self;
}
@end

@interface AgoraEduLaunchConfig ()
@end

@implementation AgoraEduLaunchConfig
- (instancetype)init {
    self = [super init];
    if (self) {
        self.roleType = AgoraEduRoleTypeStudent;
    }
    return self;
}
- (instancetype)initWithUserName:(NSString *)userName userUuid:(NSString *)userUuid roleType:(AgoraEduRoleType)roleType roomName:(NSString *)roomName roomUuid:(NSString *)roomUuid roomType:(AgoraEduRoomType)roomType token:(NSString *)token {
    
    self = [self init];
    self.userName = userName;
    self.userUuid = userUuid;
    self.roomName = roomName;
    self.roomUuid = roomUuid;
    self.roomType = roomType;
    if (token != nil) {
        self.token = token;
    }
    
    return self;
}
@end

@implementation AgoraEduReplayConfig
- (instancetype)initWithBoardAppId:(NSString *)whiteBoardAppId boardId:(NSString *)whiteBoardId boardToken:(NSString *)whiteBoardToken videoUrl:(NSString *)videoUrl beginTime:(NSInteger)beginTime endTime:(NSInteger)endTime {

    self = [super init];
    if (self) {
        self.whiteBoardAppId = whiteBoardAppId;
        self.whiteBoardId = whiteBoardId;
        self.whiteBoardToken = whiteBoardToken;
        self.videoUrl = videoUrl;
        self.beginTime = beginTime;
        self.endTime = endTime;
    }
    return self;
}
@end
