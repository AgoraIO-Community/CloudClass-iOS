//
//  AgoraExtAppObjects.m
//  AgoraExtApp
//
//  Created by Cavan on 2021/4/25.
//

#import "AgoraExtAppObjects.h"

@implementation AgoraExtAppConfiguration
- (instancetype)initWithAppIdentifier:(NSString *)appIdentifier
                          extAppClass:(Class)extAppClass
                                frame:(UIEdgeInsets)frame
                             language:(NSString *)language {
    self = [super init];
    if (self) {
        self.appIdentifier = appIdentifier;
        self.extAppClass = extAppClass;
        self.frame = frame;
        self.language = language;
    }
    return self;
}
@end

@implementation AgoraExtAppError
- (instancetype)initWithCode:(NSInteger )code
                     message:(NSString *)message {
    self = [super init];
    
    if (self) {
        self.code = code;
        self.message = message;
    }
    
    return self;
}
@end

@implementation AgoraExtAppUserInfo
- (instancetype)initWithUserUuid:(NSString *)userUuid
                        userName:(NSString *)userName
                        userRole:(NSString *)userRole {
    self = [super init];
    
    if (self) {
        self.userUuid = userUuid;
        self.userName = userName;
        self.userRole = userRole;
    }
    
    return self;
}
@end

@implementation AgoraExtAppRoomInfo
- (instancetype)initWithRoomUuid:(NSString *)roomUuid
                        roomName:(NSString *)roomName
                        roomType:(NSUInteger)roomType {
    self = [super init];
    
    if (self) {
        self.roomUuid = roomUuid;
        self.roomName = roomName;
        self.roomType = roomType;
    }
    
    return self;
}
@end

@implementation AgoraExtAppContext
- (instancetype)initWithAppIdentifier:(NSString *)appIdentifier
                        localUserInfo:(AgoraExtAppUserInfo *)userInfo
                             roomInfo:(AgoraExtAppRoomInfo *)roomInfo
                           properties:(NSDictionary *)properties
                             language:(NSString *)language; {
    self = [super init];
    
    if (self) {
        self.appIdentifier = appIdentifier;
        self.localUserInfo = userInfo;
        self.roomInfo = roomInfo;
        self.properties = properties;
        self.language = language;
    }
    
    return self;
}
@end

@implementation AgoraExtAppInfo
- (instancetype)initWithAppIdentifier:(NSString *)appIdentifier
                             language:(NSString *)language {
    self = [super init];
    
    if (self) {
        self.appIdentifier = appIdentifier;
        self.language = language;
    }
    
    return self;
}
@end
