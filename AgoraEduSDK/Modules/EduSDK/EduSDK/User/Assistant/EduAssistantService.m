//
//  EduAssistantService.m
//  EduSDK
//
//  Created by SRS on 2020/8/27.
//

#import "EduAssistantService.h"
#import "EduChannelMessageHandle.h"

@interface EduAssistantService ()
@property (nonatomic, strong) EduChannelMessageHandle *messageHandle;
@end

@implementation EduAssistantService

- (void)setDelegate:(id<EduAssistantDelegate>)delegate {
    _delegate = delegate;
    self.messageHandle.userDelegate = delegate;
}

- (void)createOrUpdateTeacherStream:(EduStream *)stream success:(EduSuccessBlock)successBlock failure:(EduFailureBlock _Nullable)failureBlock {
    
    [self publishStream:stream success:successBlock failure:failureBlock];
}

- (void)createOrUpdateStudentStream:(EduStream *)stream success:(EduSuccessBlock)successBlock failure:(EduFailureBlock _Nullable)failureBlock {
    
    [self publishStream:stream success:successBlock failure:failureBlock];
}

@end
