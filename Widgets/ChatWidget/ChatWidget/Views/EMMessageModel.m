//
//  EMMessageModel.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/18.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMMessageModel.h"

@implementation EMMessageModel

- (instancetype)initWithEMMessage:(EMMessage *)aMsg
{
    self = [super init];
    if (self) {
        _emModel = aMsg;
        _direction = aMsg.direction;
        if (aMsg.body.type == EMMessageBodyTypeText) {
            _type = EMMessageTypeText;
            if ([aMsg.ext objectForKey:MSG_EXT_GIF]) {
                _type = EMMessageTypeExtGif;
            } else if ([aMsg.ext objectForKey:MSG_EXT_RECALL]) {
                _type = EMMessageTypeExtRecall;
            }
            if (aMsg.isNeedGroupAck) {
                _readReceiptCount = [NSString stringWithFormat:@"阅读回执，已读用户（%d）",aMsg.groupAckCount];
            }
            if(aMsg.isNeedGroupAck  && aMsg.status == EMMessageStatusFailed) {
                _readReceiptCount = @"只有群主支持本格式消息";
            }
        } else {
            _type = (EMMessageType)aMsg.body.type;
        }
    }
    
    return self;
}

@end
