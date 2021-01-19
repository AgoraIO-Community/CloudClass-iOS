//
//  WhiteBoardUtil.h
//  AgoraWhiteBoard
//
//  Created by SRS on 2020/7/14.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ColorWithHex(hex, a) ([UIColor colorWithRed:((float)((hex & 0xff0000) >> 16))/255.0 green:((float)((hex & 0x00ff00) >> 8))/255.0 blue:((float)(hex & 0x0000ff))/255.0 alpha:a])

#define WEAK(object) __weak typeof(object) weak##object = object

NS_ASSUME_NONNULL_BEGIN

@interface WhiteBoardUtil : NSObject

+ (NSString *)localizedString:(NSString *)key;
+ (NSBundle *)getBundle;

@end

NS_ASSUME_NONNULL_END
