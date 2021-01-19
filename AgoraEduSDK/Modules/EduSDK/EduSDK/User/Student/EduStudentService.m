//
//  EduStudentService.m
//  Demo
//
//  Created by SRS on 2020/6/19.
//  Copyright © 2020 agora. All rights reserved.
//

#import "EduStudentService.h"
#import "EduConstants.h"
#import "EduMessageHandle.h"
#import "EduStream+ConvenientInit.h"
#import "EduChannelMessageHandle.h"

@interface EduStudentService ()
@property (nonatomic, strong) EduChannelMessageHandle *messageHandle;
@end

@implementation EduStudentService

- (void)setDelegate:(id<EduStudentDelegate>)delegate {
    _delegate = delegate;
    self.messageHandle.userDelegate = delegate;
}

@end
