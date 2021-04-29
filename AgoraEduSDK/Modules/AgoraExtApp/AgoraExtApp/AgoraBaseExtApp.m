//
//  AgoraBaseExtApp.m
//  AgoraExtApp
//
//  Created by Cavan on 2021/4/8.
//

#import "AgoraBaseExtApp.h"

@interface AgoraBaseExtApp ()
@property (nonatomic, strong) AgoraBaseUIView *view;
@property (nonatomic, copy) NSString *appIdentifier;
@end

@implementation AgoraBaseExtApp
- (instancetype)initWithAppIdentifier:(NSString *)appIdentifier
                        localUserInfo:(AgoraExtAppUserInfo *)userInfo
                             roomInfo:(AgoraExtAppRoomInfo *)roomInfo
                           properties:(NSDictionary *)properties {
    self = [super init];
    
    if (self) {
        self.appIdentifier = appIdentifier;
        self.localUserInfo = userInfo;
        self.roomInfo = roomInfo;
        self.properties = properties;
        self.view = [[AgoraBaseUIView alloc] initWithFrame:CGRectZero];
    }
    
    return self;
}

- (void)localUserInfoDidUpdate:(AgoraExtAppUserInfo *)userInfo {
    self.localUserInfo = userInfo;
}

- (void)roomInfoDidUpdate:(AgoraExtAppRoomInfo *)roomInfo {
    self.roomInfo = roomInfo;
}

- (void)propertiesDidUpdate:(NSDictionary *)properties {
    self.properties = properties;
}

- (void)updateProperties:(NSDictionary *)properties
                 success:(AgoraExtAppCompletion)success
                    fail:(AgoraExtAppErrorCompletion)fail {
    SEL func = @selector(extApp:updateProperties:success:fail:);
    
    if ([self.delegate respondsToSelector:func]) {
        [self.delegate extApp:self
             updateProperties:properties
                      success:success
                         fail:fail];
    }
}

- (void)deleteProperties:(NSArray <NSString *> *)keys
                 success:(AgoraExtAppCompletion)success
                    fail:(AgoraExtAppErrorCompletion)fail {
    SEL func = @selector(extApp:deleteProperties:success:fail:);
    
    if ([self.delegate respondsToSelector:func]) {
        [self.delegate extApp:self
             deleteProperties:keys
                      success:success
                         fail:fail];
    }
}

- (void)unload {
    SEL func = @selector(extAppWillUnload:);
    
    if ([self.delegate respondsToSelector:func]) {
        [self.delegate extAppWillUnload:self];
    }
}

#pragma mark - Life cycle
- (void)extAppDidLoad:(AgoraExtAppContext *)context {
    
}

- (void)extAppWillUnload {
    
}
@end
