//
//  AgoraEduKeyCenter.m
//  AgoraEducation
//
//  Created by SRS on 2020/3/26.
//  Copyright © 2020 Agora. All rights reserved.
//

#import "AgoraEduKeyCenter.h"
//
static NSString *_agoraAppid = @"";
static NSString *_boardAppid = @"";

@implementation AgoraEduKeyCenter
+ (NSString *)agoraAppid {
    return _agoraAppid;
}
 
+ (void)setAgoraAppid:(NSString *)agoraAppid {
    _agoraAppid = [agoraAppid copy];
}

+ (NSString *)boardAppid {
    return _boardAppid;
}
 
+ (void)setBoardAppid:(NSString *)boardAppid {
    _boardAppid = [boardAppid copy];
}

@end
