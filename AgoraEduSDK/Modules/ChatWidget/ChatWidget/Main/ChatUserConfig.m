//
//  ChatUserConfig.m
//  AgoraEducation
//
//  Created by lixiaoming on 2021/5/12.
//  Copyright © 2021 Agora. All rights reserved.
//

#import "ChatUserConfig.h"

@implementation ChatUserConfig

-(instancetype)init
{
    self = [super init];
    if(self) {
        self.avatarurl = @"";
        self.nickname = @"";
        self.role = 2;
        self.username = @"";
        self.roomUuid = @"";
    }
    return  self;
}
@end
