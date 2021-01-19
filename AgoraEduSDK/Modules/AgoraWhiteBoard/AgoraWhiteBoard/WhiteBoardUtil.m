//
//  WhiteBoardUtil.m
//  AgoraWhiteBoard
//
//  Created by SRS on 2020/7/14.
//  Copyright © 2020 agora. All rights reserved.
//

#import "WhiteBoardUtil.h"

@implementation WhiteBoardUtil

+ (NSString *)localizedString:(NSString *)key {
    NSBundle *bundle = [WhiteBoardUtil getBundle];
    NSString *str =  NSLocalizedStringFromTableInBundle(key, nil, bundle, nil);
    return str;
}

+ (NSBundle *)getBundle {
    NSBundle *mainBundle = [NSBundle bundleForClass:WhiteBoardUtil.class];
    NSURL *url = [mainBundle URLForResource:@"WhiteBoard" withExtension:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithURL:url];
    return bundle;
}

@end
