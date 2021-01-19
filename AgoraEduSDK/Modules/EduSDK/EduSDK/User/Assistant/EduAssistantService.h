//
//  EduAssistantService.h
//  EduSDK
//
//  Created by SRS on 2020/8/27.
//

#import "EduUserService.h"
#import "EduEnumerates.h"
#import "EduUserDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface EduAssistantService : EduUserService

@property (nonatomic, weak) id<EduAssistantDelegate> delegate;

- (void)createOrUpdateTeacherStream:(EduStream *)stream success:(EduSuccessBlock)successBlock failure:(EduFailureBlock _Nullable)failureBlock;

- (void)createOrUpdateStudentStream:(EduStream *)stream success:(EduSuccessBlock)successBlock failure:(EduFailureBlock _Nullable)failureBlock;

@end

NS_ASSUME_NONNULL_END
