//
//  AgoraWidgetObjects.m
//  AgoraWidget
//
//  Created by Cavan on 2021/5/8.
//

#import "AgoraWidgetObjects.h"

@implementation AgoraWidgetConfiguration
- (instancetype)initWithClass:(Class)widgetClass
                     widgetId:(NSString *)widgetId {
    self = [super init];
    
    if (self) {
        self.widgetClass = widgetClass;
        self.widgetId = widgetId;
    }
    
    return self;
}
@end

@implementation AgoraWidgetInfo
- (instancetype)initWithClass:(Class)widgetClass
                     widgetId:(NSString *)widgetId {
    self = [super init];
    
    if (self) {
        self.widgetClass = widgetClass;
        self.widgetId = widgetId;
    }
    
    return self;
}
@end
