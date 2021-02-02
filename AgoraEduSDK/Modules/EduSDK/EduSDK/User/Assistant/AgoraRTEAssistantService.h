//
//  AgoraRTEAssistantService.h
//  EduSDK
//
//  Created by SRS on 2020/8/27.
//

#import "AgoraRTEUserService.h"
#import "AgoraRTEEnumerates.h"
#import "AgoraRTEUserDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface AgoraRTEAssistantService : AgoraRTEUserService

@property (nonatomic, weak) id<AgoraRTEAssistantDelegate> delegate;

- (void)createOrUpdateTeacherStream:(AgoraRTEStream *)stream success:(AgoraRTESuccessBlock)successBlock failure:(AgoraRTEFailureBlock _Nullable)failureBlock;

- (void)createOrUpdateStudentStream:(AgoraRTEStream *)stream success:(AgoraRTESuccessBlock)successBlock failure:(AgoraRTEFailureBlock _Nullable)failureBlock;

@end

NS_ASSUME_NONNULL_END
