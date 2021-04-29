//
//  AgoraExtAppController.m
//  AgoraExtApp
//
//  Created by Cavan on 2021/4/25.
//

#import "AgoraExtAppController.h"
#import <AgoraExtApp/AgoraExtApp-Swift.h>

@interface AgoraExtAppsController ()
@property (nonatomic, strong) AgoraBaseUIView *containerView;
@property (nonatomic, strong, nullable) NSMutableDictionary <NSString *, AgoraExtAppItem *> *extApps; // key: AgoraExtAppIdentifier
@property (nonatomic, strong, nullable) NSMutableDictionary <NSString *, AgoraExtAppDirtyTag *> *extAppDirtyTags;// key: AgoraExtAppIdentifier
@property (nonatomic, strong, nullable) NSMutableArray <AgoraExtAppInfo *> * extAppInfos;
@end

@implementation AgoraExtAppsController
#pragma mark - Public
- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.containerView = [[AgroaExtAppContainer alloc] initWithFrame:CGRectZero];
        [self.containerView setHidden:YES];
    }
    
    return self;
}

- (void)registerApps:(NSArray<AgoraExtAppConfiguration *> *)apps {
    if (apps.count <= 0) {
        return;
    }
    
    self.extApps = [NSMutableDictionary dictionary];
    self.extAppInfos = [NSMutableArray array];
    
    for (AgoraExtAppConfiguration *item in apps) {
        // AgoraExtAppItem
        self.extApps[item.appIdentifier] = [[AgoraExtAppItem alloc] initWithLayout:item.frame
                                                                       extAppClass:item.extAppClass
                                                                          language:item.language];
        
        // AgoraExtAppInfo
        AgoraExtAppInfo *info = [[AgoraExtAppInfo alloc] initWithAppIdentifier:item.appIdentifier
                                                                      language:item.language];
        info.image = item.image;
        info.selectedImage = item.selectedImage;
        
        [self.extAppInfos addObject:info];
    }
}

- (void)updatePerExtAppProperties:(NSDictionary *)properties {
    if (self.extApps.count <= 0) {
        return;
    }
    
    for (NSString *appIdentifier in properties.allKeys) {
        NSDictionary *appProperties = properties[appIdentifier];
        
        for (AgoraExtAppItem *item in self.extApps.allValues) {
            if (item.instance == nil) {
                continue;
            }
            
            NSString *appId = [self extAppIdentifierFormat:item.instance.appIdentifier];
            
            if ([appId isEqualToString:appIdentifier]) {
                [item.instance propertiesDidUpdate:appProperties];
            }
        }
    }
}

- (void)updateLocalUserInfo:(AgoraExtAppUserInfo *)userInfo {
    if (self.extApps.count <= 0) {
        return;
    }
    
    for (AgoraExtAppItem *item in self.extApps.allValues) {
        if (item.instance == nil) {
            continue;
        }
        
        [item.instance localUserInfoDidUpdate:userInfo];
    }
}

- (void)updateRoomInfo:(AgoraExtAppRoomInfo *)roomInfo {
    if (self.extApps.count <= 0) {
        return;
    }
    
    for (AgoraExtAppItem *item in self.extApps.allValues) {
        if (item.instance == nil) {
            continue;
        }
        
        [item.instance roomInfoDidUpdate:roomInfo];
    }
}

#pragma mark - Launch
- (NSInteger)willLaunchExtApp:(NSString *)appIdentifier {
    AgoraExtAppItem *item = self.extApps[appIdentifier];
    
    if (item.instance) {
        return -1;
    }
    
    if (self.dataSource == nil) {
        NSAssert(NO, @"dataSource nil");
    }
    
     AgoraExtAppDirtyTag *dirty = [self insertDirtyTag:appIdentifier];
    
    __weak AgoraExtAppsController *weakSelf = self;
    
    [self.dataSource appsController:self
   needPropertiesOfExtAppIdentifier:[self extAppIdentifierFormat:appIdentifier]
                         properties:^(NSDictionary * _Nonnull properties) {
        dirty.properties = properties;
        [weakSelf launchExtApp:appIdentifier];
    }];
    
    [self.dataSource appsController:self
                       needUserInfo:^(AgoraExtAppUserInfo * _Nonnull userInfo) {
        dirty.localUserInfo = userInfo;
        [weakSelf launchExtApp:appIdentifier];
    } needRoomInfo:^(AgoraExtAppRoomInfo * _Nonnull roomInfo) {
        dirty.roomInfo = roomInfo;
        [weakSelf launchExtApp:appIdentifier];
    }];
    
    return 0;
}

- (void)launchExtApp:(NSString *)appIdentifier {
    AgoraExtAppDirtyTag *dirty = self.extAppDirtyTags[appIdentifier];
    
    if (dirty == nil || !dirty.isPass) {
        return;
    }
    
    [self removeDirtyTag:appIdentifier];
    
    AgoraExtAppItem *item = self.extApps[appIdentifier];
    
    if (![item.extAppClass isSubclassOfClass:[AgoraBaseExtApp class]]) {
        NSAssert(NO, @"ExtApp class error");
    }
    
    AgoraBaseExtApp *instance = [[item.extAppClass alloc] initWithAppIdentifier:appIdentifier
                                                                  localUserInfo:dirty.localUserInfo
                                                                       roomInfo:dirty.roomInfo
                                                                     properties:dirty.properties];
    
    instance.delegate = self;
    item.instance = instance;
    
    AgoraExtAppContext *context = [[AgoraExtAppContext alloc] initWithAppIdentifier:appIdentifier
                                                                      localUserInfo:dirty.localUserInfo
                                                                           roomInfo:dirty.roomInfo
                                                                         properties:dirty.properties
                                                                           language:item.language];
    
    [self.containerView addSubview:instance.view];
    instance.view.agora_x = item.layout.left;
    instance.view.agora_y = item.layout.top;
    instance.view.agora_right = item.layout.right;
    instance.view.agora_bottom = item.layout.bottom;
    [self.containerView layoutIfNeeded];
    [self.containerView setHidden:NO];
    
    [instance extAppDidLoad:context];
}

- (NSArray<AgoraExtAppInfo *> *)getExtAppInfos {
    return [NSArray arrayWithArray:self.extAppInfos];
}

#pragma mark - AgoraExtAppDelegate
- (void)extApp:(AgoraBaseExtApp *)app
deleteProperties:(NSArray<NSString *> *)keys
       success:(AgoraExtAppCompletion)success
          fail:(AgoraExtAppErrorCompletion)fail {
    
}

- (void)extApp:(AgoraBaseExtApp *)app
updateProperties:(NSDictionary *)properties
       success:(AgoraExtAppCompletion)success
          fail:(AgoraExtAppErrorCompletion)fail {
    
}

- (void)extAppWillUnload:(AgoraBaseExtApp *)app {
    AgoraExtAppItem *item = self.extApps[app.appIdentifier];
    
    if (item == nil || item.instance == nil) {
        return;
    }
    
    [item.instance.view removeFromSuperview];
    item.instance = nil;
    [item.instance extAppWillUnload];
    
    if (self.extApps.count == 0) {
        [self.containerView setHidden:YES];
    }
}

#pragma mark - Private
- (AgoraExtAppDirtyTag *)insertDirtyTag:(NSString *)appIdentifier {
    AgoraExtAppDirtyTag *dirty = [[AgoraExtAppDirtyTag alloc] init];
    
    if (self.extAppDirtyTags == nil) {
        self.extAppDirtyTags = [NSMutableDictionary dictionary];
    }
    
    self.extAppDirtyTags[appIdentifier] = dirty;
    
    return dirty;
}

- (void)removeDirtyTag:(NSString *)appIdentifier {
    [self.extAppDirtyTags removeObjectForKey:appIdentifier];
}

- (NSString *)extAppIdentifierFormat:(NSString *)appIdentifier {
    return [appIdentifier stringByReplacingOccurrencesOfString:@"."
                                                    withString:@"_"];
}
@end
