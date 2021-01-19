//
//  EduSyncStreamModel.m
//  EduSDK
//
//  Created by SRS on 2020/8/31.
//

#import "EduSyncStreamModel.h"
#import <YYModel/YYModel.h>
#import "EduStream+ConvenientInit.h"
#import "EduUser.h"

@implementation EduSyncStreamModel

- (EduStream *)mapEduStream {
    EduStream *user = [EduStream new];
    id userObj = [self yy_modelToJSONObject];
    [user yy_modelSetWithJSON:userObj];
    return user;
}

- (EduStreamEvent *)mapEduStreamEvent {
    EduStream *stream = [self mapEduStream];
    
    EduBaseUser *opr = nil;
    if(self.operator != nil) {
        opr = [EduBaseUser new];
        id oprObj = [self.operator yy_modelToJSONObject];
        [opr yy_modelSetWithJSON:oprObj];
    }

    EduStreamEvent *event = [[EduStreamEvent alloc] initWithModifiedStream:stream operatorUser:opr];
    return event;
}

@end
