//
//  AgoraRTESyncStreamModel.m
//  EduSDK
//
//  Created by SRS on 2020/8/31.
//

#import "AgoraRTESyncStreamModel.h"
#import <YYModel/YYModel.h>
#import "AgoraRTEStream+ConvenientInit.h"
#import "AgoraRTEUser.h"

@implementation AgoraRTESyncStreamModel

- (AgoraRTEStream *)mapAgoraRTEStream {
    AgoraRTEStream *user = [AgoraRTEStream new];
    id userObj = [self yy_modelToJSONObject];
    [user yy_modelSetWithJSON:userObj];
    return user;
}

- (AgoraRTEStreamEvent *)mapAgoraRTEStreamEvent {
    AgoraRTEStream *stream = [self mapAgoraRTEStream];
    
    AgoraRTEBaseUser *opr = nil;
    if(self.operator != nil) {
        opr = [AgoraRTEBaseUser new];
        id oprObj = [self.operator yy_modelToJSONObject];
        [opr yy_modelSetWithJSON:oprObj];
    }

    AgoraRTEStreamEvent *event = [[AgoraRTEStreamEvent alloc] initWithModifiedStream:stream operatorUser:opr];
    return event;
}

@end
