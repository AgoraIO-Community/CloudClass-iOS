//
//  AgoraWidgetController.m
//  AgoraWidget
//
//  Created by Cavan on 2021/5/8.
//

#import "AgoraWidgetController.h"

@interface AgoraWidgetController()
@property (nonatomic, strong) NSMutableDictionary <NSString *, AgoraWidgetConfiguration *> *configs;
@end

@implementation AgoraWidgetController
- (void)registerWidgets:(NSArray <AgoraWidgetConfiguration *> *)widgets {
    for (AgoraWidgetConfiguration *item in widgets) {
        self.configs[item.widgetId] = item;
    }
}

- (AgoraBaseWidget *)createWidgetWithInfo:(AgoraWidgetInfo *)info {
    if (![info.widgetClass isSubclassOfClass:[AgoraBaseWidget class]]) {
        NSAssert(NO, @"Component class error");
    }
    
    AgoraBaseWidget *component = [info.widgetClass init];
    return component;
}

- (NSArray<AgoraWidgetInfo *>  * _Nullable )getWidgetInfos {
    if (self.configs.count <= 0) {
        return nil;
    }
    
    NSMutableArray *array = [NSMutableArray array];
    
    for (AgoraWidgetConfiguration *config in [self.configs allValues]) {
        AgoraWidgetInfo *info = [[AgoraWidgetInfo alloc] initWithClass:config.widgetClass
                                                              widgetId:config.widgetId];
        info.selectedImage = config.selectedImage;
        info.image = config.image;
        info.properties = config.properties;
        [array addObject:info];
    }
    
    return array;
}

- (NSDictionary<NSString *, AgoraWidgetConfiguration *> *)configs {
    if (!_configs) {
        _configs = [NSMutableDictionary dictionary];
    }
    
    return _configs;
}
@end
