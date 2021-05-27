//
//  AgoraBaseWidget.m
//  AgoraWidget
//
//  Created by Cavan on 2021/5/8.
//

#import "AgoraBaseWidget.h"

@interface AgoraBaseWidget()
@property (nonatomic, strong) AgoraBaseUIContainer *containerView;
@property (nonatomic, strong) NSPointerArray *messageObservers;
@property (nonatomic, copy) NSString *widgetId;
@end

@implementation AgoraBaseWidget
- (instancetype)initWithWidgetId:(NSString *)widgetId
                      properties:(NSDictionary * _Nullable)properties {
    self = [super init];
    
    if (self) {
        self.containerView = [[AgoraBaseUIContainer alloc] init];
        self.widgetId = widgetId;
        self.messageObservers = [NSPointerArray weakObjectsPointerArray];
    }
    
    return self;
}

- (void)addMessageObserver:(NSObject<AgoraWidgetDelegate> *)observer {
    [self.messageObservers addPointer:(__bridge void * _Nullable)(observer)];
}

- (void)widgetDidReceiveMessage:(NSString *)message {
    
}

- (void)sendMessage:(NSString *)message {
    for (NSObject<AgoraWidgetDelegate> * observer in self.messageObservers) {
        [observer widget:self
          didSendMessage:message];
    }
}
@end
