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
@property (nonatomic, strong, nullable) NSMutableDictionary <NSString *, AgoraExtAppPositionItem *> * extAppPositions;
@end

@implementation AgoraExtAppsController
#pragma mark - Public
- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.containerView = [AgroaExtAppWrapper getView];
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
    self.extAppPositions = [NSMutableDictionary dictionary];
    
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

- (void)perExtAppPropertiesDidUpdate:(NSDictionary *)properties {
    if (self.extApps.count <= 0) {
        return;
    }
    
    for (NSString *appIdentifier in properties.allKeys) {
        NSDictionary *appProperties = properties[appIdentifier];
        
        AgoraExtAppInfo *info = [self getAppInfoWithIdentifier:appIdentifier];
        if (!info) {
            continue;
        }
        
        AgoraExtAppItem *item = self.extApps[info.appIdentifier];
        if (!item.instance) {
            continue;
        }
        
        [item.instance propertiesDidUpdate:appProperties];
    }
}

- (void)userInfoDidUpdate:(AgoraExtAppUserInfo *)userInfo {
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

- (void)roomInfoDidUpdate:(AgoraExtAppRoomInfo *)roomInfo {
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

- (void)syncAppPosition:(NSString *)appIdentifier
              diffPoint:(CGPoint)diffPoint {
    AgoraExtAppPositionItem *itemPosition = [[AgoraExtAppPositionItem alloc] initWithX:diffPoint.x
                                                                             y:diffPoint.y];
    self.extAppPositions[appIdentifier] = itemPosition;
//    NSLog(@"Srs syncAppPosition:%f %f", itemPosition.x, itemPosition.y);
    
    if (self.extApps.count <= 0) {
        return;
    }
    
    AgoraExtAppInfo *info = nil;
    for (AgoraExtAppInfo *item in self.extAppInfos) {
        if ([item.appIdentifier isEqualToString:appIdentifier]) {
            info = item;
            break;
        }
    }
    if (!info) {
        return;
    }
    
    AgoraExtAppItem *item = self.extApps[info.appIdentifier];
    if (!item.instance) {
        return;
    }
    
    [AgoraBaseExtAppUIViewWrapper onExtAppUIViewPositionSync:item.instance.view
                                                       point:diffPoint];
}

- (void)appsCommonDidUpdate:(NSDictionary<NSString *,id> *)appsCommonDic {
    if (appsCommonDic.count == 0) {
        return;
    }

    for (NSString *appId in appsCommonDic.allKeys) {
        NSDictionary *value = appsCommonDic[appId];
        NSNumber *commonState = (NSNumber *)[value valueForKey:@"state"];
        
        AgoraExtAppInfo *info = [self getAppInfoWithIdentifier:appId];
        if (!info) {
            continue;
        }
        
        switch (commonState.integerValue) {
            case 0: {
                AgoraExtAppItem *item = self.extApps[info.appIdentifier];
                [item.instance unload];
                break;
            }
            case 1:
                [self willLaunchExtApp:info.appIdentifier];
                break;
            default:
                break;
        }
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
    
    AgoraExtAppContext *context = [self getContextWithAppIdentifier:appIdentifier
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
    
    if (self.extAppPositions[appIdentifier] != nil &&
        [AgoraBaseExtAppUIViewWrapper isExtAppUIView:instance.view]) {

        AgoraExtAppPositionItem *itemPosition = self.extAppPositions[appIdentifier];
        CGPoint diffPoint = CGPointMake(itemPosition.x,
                                        itemPosition.y);
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [AgoraBaseExtAppUIViewWrapper onExtAppUIViewPositionSync:instance.view
                                                               point:diffPoint];
        });
    }
}

- (AgoraExtAppContext *)getContextWithAppIdentifier:(NSString *)appIdentifier
                                      localUserInfo:(AgoraExtAppUserInfo *)userInfo
                                           roomInfo:(AgoraExtAppRoomInfo *)roomInfo
                                         properties:(NSDictionary *)properties
                                           language:(NSString *)language {

    AgoraExtAppContext *context = [[AgoraExtAppContext alloc] initWithAppIdentifier:appIdentifier
                                                                      localUserInfo:userInfo
                                                                           roomInfo:roomInfo
                                                                         properties:properties
                                                                           language:language];
    return context;
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
- (void)extApp:(AgoraBaseExtApp *)app
syncAppPosition:(CGPoint)diffPoint {
    [self.dataSource appsController:self
                    syncAppPosition:app.appIdentifier
                          diffPoint:diffPoint];
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

- (AgoraExtAppInfo * _Nullable)getAppInfoWithIdentifier:(NSString *)identifier {
    for (AgoraExtAppInfo *item in self.extAppInfos) {
        NSString *appId = [self extAppIdentifierFormat:item.appIdentifier];
        
        if ([appId isEqualToString:identifier]) {
            return item;
        }
    }
    
    return nil;
}

- (void)removeDirtyTag:(NSString *)appIdentifier {
    [self.extAppDirtyTags removeObjectForKey:appIdentifier];
}

- (NSString *)extAppIdentifierFormat:(NSString *)appIdentifier {
    return [appIdentifier stringByReplacingOccurrencesOfString:@"."
                                                    withString:@"_"];
}
@end
