//
//  AgoraBaseWidget.h
//  AgoraWidget
//
//  Created by Cavan on 2021/5/8.
//

#import <Foundation/Foundation.h>
#import <AgoraUIBaseViews/AgoraUIBaseViews-Swift.h>

NS_ASSUME_NONNULL_BEGIN

@class AgoraBaseWidget;
@protocol AgoraWidgetDelegate <NSObject>
- (void)widget:(AgoraBaseWidget *)widget
didSendMessage:(NSString *)message;
@end

@interface AgoraBaseWidget : NSObject
@property (nonatomic, strong, readonly) AgoraBaseUIContainer *containerView;
@property (nonatomic, copy, readonly) NSString *widgetId;

- (void)addMessageObserver:(NSObject<AgoraWidgetDelegate> *)observer;
- (void)widgetDidReceiveMessage:(NSString *)message;
- (void)sendMessage:(NSString *)message;

- (instancetype)initWithWidgetId:(NSString *)widgetId
                      properties:(NSDictionary * _Nullable)properties;
@end

NS_ASSUME_NONNULL_END
