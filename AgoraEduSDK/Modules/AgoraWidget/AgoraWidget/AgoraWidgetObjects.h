//
//  AgoraWidgetObjects.h
//  AgoraWidget
//
//  Created by Cavan on 2021/5/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AgoraWidgetConfiguration : NSObject
@property (nonatomic, strong, nullable) UIImage *selectedImage;
@property (nonatomic, strong, nullable) UIImage *image;
@property (nonatomic, strong, nullable) NSDictionary *properties;
@property (nonatomic, strong) Class widgetClass;
@property (nonatomic, copy) NSString *widgetId;

- (instancetype)initWithClass:(Class)widgetClass
                     widgetId:(NSString *)widgetId;
@end

@interface AgoraWidgetInfo : NSObject
@property (nonatomic, strong, nullable) UIImage *selectedImage;
@property (nonatomic, strong, nullable) UIImage *image;
@property (nonatomic, strong, nullable) NSDictionary *properties;
@property (nonatomic, strong) Class widgetClass;
@property (nonatomic, copy) NSString *widgetId;

- (instancetype)initWithClass:(Class)widgetClass
                     widgetId:(NSString *)widgetId;
@end

NS_ASSUME_NONNULL_END
