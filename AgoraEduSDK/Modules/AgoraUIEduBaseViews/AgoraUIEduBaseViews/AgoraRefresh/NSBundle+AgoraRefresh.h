//
//  NSBundle+AgoraRefresh.h
//  AgoraRefreshExample
//
//  Created by MJ Lee on 16/6/13.
//  Copyright © 2016年 小码哥. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSBundle (AgoraRefresh)
+ (instancetype)agora_refreshBundle;
+ (UIImage *)agora_arrowImage;
+ (UIImage *)agora_trailArrowImage;
+ (NSString *)agora_localizedStringForKey:(NSString *)key value:(nullable NSString *)value;
+ (NSString *)agora_localizedStringForKey:(NSString *)key;
@end

NS_ASSUME_NONNULL_END
