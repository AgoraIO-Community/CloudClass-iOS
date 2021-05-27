//
//  AgoraWidgetController.h
//  AgoraWidget
//
//  Created by Cavan on 2021/5/8.
//

#import <Foundation/Foundation.h>
#import "AgoraBaseWidget.h"
#import "AgoraWidgetObjects.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AgoraWidgetProtocol <NSObject>
- (AgoraBaseWidget *)createWidgetWithInfo:(AgoraWidgetInfo *)info;
- (NSArray<AgoraWidgetInfo *> * _Nullable )getWidgetInfos;
@end

@interface AgoraWidgetController : NSObject <AgoraWidgetProtocol>
- (void)registerWidgets:(NSArray <AgoraWidgetConfiguration *> *)widgets;
- (AgoraBaseWidget *)createWidgetWithInfo:(AgoraWidgetInfo *)info;
- (NSArray<AgoraWidgetInfo *> * _Nullable )getWidgetInfos;
@end

NS_ASSUME_NONNULL_END
