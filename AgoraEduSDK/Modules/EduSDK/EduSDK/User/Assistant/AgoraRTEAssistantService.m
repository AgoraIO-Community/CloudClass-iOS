//
//  AgoraRTEAssistantService.m
//  EduSDK
//
//  Created by SRS on 2020/8/27.
//

#import "AgoraRTEAssistantService.h"
#import "AgoraRTEChannelMessageHandle.h"

@interface AgoraRTEAssistantService ()
@property (nonatomic, strong) AgoraRTEChannelMessageHandle *messageHandle;
@end

@implementation AgoraRTEAssistantService

- (void)setDelegate:(id<AgoraRTEAssistantDelegate>)delegate {
    _delegate = delegate;
    self.messageHandle.userDelegate = delegate;
}

- (void)createOrUpdateTeacherStream:(AgoraRTEStream *)stream success:(AgoraRTESuccessBlock)successBlock failure:(AgoraRTEFailureBlock _Nullable)failureBlock {
    
    [self publishStream:stream success:successBlock failure:failureBlock];
}

- (void)createOrUpdateStudentStream:(AgoraRTEStream *)stream success:(AgoraRTESuccessBlock)successBlock failure:(AgoraRTEFailureBlock _Nullable)failureBlock {
    
    [self publishStream:stream success:successBlock failure:failureBlock];
}

@end
