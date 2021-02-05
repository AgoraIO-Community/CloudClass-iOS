//
//  AgoraRefreshConfig.m
//
//  Created by Frank on 2018/11/27.
//  Copyright © 2018 小码哥. All rights reserved.
//

#import "AgoraRefreshConfig.h"

@implementation AgoraRefreshConfig

static AgoraRefreshConfig *agora_RefreshConfig = nil;

+ (instancetype)defaultConfig {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        agora_RefreshConfig = [[self alloc] init];
    });
    return agora_RefreshConfig;
}



@end
